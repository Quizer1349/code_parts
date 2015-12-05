//
//  BackgroundNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 27.11.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit

class BackgroundNode: SKSpriteNode {

    var imageName: String?
    
    var leftFinishBody:SKPhysicsBody!;
    var centerFinishBody:SKPhysicsBody!;
    var rightFinishBody:SKPhysicsBody!;
    
    init(imageNamed imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        
        self.imageName = imageName
        
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        zPosition = 1
        anchorPoint = CGPointZero
        
//        physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
//        physicsBody!.dynamic = false
    }
    
    init(color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
