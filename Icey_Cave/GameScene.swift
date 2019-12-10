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
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    public var storedLevel: GameScene!
    public var isPlayerDead = false

    private var MainMenuScene: MainMenu!
    private var motionManager: CMMotionManager?
    private var RestartScene = SKScene()
    private var backgroundMusic: AVAudioPlayer?
    private var LoseMusic: AVAudioPlayer?
    
    private var player: SKSpriteNode!
    private var background: SKSpriteNode!

    private var moveFire: Array<SKSpriteNode> = Array()
    private var cameraNode = SKCameraNode()
    private var scoreLabel: SKLabelNode!
    private var restartButton: SKLabelNode!
    private var MainMenuButton: SKLabelNode!
    private var loseLabel: SKLabelNode!
    
    private var HighScoreLabel: SKLabelNode!
    private var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    
    private var isGameOver = false
    private var isCameraReset = false
    
    private var tempPlayerPos = CGFloat(0)
    private var playerColourBlend = CGFloat(0.1)
    private var applyYimpulse = CGFloat(5)
    private var resetCameraSpeed = CGFloat(8)
    private let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1), duration: 2.0)
    
    private var tapCount = 0
    private var score = 0 {
    didSet {
        scoreLabel.text = "\(score)ft"
        }
    }
    
    override func sceneDidLoad() {
        //Gets the app delegate in the application and does it on the main thread
        DispatchQueue.main.async { [weak self] in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.gameScene = self
        }
                
        UserDefaults().set(0, forKey: "HIGHSCORE") //Initally sets the highscore to 0
        
        motionManager = CMMotionManager() //Gets the CMMotionManger for Acceleromemter
        motionManager?.startAccelerometerUpdates() //Starts checking for updated of accelermeter
        
        //Load the mp3 file into a AVAudioPlayer then preloads it and play the audio
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
        //Gets called everytime the scene is moved into the SKView and Resets the scene
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
    
    func SetGamePaused(_ isPaused: Bool)
    {
        isGameOver = isPaused
    }
    
    func createSKLabel(_ node: SKLabelNode, name: String, text: String, fontSize: Int , position: CGPoint, isHidden: Bool)
    { //Creates SKLabels
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
        //Checks the player with collision of other nodes
        if (nodeA == player){
            print("hit")
            playerCollided(with: nodeB)
        } else if (nodeB == player){
            playerCollided(with: nodeA)
        }
    }
    
    func createPlayer() { //Loads the SKSPrite and contactTestBitMask for collisions
        player = SKSpriteNode(imageNamed: "snowBall")
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
    
    func createCameraNode() { //Creates a cameraNode sets the scene camera to it
        cameraNode.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
    }
    
    public func createRestartMenu() { //Creates all the SKLabels/SpriteNodes and adds to scene
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
        
    func saveHighScore() { //Using User Defaults set the highscore with the value score
        UserDefaults.standard.set(score, forKey: "HIGHSCORE")
        HighScoreLabel.text = "High Score: \(UserDefaults().integer(forKey: "HIGHSCORE"))"
    }
    
    func SetDeathScreen(_ node: SKNode)
    {//When the player dies Load the death screen, score, restart and back to main menu
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
        
        /*Checks if the players current score is greater or equal to UserDefaults HighScore
        if so set it.*/
        if score >= UserDefaults().integer(forKey: "HIGHSCORE")
        {
            saveHighScore()
        }
        
        let move = SKAction.move(to: node.position, duration: 0.25)
        let scale = SKAction.scale(to: 0.0001, duration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, scale, remove])
        //Moves the player and decreaes the scale then removes the player node
        player.run(sequence) { [weak self] in //Runs the sequence
            if (!((self?.player.parent) != nil))
            {
                self?.backgroundMusic?.stop()
                self?.LoseMusic?.prepareToPlay()
                self?.LoseMusic?.play()
            }
        }
    }
    
    func playerCollided(with node: SKNode){ //Checks for player collision
        if (node.physicsBody?.categoryBitMask == CollisionTypes.fire.rawValue) {
            SetDeathScreen(node) //if the player collides with fire kill the player
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.wall.rawValue {
            //Reset SKAction Nodes
            if let action = player.action(forKey: "hotSurface")
            {
                action.speed = 0
            }
            tapCount = 0 //If the player collide with the wall/floor reset the jump count
        } else if node.physicsBody?.categoryBitMask == CollisionTypes.hotSurface.rawValue {
            //if the player collides with hot surface then slowly the player gets redder
            let hotSurface = SKAction.colorize(with: UIColor.red, colorBlendFactor: CGFloat(1.2), duration: 1.0)
            hotSurface.speed = 1
            player.run(hotSurface, withKey: "hotSurface")
            playerColourBlend += 0.2
            
            if(player.colorBlendFactor >= 1) //if the colourBlend of red hits 1 the player dies
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
    
    public func loadLevel() { //Load the level from a txt file
        //Gets the levelURL in the project
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else { fatalError("Could not find level1.txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not find level1.txt in the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        
        var texturesArray: Array<SKTexture> = Array()
        //Addes all the SKTextures to texturesArray
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

        //Preloads the array of SKTextures, then creates the level
        SKTexture.preload(texturesArray) {
        var indexOfFire = 0
        for (row, line) in lines.enumerated() {
            var isEndofLine = false
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (24 * column), y: (-24 * row) + 414)
                //Create the textures and set the position of where they are in the txt file
                switch(letter)
                {//letters like "x" are used for the walls and is used to create a level
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
                {//If true continue onto the next row
                    isEndofLine = false
                    continue
                }
            }
        }
    }
    
    func createRectTile(_ textureImg: SKTexture, name: String, position: CGPoint, CollisionType: CollisionTypes) { //Creates a SKSprite node with rectangle physicsBody
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
    
    func createNodeTexture(_ node: SKSpriteNode, name: String, position: CGPoint, CollisionType: CollisionTypes) {//Used for the Move Fire that passes in a SKNode and sets physicsBody
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
        //Creates a SKSprite node with more expensive texture collision physicsBody
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
        guard isGameOver == false else { return } //if isGameOver is true stop updating
        
        if(player.position.y <=  tempPlayerPos - 100)
            //Checks if the player has moved enough downwards and if so add 1 to the score
        {
            tempPlayerPos = player.position.y
            score += 1
        }
        if(isCameraReset) //if the cameraReset is true move the cameraNode back to the start
        {
            if(cameraNode.position.y >= 207)
            { //Checks once the cameraNode is back at the top of the level
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
        /*if the motionManager has accelermemterData set the phsyicsworld gravity
        *and move the player in the y direction depending of where the device is tilting*/
        if let accelerometerData = motionManager?.accelerometerData
            {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -16, dy: -9.8)
            }
        
        for moveFireIndex in moveFire //Goes through all of the moveFire Nodes
            {
                if(moveFireIndex.position.x <= 72)
                { //if at the leftside of the screen then moves the node to 790 in the x axis
                    moveFireIndex.run(SKAction.moveTo(x: 790, duration: 1.5))
                } //if at the rightside of the screen then moves the node to 71 in the x axis
                else if(moveFireIndex.position.x >= 789)
                {
                    moveFireIndex.run(SKAction.moveTo(x: 71, duration: 1.5))
                }
            }
        
            if(player.position.y <= cameraNode.position.y)
            {//Moves the cameraNode to follow the player position if it goes below the cameraNode
                cameraNode.position.y -=  cameraNode.position.y - player.position.y
                resetCameraSpeed += cameraNode.position.y - player.position.y
                scene?.camera = cameraNode
            }
            scene?.camera = cameraNode //Sets the scene camera to the cameraNode
            //Set the position of the score with the scene camera so it moves with it
            scoreLabel.position.y = (scene?.camera?.position.y)! + 160
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            let node = atPoint(position)
            if node.name == "RestartButton"
            { //Gets position of the touch and if its the restartbutton node restart the game
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
              {//if the main menu button is pressed, stop music and load the MainMenu Scene
                    score = 0
                    LoseMusic?.stop()
                    scene?.camera = cameraNode
                    tempPlayerPos = player.position.y
                    isPlayerDead = false
                    
                    if let view = self.view {
                    MainMenuScene = MainMenu(fileNamed: "MainMenu")
                    MainMenuScene.scaleMode = .aspectFill
                    /*Passes in the preLoaded level scene instead of having to load the
                    *whole level again (Plays the GameScene instantly*/
                    MainMenuScene.SetGameScene(storedLevel)
                    let transition = SKTransition.moveIn(with: .up, duration: 1)
                    view.presentScene(MainMenuScene, transition: transition)
                    view.showsFPS = true
                }
            }
        }
        
        if(tapCount != 3 && !isCameraReset)
        {//Limits the amount of taps to jump to 3
            player.physicsBody!.applyImpulse(CGVector(dx: 1, dy: applyYimpulse))
            tapCount += 1
        }
    }
}
