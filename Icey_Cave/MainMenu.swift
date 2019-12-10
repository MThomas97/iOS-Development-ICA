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
    var TitleScreenMusic: AVAudioPlayer?
    override func didMove(to view: SKView) {
        //Load the mp3 file into a AVAudioPlayer then preloads it and play the audio
        let path = Bundle.main.path(forResource: "Music/TitleMusic.mp3", ofType:nil)!
             let url = URL(fileURLWithPath: path)

             do {
                 TitleScreenMusic = try AVAudioPlayer(contentsOf: url)
                 TitleScreenMusic?.numberOfLoops = -1 //Loops forever
                 TitleScreenMusic?.prepareToPlay()
                 TitleScreenMusic?.play()
             } catch {
                 // couldn't load file
             }
        //Loads the SKLabelNodes and add the nodes to the scene
        createSKLabel(name: "GameTitle", text: "Icey Cave", fontSize: 40, position: CGPoint(x: 360, y: 300))
        
        createSKLabel(name: "StartButton", text: "Play!", fontSize: 40, position: CGPoint(x: 400, y: 207))
        
        createSKLabel(name: "instructions", text: "Instructions", fontSize: 28, position: CGPoint(x: 360, y: 130))
        
        createSKLabel(name: "TapLabel", text: "Tap to Jump", fontSize: 24, position: CGPoint(x: 375, y: 100))
        
        createSKLabel(name: "TiltLabel", text: "Tilt device to move", fontSize: 24, position: CGPoint(x: 320, y: 70))
    }
    
    func createSKLabel(name: String, text: String, fontSize: Int , position: CGPoint)
    { //Creates SKLabels
        let node = SKLabelNode(fontNamed: "IceCaps")
        node.name = name
        node.text = text
        node.fontSize = CGFloat(fontSize)
        node.horizontalAlignmentMode = .left
        node.position = position
        node.zPosition = 2
        addChild(node)
    }
    
    public func SetGameScene(_ scene: GameScene) {
        //When this called it sets the GameScene and also stores a copy inside the GameScene
        GameSceneLevel = scene
        GameSceneLevel.storedLevel = scene
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /*When the Start Button is pressed in the main menu, load the GameScene onto the main
         thread, also stop playing the TitleScreen music, then transition the scene into
         the GameScene*/
        DispatchQueue.main.async { [weak self] in
        if let touch = touches.first {
            let position = touch.location(in: (self?.scene)!)
            let node = self?.atPoint(position)
                if node?.name == "StartButton"
                {
                 if let view = self?.view {
                    
                    self?.TitleScreenMusic?.stop()
                    
                    let transition = SKTransition.reveal(with: .up, duration: 0.8)
                    
                    view.presentScene(self!.GameSceneLevel, transition: transition)
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
