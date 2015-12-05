//
//  ScoreLabelNode.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 01.12.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import SpriteKit

class ScoreLabelNode: SKLabelNode {
    
    override init() {
        
        super.init()
        
        horizontalAlignmentMode = .Center
        position = CGPoint(x: 70, y: 410)
        zPosition = 1000
        
        text = "0"
        
        fontSize = 38
        fontName = FontName.RegularFont
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
