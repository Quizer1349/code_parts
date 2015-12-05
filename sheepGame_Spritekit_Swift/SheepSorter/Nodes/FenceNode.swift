//
//  FenceNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 27.11.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit

class FenceNode: SKSpriteNode {
    
    init() {
        
        let texture = SKTexture(imageNamed: TextureFileName.FullFence)
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
       
        zPosition = 2
        anchorPoint = CGPointZero
        position = CGPointZero
        
        physicsBody = SKPhysicsBody(bodies: addPhysicsBodiesToFence())
        physicsBody!.restitution = 0
        physicsBody!.density = 1
        physicsBody!.dynamic = false
        
        physicsBody!.categoryBitMask = PhysicsCategory.Fence
        //physicsBody!.contactTestBitMask = PhysicsCategory.LeftGate | PhysicsCategory.RightGate | PhysicsCategory.Fence
    }
    
    
    init(color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addPhysicsBodiesToFence() -> [SKPhysicsBody]{
    
        /*Top Left Section*/
        let topLeftPBPath = UIBezierPath()
        topLeftPBPath.moveToPoint(CGPointMake(120, 460))
        topLeftPBPath.addLineToPoint(CGPointMake(120, 195))
        topLeftPBPath.addLineToPoint(CGPointMake(0, 55))
        
        let topLeftPB = SKPhysicsBody(edgeLoopFromPath: topLeftPBPath.CGPath)
        
        /*Top Right Section*/
        let topRightPBPath = UIBezierPath()
        topRightPBPath.moveToPoint(CGPointMake(200, 460))
        topRightPBPath.addLineToPoint(CGPointMake(200, 195))
        topRightPBPath.addLineToPoint(CGPointMake(320, 55))
        
        let topRightPB = SKPhysicsBody(edgeLoopFromPath: topRightPBPath.CGPath)
        
        /*Bottom Left Section*/
        let bottomLeftPBPath = UIBezierPath()
        bottomLeftPBPath.moveToPoint(CGPointMake(38, 0))
        bottomLeftPBPath.addLineToPoint(CGPointMake(120, 95))
        bottomLeftPBPath.addLineToPoint(CGPointMake(127, 85))
        bottomLeftPBPath.addLineToPoint(CGPointMake(127, 0))
        
        let bottomLeftPB = SKPhysicsBody(edgeLoopFromPath: bottomLeftPBPath.CGPath)
        
        /*Bottom Right Section*/
        let bottomRightPBPath = UIBezierPath()
        bottomRightPBPath.moveToPoint(CGPointMake(283, 0))
        bottomRightPBPath.addLineToPoint(CGPointMake(200, 95))
        bottomRightPBPath.addLineToPoint(CGPointMake(193, 85))
        bottomRightPBPath.addLineToPoint(CGPointMake(193, 0))
        
        let bottomRightPB = SKPhysicsBody(edgeLoopFromPath: bottomRightPBPath.CGPath)

        return [topLeftPB, topRightPB, bottomLeftPB, bottomRightPB];
    }
}
