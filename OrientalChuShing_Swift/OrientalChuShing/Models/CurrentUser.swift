//
//  CurrentUser.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 09.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class CurrentUser: NSObject {
   
    var userFistName:String?
    var userEmail:String?
    var userCity:String?
    var userCountry:String?
    var userState:String?
    var userStateShort:String?
    var userPlatform:String = "IOS"
    var userDevice:String?
    
    
    class var sharedInstance : CurrentUser {
        struct Static {
            static let instance : CurrentUser = CurrentUser()
        }
        return Static.instance
    }
    
    override init() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userFistName = userDefaults.stringForKey(Constants.UserDefaults.UserFirstNameKey)
        userEmail = userDefaults.stringForKey(Constants.UserDefaults.UserEmailKey)
        
        userCountry = userDefaults.stringForKey(Constants.UserDefaults.UserCountryKey)
        userState = userDefaults.stringForKey(Constants.UserDefaults.UserStateKey)
        userStateShort = userDefaults.stringForKey(Constants.UserDefaults.UserStateShortKey)
        userCity = userDefaults.stringForKey(Constants.UserDefaults.UserCityKey)
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            userDevice = "ipad"
        }else if (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            userDevice = "iphone"
        }else{
            userDevice = "unspecified"
        }
    }
    
    
    func createUser(fistName fistName:String!, email:String!, country:String?, state:String?, city:String?, stateShort:String?){
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(fistName, forKey: Constants.UserDefaults.UserFirstNameKey)
        userDefaults.setObject(email, forKey: Constants.UserDefaults.UserEmailKey)
        
        self.userFistName = fistName
        self.userEmail = email
        
        if (country != nil){
            userDefaults.setObject(country, forKey: Constants.UserDefaults.UserCountryKey)
            self.userCountry = country
        }
        
        if (state != nil){
            userDefaults.setObject(state, forKey: Constants.UserDefaults.UserStateKey)
            self.userState = state
        }
        
        if (city != nil){
            userDefaults.setObject(city, forKey: Constants.UserDefaults.UserCityKey)
            self.userCity = city
        }
        
        if(stateShort != nil){
        
            userDefaults.setObject(city, forKey: Constants.UserDefaults.UserStateShortKey)
            self.userStateShort = stateShort
        }
        
        userDefaults.synchronize()
        
    }

    
    class func isUserLoged() -> Bool{
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let result:Bool! = userDefaults.boolForKey(Constants.UserDefaults.isLogedKey)
        return result
    }
}


