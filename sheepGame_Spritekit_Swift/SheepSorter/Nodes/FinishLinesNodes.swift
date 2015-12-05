//
//  LeftFinishLineNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 01.12.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit

class LeftFinishLineNode: SKShapeNode {
    
    override init() {
        
        super.init()
        
        // Draw Path
        let leftFinishPath = UIBezierPath()
        leftFinishPath.moveToPoint(CGPointMake(3, 55))
        leftFinishPath.addLineToPoint(CGPointMake(3, 3))
        leftFinishPath.addLineToPoint(CGPointMake(38, 3))
        
        self.path = leftFinishPath.CGPath
        
        // Fill
        fillColor = UIColor.clearColor()
        strokeColor = UIColor.clearColor()
        
        // Physics
        physicsBody = SKPhysicsBody(polygonFromPath: leftFinishPath.CGPath)
        physicsBody!.categoryBitMask = PhysicsCategory.LeftFinish
        physicsBody!.contactTestBitMask = PhysicsCategory.Sheep
        physicsBody!.collisionBitMask = 0
        physicsBody!.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CenterFinishLineNode: SKShapeNode {
    
    override init() {
        
        super.init()
        
        // Draw Path
        let centerFinishPath = UIBezierPath()
        centerFinishPath.moveToPoint(CGPointMake(128, 3))
        centerFinishPath.addLineToPoint(CGPointMake(193, 3))
        
        self.path = centerFinishPath.CGPath
        
        // Fill
        fillColor = UIColor.clearColor()
        strokeColor = UIColor.clearColor()
        
        // Physics
        physicsBody = SKPhysicsBody(edgeChainFromPath: centerFinishPath.CGPath)
        physicsBody!.categoryBitMask = PhysicsCategory.CenterFinish
        physicsBody!.contactTestBitMask = PhysicsCategory.Sheep
        physicsBody!.collisionBitMask = 0
        physicsBody!.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class RightFinishLineNode: SKShapeNode {

    override init() {
        
        super.init()

        // Draw Path
        let rightFinishPath = UIBezierPath()
        rightFinishPath.moveToPoint(CGPointMake(283, 3))
        rightFinishPath.addLineToPoint(CGPointMake(317, 3))
        rightFinishPath.addLineToPoint(CGPointMake(317, 55))
        
        self.path = rightFinishPath.CGPath
        
        // Fill
        fillColor = UIColor.clearColor()
        strokeColor = UIColor.clearColor()
        
        // Physics
        physicsBody = SKPhysicsBody(polygonFromPath: rightFinishPath.CGPath)
        physicsBody!.categoryBitMask = PhysicsCategory.RightFinish
        physicsBody!.contactTestBitMask = PhysicsCategory.Sheep
        physicsBody!.collisionBitMask = 0
        physicsBody!.usesPreciseCollisionDetection = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
