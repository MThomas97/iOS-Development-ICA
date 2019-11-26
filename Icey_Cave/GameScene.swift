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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    var player: SKSpriteNode!
    var moveFire: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var Walls: SKSpriteNode = SKSpriteNode()
    var FireObjects: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    var isCameraReset = false
    var isMovingForward = true
    var tapCount = 0
    var applyYimpulse = CGFloat(12)
    var score = 0 {
    didSet {
        scoreLabel.text = "Score: \(score)"
        }
    }
    
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
        player.size = CGSize(width: 22, height: 22)
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
        } else if node.name == "lava" {
            //hot surface change the scale for every second the player is on it or slowly change colour do whichever looks best
        } else if node.name == "finish" {
            // next level
        }
    }

    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find level1.txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        //Load image files
        let Wall = SKTexture(imageNamed: "Wall")
        let Floor = SKTexture(imageNamed: "Floor")
        let PlatformLeft = SKTexture(imageNamed: "PlatformLeft")
        let PlatformRight = SKTexture(imageNamed: "PlatformRight")
        let UnderFloor = SKTexture(imageNamed: "underFloor")
        let FireBottom = SKTexture(imageNamed: "Fire_PixelBottom")
        let FireTop = SKTexture(imageNamed: "Fire_PixelTop")
        let FireLeft = SKTexture(imageNamed: "Fire_PixelLeft")
        let FireRight = SKTexture(imageNamed: "Fire_PixelRight")
        let VolAltHalfLeft = SKTexture(imageNamed: "volcanoAltHalfLeft")
        let VolAltHalfRight = SKTexture(imageNamed: "volcanoAltHalfRight")
        
        //FIX Comment "/" so when it hits it go to next line
        for (row, line) in lines.enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (24 * column), y: (-24 * row) + 414)
                
                switch(letter)
                {
                case "x":
                    //Load wall texture
                    let node = SKSpriteNode(texture: Wall)
                    createRectTile(node, name: "Wall", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "v":
                    //load floor texture
                    let node = SKSpriteNode(texture: Floor)
                    createRectTile(node, name: "Floor", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "u":
                    //load under floor texture
                    let node = SKSpriteNode(texture: UnderFloor)
                    createRectTile(node, name: "underFloor", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "l":
                    //load volcano alt half tile leftside
                    let node = SKSpriteNode(texture: VolAltHalfLeft)
                    createTextureTile(node, name: "volcanoAltHalfLeft", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "r":
                    //load volcano alt half tile right rightside
                    let node = SKSpriteNode(texture: VolAltHalfRight)
                    createTextureTile(node, name: "VolcanoAltHalfRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    
                    addChild(node)
                    break;
                case "f":
                    //load fire at bottom
                    let node = SKSpriteNode(texture: FireBottom)
                    createTextureTile(node, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    addChild(node)
                    break
                case "d":
                    //load fire Above
                    let node = SKSpriteNode(texture: FireTop)
                    createTextureTile(node, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    addChild(node)
                    break
                case "a":
                    //load fire to the left
                    let node = SKSpriteNode(texture: FireLeft)
                    createTextureTile(node, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    addChild(node)
                    break
                case "s":
                    //load fire to the right
                    let node = SKSpriteNode(texture: FireRight)
                    createTextureTile(node, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    addChild(node)
                    break
                case "m":
                    //load Moving Fire
                    moveFire = SKSpriteNode(texture: FireBottom)
                    createTextureTile(moveFire, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    addChild(moveFire)
                    break
                case "t":
                    //load Left Platform
                    let node = SKSpriteNode(texture: PlatformLeft)
                    createRectTile(node, name: "PlatformLeft", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "y":
                    //load right platform
                    let node = SKSpriteNode(texture: PlatformRight)
                    createRectTile(node, name: "PlatformRight", position: position, CollisionType: CollisionTypes.wall)
                    
                    addChild(node)
                    break
                case "w":
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
                   break
                case " ":
                    //this is an empty space - do nothing!
                    break;
                case "/":
                    //this is comment do nothing!
                    break;
                default:
                    fatalError("Unknown level letter: \(letter)")
                }
                if(letter == "/")
                {
                    //ignores every letter after "/" and continues onto the next line
                    break
                }
            }
        }
    }
    
    func createRectTile(_ node: SKSpriteNode, name: String, position: CGPoint, CollisionType: CollisionTypes) {
        node.name = name
        node.position = position
        node.size = CGSize(width: 24, height: 24)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionType.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
    }
    
    func createTextureTile(_ node: SKSpriteNode, name: String, position: CGPoint, CollisionType: CollisionTypes) {
        node.name = name
        node.position = position
        node.size = CGSize(width: 24, height: 24)
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionType.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
    
        if(isCameraReset)
        {
            if(cameraNode.position.y >= 207)
            {
                isCameraReset = false
            }
            else
            {
                cameraNode.position.y += 5
                scene?.camera = cameraNode
            }
        } else if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -20, dy: -9.8)
        }
    }
    
    override func didFinishUpdate() {
        //cameraNode.position.y -= 0.1
        if(moveFire != nil && isMovingForward)
        {
            moveFire.run(SKAction.moveTo(x: 790, duration: 0.3))
            isMovingForward = moveFire.position.x >= 789 ? false : true
            print(moveFire.position.x)
        }
        else
        {
            moveFire.run(SKAction.moveTo(x: 50, duration: 0.3))
            isMovingForward = moveFire.position.x <= 51 ? true : false
        }
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
