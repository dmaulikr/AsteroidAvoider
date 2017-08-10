//
//  HelloScene.swift
//  AsteroidAvoider_Swift
//
//  Created by Ash Mishra on 2015-05-12.
//  Copyright (c) 2015 VFS. All rights reserved.
//

import Foundation
import SpriteKit

public class HelloScene: SKScene {
    
    var viewController: UIViewController!
    
    private var contentCreated = false
    private let kHelloNodeName = "helloNode"
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func didMoveToView(view: SKView) {
        
        if !contentCreated {
            self.createSceneContents()
            self.contentCreated = true
        }
    }
    
    func createSceneContents() {
        self.backgroundColor = SKColor.redColor()
        self.scaleMode = SKSceneScaleMode.AspectFit
        self.addChild(self.helloNode())
    }
    
    func helloNode() -> SKLabelNode {
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.name = kHelloNodeName
        
        labelNode.text = "Avoid the Asterioids"
        labelNode.fontSize = 24
        labelNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        return labelNode
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
        let helloNode = self.childNodeWithName(kHelloNodeName)
        if helloNode==nil {
            return
        }
        
        let moveUp = SKAction.moveByX(0, y: 100, duration: 0.5)
        let zoom = SKAction.scaleTo(0, duration: 0.25)
        let remove = SKAction.removeFromParent()
        
        let moveSequence = SKAction.sequence([moveUp, zoom, remove])
        
        helloNode?.runAction(moveSequence, completion: { () -> Void in
            
            let spaceScene = SpaceshipScene(size: self.size)
            spaceScene.viewController = self.viewController
            let doorsTransition = SKTransition.doorsOpenVerticalWithDuration(0.5)
            
            self.view?.presentScene(spaceScene, transition: doorsTransition)
            
        })
    }
}