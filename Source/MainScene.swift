import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    var gameOver = false
    weak var restartButton : CCButton!
    weak var hero: CCSprite!
    
    weak var ground1: CCSprite!
    weak var ground2: CCSprite!
    var grounds = [CCSprite]()  // initializes an empty array
    
    var sinceTouch : CCTime = 0
    
    var scrollSpeed : CGFloat = 80
    
    weak var gamePhysicsNode : CCPhysicsNode!
    
    var obstacles : [Obstacle] = []
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 160
    weak var obstaclesLayer : CCNode!
    
    func didLoadFromCCB() {
        gamePhysicsNode.collisionDelegate = self
        
        userInteractionEnabled = true
        grounds.append(ground1)
        grounds.append(ground2)
        
        // spawn the first obstacles
        for i in 1...3 {
            spawnNewObstacle()
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (gameOver == false) {
            hero.physicsBody.applyImpulse(ccp(0, 400))
            hero.physicsBody.applyAngularImpulse(10000)
            sinceTouch = 0
        }
    }    
    
    override func update(delta: CCTime) {
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)

        
        sinceTouch += delta
        hero.rotation = clampf(hero.rotation, -30, 90)
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
            
        }
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
            for obstacle in obstacles.reverse() {
                let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
                let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
                
                // obstacle moved past left side of screen?
                if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                    obstacle.removeFromParent()
                    obstacles.removeAtIndex(find(obstacles, obstacle)!)
                    
                    // for each removed obstacle, add a new one
                    spawnNewObstacle()
                }
            }
        }
        
    }//update
  
    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        triggerGameOver()
        return true
    }
    
    func restart() {
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    func triggerGameOver() {
        if (gameOver == false) {
            gameOver = true
            restartButton.visible = true
            scrollSpeed = 0
            hero.rotation = 90
            hero.physicsBody.allowsRotation = false
            
            // just in case
            hero.stopAllActions()
            
            let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.2, position: ccp(0, 4)))
            let moveBack = CCActionEaseBounceOut(action: move.reverse())
            let shakeSequence = CCActionSequence(array: [move, moveBack])
            runAction(shakeSequence)
        }
        
    }
}



