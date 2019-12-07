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
import UIKit

enum CollisionTypes : UInt32 {
    case player = 1
    case wall = 2
    case hotSurface = 4
    case fire = 8
    case finish = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager: CMMotionManager?
    var RestartScene = SKScene()
    var backgroundMusic: AVAudioPlayer?
    var LoseMusic: AVAudioPlayer?
    var player: SKSpriteNode!
    var moveFire: Array<SKSpriteNode> = Array()
    var cameraNode = SKCameraNode()
    var Walls: SKSpriteNode = SKSpriteNode()
    var FireObjects: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKLabelNode!
    var restartButton: SKLabelNode!
    var MainMenuButton: SKLabelNode!
    var background: SKSpriteNode!
    var loseLabel: SKLabelNode!
    var HighScoreLabel: SKLabelNode!
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    var isGameOver = false
    var isCameraReset = false
    var isMovingForward = false
    var isMovingBackwards = false
    var tempPlayerPos = CGFloat(0)
    var playerColourBlend = CGFloat(0.1)
    var tapCount = 0
    var applyYimpulse = CGFloat(6)
    var resetCameraSpeed = CGFloat(12)
    var runOnce = 0
    let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1), duration: 2.0)
    var score = 0 {
    didSet {
        scoreLabel.text = "\(score)ft"
        }
    }
    
    override func didMove(to view: SKView) {
        scene?.anchorPoint.y = CGFloat(0.5)
        scoreLabel = SKLabelNode(fontNamed: "Ice Caps")
        scoreLabel.text = "0ft"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 50, y: 20)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        physicsWorld.contactDelegate = self
        
        createPlayer()
        createCameraNode()
        createRestartMenu()
        
        UserDefaults().set(0, forKey: "HIGHSCORE")
        
        tempPlayerPos = player.position.y
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        let path = Bundle.main.path(forResource: "Music/WinterMusic.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.numberOfLoops = -1 //Loops forever
            backgroundMusic?.prepareToPlay()
            backgroundMusic?.play()
        } catch {
            // couldn't load file
        }
        
        let Losepath = Bundle.main.path(forResource: "Music/loseMusic.wav", ofType:nil)!
        let Loseurl = URL(fileURLWithPath: Losepath)

        do {
            LoseMusic = try AVAudioPlayer(contentsOf: Loseurl)
            LoseMusic?.numberOfLoops = -1 //Loops forever
            LoseMusic?.prepareToPlay()
        } catch {
            // couldn't load file
        }
    }
    
    func createSKLabel(_ node: SKLabelNode, name: String, text: String, fontSize: Int , position: CGPoint, isHidden: Bool)
    {
        node.name = name
        node.text = text
        node.fontSize = CGFloat(fontSize)
        node.horizontalAlignmentMode = .left
        node.position = CGPoint(x: position.x, y: (scene?.camera?.position.y)! + position.y)
        node.zPosition = 2
        node.isHidden = isHidden
        addChild(node)
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
        
        background = SKSpriteNode(color: UIColor.black, size: CGSize(width: 950, height: 450))
        background.name = "RestartBackground"
        background.alpha = CGFloat(0.7)
        background.position = (scene?.camera!.position)!
        background.zPosition = 2
        background.isHidden = true
        addChild(background)
        
        restartButton = SKLabelNode(fontNamed: "Ice Caps")
        createSKLabel(restartButton, name: "RestartButton", text: "Restart", fontSize: 40, position: CGPoint(x: 520, y: 0), isHidden: true)
        
        MainMenuButton = SKLabelNode(fontNamed: "Ice Caps")
        createSKLabel(MainMenuButton, name: "MainMenuButton", text: "Main Menu", fontSize: 40, position: CGPoint(x: 210, y: 0), isHidden: true)
        
        HighScoreLabel = SKLabelNode(fontNamed: "Guevara")
        createSKLabel(HighScoreLabel, name: "HighScore", text: "High Score: ", fontSize: 40, position: CGPoint(x: 310, y: 120), isHidden: true)
        
        loseLabel = SKLabelNode(fontNamed: "Guevara")
        createSKLabel(loseLabel, name: "Lost", text: "Depth: \(score)", fontSize: 40, position: CGPoint(x: 350, y: 80), isHidden: true)
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
    
    func saveHighScore() {
        UserDefaults.standard.set(score, forKey: "HIGHSCORE")
        HighScoreLabel.text = "High Score: \(UserDefaults().integer(forKey: "HIGHSCORE"))"
    }
    
    func SetDeathScreen(_ node: SKNode)
    {
        player.physicsBody?.isDynamic = false
        isGameOver = true
        scoreLabel.isHidden = true
        //background.position = (scene?.camera?.position)!
        loseLabel.position.y = (cameraNode.position.y + 80)
        loseLabel.text = "Depth: \(score)"
        HighScoreLabel.position.y = (cameraNode.position.y + 120)
        restartButton.position.y = cameraNode.position.y
        MainMenuButton.position.y = cameraNode.position.y
        background.isHidden = false
        loseLabel.isHidden = false
        HighScoreLabel.isHidden = false
        restartButton.isHidden = false
        MainMenuButton.isHidden = false
        tapCount = 0
        playerColourBlend = 0.1
        
        if score >= UserDefaults().integer(forKey: "HIGHSCORE")
        {
            saveHighScore()
        }
        
        let move = SKAction.move(to: node.position, duration: 0.25)
        let scale = SKAction.scale(to: 0.0001, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, scale, remove])
        
        player.run(sequence) { [weak self] in
            if (!((self?.player.parent) != nil))
            {
                self?.backgroundMusic?.stop()
                self?.LoseMusic?.play()
            }
        }
    }
    
    func playerCollided(with node: SKNode){
        if (node.physicsBody?.categoryBitMask == CollisionTypes.fire.rawValue) {
            SetDeathScreen(node)
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.wall.rawValue {
            if let action = player.action(forKey: "hotSurface")
            {
                action.speed = 0
            }
            tapCount = 0
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.hotSurface.rawValue {
            let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1.2), duration: 1.0)
            hotSurface.speed = 1
            player.run(hotSurface, withKey: "hotSurface")
            playerColourBlend += 0.2
            print(playerColourBlend)
            if(player.colorBlendFactor >= 1)
            {
                SetDeathScreen(node)
            }
        } else if node.name == "Wall" {
            //Reset SKAction Nodes
            if let action = player.action(forKey: "hotSurface")
            {
                action.speed = 0
            }
        }
    }

    public func preLoadTextures()
    {
        //Figure a way to preload textures into an array and preload them into memory
        //and if the for loop is the issue like it hasnt completed the level yet then keep the level in memory?
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
        let VolAltHalfCentre = SKTexture(imageNamed: "volcanoAltHalfMid")
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
                case "w":
                    //load Left Platform
                    createTextureTile(VolAltHalfCentre, name: "VolAltPlatformCentre", position: position, CollisionType: CollisionTypes.wall)
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
        if(player.position.y <=  tempPlayerPos - 100)
        {
            tempPlayerPos = player.position.y
            score += 1
        }
        if(isCameraReset)
        {
            if(cameraNode.position.y >= 207)
            {
                isCameraReset = false
                player.physicsBody?.isDynamic = true
            }
            else
            {
                player.physicsBody?.isDynamic = false
                cameraNode.position.y += 5
                scene?.camera = cameraNode
            }
        }
        if let accelerometerData = motionManager?.accelerometerData
        {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -16, dy: -9.8)
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

            cameraNode.position.y -=  cameraNode.position.y - player.position.y
            resetCameraSpeed += cameraNode.position.y - player.position.y
            scene?.camera = cameraNode
        }
        scene?.camera = cameraNode
        //Set the position of the score with the scene camera so it moves with it
        scoreLabel.position.y = (scene?.camera?.position.y)! + 160
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            let node = atPoint(position)
            print(node.position)
            if node.name == "RestartButton"
            {
                score = 0
                LoseMusic?.stop()
                backgroundMusic?.play()
                restartButton.isHidden = true
                background.isHidden = true
                MainMenuButton.isHidden = true
                loseLabel.isHidden = true
                HighScoreLabel.isHidden = true
                scoreLabel.isHidden = false
                isGameOver = false
                isCameraReset = true
                createPlayer()
                tempPlayerPos = player.position.y
            } else if node.name == "MainMenuButton"
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
            player.physicsBody!.applyImpulse(CGVector(dx: 1, dy: applyYimpulse))
            tapCount += 1
        }
    }
}
