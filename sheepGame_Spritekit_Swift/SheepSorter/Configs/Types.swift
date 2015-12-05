//
//  Types.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 27.11.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import Foundation

struct ColorHex {
    static let BackgroundColor = "#282554"
    static let TextColor = "#e0ebed"
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Sheep: UInt32 = 0x1 << 1
    static let LeftFinish: UInt32 = 0x1 << 2
    static let CenterFinish: UInt32 = 0x1 << 3
    static let RightFinish: UInt32 = 0x1 << 4
    static let Fence: UInt32 = 0x1 << 5
    static let LeftGate: UInt32 = 0x1 << 6
    static let RightGate: UInt32 = 0x1 << 7
}

enum AxisType {
    case Both
    case X
    case Y
}

struct FontName {
    static let RegularFont = "Noteworthy-Bold"
}

struct EffectFileName {
    static let AfterSheepDust = "DustParticle.sks"
}

struct SoundFileName {
    static let BackgroundMusic = "GameMusic.mp3"
    static let Flying = "Spaceship.caf"
    static let Explosion = "Explosion.caf"
    static let Button = "ButtonTap.caf"
    static let Bonus = "MeowBonus.caf"
    static let Result = "GameResult.caf"
    static let Pop = "PopHigh.caf"
}

struct KeyForUserDefaults {
    static let SoundDisabled = "SoundDisabled"
    static let MusicDisabled = "MusicDisabled"
    static let ControlSensitivity = "ControlSensitivity"
}

struct TextureAtlasFileName {
    static let Environment = "Environment"
    static let Character = "Character"
    static let UserInterface = "UserInterface"
}


struct TextureFileName {
    
    static let Background = "sceneBackground"
    
    static let FullFence  = "fullFence"
    
    static let SheepImage = "sheep"
    
    static let LeftGateImage   = "leftGate"
    static let RightGateImage  = "rightGate"
    
    static let LeftArrowImage    = "leftArrow"
    static let CenterArrowImage  = "centerArrow"
    static let RightArrowImage   = "rightArrow"

}