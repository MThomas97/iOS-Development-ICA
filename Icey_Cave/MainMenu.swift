//
//  MainMenu.swift
//  Icey_Cave
//
//  Created by Michael Thomas on 03/12/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//

import GameplayKit
import SpriteKit
import CoreMotion
import AVFoundation

class MainMenu: SKScene {

    var GameSceneLevel: GameScene!
    var StoredGameLevel: GameScene!
    var LoadingScreen: LoadingScene!
    var TitleScreenMusic: AVAudioPlayer?
    override func didMove(to view: SKView) {
        let path = Bundle.main.path(forResource: "Music/TitleMusic.mp3", ofType:nil)!
             let url = URL(fileURLWithPath: path)

             do {
                 TitleScreenMusic = try AVAudioPlayer(contentsOf: url)
                 TitleScreenMusic?.numberOfLoops = -1 //Loops forever
                 TitleScreenMusic?.play()
             } catch {
                 // couldn't load file
             }
        //Loads the SKLabelNodes
        let GameName = SKLabelNode(fontNamed: "Ice Caps")
        GameName.text = "Icey Cave"
        GameName.fontSize = CGFloat(40)
        GameName.horizontalAlignmentMode = .left
        GameName.position = CGPoint(x: 365, y: 300)
        GameName.zPosition = 2
        addChild(GameName)
        
        let playButton = SKLabelNode(fontNamed: "IceCaps")
        playButton.text = "Play!"
        playButton.fontSize = CGFloat(40)
        playButton.horizontalAlignmentMode = .left
        playButton.position = CGPoint(x: 400, y: 207)
        playButton.zPosition = 2
        playButton.name = "StartButton"
        addChild(playButton)
    }
    
    public func SetGameScene(_ scene: GameScene) {
        GameSceneLevel = scene
        GameSceneLevel.storedLevel = scene
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async { [weak self] in
        if let touch = touches.first {
            let position = touch.location(in: (self?.scene)!)
            let node = self?.atPoint(position)
                if node?.name == "StartButton"
                {
                 if let view = self?.view {
                    
                    self?.TitleScreenMusic?.stop()
                    
                    view.presentScene(self?.GameSceneLevel)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsPhysics = true
                    view.showsNodeCount = true
                    view.showsDrawCount = true
                    }
                }
            }
        }
    }
}
