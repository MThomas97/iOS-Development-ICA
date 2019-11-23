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

enum CollisionTypes : UInt32 {
    case player = 1
    case wall = 2
    case hotSurface = 4
    case fire = 8
    case finish = 16
}

class IceCube: SKSpriteNode {
    
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var Walls: SKSpriteNode = SKSpriteNode()
    var FireObjects: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    var isCameraReset = false
    var tapCount = 0
    var applyYimpulse = CGFloat(12)
    var score = 0 {
    didSet {
        scoreLabel.text = "Score: \(score)"
        }
    }
    
    let tapRec = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        physicsWorld.contactDelegate = self
        
        loadLevel()
        createPlayer()
        createCameraNode()
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
                
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if (nodeA == player){
            playerCollided(with: nodeB)
        } else if (nodeB == player){
            playerCollided(with: nodeA)
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "snowBall2")
        player.size = CGSize(width: 24, height: 24)
        player.name = "player"
        player.position = CGPoint(x: 800, y: 380)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.linearDamping = 0
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.hotSurface.rawValue | CollisionTypes.fire.rawValue | CollisionTypes.finish.rawValue
        addChild(player)
    }
    
    func createCameraNode() {
        cameraNode.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
        print(scene!.size)
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
    }
    
    func playerCollided(with node: SKNode){
        if (node.name == "Fire") {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            tapCount = 0
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                if (!((self?.player.parent) != nil))
                {
                    self?.createPlayer()
                    self?.isGameOver = false
                    self?.isCameraReset = true
                }
            }
            
            print("Collision occured with fire")
        } else if node.name == "Floor" {
            //node.removeFromParent()
            tapCount = 0
            score += 1
        } else if node.name == "finish" {
            // next level
        }
    }
    
    @objc func tappedView() {
        //print("we tapped")
        //player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
        
    }

    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find level1.txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        
        let textureWall = SKTexture(imageNamed: "Wall")
        let textureFloor = SKTexture(imageNamed: "Floor")
        let textureUnderFloor = SKTexture(imageNamed: "underFloor")
        let textureHillLeft = SKTexture(imageNamed: "HillLeft")
        let textureHillRight = SKTexture(imageNamed: "HillRight")
        let textureFirePixel = SKTexture(imageNamed: "Fire_Pixel")
        
        for (row, line) in lines.enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (24 * column), y: (-24 * row) + 414)
                
                if letter == "x" {
                    //load wall
                    let node = SKSpriteNode(texture: textureWall)
                    
                    node.name = "Wall"
                    node.size = CGSize(width: 24, height: 24)
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.isDynamic = false
                    node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
                    
                    addChild(node)
                } else if letter == "v" {
                    //load floor platform
                    let node = SKSpriteNode(texture: textureFloor)
                    node.name = "Floor"
                    node.size = CGSize(width: 24, height: 24)
                    node.position = position
                    //node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.fire.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "u" {
                    //load under floor
                    let node = SKSpriteNode(texture: textureUnderFloor)
                    node.name = "underFloor"
                    node.size = CGSize(width: 24, height: 24)
                    node.position = position
                    //node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.fire.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "l" {
                    //load fire
                    let node = SKSpriteNode(texture: textureHillLeft)
                    node.name = "HillLeft"
                    node.size = CGSize(width: 24, height: 24)
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hotSurface.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "f" {
                    //load fire
                    let node = SKSpriteNode(texture: textureFirePixel)
                    node.name = "Fire"
                    node.size = CGSize(width: 24, height: 24)
                    node.anchorPoint = CGPoint(x: 0.5, y: 0)
                    node.position.x = position.x - 12
                    node.position.y = position.y - 12
                    node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width, height:  node.size.height / 2))
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hotSurface.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "r" {
                    //load fire
                    let node = SKSpriteNode(texture: textureHillRight)
                    node.name = "HillRight"
                    node.size = CGSize(width: 24, height: 24)
                    node.position = position
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.hotSurface.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == "f" {
                    //load finish point
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.position = position
                    node.size = CGSize(width: 24, height: 24)
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    
                    addChild(node)
                } else if letter == " " {
                    //this is an empty space - do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
    
        if(isCameraReset)
        {
            if(cameraNode.position.y >= 207)
            {
                isCameraReset = false
            }
            cameraNode.position.y += 5
            scene?.camera = cameraNode
        } else if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -20, dy: -9.8)
        }
    }
    
    override func didFinishUpdate() {
        cameraNode.position.y -= 0.4
        //FIX Camera player jumping when camera follows player
        if(player.position.y <= cameraNode.position.y)
        {
            print(cameraNode.position.y - player.position.y)
            cameraNode.position.y -=  cameraNode.position.y - player.position.y
            applyYimpulse += cameraNode.position.y - player.position.y
            scene?.camera = cameraNode
        }
        scene?.camera = cameraNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(tapCount != 3 && !isCameraReset)
        {
            player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: applyYimpulse))
            tapCount += 1
            print("we tapped")
        }
    }
}
