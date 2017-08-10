//
//  SpaceshipScene.swift
//  AsteroidAvoider_Swift
//
//  Created by Ash Mishra on 2015-05-12.
//  Copyright (c) 2015 VFS. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

public class SpaceshipScene: SKScene, SKPhysicsContactDelegate {
    
    var viewController: UIViewController!
    
    let MAX_HIT_COUNT = 10
    let ASTEROID_DAMAGE = 1
    let ASTRONAUT_REPAIR = 1
    //private let nameKey = "nameKey"
    private let highscoreKey = "highscoreKey"
    
    var hasEnded:Bool = false
    
    //private let kGameNodeName = "gameNode"
    
    private var hitCount: Int = 0
    private var highscoreValue: Float = 10.0
    private var timer: Float = 0.0
    private var lastTime: CFTimeInterval = CFTimeInterval()
    
    //for sound
    var astronautSound = SKAction.playSoundFileNamed("bell_tree_gliss.mp3", waitForCompletion: false)
    var asteroidSound = SKAction.playSoundFileNamed("metal_weight_plate_dropped.mp3", waitForCompletion: false)
    var alarmSound = SKAction.playSoundFileNamed("rising_sci_fi_alarm.mp3", waitForCompletion: false)
    
    // for motion control
    private let motionManager: CMMotionManager
    
    // state variables for moving the ship
    private var shipWidth: CGFloat = 0.0
    private var shipHeight: CGFloat = 0.0
    private var xMax:CGFloat = 0.0
    private var yMax:CGFloat = 0.0
    
    // contact bit masks.  << is left shift of base 2
    private let rockCategory: UInt32 = 0x1 << 1
    private let shipCategory: UInt32 = 0x1 << 2
    //private let astronautCategory: UInt32 = 0x1 << 3
    
    
    override init(size: CGSize) {
        self.motionManager = CMMotionManager()
        super.init(size: size)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playSound(sound : SKAction) {
        runAction(sound)
    }

    // START ADDING YOUR CODE HERE
    
//    override public func update(currentTime: CFTimeInterval) {
////        print(currentTime)
////        print(self.lastTime)
//        let timeNode = self.childNodeWithName("time") as! SKLabelNode
//        
//        //var time = 0.0
//        
//        
//        self.timer = self.timer + 0.01
//        print(self.timer)
//        timeNode.text = NSString(format: "%.1f", self.timer) as String
//        
//        /* Called before each frame is rendered */
//    }
    
    override public func didMoveToView (view: SKView) {
        self.initSceneContents()
        self.initMotionManager()
        self.initTimer()
        self.loadData()
    }
    
    func loadData() {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let hScore = prefs.stringForKey(self.highscoreKey){
            self.highscoreValue = Float(hScore)!
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            prefs.setValue("\(self.highscoreValue)", forKey: self.highscoreKey)
        }
        let highscoreNode = self.childNodeWithName("highscore") as! SKLabelNode
        highscoreNode.text = "Highscore: \(self.highscoreValue)"
        
        let healthNode = self.childNodeWithName("health") as! SKLabelNode
        healthNode.text = "Health: \(self.MAX_HIT_COUNT-self.hitCount)"
    }
    
    func initTimer() {
        let wait = SKAction.waitForDuration(0.01)
        let run = SKAction.runBlock {
            let timeNode = self.childNodeWithName("time") as! SKLabelNode
            self.timer = self.timer + 0.01
            timeNode.text = NSString(format: "%.1f", self.timer) as String
            
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence([wait, run])))
    }
    
    override public func didSimulatePhysics() {
        // iterate over the rocks in the scene, and delete those that are now offscreen
//        self.enumerateChildNodesWithName("rock", usingBlock:{ (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void
//                if node.position.y<0 { node.removeFromParent() } })
//        self.enumerateChildNodesWithName("rock", usingBlock: node in { if node.position.y<0 { node.removeFromParent() } })
        self.enumerateChildNodesWithName("rock") { node, stop in
            if node.position.y<0 { node.removeFromParent() }
        }
    }
    
    public func didBeginContact(contact: SKPhysicsContact) {
        var shipPhysicsBody: SKPhysicsBody
        var objectPhysicsBody: SKPhysicsBody
        // we have a collision between a rock and a ship, and SKPhysicsContact has bodyA and bodyB properties, but we need to determine which one is the ship
        if (contact.bodyA.categoryBitMask == shipCategory) {
            shipPhysicsBody = contact.bodyA
            objectPhysicsBody = contact.bodyB
        } else {
            shipPhysicsBody = contact.bodyB
            objectPhysicsBody = contact.bodyA
        }
        // show damage on the ship
        let ship = shipPhysicsBody.node as! SKSpriteNode
        let object = objectPhysicsBody.node as! SKSpriteNode
        if (object.name == "rock") {
            self.hitCount += self.ASTEROID_DAMAGE // # of times the rocks hit the ship
            self.playSound(self.asteroidSound)
            //print(self.hitCount)
        } else {
            if self.hitCount>0 {
                self.hitCount -= self.ASTRONAUT_REPAIR // # of times the rocks hit the ship
                self.playSound(self.astronautSound)
            }
        }
        //let addDamage = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor:CGFloat(self.hitCount/self.MAX_HIT_COUNT), duration:0)
        let addDamage = SKAction.colorizeWithColor(SKColor.redColor(), colorBlendFactor:CGFloat(self.hitCount)/CGFloat(self.MAX_HIT_COUNT), duration:0)
        ship.runAction(addDamage)
        let healthNode = self.childNodeWithName("health") as! SKLabelNode
        healthNode.text = "Health: \(self.MAX_HIT_COUNT-self.hitCount)"
        if self.hitCount==self.MAX_HIT_COUNT {
            self.playSound(self.alarmSound)
            self.gameOver()
        }
    }
    
    // the sprite node for the spaceship and its lights
    func addSpaceShip() {
        // add a texture for the spaceship
        let shipTexture = SKTexture(imageNamed:"rocket.png")
        let ship = SKSpriteNode(texture:shipTexture)
        // give the Node a name (so we can reference it later)
        ship.name = "spaceship"
        // rocket.png is not a retina graphic, let's scale it by 1/2
        ship.xScale = 0.5
        ship.yScale = 0.5
        
        
        // create a physics body for the ship using the texture
        ship.physicsBody = SKPhysicsBody(texture:shipTexture, alphaThreshold: 0, size:ship.size);
        // don't apply world physics to the spaceship hull (i.e. no gravity, no torque)
        ship.physicsBody?.dynamic = false
        // assign a category to the ship's body in the physics simulator
        ship.physicsBody?.categoryBitMask = shipCategory
        // configure the ship's physics to allow collisions with rocks
        ship.physicsBody?.collisionBitMask = rockCategory
        // enable callbacks when the ship collides with a rock
        ship.physicsBody?.contactTestBitMask = rockCategory
        
        
        // create a dynamic engine flare for the ship
        let engineFlare = self.engineFlare()
        engineFlare.position = CGPointMake(0, -ship.size.height+30)
        ship.addChild(engineFlare)
        // center the ship in the scene
        ship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        // add the spaceship to the scene
        self.addChild(ship)
        // save global values for later reference
        self.shipWidth = ship.size.width
        self.shipHeight = ship.size.height
        self.xMax = self.frame.size.width - self.shipWidth
        self.yMax = self.frame.size.height - self.shipHeight
    }
    
    func addRockNode() {
        // create a rock – a simple square object
        // add a texture for the spaceship
        let rockTexture = SKTexture(imageNamed:"asteroid.png")
        let rock = SKSpriteNode(texture:rockTexture)
        // give the Node a name (so we can reference it later)
        //rock.name = "spaceship"
        // rocket.png is not a retina graphic, let's scale it by 1/2
        rock.xScale = 0.05
        rock.yScale = 0.05
        //let rock = SKSpriteNode(color:SKColor.brownColor(), size:CGSizeMake(8, 8))
        rock.position = CGPointMake(skRand(0, high: self.size.width), skRand(self.size.height-100, high:self.size.height))
        // give the node a name
        rock.name = "rock"
        // giving the rock a physics body allows the world to apply gravity and collisions
        rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
        rock.physicsBody!.usesPreciseCollisionDetection = true
        // add the rock to the scene
        self.addChild(rock)
    }
    
    func addRocks() {
        // add rocks to the view
        let addRocksAction = SKAction.sequence(
            [ // a sequence is an array of actions
            SKAction.runBlock(self.addRockNode),
            SKAction.waitForDuration(0.10, withRange:0.15)
            ])
        // let's add rocks to the scene "forever"
        self.runAction(SKAction.repeatActionForever(addRocksAction))
    }
    
    func addAstronautNode() {
        // create a rock – a simple square object
        // add a texture for the spaceship
        let astronautTexture = SKTexture(imageNamed:"astronaut.png")
        let astronaut = SKSpriteNode(texture:astronautTexture)
        // give the Node a name (so we can reference it later)
        //rock.name = "spaceship"
        // rocket.png is not a retina graphic, let's scale it by 1/2
        astronaut.xScale = 0.05
        astronaut.yScale = 0.05
        //let rock = SKSpriteNode(color:SKColor.brownColor(), size:CGSizeMake(8, 8))
        astronaut.position = CGPointMake(skRand(0, high: self.size.width), skRand(self.size.height-100, high:self.size.height))
        // give the node a name
        astronaut.name = "astronaut"
        // giving the rock a physics body allows the world to apply gravity and collisions
        astronaut.physicsBody = SKPhysicsBody(rectangleOfSize: astronaut.size)
        astronaut.physicsBody!.usesPreciseCollisionDetection = true
        // add the rock to the scene
        self.addChild(astronaut)
    }
    
    func addAstronauts() {
        // add rocks to the view
        let addAstronautsAction = SKAction.sequence(
            [ // a sequence is an array of actions
                SKAction.runBlock(self.addAstronautNode),
                SKAction.waitForDuration(0.10, withRange:0.15)
            ])
        // let's add rocks to the scene "forever"
        self.runAction(SKAction.repeatActionForever(addAstronautsAction))
    }
    
    func initSceneContents() {
        self.backgroundColor = SKColor.blackColor()
        // set this scene as the delegate for contact hits
        self.physicsWorld.contactDelegate = self
        // add a spaceship to the middle of the scene
        self.addSpaceShip()
        // add the elapsed time clock
        self.addClock()
        // add the highscore label
        self.addHighscoreLabel()
        // add the health label
        self.addHealthLabel()
        // add the asteroids
        self.addRocks()
        // add the astronauts
        self.addAstronauts()
    }
    
    func initMotionManager() {
        
        self.motionManager.accelerometerUpdateInterval = 1/60.0
        
        let shipNode = self.childNodeWithName("spaceship")
//        let timeNode = self.childNodeWithName("time") as! SKLabelNode
//        
//        var time = 0.0
        
//        self.motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (data, error) -> Void in
//            //self.motionManager.startAccelerometerUpdatesToQueue( OperationQueue.current!, withHandler: { (accelerometerData, error) -> Void in
//            
//            time = time + 0.01
//            print(time)
//            timeNode.text = NSString(format: "%.1f", time) as String
//            var xDelta = CGFloat(data!..x * 5)
//            let xPosition = shipNode!.position.x
//            let newX = CGFloat(xDelta) + xPosition
//            if (newX < self.shipWidth || newX > self.xMax) { xDelta = 0 }
//            var yDelta = CGFloat(data!.acceleration.y * 5)
//            let yPosition = CGFloat(shipNode!.position.y)
//            let newY = CGFloat(yDelta) + yPosition
//            
//            if (newY < self.shipHeight || newY > self.yMax) { yDelta = 0 }
//            if (newX > 0 || newY > 0) {
//                let moveShip = SKAction.moveByX(xDelta, y: yDelta, duration: 0)
//                shipNode!.runAction(moveShip)
//            }
//            
//        })
        
        self.motionManager.startAccelerometerUpdatesToQueue( NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData, error) -> Void in
        //self.motionManager.startAccelerometerUpdatesToQueue( OperationQueue.current!, withHandler: { (accelerometerData, error) -> Void in
            
//            time = time + 0.01
//            print(time)
//            timeNode.text = NSString(format: "%.1f", time) as String
            
            var xDelta = CGFloat(accelerometerData!.acceleration.x * 5)
            let xPosition = shipNode!.position.x
            let newX = CGFloat(xDelta) + xPosition
            if (newX < self.shipWidth || newX > self.xMax) { xDelta = 0 }
            var yDelta = CGFloat(accelerometerData!.acceleration.y * 5)
            let yPosition = CGFloat(shipNode!.position.y)
            let newY = CGFloat(yDelta) + yPosition
            
            if (newY < self.shipHeight || newY > self.yMax) { yDelta = 0 }
            if (newX > 0 || newY > 0) {
                let moveShip = SKAction.moveByX(xDelta, y: yDelta, duration: 0)
                shipNode!.runAction(moveShip)
            }
            
        })
        
    }
    
    func addClock() {
        
        let timeNode = SKLabelNode(fontNamed: "Helvetica")
        timeNode.name = "time"
        timeNode.fontSize = 16
        timeNode.text = "0.0"  // initial time is zero
        timeNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        timeNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        timeNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        
        self.addChild(timeNode)
    }
    
    func addHighscoreLabel() {
        
        let highscoreNode = SKLabelNode(fontNamed: "Helvetica")
        highscoreNode.name = "highscore"
        highscoreNode.fontSize = 16
        highscoreNode.text = "Highscore: \(self.highscoreValue)"  // initial time is zero
        highscoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        highscoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        highscoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-20.0)
        //highscoreNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        
        self.addChild(highscoreNode)
    }
    
    func addHealthLabel() {
        
        let healthNode = SKLabelNode(fontNamed: "Helvetica")
        healthNode.name = "health"
        healthNode.fontSize = 16
        healthNode.text = "Health: 100"  // initial time is zero
        healthNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        healthNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Bottom
        healthNode.position = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame))
        
        
        self.addChild(healthNode)
    }
    
    func engineFlare() -> SKEmitterNode {
        
        let burstPath = NSBundle.mainBundle().pathForResource("Burst", ofType: "sks")
        let burstEmitter = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!) as! SKEmitterNode
        
        burstEmitter.emissionAngle = -1.571 // flip the particle to point downwards
        burstEmitter.particleSize = CGSizeMake(20, 100)  // define width and height
        burstEmitter.particlePositionRange = CGVectorMake(10, 0) // x and y variance of the particles generated
        
        burstEmitter.targetNode = self
        
        return burstEmitter
    }
    
    func gameOver() {
        if (self.hasEnded) {
            return
        }
        self.hasEnded = true
        //self.playSound(self.alarmSound)
        self.removeAllActions()
        self.motionManager.stopAccelerometerUpdates()
        
        let gameOverNode = SKLabelNode(fontNamed: "Chalkduster")
        gameOverNode.name = "gameover"
        gameOverNode.text = "GAME OVER"
        gameOverNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        gameOverNode.xScale = 0.1
        gameOverNode.yScale = 0.1
        gameOverNode.alpha = 0.0
        
        self.addChild(gameOverNode)

    
        let zoomInAction = SKAction.group([
            SKAction.fadeAlphaTo(1, duration: 0.25),
            SKAction.scaleXTo(1, y: 1, duration: 0.25)
            ]
        )
        
        let zoomOutAction = SKAction.group([
            SKAction.fadeAlphaTo(0.5, duration: 0.25),
            SKAction.scaleXTo(0.9, y: 0.9, duration: 0.25)
            ]
        )
        
        let gameOverAction = SKAction.repeatActionForever(
            SKAction.sequence([zoomInAction, zoomOutAction])
        )
        
        gameOverNode.runAction(gameOverAction)
        
        self.checkHighscore()
    }
    
    func checkHighscore() {
        var builtMsg = ""
        if (self.timer > self.highscoreValue) {
            builtMsg = "New highscore: \(self.timer)!!"
            self.saveNewHighscore()
        } else {
            builtMsg = "Good luck next time."
        }
        let alert = UIAlertController(title: "Game Over", message: builtMsg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "PlayAgain", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.playAgainHandler(alert)}))
        self.viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveNewHighscore() {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue("\(self.timer)", forKey: self.highscoreKey)
        
        let highscoreNode = self.childNodeWithName("highscore") as! SKLabelNode
        highscoreNode.text = "Highscore: \(self.timer)"
    }
    
    func playAgainHandler(alert: UIAlertAction!) {
        let helloScene = HelloScene(size: self.size)
        helloScene.viewController = self.viewController
        let doorsTransition = SKTransition.doorsOpenVerticalWithDuration(0.5)
        self.view?.presentScene(helloScene, transition: doorsTransition)
    }
    
    // random math functions
    func skRandf() -> CGFloat {
        return CGFloat(rand()) / CGFloat(RAND_MAX)
    }
    
    func skRand(low: CGFloat, high: CGFloat) -> CGFloat {
        return skRandf() * (high-low) + low;
    }
}
