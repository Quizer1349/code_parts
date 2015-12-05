//
//  DataManager.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class DataManager: NSObject, ChimpKitRequestDelegate {
    
    let itemListFilename:String = "places"
    
    struct Static {
        static let instance = DataManager()
    }
    
    class var sharedInstance: DataManager {
        return Static.instance
    }
    
    func getAllPlaces() -> NSArray{
        

        let placesArray: NSMutableArray = NSMutableArray()
        
        if let path = NSBundle.mainBundle().pathForResource(itemListFilename, ofType: "plist")
        {
            
            if let itemsArray = NSArray(contentsOfFile: path)
            {
                
                for item in itemsArray as! [NSDictionary]
                {
                    
                    let placeObj:Place = Place(dictionary: item)
                    placesArray.addObject(placeObj)
                }
                
            }
        }
        
        return placesArray
    }
    
    
    func signupUser(fistName fistName:String!, email:String!, latitude:Double?, longitude:Double?){
    
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: Constants.UserDefaults.isLogedKey)
        userDefaults.synchronize()
        
        if(latitude != 0 && longitude != 0 && latitude != nil && longitude != nil){
            
            let locationManager = LocationManager.sharedInstance
            locationManager.reverseGeocodeLocationUsingGoogleWithLatLon(latitude: latitude!, longitude: longitude!,
                    onReverseGeocodingCompletionHandler: { (reverseGecodeInfo, placemark, error) -> Void in
                
                        if(error == nil){
                            
                            let country:String? = reverseGecodeInfo?["country"] as? String
                            let state:String? = reverseGecodeInfo?["state"] as? String
                            let stateShort:String? = reverseGecodeInfo?["shortState"] as? String
                            let city:String? = reverseGecodeInfo?["locality"] as? String
                            
                            CurrentUser.sharedInstance.createUser(fistName: fistName, email: email, country:country, state:state, city:city, stateShort:stateShort)
                        
                        }else{
                        
                            CurrentUser.sharedInstance.createUser(fistName: fistName, email: email, country:nil, state:nil, city:nil, stateShort:nil)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.saveToParse()
                            self.subscribeToMailChimp()
                        })

            })
        }else{
            CurrentUser.sharedInstance.createUser(fistName: fistName, email: email, country:nil, state:nil, city:nil, stateShort:nil)
           
            self.saveToParse()
            self.subscribeToMailChimp()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    //MARK: - Parce.com
    private func saveToParse(){
        
        let user:CurrentUser = CurrentUser.sharedInstance
        
        if !Constants.Platform.isSimulator{
            
            /*Parse storing*/
            let installation = PFInstallation.currentInstallation()
            
            installation.setObject(user.userFistName!, forKey: Constants.Parse_com.UserFistName)
            installation.setObject(user.userEmail!, forKey: Constants.Parse_com.UserEmail)
            
            
            if(user.userCountry != nil){
                
                installation.setObject(user.userCountry!, forKey: Constants.Parse_com.UserCountry)
            }
            
            if(user.userStateShort != nil ){
                
                installation.setObject(user.userStateShort!, forKey: Constants.Parse_com.UserStateShort)
                
            }
            
            if(user.userState != nil){
                
                installation.setObject(user.userState!, forKey: Constants.Parse_com.UserState)
            }
            
            if(user.userCity != nil){
                
                installation.setObject(user.userCity!, forKey: Constants.Parse_com.UserCity)
            }

            //installation.setObject(user.userPlatform, forKey: Constants.Parse_com.UserDeviceSystem)
            installation.setObject(user.userDevice!, forKey: Constants.Parse_com.UserDeviceType)
            
            installation.saveInBackground()
        }
        
    }
    
    
    //MARK: - MailChimp
    private func subscribeToMailChimp(){
        
        let user:CurrentUser = CurrentUser.sharedInstance
        
        let emailParams:[String: String] = ["email": user.userEmail!]
        
        var userDataParams:[String: AnyObject] = ["FNAME": user.userFistName!, "platform": user.userPlatform, "device": user.userDevice!]
       
        
        if(user.userCountry != nil){

            userDataParams["country"] = user.userCountry
        }
        
        if(user.userStateShort != nil ){
            
            userDataParams["state"] = user.userStateShort
            
        }else if(user.userState != nil){
            
            userDataParams["state"] = user.userState
        }
        
        if(user.userCity != nil){
            
            userDataParams["city"] = user.userCity
        }
        
        
        let params:[NSObject: AnyObject] = ["id": Constants.MailChimp.ListID, "email":emailParams, "merge_vars": userDataParams, "double_optin" : false, "update_existing" : true];
        
        let requestMethod:String = "lists/subscribe"
        
        ChimpKit.sharedKit().callApiMethod(requestMethod, withParams: params, andDelegate: self)
    }
    
    
    //MARK: - ChimpKitRequestDelegate
    
    func ckRequestFailedWithIdentifier(requestIdentifier: UInt, andError anError: NSError!) {
        
        print("MailChimp Error - " + anError.localizedDescription)
    }
    
    func ckRequestIdentifier(requestIdentifier: UInt, didSucceedWithResponse response: NSURLResponse!, andData data: NSData!) {
        
        
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            if(jsonResult!.isKindOfClass(NSDictionary.self)){
                
                print("MailChimp Response - " + jsonResult!.description)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    
}