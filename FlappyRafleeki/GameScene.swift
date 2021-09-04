//
//  GameScene.swift
//  FlappyRafleeki
//
//  Created by Drew Bayles on 9/2/21.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Raphael : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var Ground = SKSpriteNode()
    private var Raphael : SKSpriteNode?
    private var wallPair = SKNode()
    private var moveAndRemove = SKAction()
    private var gameStarted = Bool()
    private var died = Bool()
    private var score = Int()
    private var restartBtn = SKLabelNode()
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var scoreLabel = SKLabelNode()
    //private var scoreLabel : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: 0, y: 0 + self.frame.height / 4)
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 200
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(3.0)
        Ground.position = CGPoint(x: 0, y: -self.frame.height/2 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Raphael
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Raphael
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        self.Raphael = self.childNode(withName: "//character") as? SKSpriteNode
        if let Raphael = self.Raphael {
            //Raphael = SKSpriteNode(imageNamed: "Raphael_1")
            //Raphael.size = CGSize(width: 300, height: 300)
            //Raphael.position = CGPoint(x: 0, y: 0)
            
            Raphael.physicsBody = SKPhysicsBody(circleOfRadius: Raphael.frame.height / 2)
            Raphael.physicsBody?.categoryBitMask = PhysicsCategory.Raphael
            Raphael.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
            Raphael.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
            Raphael.physicsBody?.affectedByGravity = false
            Raphael.physicsBody?.isDynamic = true
            
            Raphael.zPosition = 2
        }
        
        
        
        //Raphael.run(SKAction.move(by: CGVector(dx: 4, dy: 0), duration: 0.5))
        //Raphael.run(SKAction.move(by: CGVector(dx: -4, dy: 0), duration: 0.5))
        
//        let raphaelUp = SKAction.run({
//            //() in
//            SKAction.move(by: CGVector(dx: 0, dy: 800), duration: 0.5)
//        })
//        let raphaelDown = SKAction.run({
//            //() in
//            SKAction.move(by: CGVector(dx: 0, dy: -800), duration: 0.5)
//        })
//        let hoverAction = SKAction.sequence([raphaelUp, raphaelDown])
//        let hoverActionForever = SKAction.repeatForever(hoverAction)
//        self.run(hoverActionForever)
    }
    
    override func sceneDidLoad() {
        createScene()
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        /*
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        */
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height: self.frame.height)
        scoreNode.position = CGPoint(x: self.frame.width, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Raphael
        
        wallPair = SKNode()
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: 1500)
        btmWall.position = CGPoint(x: self.frame.width, y: -1500)
        
        topWall.zRotation = CGFloat(Double.pi)
        
        topWall.setScale(2.0)
        btmWall.setScale(2.0)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Raphael
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Raphael
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Raphael
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Raphael
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomNumber = CGFloat(arc4random_uniform(1300)) - 650
        wallPair.position.y = wallPair.position.y + randomNumber
        
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    func createBtn() {
        //restartBtn = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 400, height: 200))
        restartBtn = SKLabelNode(text: "Reset")
        restartBtn.position = CGPoint(x: 0, y: 0)
        restartBtn.zPosition = 5
        restartBtn.fontSize = 200
        self.addChild(restartBtn)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Raphael ||
            firstBody.categoryBitMask == PhysicsCategory.Raphael && secondBody.categoryBitMask == PhysicsCategory.Score {
            score += 1
            scoreLabel.text = "\(score)"
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Raphael ||
            firstBody.categoryBitMask == PhysicsCategory.Raphael && secondBody.categoryBitMask == PhysicsCategory.Wall {
            died = true
            createBtn()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "FadeOut")!, withKey: "fadeOut")
        }

        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
            let location = t.location(in: self)
            if died == true {
                if restartBtn.contains(location) { restartScene() }
            }
        }
        
        if gameStarted == false {
            
            gameStarted = true
            
            if let Raphael = self.Raphael {
                Raphael.physicsBody?.affectedByGravity = true
            }
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 1.3)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width*2)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.0016 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            if let Raphael = self.Raphael {
                Raphael.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Raphael.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 6000))
            }
        }
        else {
            
            if died == true {
                
            }
            else {
                if let Raphael = self.Raphael {
                    Raphael.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    Raphael.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 4000))
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
