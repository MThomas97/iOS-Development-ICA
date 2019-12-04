//
//  GameScene.swift
//  Icey_Cave
//
//  Created by THOMAS, MICHAEL on 12/11/2019.
//  Copyright © 2019 THOMAS, MICHAEL. All rights reserved.
//
//Assets used e.g


import CoreMotion
import SpriteKit
import GameplayKit
import AVFoundation

enum CollisionTypes : UInt32 {
    case player = 1
    case wall = 2
    case hotSurface = 4
    case fire = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    var backgroundMusic : AVAudioPlayer?
    var LoseMusic : AVAudioPlayer?
    var player: SKSpriteNode!
    var moveFire: Array<SKSpriteNode> = Array()
    var cameraNode = SKCameraNode()
    var Walls: SKSpriteNode = SKSpriteNode()
    var FireObjects: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode!
    var restartButton: SKLabelNode!
    var MainMenuButton: SKLabelNode!
    var background: SKSpriteNode!
    var isGameOver = false
    var isCameraReset = false
    var isMovingForward = false
    var isMovingBackwards = false
    var playerColourBlend = CGFloat(0.1)
    var tapCount = 0
    var applyYimpulse = CGFloat(10)
    var runOnce = 0
    let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1), duration: 2.0)
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
        
        createPlayer()
        createCameraNode()
                
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        let path = Bundle.main.path(forResource: "Music/WinterMusic.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.numberOfLoops = -1 //Loops forever
            backgroundMusic?.play()
        } catch {
            // couldn't load file
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if (nodeA == player){
            print("hit")
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
        player.zPosition = -1
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
    
    func createRestartMenu() {
        background = SKSpriteNode(color: UIColor.black, size: CGSize(width: (cameraNode.scene?.size.width)!, height: (cameraNode.scene?.size.height)!))
        background.name = "RestartBackground"
        background.alpha = CGFloat(0.5)
        background.position = cameraNode.position
        background.zPosition = 1
        addChild(background)
        
        restartButton = SKLabelNode(fontNamed: "Chalkduster")
        restartButton.name = "RestartButton"
        restartButton.text = "Restart"
        restartButton.horizontalAlignmentMode = .left
        restartButton.position = CGPoint(x: 500,y: (scene?.camera!.position.y)!)
        restartButton.zPosition = 2
        addChild(restartButton)
                
        MainMenuButton = SKLabelNode(fontNamed: "Chalkduster")
        MainMenuButton.name = "MainMenuButton"
        MainMenuButton.text = "Main Menu"
        MainMenuButton.horizontalAlignmentMode = .left
        MainMenuButton.position = CGPoint(x: 500,y: (scene?.camera!.position.y)!)
        MainMenuButton.zPosition = 2
        //addChild(MainMenuButton)
    }
    
    func PlayMusic(AVPlayer: AVAudioPlayer, URLpath: String) {
        let path = Bundle.main.path(forResource: URLpath, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        var AudioPlayer = AVPlayer
        do {
            AudioPlayer = try AVAudioPlayer(contentsOf: url)
            AudioPlayer.numberOfLoops = -1 //Loops forever
            AudioPlayer.play()
        } catch {
            // couldn't load file
        }
    }
    
    func playerCollided(with node: SKNode){
        if (node.physicsBody?.categoryBitMask == CollisionTypes.fire.rawValue) {
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
                    self?.backgroundMusic?.stop()
                    let path = Bundle.main.path(forResource: "Music/loseMusic.wav", ofType:nil)!
                    let url = URL(fileURLWithPath: path)

                    do {
                        self?.LoseMusic = try AVAudioPlayer(contentsOf: url)
                        self?.LoseMusic?.numberOfLoops = -1 //Loops forever
                        self?.LoseMusic?.play()
                    } catch {
                        // couldn't load file
                    }
                    self?.createRestartMenu()
                }
            }
            print("Collision occured with fire")
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.wall.rawValue {
            if let action = player.action(forKey: "hotSurface")
            {
                action.speed = 0
            }
            tapCount = 0
            score += 1
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.hotSurface.rawValue {
            let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1.2), duration: 1.0)
            hotSurface.speed = 1
            player.run(hotSurface, withKey: "hotSurface")
            playerColourBlend += 0.2
            print(playerColourBlend)
            if(player.colorBlendFactor >= 1)
            {
                player.physicsBody?.isDynamic = false
                isGameOver = true
                score -= 1
                tapCount = 0
                playerColourBlend = 0.1
                let move = SKAction.move(to: node.position, duration: 0.25)
                let scale = SKAction.scale(to: 0.0001, duration: 0.25)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([move, scale, remove])
                
                player.run(sequence) { [weak self] in
                    if (!((self?.player.parent) != nil))
                    {
                        self?.createRestartMenu()
                    }
                }
            }
        } else if node.name == "Wall" {
            //Reset SKAction Nodes
            if let action = player.action(forKey: "hotSurface")
            {
                action.speed = 0
            }
        } else if node.name == "finish" {
            // next level
        }
    }

    public func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find level1.txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        //Load image files
        let Wall = SKTexture(imageNamed: "Wall")
        let Floor = SKTexture(imageNamed: "Floor")
        let UnderFloor = SKTexture(imageNamed: "underFloor")
        let FireBottom = SKTexture(imageNamed: "Fire_PixelBottom")
        let FireTop = SKTexture(imageNamed: "Fire_PixelTop")
        let FireLeft = SKTexture(imageNamed: "Fire_PixelLeft")
        let FireRight = SKTexture(imageNamed: "Fire_PixelRight")
        let VolAltHalfLeft = SKTexture(imageNamed: "volcanoAltHalfLeft")
        let VolAltHalfRight = SKTexture(imageNamed: "volcanoAltHalfRight")
        let VolAltTextureLeft = SKTexture(imageNamed: "volcanoAltLeft")
        let VolAltTextureCentre = SKTexture(imageNamed: "volcanoAltCentre")
        let VolAltTextureRight = SKTexture(imageNamed: "volcanoAltRight")
        let VolAltHalfCirLeft = SKTexture(imageNamed: "volcanoHalfCirLeft")
        let VolAltHalfCirRight = SKTexture(imageNamed: "volcanoHalfCirRight")
        let VolTextureLeft = SKTexture(imageNamed: "volcanoLeft")
        let VolTextureCentre = SKTexture(imageNamed: "volcanoCentre")
        let VolTextureRight = SKTexture(imageNamed: "volcanoRight")
        let VolHalfRndLeft = SKTexture(imageNamed: "volcanoHalfLeft")
        let VolHalfRndCentre = SKTexture(imageNamed: "volcanoHalfMid")
        let VolHalfRndRight = SKTexture(imageNamed: "volcanoHalfRight")
        let VolAltHalfRnd = SKTexture(imageNamed: "volcanoAltHalfRnd")
        let VolHalfRnd = SKTexture(imageNamed: "volcanoHalfRnd")
        let Lava = SKTexture(imageNamed: "volcanoLava")
        let LavaBelow = SKTexture(imageNamed: "volcanoLavaBelow")
        let BlackLava = SKTexture(imageNamed: "BlackLava")
        let BlackLavaBelow = SKTexture(imageNamed: "BlackLavaBelow")
        let VolHalfCirLeft = SKTexture(imageNamed: "HalfCirLeft")
        let VolHalfCirRight = SKTexture(imageNamed: "HalfCirRight")
        
        var indexOfFire = 0
        for (row, line) in lines.enumerated() {
            var isEndofLine = false
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (24 * column), y: (-24 * row) + 414)
                
                switch(letter)
                {
                case "x":
                    //Load wall texture
                    createRectTile(Wall, name: "Wall", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "v":
                    //load floor texture
                    createRectTile(Floor, name: "Floor", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "u":
                    //load under floor texture
                    createRectTile(UnderFloor, name: "underFloor", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "l":
                    //load volcano alt half tile leftside
                    createTextureTile(Lava, name: "Lava", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "r":
                    //load volcano alt half tile right rightside
                    createTextureTile(LavaBelow, name: "LavaBelow", position: position, CollisionType: CollisionTypes.fire)
                    break;
                case "f":
                    //load fire at bottom
                    createTextureTile(FireBottom, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "d":
                    //load fire Above
                    createTextureTile(FireTop, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "a":
                    //load fire to the left
                    createTextureTile(FireLeft, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "s":
                    //load fire to the right
                    createTextureTile(FireRight, name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "m":
                    //load Moving Fire
                    moveFire.append(SKSpriteNode(texture: FireBottom))
                    createNodeTexture(moveFire[indexOfFire], name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    indexOfFire += 1
                    break
                case "t":
                    //load Left Platform
                    createTextureTile(VolAltHalfLeft, name: "VolAltPlatformLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "y":
                    //load right platform
                    createTextureTile(VolAltHalfRight, name: "VolAltPlatformRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "b":
                    //load right platform
                    createTextureTile(VolAltTextureLeft, name: "VolAltTextureLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "c":
                    //load right platform
                    createTextureTile(VolAltTextureCentre, name: "VolAltTextureCentre", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "e":
                    //load right platform
                    createTextureTile(VolAltTextureRight, name: "VolAltTextureRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "g":
                    //load right platform
                    createTextureTile(VolAltHalfCirLeft, name: "VolAltCirLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "h":
                    //load right platform
                    createTextureTile(VolAltHalfCirRight, name: "PlatformRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "i":
                    //load right platform
                    createTextureTile(VolTextureLeft, name: "volcanoTextureLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "j":
                    createTextureTile(VolTextureCentre, name: "volcanoTextureCentre", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "k":
                    createTextureTile(VolTextureRight, name: "volcanoTextureRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "n":
                    createTextureTile(VolHalfRndLeft, name: "volcanoRndLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "o":
                    createTextureTile(VolHalfRndCentre, name: "volcanoRndCentre", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "p":
                    createTextureTile(VolHalfRndRight, name: "volcanoRndRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "q":
                    createTextureTile(VolAltHalfRnd, name: "volcanoAltRnd", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "A":
                    createTextureTile(VolHalfRnd, name: "volcanoRnd", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "B":
                    createTextureTile(BlackLava, name: "BlackLava", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "C":
                    createTextureTile(BlackLavaBelow, name: "BlackLavaBelow", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "D":
                    createTextureTile(VolHalfCirLeft, name: "volcanoCirLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "E":
                    createTextureTile(VolHalfCirRight, name: "volcanoCirRight", position: position, CollisionType: CollisionTypes.hotSurface)
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
                    break;
                    //fatalError("Unknown level letter: \(letter)")
                }
                if(letter == "/")
                {
                    //ignores every letter after "/" and continues onto the next line
                    isEndofLine = true
                    break
                }
            }
            if(isEndofLine)
            {
                isEndofLine = false
                continue
            }
        }
    }
    
    func createRectTile(_ textureImg: SKTexture, name: String, position: CGPoint, CollisionType: CollisionTypes) {
        let node = SKSpriteNode(texture: textureImg)
        node.name = name
        node.position = position
        node.size = CGSize(width: 24, height: 24)
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionType.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func createNodeTexture(_ node: SKSpriteNode, name: String, position: CGPoint, CollisionType: CollisionTypes) {
        node.name = name
        node.position = position
        node.size = CGSize(width: 24, height: 24)
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionType.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func createTextureTile(_ textureImg: SKTexture, name: String, position: CGPoint, CollisionType: CollisionTypes) {
        let node = SKSpriteNode(texture: textureImg)
        node.name = name
        node.position = position
        node.size = CGSize(width: 24, height: 24)
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionType.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        if(isCameraReset)
        {
            if(cameraNode.position.y >= 207)
            {
                isCameraReset = false
                player.speed = 1
            }
            else
            {
                cameraNode.position.y += 5
                scene?.camera = cameraNode
            }
        } else if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -15, dy: -9.8)
        }
    }
    
    override func didFinishUpdate() {
        //cameraNode.position.y -= 0.1
        for moveFireIndex in moveFire
        {
            if(moveFireIndex.position.x <= 72)
            {
                moveFireIndex.run(SKAction.moveTo(x: 790, duration: 1.5))
                isMovingForward = moveFireIndex.position.x >= 789 ? false : true
            }
            else if(moveFireIndex.position.x >= 789)
            {
                moveFireIndex.run(SKAction.moveTo(x: 71, duration: 1.5))
                isMovingForward = moveFireIndex.position.x <= 51 ? true : false
            }
        }
    
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
        if let touch = touches.first {
            let position = touch.location(in: view)
            let node = atPoint(position)
            if node.name == "RestartButton"
            {
                LoseMusic?.stop()
                backgroundMusic?.play()
                isGameOver = false
                isCameraReset = true
                let remove = SKAction.removeFromParent()
                restartButton.run(remove)
                MainMenuButton.run(remove)
                background.alpha = 0
                createPlayer()
                player.speed = 0
                //isGameOver = false
                //isCameraReset = true
            }
            
        }
        if let touch = touches.first {
            let position = touch.location(in: view)
            let node = atPoint(position)
            if node.name == "MainMenuButton"
            {
                print(true)
                if let view = self.view {
                    // Load the SKScene from 'GameScene.sks'
                    if let scene = SKScene(fileNamed: "MainMenu") {
                        // Set the scale mode to scale to fit the available space
                        scene.scaleMode = .aspectFill
                        // Present the scene
                        view.presentScene(scene)
                    }
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
        if(tapCount != 3 && !isCameraReset)
        {
            player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: applyYimpulse))
            tapCount += 1
        }
    }
}
