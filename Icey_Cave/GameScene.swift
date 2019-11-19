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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    var PlayerIceCube:SKSpriteNode = SKSpriteNode()
    var Walls:SKSpriteNode = SKSpriteNode()
    var FireObjects:SKSpriteNode = SKSpriteNode()
    
    let tapRec = UITapGestureRecognizer()
    let playerCategory:UInt32 = 0x1 << 0 // 1
    let fireCategory:UInt32 = 0x1 << 1 // 2
    let groundCategory:UInt32 = 0x1 << 2 // 4


    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        if let IceCubeNode:SKSpriteNode = self.childNode(withName: "IceCube") as? SKSpriteNode
        {
            PlayerIceCube = IceCubeNode
        }
        
        if let WallsNode:SKSpriteNode = self.childNode(withName: "Floor") as? SKSpriteNode
        {
            Walls = WallsNode
        }
        
        if let FireObjectsNode:SKSpriteNode = self.childNode(withName: "FireObjects") as? SKSpriteNode
        {
            FireObjects = FireObjectsNode
        }
        //self.view!.isMultipleTouchEnabled = true
        //self.view!.isUserInteractionEnabled = true
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
                
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        //figure out how to have all the walls collide with the player
        //when the fire is collided with the player, game over
        Walls.physicsBody?.categoryBitMask = groundCategory
        PlayerIceCube.physicsBody?.collisionBitMask = groundCategory
        FireObjects.physicsBody?.categoryBitMask = fireCategory
        
        PlayerIceCube.physicsBody?.categoryBitMask = playerCategory
        Walls.physicsBody?.contactTestBitMask = playerCategory
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == groundCategory | playerCategory
        {
            print("collision with ice cube occured")
        }
    }
    
    @objc func tappedView() {
        print("we tapped")
        PlayerIceCube.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -20, dy: -9.8)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // print("we tapped")
        //PlayerIceCube.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        
    }
    
}
