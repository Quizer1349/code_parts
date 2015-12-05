//
//  MapInterfaceController.swift
//  MyCarRadar
//
//  Created by Alex Sklyarenko on 16.09.15.
//  Copyright © 2015 itinarray. All rights reserved.
//

import WatchKit
import Foundation


class MapInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var mapView: WKInterfaceMap!
    
    var carLatitude:Double! = 0
    var carLongitude:Double! = 0
    
    let lastCarLocationDic:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("lastKnowCarLocation") as! NSDictionary
    var lastCarLocation:CLLocation? = nil
    
    /// Location manager to request authorization and location updates.
    let manager = CLLocationManager()
    
    /// Flag indicating whether the manager is requesting the user's location.
    var isRequestingLocation = false
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        manager.delegate = self
        
        manager.distanceFilter = kCLDistanceFilterNone;
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        lastCarLocation = CLLocation(latitude: lastCarLocationDic["lat"] as! CLLocationDegrees, longitude: lastCarLocationDic["long"] as! CLLocationDegrees)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    /// MARK - CLLocationManagerDelegate Methods
    
    /**
    When the location manager receives new locations, display the latitude and
    longitude of the latest location and restart the timers.
    */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.isRequestingLocation = true
            
            
            self.mapView.removeAllAnnotations()
            
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let coordRegion = MKCoordinateRegionMake((locations.last?.coordinate)!, span)
            self.mapView.setRegion(coordRegion)
            
            self.mapView.addAnnotation((locations.last?.coordinate)!, withPinColor: .Green)
            
            self.mapView.addAnnotation(self.lastCarLocation!.coordinate, withPinColor: .Red)
                        
            self.carLatitude = locations.last?.coordinate.latitude
            self.carLongitude = locations.last?.coordinate.longitude
            
        }
    }


    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
}
