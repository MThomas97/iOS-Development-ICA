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
    
    var MainMenuScene: MainMenu!
    var storedLevel: GameScene!
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
    var isPlayerDead = false
    var isCameraReset = false
    var isMovingForward = false
    var isMovingBackwards = false
    var tempPlayerPos = CGFloat(0)
    var playerColourBlend = CGFloat(0.1)
    var tapCount = 0
    var applyYimpulse = CGFloat(5)
    var resetCameraSpeed = CGFloat(8)
    var runOnce = 0
    let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1), duration: 2.0)
    var score = 0 {
    didSet {
        scoreLabel.text = "\(score)ft"
        }
    }
    
    override func sceneDidLoad() {
        
        DispatchQueue.main.async { [weak self] in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.gameScene = self
        }
                
        UserDefaults().set(0, forKey: "HIGHSCORE")
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        let path = Bundle.main.path(forResource: "Music/WinterMusic.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.numberOfLoops = -1 //Loops forever
            backgroundMusic?.prepareToPlay()
        } catch {
            // couldn't load file
        }
                
        let Losepath = Bundle.main.path(forResource: "Music/loseMusic.mp3", ofType:nil)!
        let loseUrl = URL(fileURLWithPath: Losepath)

        do {
            LoseMusic = try AVAudioPlayer(contentsOf: loseUrl)
            LoseMusic?.numberOfLoops = -1 //Loops forever
            LoseMusic?.prepareToPlay()
        } catch {
            // couldn't load file
        }
    }
    
    override func didMove(to view: SKView) {
        isGameOver = false
        backgroundMusic?.play()
        physicsWorld.contactDelegate = self
        restartButton.isHidden = true
        background.isHidden = true
        MainMenuButton.isHidden = true
        loseLabel.isHidden = true
        HighScoreLabel.isHidden = true
        scoreLabel.isHidden = false
        cameraNode.position.y = 207
        createPlayer()
        tempPlayerPos = player.position.y
    }
    
    override func willMove(from view: SKView) {
        print("removed")
    }
    
    func SetGamePaused(_ isPaused: Bool)
    {
        isGameOver = isPaused
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
        player.physicsBody?.contactTestBitMask = CollisionTypes.hotSurface.rawValue | CollisionTypes.fire.rawValue
        addChild(player)
    }
    
    func createCameraNode() {
        cameraNode.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
        print(scene!.size)
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
    }
    
    func createRestartMenu() {
        scoreLabel = SKLabelNode(fontNamed: "Ice Caps")
        createSKLabel(scoreLabel, name: "Score", text: "0ft", fontSize: 32, position: CGPoint(x: 50, y: 20), isHidden: false)
        
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
        
    func saveHighScore() {
        UserDefaults.standard.set(score, forKey: "HIGHSCORE")
        HighScoreLabel.text = "High Score: \(UserDefaults().integer(forKey: "HIGHSCORE"))"
    }
    
    func SetDeathScreen(_ node: SKNode)
    {
        player.physicsBody?.isDynamic = false
        isGameOver = true
        isPlayerDead = true
        scoreLabel.isHidden = true
        background.position = (scene?.camera?.position)!
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
                self?.LoseMusic?.play()
                self?.backgroundMusic?.stop()
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
    
    public func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find level1.txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        //Load image files
        var texturesArray: Array<SKTexture> = Array()
        
        texturesArray.append(SKTexture(imageNamed: "Wall"))
        texturesArray.append(SKTexture(imageNamed: "Floor"))
        texturesArray.append(SKTexture(imageNamed: "underFloor"))
        texturesArray.append(SKTexture(imageNamed: "volcanoLava"))
        texturesArray.append(SKTexture(imageNamed: "volcanoLavaBelow"))
        texturesArray.append(SKTexture(imageNamed: "Fire_PixelBottom"))
        texturesArray.append(SKTexture(imageNamed: "Fire_PixelTop"))
        texturesArray.append(SKTexture(imageNamed: "Fire_PixelLeft"))
        texturesArray.append(SKTexture(imageNamed: "Fire_PixelRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltHalfLeft"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltHalfMid"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltHalfRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltLeft"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltCentre"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfCirLeft"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfCirRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoLeft"))
        texturesArray.append(SKTexture(imageNamed: "volcanoCentre"))
        texturesArray.append(SKTexture(imageNamed: "volcanoRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfLeft"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfMid"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltHalfRnd"))
        texturesArray.append(SKTexture(imageNamed: "volcanoHalfRnd"))
        texturesArray.append(SKTexture(imageNamed: "BlackLava"))
        texturesArray.append(SKTexture(imageNamed: "BlackLavaBelow"))
        texturesArray.append(SKTexture(imageNamed: "HalfCirLeft"))
        texturesArray.append(SKTexture(imageNamed: "HalfCirRight"))
        texturesArray.append(SKTexture(imageNamed: "volcanoAltFloor"))

        SKTexture.preload(texturesArray) { //Preload the array of SKTextures
        var indexOfFire = 0
        for (row, line) in lines.enumerated() {
            var isEndofLine = false
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (24 * column), y: (-24 * row) + 414)
                //Create the textures and set the position of where they are in the txt file
                switch(letter)
                {
                case "x":
                    self.createRectTile(texturesArray[0], name: "Wall", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "v":
                    self.createRectTile(texturesArray[1], name: "Floor", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "u":
                    self.createRectTile(texturesArray[2], name: "underFloor", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "l":
                    self.createTextureTile(texturesArray[3], name: "Lava", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "r":
                    self.createRectTile(texturesArray[4], name: "LavaBelow", position: position, CollisionType: CollisionTypes.fire)
                    break;
                case "f":
                    self.createTextureTile(texturesArray[5], name: "FireBottom", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "d":
                    self.createTextureTile(texturesArray[6], name: "FireTop", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "a":
                    self.createTextureTile(texturesArray[7], name: "FireLeft", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "s":
                    self.createTextureTile(texturesArray[8], name: "FireRight", position: position, CollisionType: CollisionTypes.fire)
                    break
                case "m":
                    //Create Fire that moves right to left on the floor
                    self.moveFire.append(SKSpriteNode(texture: texturesArray[5]))
                    self.createNodeTexture(self.moveFire[indexOfFire], name: "Fire", position: position, CollisionType: CollisionTypes.fire)
                    
                    indexOfFire += 1
                    break
                case "t":
                    self.createTextureTile(texturesArray[9], name: "VolAltPlatformLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "w":
                    self.createTextureTile(texturesArray[10], name: "VolAltPlatformCentre", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "y":
                    self.createTextureTile(texturesArray[11], name: "VolAltPlatformRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "b":
                    self.createRectTile(texturesArray[12], name: "VolAltTextureLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "c":
                    self.createRectTile(texturesArray[13], name: "VolAltTextureCentre", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "e":
                    self.createRectTile(texturesArray[14], name: "VolAltTextureRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "g":
                    self.createTextureTile(texturesArray[15], name: "VolAltCirLeft", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "h":
                    self.createTextureTile(texturesArray[16], name: "VolAltCirRight", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "i":
                    self.createRectTile(texturesArray[17], name: "volcanoTextureLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "j":
                    self.createRectTile(texturesArray[18], name: "volcanoTextureCentre", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "k":
                    self.createRectTile(texturesArray[19], name: "volcanoTextureRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "n":
                    self.createTextureTile(texturesArray[20], name: "volcanoRndLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "o":
                    self.createTextureTile(texturesArray[21], name: "volcanoRndCentre", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "p":
                    self.createTextureTile(texturesArray[22], name: "volcanoRndRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "q":
                    self.createTextureTile(texturesArray[23], name: "volcanoAltRnd", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "A":
                    self.createTextureTile(texturesArray[24], name: "volcanoRnd", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "B":
                    self.createTextureTile(texturesArray[25], name: "BlackLava", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "C":
                    self.createRectTile(texturesArray[26], name: "BlackLavaBelow", position: position, CollisionType: CollisionTypes.wall)
                    break
                case "D":
                    self.createTextureTile(texturesArray[27], name: "volcanoCirLeft", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "E":
                    self.createTextureTile(texturesArray[28], name: "volcanoCirRight", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case "F":
                    self.createRectTile(texturesArray[29], name: "volcanoFloor", position: position, CollisionType: CollisionTypes.hotSurface)
                    break
                case " ":
                    //this is an empty space - do nothing!
                    break;
                case "/":
                    //this is comment do nothing!
                    break;
                default:
                    break;
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
                isPlayerDead = false
                isGameOver = false
                isCameraReset = true
                createPlayer()
                tempPlayerPos = player.position.y
            } else if node.name == "MainMenuButton"
              {
                // load resources on other thread
                if let view = self.view {
                    //Load the SKScene from 'MainMenu.sks'
                    score = 0
                    LoseMusic?.stop()
                    scene?.camera = cameraNode
                    tempPlayerPos = player.position.y
                    isPlayerDead = false
                    
                    MainMenuScene = MainMenu(fileNamed: "MainMenu")
                    MainMenuScene.scaleMode = .aspectFill
                    MainMenuScene.SetGameScene(storedLevel)
                    let transition = SKTransition.moveIn(with: .up, duration: 1)
                    view.presentScene(MainMenuScene, transition: transition)
                    view.showsFPS = true
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
