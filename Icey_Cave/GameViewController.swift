//
//  GameViewController.swift
//  Icey_Cave
//
//  Created by THOMAS, MICHAEL on 12/11/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var startButton = UIButton()
    var LoadingScene: SKScene!
    var TitleScene: MainMenu!
    var GameSceneLevel: GameScene!
    var loadingLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load resources on other thread
        if let view = self.view as! SKView? {
            //Load the SKScene from 'MainMenu.sks'
            if let scene = SKScene(fileNamed: "LoadingScene") {
                scene.scaleMode = .aspectFill
                
                view.presentScene(scene)
            }
            view.showsFPS = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
