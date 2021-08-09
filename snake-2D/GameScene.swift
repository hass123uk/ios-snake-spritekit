//
//  GameScene.swift
//  snake-2D
//
//  Created by Hassan Mahmud on 8/7/21.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
  static let none           : UInt32 = 0
  static let all            : UInt32 = UInt32.max
  static let border         : UInt32 = 0b1        // 1
  static let snakeHead      : UInt32 = 0b10       // 2
  static let snakeBody      : UInt32 = 0b100      // 3
}

class GameScene: SKScene {
    
    var border: SKShapeNode? = nil
    let player = SKSpriteNode(imageNamed: "player")
    let playerSpeed = 200.0
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        backgroundColor = SKColor.white
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//        physicsBody?.categoryBitMask = PhysicsCategory.border
//        physicsBody?.contactTestBitMask = PhysicsCategory.snakeHead
//        physicsBody?.collisionBitMask = PhysicsCategory.none
        
        border = SKShapeNode(rect: frame)
        border?.name = "border"
        //border?.position = CGPoint(frame.)
        //border.strokeColor = SKColor.blue
        border?.lineWidth = 10
        border?.physicsBody = SKPhysicsBody(edgeLoopFrom: border!.path!)
        border?.physicsBody?.categoryBitMask = PhysicsCategory.border
        border?.physicsBody?.contactTestBitMask = PhysicsCategory.snakeHead
        border?.physicsBody?.collisionBitMask = PhysicsCategory.none

        addChild(border!)
        
        let w = size.width * 0.10;
        player.size = CGSize(width: w, height:  w)
        //let y = size.height * 0.5
        player.position = CGPoint(x: frame.midX, y: frame.midY)

        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.snakeHead
        player.physicsBody?.contactTestBitMask = PhysicsCategory.border | PhysicsCategory.snakeBody
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(player)
        
        player.run(SKAction.repeatForever(SKAction.moveTo(x: CGFloat(10000), duration: playerSpeed)), withKey: "move")
        
        let action = #selector(self.handleSwipe(_:))
        
        let upRecognizer = UISwipeGestureRecognizer(target: self, action: action)
        let downRecognizer = UISwipeGestureRecognizer(target: self, action: action)
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: action)
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: action)
        
        upRecognizer.direction = .up
        leftRecognizer.direction = .down
        downRecognizer.direction = .left
        rightRecognizer.direction = .right
        
        view.addGestureRecognizer(upRecognizer)
        view.addGestureRecognizer(downRecognizer)
        view.addGestureRecognizer(leftRecognizer)
        view.addGestureRecognizer(rightRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        let tap2Recognizer = UITapGestureRecognizer(target: self, action: #selector(self.handle2Tap(_:)))
        tap2Recognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap2Recognizer)
    }
    
    @IBAction func handleTap(_ gestureRecognizer : UITapGestureRecognizer) {
        player.removeAllActions()
    }
    
    @IBAction func handle2Tap(_ gestureRecognizer : UITapGestureRecognizer) {
        player.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    @IBAction func handleSwipe(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }
        
        var destination: CGPoint

        switch gestureRecognizer.direction {
        case .down:
            destination = CGPoint(x: player.position.x, y: CGFloat(-10000))
            break
        case .up:
            destination = CGPoint(x: player.position.x, y: CGFloat(10000))
            break
        case .left:
            destination = CGPoint(x: CGFloat(-10000), y: player.position.y)
            break
        default:
            //Right is handled by default
            destination = CGPoint(x: CGFloat(10000), y: player.position.y)
        }
        
        player.removeAllActions()
        player.run(SKAction.repeatForever(SKAction.move(to: destination, duration: playerSpeed)), withKey: "move")
    }
    
    func snakeHitWallEnd(snake: SKSpriteNode, border: SKShapeNode) {
//        print("Snake", snake.debugDescription)
//        print("border", border.debugDescription)
                
        let borderFrame = border.calculateAccumulatedFrame()
        let minX = borderFrame.minX
        let maxX = borderFrame.maxX
        let minY = borderFrame.minY
        let maxY = borderFrame.maxY

        let snakeWidth = snake.frame.width/2
        let snakeHeight = snake.frame.height/2
        var snakeX = snake.position.x
        var snakeY = snake.position.y
    
        if snakeX < minX {
            print("left edge")
            snakeX = maxX + snakeWidth
        }
        else if snakeX > maxX {
            print("right edge")
            snakeX = minX - snakeWidth
        }
        else if snakeY < minY {
            print("top edge")
            snakeY = maxY + snakeHeight
        }
        else if snakeY > maxY {
            print("bottom edge")
            snakeY = minY - snakeHeight
        } else {
            return
        }
        
        let playerTemp: SKSpriteNode = player.copy() as! SKSpriteNode
        playerTemp.physicsBody = nil
        playerTemp.run(SKAction.sequence([
            SKAction.wait(forDuration: 10),
            SKAction.removeFromParent()
        ]))
        addChild(playerTemp)
        

        guard let currentAction = player.action(forKey: "move") else { return }
        player.removeAllActions()
        
        player.run(
            SKAction.move(to: CGPoint(x: snakeX, y: snakeY), duration: 0),
            completion: { () -> Void in
                self.player.run(currentAction, withKey: "move")
            }
        )
    }
    
    func snakeHitWall(snake: SKSpriteNode, border: SKSpriteNode) {
        let borderFrame = border.calculateAccumulatedFrame()
        let snakeFrame = snake.calculateAccumulatedFrame()
        
        print(borderFrame.minY, borderFrame.maxY, borderFrame.minX, borderFrame.maxX)
        print(snakeFrame.minY, snakeFrame.maxY, snakeFrame.minX, snakeFrame.maxX)
        
        var snakeX = snake.position.x
        var snakeY = snake.position.y
        
        if snakeFrame.minX < borderFrame.minX {
            print("left edge")
            snakeX = borderFrame.maxX + snakeFrame.width/2
        }
        else if snakeFrame.maxX > borderFrame.maxX {
            print("right edge")
            snakeX = borderFrame.minX - snakeFrame.width/2
        }
        else if snakeFrame.minY < borderFrame.minY {
            print("bottom edge")
            snakeY = borderFrame.maxY + snakeFrame.height/2
        }
        else if snakeFrame.maxY > borderFrame.maxY {
            print("top edge")
            snakeY = borderFrame.minY - snakeFrame.height/2
        } else {
            return
        }
        
        let playerTemp: SKSpriteNode = player.copy() as! SKSpriteNode
        playerTemp.physicsBody = nil
        playerTemp.run(SKAction.sequence([
            SKAction.wait(forDuration: 5),
            SKAction.removeFromParent()
        ]))
        addChild(playerTemp)
        

        guard let currentAction = player.action(forKey: "move") else { return }
        player.removeAllActions()
        
        player.run(
            SKAction.move(to: CGPoint(x: snakeX, y: snakeY), duration: 0),
            completion: { () -> Void in
                self.player.run(currentAction, withKey: "move")
            }
        )
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didEnd(_ contact: SKPhysicsContact) {
      var firstBody: SKPhysicsBody
      var secondBody: SKPhysicsBody
      if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
        firstBody = contact.bodyA
        secondBody = contact.bodyB
      } else {
        firstBody = contact.bodyB
        secondBody = contact.bodyA
      }
        
      if ((firstBody.categoryBitMask & PhysicsCategory.border != 0) &&
          (secondBody.categoryBitMask & PhysicsCategory.snakeHead != 0)) {
        if let border = firstBody.node as? SKShapeNode,
          let snakeHead = secondBody.node as? SKSpriteNode {
            snakeHitWallEnd(snake: snakeHead, border: border)
        }
      }
    }
}

