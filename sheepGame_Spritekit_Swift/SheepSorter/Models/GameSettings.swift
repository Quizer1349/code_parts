//
//  GameSettings.swift
//  SheepSorter
//
//  Created by Alex Sklyarenko on 01.12.15.
//  Copyright © 2015 Alex Sklyarenko. All rights reserved.
//

import UIKit

class GameSettings: NSObject {
    
    
    class var sharedInstance: GameSettings {
        struct Static {
            static let instance = GameSettings()
        }
        return Static.instance
    }
    
    //MARK: Music & Sound
    func isSoundEnabled() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        return userDefaults.boolForKey(KeyForUserDefaults.SoundDisabled) != true
    }
    
    
    func isMusicEnabled() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        return userDefaults.boolForKey(KeyForUserDefaults.MusicDisabled) != true
    }
    
    //MARK: Control Sensitivity
    func getControlSensitivity() -> Int{
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        guard let sesitivity = userDefaults.objectForKey(KeyForUserDefaults.ControlSensitivity) as? NSNumber else {

            return ControlSensitivityDef
        }
        
        return Int(sesitivity)
    }
    
    
    func setControlSensitivity(sesitivity:Int){
    
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSNumber(integer:sesitivity), forKey: KeyForUserDefaults.ControlSensitivity)
    }
}
