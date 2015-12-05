//
//  NetworkManager.swift
//  OrientalChuShing
//
//  Created by Alexey Sklyarenko on 12.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit
import SystemConfiguration

class NetworkManager: NSObject {
    
    
    struct Static {
        static let instance = NetworkManager()
    }
    
    class var sharedInstance: NetworkManager {
        return Static.instance
    }
    
    private override init() {
        
        super.init()
        
        
    }
    
    class func isConnectionAvailble()->Bool{
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
