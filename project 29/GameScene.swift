//
//  GameScene.swift
//  project 29
//
//  Created by Kristoffer Eriksson on 2020-12-01.
//

import SpriteKit

enum CollisionType: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var viewController: GameViewController?
    var buildings = [BuildingNode]()
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    var player1Label: SKLabelNode!
    var player1Score = 0 {
        didSet{
            player1Label.text = "Player1: \(player1Score)"
        }
    }
    var player2Label: SKLabelNode!
    var player2Score = 0 {
        didSet{
            player2Label.text = "Player1: \(player2Score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        addBasicElements()
        createBuildings()
        createPlayers()
        
        if player1Score > 2 {
            endGame(winner: "player 1")
        } else if player2Score > 2 {
            endGame(winner: "player 2")
        }
        
        physicsWorld.contactDelegate = self
        randomWind()
        
    }
    
    func randomWind(){
        
        let windX = Int.random(in: -5...5)
        
        physicsWorld.gravity.dx = CGFloat(windX)
        physicsWorld.gravity.dy = -9.8
        
        let windLabel = SKLabelNode(fontNamed: "chalkduster")
        windLabel.position = CGPoint(x: 513, y: 600)
        windLabel.zPosition = 2
        windLabel.fontSize = 15
        
        if windX < 0 {
            windLabel.text = "wind is: \(windX)m/s West"
        } else {
            windLabel.text = "wind is: \(windX)m/s East"
        }
        
        addChild(windLabel)
        
    }
    
    func endGame(winner: String){
        
        viewController?.angleSlider.isHidden = true
        viewController?.angleLabel.isHidden = true
        viewController?.velocitySlider.isHidden = true
        viewController?.velocityLabel.isHidden = true
        viewController?.launchButton.isHidden = true
        viewController?.playerNumber.isHidden = true
        
        buildings.removeAll()
        
        let endScreen = SKLabelNode(fontNamed: "chalkduster")
        endScreen.position = CGPoint(x: 512, y: 650)
        endScreen.text = "GAME OVER"
        endScreen.fontSize = 44
        endScreen.fontColor = .red
        endScreen.zPosition = 5
        addChild(endScreen)
        
        let endScore = SKLabelNode(fontNamed: "chalkduster")
        endScore.position = CGPoint(x: 512, y: 550)
        endScore.text = "Winner is: \(winner) with 3 points!"
        endScore.fontSize = 40
        
        endScore.fontColor = .red
        endScore.zPosition = 4
        addChild(endScore)
        
    }
    
    func addBasicElements(){
        player1Label = SKLabelNode(fontNamed: "chalkduster")
        player1Label.text = "Player 1: \(player1Score)"
        player1Label.zPosition = 2
        player1Label.fontSize = 26
        player1Label.position = CGPoint(x: 130, y: 650)
        addChild(player1Label)
        
        player2Label = SKLabelNode(fontNamed: "chalkduster")
        player2Label.text = "Player 2: \(player2Score)"
        player2Label.zPosition = 2
        player2Label.fontSize = 26
        player2Label.position = CGPoint(x: 900, y: 650)
        addChild(player2Label)

    }
    
    func createBuildings(){
        var currentX : CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    func launch(angle: Int, velocity: Int){
        
        //forgot about 10.0
        let speed = Double(velocity) / 10.0
        let radians = deg2rad(degrees: angle)
        
        //remove from memory
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        
    }
    
    func createPlayers(){
        
        //player1Label.text = "Player 1: 0"
        //player2Label.text = "Player 2: 0"
        
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 4)
        player1.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        //makes the player stand atop the building and not on half
        let playerOneBuilding = buildings[1]
        player1.position = CGPoint(x: playerOneBuilding.position.x, y: playerOneBuilding.position.y + ((playerOneBuilding.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 4)
        player2.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        let playerTwoBuilding = buildings[buildings.count - 2]
        player2.position = CGPoint(x: playerTwoBuilding.position.x, y: playerTwoBuilding.position.y + ((playerTwoBuilding.size.height + player2.size.height) / 2))
        addChild(player2)
    }
   
    func deg2rad(degrees: Int) -> Double {
        //forgot about Double.pi
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody
        let secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else {return}
        guard let secondNode = secondBody.node else {return}
        
        if firstNode.name == "banana" && secondNode.name == "building"{
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1"{
            destroy(player: player1)
            player2Score += 1
        }
        if firstNode.name == "banana" && secondNode.name == "player2"{
            destroy(player: player2)
            player1Score += 1
        }
    }
    
    func destroy(player: SKSpriteNode){
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer"){
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        //loads a new scene / game
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
    
            newGame.player1Label = self.player1Label
            newGame.player2Label = self.player2Label
            
            newGame.player1Score = self.player1Score
            newGame.player2Score = self.player2Score

            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint){
        guard let building = building as? BuildingNode else {return}
        
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding"){
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func changePlayer(){
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else {return}
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}
