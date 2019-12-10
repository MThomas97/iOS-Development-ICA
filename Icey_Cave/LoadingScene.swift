//
//  LoadingScene.swift
//  Icey_Cave
//
//  Created by Michael Thomas on 08/12/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//

import GameplayKit
import SpriteKit
import CoreMotion
import AVFoundation

class LoadingScene: SKScene {
    
    var GameSceneLevel: GameScene!
    var MainMenuScene: MainMenu!
    
    override func didMove(to view: SKView) {
        let group = DispatchGroup()
        group.enter()
        
        //Preloads GameScene level in another thread, when the game is launched
        // load resources on other thread
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.GameSceneLevel = GameScene(fileNamed: "GameScene")!
            self?.GameSceneLevel.scaleMode = .aspectFill
            self?.GameSceneLevel.loadLevel()
            self?.GameSceneLevel.createCameraNode()
            self?.GameSceneLevel.createRestartMenu()
            group.leave()
        }
        
        //Wait till the level has been loaded on other thread
        group.wait()

        if let view = self.view {
            //Load the SKScene from 'MainMenu.sks'
            MainMenuScene = MainMenu(fileNamed: "MainMenu")

            MainMenuScene.scaleMode = .aspectFill
            //Sets the preloaded GameScene in local MainMenu GameScene to be used later
            MainMenuScene.SetGameScene(GameSceneLevel)
            let transition = SKTransition.fade(withDuration: 2)
            view.presentScene(MainMenuScene, transition: transition)
            view.showsFPS = true
        }
    }    
}
