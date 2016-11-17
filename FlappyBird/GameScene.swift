//
//  GameScene.swift
//  FlappyBird
//
//  Created by Greg Mor Bacskai on 10/11/16.
//  Copyright © 2016 bacskai. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gamePlay = false
    var gameOver = false
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    var timer = Timer()
    var gameOverNode = SKSpriteNode()
    
    enum ColliderType : UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setUpGame()
    }
    
    func setUpGame(){
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBgBack = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let makeBgAnimated = SKAction.repeatForever(SKAction.sequence([moveBgAnimation, shiftBgBack]))
        
        var i:CGFloat = 0
        
        while i<3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            
            bg.zPosition = -2
            bg.run(makeBgAnimated)
            self.addChild(bg)
            i+=1
        }
        
        
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        self.addChild(bird)
        
        //ground
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        self.addChild(ground)
        
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        //sky
        let sky = SKNode()
        sky.position = CGPoint(x: self.frame.midX, y: self.frame.height/2)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        sky.physicsBody!.isDynamic = false
        self.addChild(sky)
        
        //scoreLabel
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 50
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 10-self.frame.width/2+scoreLabel.frame.width/2, y: self.frame.size.height/2 - 60)
        scoreLabel.physicsBody?.isDynamic = false
        self.addChild(scoreLabel)

    }
    
    func spawnPipes(){
        //gap to fly through
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        //top pipe
        let pipeTextureTop = SKTexture(imageNamed: "pipe1.png")
        let pipeTop = SKSpriteNode(texture: pipeTextureTop)
        pipeTop.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTextureTop.size().height/2 + gapHeight/2 + pipeOffset)
        
        pipeTop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTextureTop.size().width, height: pipeTextureTop.size().height))
        pipeTop.physicsBody!.isDynamic = false
        
        pipeTop.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeTop.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeTop.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        pipeTop.zPosition = -1
        self.addChild(pipeTop)
        
        //bottom pipe
        let pipeTextureBottom = SKTexture(imageNamed: "pipe2.png")
        let pipeBottom = SKSpriteNode(texture: pipeTextureBottom)
        pipeBottom.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTextureBottom.size().height/2 - gapHeight/2 + pipeOffset)
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeBottom.size.width, height: pipeBottom.size.height))
        pipeBottom.physicsBody!.isDynamic = false
        
        pipeBottom.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipeBottom.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipeBottom.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        
        pipeBottom.zPosition = -1
        self.addChild(pipeBottom)
        
        //pipe movement
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        //different speed at bottom? :)
        pipeTop.run(moveAndRemovePipes)
        pipeBottom.run(moveAndRemovePipes)
        
        //gap to keep score
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width + pipeTop.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeBottom.size.width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(movePipes)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(gameOver == false){
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = "Score: \(score)"
            }
            else{
                self.speed = 0
                gameOver = true
                timer.invalidate()
                
                let gameOverTexture = SKTexture(imageNamed: "gameOver.png")
                gameOverNode = SKSpriteNode(texture: gameOverTexture)
                gameOverNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameOverNode.setScale(3.0)
                self.addChild(gameOverNode)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(gameOver == false){
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 80))
            
            if(gamePlay == false){
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.spawnPipes), userInfo: nil, repeats: true)

                gamePlay = true
            }
        }
        else{
            gameOver = false
            gamePlay = false
            score = 0
            self.removeAllChildren()
            self.speed = 1
            setUpGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
