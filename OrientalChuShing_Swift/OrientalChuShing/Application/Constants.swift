//
//  Constants.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    static let kMyCoordinatesUpdatedNotification = "kMyCoordinatesUpdatedNotification"
    
    
    /*******************************
    *                              *
    *      App Personalization     *
    *                              *
    *******************************/
    
    struct URLs {
        static let MenuUrl:NSURL! = NSURL(string: "http://m.orientalchushing.com/menu")
    }
    
    struct SettingsList {
        
        static let IsSettingsVisisble:Bool = false
        static let MenuItems:[String] = ["change language"] //Array with strings
    }
    
    struct Appearance {
        
        //static let NavBarColor:UIColor = UIColor(red:0.824,  green:0,  blue:0, alpha:1)
        static let GlobalTintColor:UIColor = UIColor(red:0.824,  green:0,  blue:0, alpha:1)
    }
    
    
    struct AppData {
        
        static let MenuMenuItems = ["Menu", "Find a Location", "Contact Us"]
        
        static let AppBusinessSite:String = "orientalchushing.com"
        static let AppBusinessPhone:String = "(613) 233-8818"
        static let AppBusinessEmail:String = "orientalchushingrestaurant@gmail.com"
        
        static let AppDistanceLimit:Float = 30000 //meters
        
        static let AppWeekDaysArray:NSArray = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    }
    
    
    struct GoogleAnalytics {
        
        static let TrackID:String = "UA-67438303-1"
        
        //screens
        static let trackSignUpScreenName = "sign up"
        static let trackMainScreenName = "menu"
        static let trackMenuWebScreenName = "menu web"
        static let trackContactUsScreenName = "contact us"
        static let trackFindLocationScreenName = "find a location"
        static let trackPlaceScreenName = "place details:"
        static let trackSettingsScreenName = "settings"
        static let trackChooseLangScreenName = "lang selection"
        static let trackPushWebScreenName = "push hyperlink"
        
        //events
        

    }
    
    struct Parse_com {
    
        static let AppID:String = "y8PgMMVMhWBdVU5KImHPGAiOLHaEna1iwXTghwE5"
        static let ClientID:String = "Z1Gk3oScPkSKnh9Nq8egIVgm4ZORXQY5E3EbSOKt"
        
        static let UserEmail:String = "email"
        static let UserFistName:String = "firstName"
        static let UserCountry:String = "country"
        static let UserState:String = "state"
        static let UserStateShort:String = "stateShort"
        static let UserCity:String = "city"
        static let UserDeviceSystem:String = "deviceType"
        static let UserDeviceType:String = "deviceSize"
        static let UserPushType:String = "pushType"
    }
    
    
    struct MailChimp {
        
        static let ApiKey:String = "578afa98aaa02f071bf2e79d1e71b854-us11"
        static let ListID:String = "f61631794f"
    }
    
    
    
    /*******************************
    *                              *
    *      System Constants        *
    *                              *
    *******************************/
    
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        static let Tmp = NSTemporaryDirectory()
    }

    
    struct Segues {
        
        static let SignUpToSettings:String = "SignUpToSettings"
        static let MainToSettings:String = "MainToSettings"
        static let MainToMenu:String = "MainToMenu"
        static let MainToPlaces:String = "MainToPlaces"
        static let MainToAboutUs:String = "MainToAboutUs"
        static let MainToContactUs:String = "MainToContactUs"
        static let PlacesToPlaceDetailes:String = "PlacesToPlaceDetailes"
        static let PlaceDetailesToMap:String = "PlaceDetailesToMap"
        static let MainToWebBrowser:String = "MainToWebBrowser"
        static let SettingsToLangChoose:String = "SettingsToLangChoose"
    }
    
    
    struct TableCells {
        
        static let MainMenuCell = "mainMenuCell"
        static let PlaceListCell = "placeListCell"
        static let WorkingHoursCell = "WorkingHoursCell"
        static let SettingsMenuItem = "SettingsMenuItem"
        static let ChooseLangCell = "ChooseLangCell"
    }
    
    
    struct ViewControllersId {
        
        static let SignUpVCId = "signUpNavVC"
        static let MainVCId = "mainNavVC"
    }
    
    struct UserDefaults {
        
        static let isLogedKey = "isUserLogedInApp"
        static let UserFirstNameKey = "userFirstName"
        static let UserEmailKey = "userEmail"
        static let UserCountryKey = "userCountry"
        static let UserStateKey = "userState"
        static let UserStateShortKey = "userStateShort"
        static let UserCityKey = "userCity"
    }
    
    struct LocalStrings{
    
        static let networkErrorTitle = "networkErrorTitle"
        static let networkErrorText = "networkErrorText"
        
        static let sendEmailErrorTitle = "sendEmailErrorTitle"
        static let sendEmailErrorText = "sendEmailErrorText"
        
        static let mailContactUsSubject = "mailContactUsSubject"
    }
    
    struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
            }()
    }
    
}

public extension NSObject{
    
    public class var classNameToString: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var classNameToString: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

extension String {
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}


