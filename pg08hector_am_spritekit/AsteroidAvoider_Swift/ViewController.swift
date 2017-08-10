//
//  ViewController.swift
//  AsteroidAvoider_Swift
//
//  Created by Ash Mishra on 2015-05-12.
//  Copyright (c) 2015 VFS. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    private var spriteView: SKView?

    override func viewDidLoad() {
        super.viewDidLoad()
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
        helloScene.viewController = self
        self.spriteView?.presentScene(helloScene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

