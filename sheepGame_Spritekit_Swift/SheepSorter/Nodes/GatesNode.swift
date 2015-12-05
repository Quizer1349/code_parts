//
//  GatesNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 27.11.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit

enum GateSide {
    
    case Left
    case Right
}


class LeftGatesNode: SKSpriteNode{

    var side:GateSide?
    
    init(position:CGPoint){
    
        let texture = SKTexture(imageNamed: TextureFileName.LeftGateImage)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.position = position
        
        zPosition = 3
        anchorPoint = CGPointMake(0.5, 0.06)
        size = GatesSize
        
        side = .Left
        
        physicsBody = SKPhysicsBody(polygonFromPath: CGPathCreateWithRect(CGRectMake(0, 0, size.width / 4, size.height - 7), nil))
        physicsBody!.pinned = true
        physicsBody!.density = 1
        physicsBody!.restitution =  0
        physicsBody!.linearDamping = 0;
        physicsBody!.angularDamping = 0;
        physicsBody!.usesPreciseCollisionDetection = true
        
        physicsBody!.categoryBitMask = PhysicsCategory.LeftGate
        physicsBody!.contactTestBitMask = PhysicsCategory.Fence | PhysicsCategory.RightGate
        physicsBody!.collisionBitMask = PhysicsCategory.Fence | PhysicsCategory.RightGate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class RightGatesNode: SKSpriteNode{

    var side:GateSide?
    
    init(position:CGPoint){
        
        let texture = SKTexture(imageNamed: TextureFileName.RightGateImage)
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.position = position
        
        zPosition = 3
        anchorPoint = CGPointMake(0.5, 0.06)
        size = GatesSize
        
        side = .Right
        
        physicsBody = SKPhysicsBody(polygonFromPath: CGPathCreateWithRect(CGRectMake(-size.width  / 4, 0, size.width  / 4, size.height - 7), nil))
        physicsBody!.pinned = true
        physicsBody!.density = 1
        physicsBody!.restitution =  0
        physicsBody!.linearDamping = 0;
        physicsBody!.angularDamping = 0;
        physicsBody!.usesPreciseCollisionDetection = true
        
        physicsBody!.categoryBitMask = PhysicsCategory.RightGate
        physicsBody!.contactTestBitMask = PhysicsCategory.Fence | PhysicsCategory.LeftGate
        physicsBody?.collisionBitMask = PhysicsCategory.Fence | PhysicsCategory.LeftGate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



