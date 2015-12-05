//
//  SheepNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 27.11.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit


enum SheepType {
    
    case Regular
    case Left
    case Center
    case Right
    
    static func randomSheepType() -> SheepType {
        
        var types = [SheepType]()

        types << .Regular
        types << .Left
        types << .Center
        types << .Right
        
        let randTypeInt = Int.random(min:1, max:3)
        
        return types[randTypeInt]
    }
}

class SheepNode: SKSpriteNode {
    
    
    var sheepType:SheepType!;
    private var dustEmitterNode = SKEmitterNode(fileNamed: EffectFileName.AfterSheepDust)
    
    init(sheepType:SheepType, position:CGPoint) {
        
        let texture = SKTexture(imageNamed: TextureFileName.SheepImage)
        
        super.init(texture: texture, color: UIColor.clearColor(), size: SheepSize)
        
        name = "Sheep"
        anchorPoint = CGPointMake(0.5, 0.5)
        self.position = position
        zPosition = 6
        
        physicsBody = addPhysicsBodyToFence()
        physicsBody!.pinned = false
        physicsBody!.dynamic = true
        physicsBody!.allowsRotation = true
        physicsBody!.density = 0.1
        physicsBody!.restitution =  0.1
        physicsBody!.linearDamping =  0.3
        physicsBody!.angularDamping =  0.7
        
        physicsBody!.usesPreciseCollisionDetection = true
        
        physicsBody!.categoryBitMask = PhysicsCategory.Sheep
        physicsBody!.contactTestBitMask = PhysicsCategory.LeftGate | PhysicsCategory.RightGate | PhysicsCategory.Fence
        physicsBody!.collisionBitMask = PhysicsCategory.LeftGate | PhysicsCategory.RightGate | PhysicsCategory.Fence | PhysicsCategory.Sheep
        
        self.sheepType = sheepType;
        
        addArrowOnSheep()
        self.addDustForRunningSheep()

    }
    
    
    init(color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addPhysicsBodyToFence() -> SKPhysicsBody{

        let sheepBodySize = CGSizeMake(self.size.width - 10, self.size.height - 10)
        let sheepBodyPath = CGPathCreateWithEllipseInRect(CGRectMake(-sheepBodySize.width / 2, -sheepBodySize.height / 2, sheepBodySize.width, sheepBodySize.height), nil)
        let sheepBody = SKPhysicsBody(polygonFromPath: sheepBodyPath)

        return sheepBody;
    }
    
    
    private func addArrowOnSheep(){
        
        switch self.sheepType!{
        
        case .Left:
            createArrowNode(TextureFileName.LeftArrowImage)
        case .Center:
            createArrowNode(TextureFileName.CenterArrowImage)
        case .Right:
            createArrowNode(TextureFileName.RightArrowImage)
        default:
            break
        }
    }
    
    
    private func createArrowNode(imageNamed:String) -> SKSpriteNode{
    
        let arrowNode = SKSpriteNode(imageNamed: imageNamed)
        arrowNode.anchorPoint = CGPointMake(0.5, 0.4)
        arrowNode.size = ArrowSize
        arrowNode.zPosition = 1
        
        self.addChild(arrowNode)
        
        return arrowNode
    }
    
    private func addDustForRunningSheep(){
        
        dustEmitterNode!.position = CGPoint(x: 0, y: 10)
        dustEmitterNode!.resetSimulation()
        //dustEmitterNode!.zPosition = zPosition
        self.addChild(dustEmitterNode!)
    }

}
