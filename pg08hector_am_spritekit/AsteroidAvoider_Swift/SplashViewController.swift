//
//  SplashViewController.swift
//  AsteroidAvoider_Swift
//
//  Created by Hector de Jesus Ramirez Landa on 2017-04-19.
//  Copyright © 2017 VFS. All rights reserved.
//

import UIKit
import SpriteKit

class SplashViewController: UIViewController {

    private var spriteView: SKView?
    
    internal var _instance:UIViewController?
    internal var instance:UIViewController {
        get {
            return _instance!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._instance = self
        self.spriteView = self.view as? SKView
        //self.spriteView = self.view as! SKView
        self.spriteView?.showsDrawCount = true
        self.spriteView?.showsNodeCount = true
        self.spriteView?.showsFPS = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let helloScene = HelloScene(size: spriteView!.bounds.size)
        self.spriteView?.presentScene(helloScene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
