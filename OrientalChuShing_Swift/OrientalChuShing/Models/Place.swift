//
//  Place.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class Place: NSObject {
   
    var title:String = ""
    var phone:String = ""
    var address:String = ""
    var email:String = ""
    
    var workingHours:Dictionary<String,String!> = Dictionary()
    
    var latitude:Double = 0
    var longitude:Double = 0
    
    
    init(dictionary: NSDictionary) {
       
        self.title = dictionary.objectForKey("title") as! String
        self.phone = dictionary.objectForKey("phone") as! String
        self.address = dictionary.objectForKey("address") as! String
        self.email = dictionary.objectForKey("email") as! String
        
        self.workingHours = dictionary.objectForKey("workingHours") as! Dictionary<String,String!>
        
        self.latitude = (dictionary.objectForKey("latitude") as! NSString).doubleValue
        self.longitude = (dictionary.objectForKey("longitude") as! NSString).doubleValue

    }
}
