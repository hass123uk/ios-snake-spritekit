//
//  GameScene.swift
//  snake-2D
//
//  Created by Hassan Mahmud on 8/7/21.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let snake = Snake(imageNamed: "snake")
    let border = SKShapeNode(rectOf: CGSize(width: 200, height: 100))
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        backgroundColor = SKColor.white
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        let w = size.width * 0.10;
        snake.size = CGSize(width: w, height:  w)
        snake.run(SKAction.repeatForever(SKAction.moveTo(x: CGFloat(10000), duration: snake.snakeDuration)), withKey: snake.moveActionName)
        snake.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(snake)
        
        addSwipeAction(view)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        
        let tap2Recognizer = UITapGestureRecognizer(target: self, action: #selector(handle2Tap(_:)))
        tap2Recognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap2Recognizer)
        
        let center = CGPoint(x: frame.midX, y: frame.midY)
        
        border.position = center//CGPoint(x: 50, y: frame.midY)
        border.strokeColor = SKColor.red
        border.lineWidth = 5
        addChild(border)
//
//        let second = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
//        second.position = center//CGPoint(x: frame.maxX - 50, y: frame.midY)
//        second.fillColor = SKColor.blue
//        addChild(second)
//
//        let aRect = first.frame.insetBy(dx: 10, dy: 10)
//
//        let third = SKShapeNode(rect: aRect)
//        third.position = CGPoint(x: 50, y: 50)//CGPoint(x: frame.midX, y: frame.midY)
//        third.fillColor = SKColor.purple
//        addChild(third)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if border.frame.contains(snake.frame) {
            return
        }
        
        //print("We are going all the way")
        
        let snakeFrame = snake.frame
        let borderFrame = border.frame
        
        var newX: CGFloat?
        var newY: CGFloat?
         
        let offsetX = snakeFrame.width/2
        let offsetY = snakeFrame.height/2
        
        if snakeFrame.maxX > borderFrame.maxX - offsetX {
            newX = borderFrame.minX
        }
        else if snakeFrame.minX < borderFrame.minX - offsetX {
            newX = borderFrame.maxX
        }
        else if snakeFrame.maxY > borderFrame.maxY - offsetY{
            newY = borderFrame.minY
        }
        else if snakeFrame.minY < borderFrame.minY - offsetY{
            newY = borderFrame.maxY
        }
        
        if (newX != nil) || (newY != nil) {
            print("Shit")
            let snakeTemp: SKSpriteNode = snake.copy() as! SKSpriteNode
            snakeTemp.run(SKAction.sequence([
                    SKAction.wait(forDuration: 2),
                    SKAction.removeFromParent()
                ]))
            addChild(snakeTemp)
                
            guard let currentAction = snake.action(forKey: "move") else { return }
            snake.removeAllActions()
            
            snake.run(
                SKAction.move(to: CGPoint(
                    x: newX ?? snake.position.x,
                    y: newY ?? snake.position.y
                ), duration: 0),
                completion: { () -> Void in
                    self.snake.run(currentAction, withKey: "move")
                }
            )
        }
    }
    
    func addSwipeAction(_ view: SKView) {
        let action = #selector(handleSwipe(_:))
        
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
    }
    
    
    @IBAction func handleSwipe(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state != .ended {
            return
        }
        
        var destination: CGPoint

        switch gestureRecognizer.direction {
        case .down:
            destination = CGPoint(x: snake.position.x, y: CGFloat(-10000))
            break
        case .up:
            destination = CGPoint(x: snake.position.x, y: CGFloat(10000))
            break
        case .left:
            destination = CGPoint(x: CGFloat(-10000), y: snake.position.y)
            break
        default:
            //Right is handled by default
            destination = CGPoint(x: CGFloat(10000), y: snake.position.y)
        }
        
        snake.removeAllActions()
        snake.run(SKAction.repeatForever(SKAction.move(to: destination, duration: snake.snakeDuration)), withKey: snake.moveActionName)
    }
    
    @IBAction func handleTap(_ gestureRecognizer : UITapGestureRecognizer) {
        snake.removeAllActions()
    }
    
    @IBAction func handle2Tap(_ gestureRecognizer : UITapGestureRecognizer) {
        snake.position = CGPoint(x: frame.midX, y: frame.midY)
    }
}


class Snake: SKSpriteNode {

    let snakeDuration = 200.0
    let moveActionName = "move"
    

    convenience init() {
        self.init(imageNamed: "snake")
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
