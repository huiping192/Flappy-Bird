//
//  GameScene.swift
//  FlappyBird
//
//  Created by Huiping Guo on 2019/12/12.
//  Copyright © 2019 Huiping Guo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // view object
    var bird = SKSpriteNode()
    let birdAtlas = SKTextureAtlas(named:"player")
    var birdSprites = [SKTexture]()

        
    
    // action
    var repeatActionbird = SKAction()
    
    
    // state
    var gameStarted = false
    var birdIsDied = false
    
    
    // timer
    var counterLbl = SKLabelNode()

    var countdown = 10 {
        didSet {
            counterLbl.text = "\(countdown)"
        }
    }
    var timer: Timer?
    
    
    // score
    var score = 0 {
        didSet {
            scoreLbl.text = "\(score)"
        }
    }
    var scoreLbl = SKLabelNode()
    
    // other
    let objetctFactory = ObjectFactory()

    var moveAndRemove = SKAction()

    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    func makeCountdown() {
        self.countdown -= 1
        
        if self.countdown <= 0 {
            self.gameOver()
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            gameStarted = true
            startGame()
            return
        }
        
        if !birdIsDied {
            doBirdFly()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted && !birdIsDied {
            enumerateChildNodes(withName: "background", using: ({
                (node, error) in
                let bg = node as! SKSpriteNode
                bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                }
            }))
        }
    }
}

// 衝突
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == CollisionBitMask.bird && bodyB.categoryBitMask == CollisionBitMask.ground {
            //gameOver()
            return
        }
        
        if bodyA.categoryBitMask == CollisionBitMask.ground && bodyB.categoryBitMask == CollisionBitMask.bird {
            //gameOver()
            return
        }
        
        
        if bodyA.categoryBitMask == CollisionBitMask.bird && bodyB.categoryBitMask == CollisionBitMask.flower {
            addScore()
            bodyB.node?.removeFromParent()
            return
        }
        
        if bodyA.categoryBitMask == CollisionBitMask.flower && bodyB.categoryBitMask == CollisionBitMask.bird {
            addScore()
            bodyA.node?.removeFromParent()
            return
        }
         
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    private func gameOver() {
        birdIsDied = true

        self.bird.removeAllActions()
        
        enumerateChildNodes(withName: "flower", using: ({
            (node, error) in
            node.speed = 0
            self.removeAllActions()
        }))
        
        timer?.invalidate()
        
        showResult()
    }
    
    private func addScore() {
        score += 1
    }
}

extension GameScene {
    func startGame() {
        bird.physicsBody?.affectedByGravity = true

        self.bird.run(repeatActionbird)

        doBirdFly()
        
        createFlows()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.makeCountdown()
        }
    }
    
    private func createFlows() {
        let spawn = SKAction.run {
            
            let a = Int.random(in: 20 ..< Int(self.frame.maxY - 20))
            let flow = self.objetctFactory.createFlower(point: CGPoint(x:self.frame.maxX + 40, y: CGFloat(a)))
            self.addChild(flow)
            
            flow.run(self.moveAndRemove)
        }
        
        let delay = SKAction.wait(forDuration: 1.5)
        let SpawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + 40)
        let movePipes = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
        let removePipes = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([movePipes, removePipes])
    }
    
    func doBirdFly() {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        birdIsDied = false
        gameStarted = false
        score = 0
        createScene()
    }
}


extension GameScene {
    func createScene() {
        self.name = "area"
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.ground
        self.physicsBody?.collisionBitMask = CollisionBitMask.bird
        self.physicsBody?.contactTestBitMask = CollisionBitMask.bird
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        //SET UP THE BIRD SPRITES FOR ANIMATION
        birdSprites.append(birdAtlas.textureNamed("bird1"))
        birdSprites.append(birdAtlas.textureNamed("bird2"))
        birdSprites.append(birdAtlas.textureNamed("bird3"))
        birdSprites.append(birdAtlas.textureNamed("bird4"))
        
        self.bird = objetctFactory.createBird(point: CGPoint(x:self.frame.midX, y:self.frame.midY))
        self.addChild(bird)
        
        //ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animatebird = SKAction.animate(with: self.birdSprites, timePerFrame: 0.1)
        self.repeatActionbird = SKAction.repeatForever(animatebird)
        
        scoreLbl = objetctFactory.createScoreLabel(point: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6))
        scoreLbl.text = "\(score)"
        self.addChild(scoreLbl)
        
        
        counterLbl = objetctFactory.createCounterLabel(point: CGPoint(x: self.frame.width - 50, y: self.frame.height - 30))
        counterLbl.text = "\(countdown)"
        self.addChild(counterLbl)
    }
    
    
    func showResult() {
        
    }
}
