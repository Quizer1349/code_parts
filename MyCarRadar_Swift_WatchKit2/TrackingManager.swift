//
//  TrackingManager.swift
//  MyCarRadar
//
//  Created by Alex Sklyarenko on 17.09.15.
//  Copyright © 2015 itinarray. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import MapKit

class TrackingManager: NSObject, CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    let motionManager:CMMotionManager = CMMotionManager()
    
    struct Notifications {
        static let DidUpdateLocation = "TrackerDidUpdateLocation"
        static let DidFailWithError = "TrackerDidFailWithError"
        static let DeniedLocationService = "DeniedLocationService"
    }
    
    class var sharedInstance: TrackingManager {
        struct Static {
            static let instance = TrackingManager()
        }
        return Static.instance
    }
    
    
    override init() {
        
        super.init()

        locationManager.delegate = self
        
        locationManager.distanceFilter = 0.01;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        
        
        if(motionManager.magnetometerAvailable){
        
            motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data, error) -> Void in

                if(error != nil){
                    print("Magnetometer ERROR - \(error?.localizedDescription)")
                }else{
                    print("Magnetometer DATA - \(data)")
                }
            })
        }
    }
    
    
    func startTracking(){
    
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .AuthorizedWhenInUse:

            locationManager.performSelector("startUpdatingLocation")
            
        case .Denied:
            break
            
        default:
            break
        }
    }
    
    
    func stopTracking(){
        
        locationManager.stopUpdatingLocation()
    }
    
    /// MARK - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(TrackingManager.Notifications.DidUpdateLocation, object: nil, userInfo: ["location":locations.last!])
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            
            if(error.code == 0){
            
                return
            }
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(TrackingManager.Notifications.DidFailWithError, object: nil, userInfo: ["error":error])
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        dispatch_async(dispatch_get_main_queue()) {
            
            switch status {
                
            case .AuthorizedWhenInUse:
                self.locationManager.performSelector("startUpdatingLocation")
                
            case .Denied:
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(TrackingManager.Notifications.DeniedLocationService, object: nil)
                
                break
                
            default:
                break
            }
        }
    }
    
    class func mapRegionForAnnotations(locations:[CLLocation]) -> MKCoordinateRegion{
    
        var minLat:Double = 90.0
        var maxLat:Double = -90.0
        var minLon:Double = 180.0
        var maxLon:Double = -180.0
        
        for location:CLLocation in locations{
        
            if ( location.coordinate.latitude  < minLat ) {minLat = location.coordinate.latitude}
            if ( location.coordinate.latitude  > maxLat ) {maxLat = location.coordinate.latitude}
            if ( location.coordinate.longitude < minLon ) {minLon = location.coordinate.longitude}
            if ( location.coordinate.longitude > maxLon ) {maxLon = location.coordinate.longitude}
        }
        
        let latDelta = maxLat - minLat
        let lonDelta = maxLon - minLon
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake((minLat + maxLat)/2.0, (minLon + maxLon)/2.0)
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(center, span)
        
        return region
    }
    
}
