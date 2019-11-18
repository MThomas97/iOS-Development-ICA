//
//  GameScene.swift
//  Icey_Cave
//
//  Created by THOMAS, MICHAEL on 12/11/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

class IceCube: SKSpriteNode {
    
}

class GameScene: SKScene {
    //var balls = ["Ice_Cube"]
    var motionManager: CMMotionManager?
    
    override func didMove(to view: SKView) {
    /*    let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
     */
        //let player = SKSpriteNode(imageNamed: "Ice_Cube")
        //let playerRadius = player.frame.width / 2.0
        
        
            /*for j in stride(from: 50, to: view.bounds.height, by: player.frame.height)
            {
                //et ballType = balls.randomElement()!
                //let ball = IceCube(imageNamed: ballType)
                player.position = CGPoint(x: 300, y: 250)
                //player.name = ballType
                
                player.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
                player.physicsBody?.allowsRotation = false
                player.physicsBody?.friction = 0
                player.physicsBody?.restitution = 0
                
                addChild(player)
            }
        */
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
 
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -20, dy: accelerometerData.acceleration.x * 20  )
        }
    }
}
