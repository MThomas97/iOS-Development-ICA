//
//  GameScene.swift
//  Icey_Cave
//
//  Created by THOMAS, MICHAEL on 12/11/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//

import SpriteKit
import GameplayKit

class IceCube: SKSpriteNode {
    
}

class GameScene: SKScene {
    var ice_cube = ["Ice_Cube", "ballBlue", "ballGreen", "ballPurple", "ballRed", "ballYellow"]
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        let ballRadius = ball.frame.width / 2.0
        
        for i in stride(from: ballRadius, to: view.bounds.width - ballRadius, by: ball.frame.width)
        }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
