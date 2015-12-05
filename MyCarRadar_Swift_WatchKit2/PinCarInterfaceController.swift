//
//  InterfaceController.swift
//  MyCarRadar WatchKit Extension
//
//  Created by Alex Sklyarenko on 14.09.15.
//  Copyright © 2015 itinarray. All rights reserved.
//

import WatchKit
import Foundation

class PinCarInterfaceController: WKInterfaceController {
   
    // MARK: - Properties
    @IBOutlet var mapView: WKInterfaceMap!
    
    @IBOutlet var requestLocationButton: WKInterfaceButton!
    @IBOutlet var saveLocationButton: WKInterfaceButton!
    @IBOutlet var setNewButton: WKInterfaceButton!
    @IBOutlet var radarButton: WKInterfaceButton!

    var carLatitude:Double? = nil
    var carLongitude:Double? = nil

    
    // MARK: - Localized String Convenience
    var interfaceTitle: String {
        return NSLocalizedString("Pin a Car", comment: "")
    }
    
    var requestLocationTitle: String {
        return NSLocalizedString("Pin my car", comment: "")
    }
    
    var saveTitle: String {
        return NSLocalizedString("Save", comment: "")
    }
    
    var cancelTitle: String {
        return NSLocalizedString("Reset", comment: "")
    }
    
    var radarlTitle: String {
        return NSLocalizedString("Radar", comment: "")
    }
    
    
    // MARK: - Interface Controller
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        setTitle(interfaceTitle)
        
        self.saveLocationButton.setTitle(saveTitle.uppercaseString)
        self.requestLocationButton.setTitle(requestLocationTitle.uppercaseString)
        self.setNewButton.setTitle(cancelTitle.uppercaseString)
        self.radarButton.setTitle(radarlTitle.uppercaseString)
        
        if let lastCarLocationDic:NSDictionary = (NSUserDefaults.standardUserDefaults().objectForKey("lastKnowCarLocation") as? NSDictionary){
        
            let lastCarLocation:CLLocation = CLLocation(latitude: lastCarLocationDic["lat"] as! CLLocationDegrees, longitude: lastCarLocationDic["long"] as! CLLocationDegrees)
            
            let carIcon = UIImage(named:"car_icon")
            
            self.mapView.addAnnotation(lastCarLocation.coordinate,  withImage:carIcon, centerOffset: CGPointMake((carIcon?.size.width)! / 2, (carIcon?.size.height)!))
            
            self.requestLocationButton.setHidden(true)
            self.saveLocationButton.setHidden(true)
            self.radarButton.setHidden(false)
            self.setNewButton.setHidden(false)
        }
        
    }
    
    
    override func willActivate() {
        super.willActivate()
        
        self.addObserverForTrackingManager()

        TrackingManager.sharedInstance.startTracking()
    }
    
    
    override func willDisappear() {
        super.willDisappear()
        
        self.removeObserverForTrackingManager()
    }
    
    
    // MARK: - Add/Remove Observer
    func addObserverForTrackingManager(){
    
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "trackerDidUpdateLocation:", name: TrackingManager.Notifications.DidUpdateLocation, object: nil)
        notificationCenter.addObserver(self, selector: "trackerDidFailedWithError:", name: TrackingManager.Notifications.DidFailWithError, object: nil)
        notificationCenter.addObserver(self, selector: "trackerDeniedLocationService", name: TrackingManager.Notifications.DeniedLocationService, object: nil)
    }
    

    func removeObserverForTrackingManager(){
    
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: TrackingManager.Notifications.DidUpdateLocation, object: nil)
        notificationCenter.removeObserver(self, name: TrackingManager.Notifications.DidFailWithError, object: nil)
        notificationCenter.removeObserver(self, name: TrackingManager.Notifications.DidFailWithError, object: nil)
        
    }
    
    
    // MARK: - Buttons actions
    @IBAction func requestLocation(sender: AnyObject) {
        guard TrackingManager.sharedInstance.locationManager.location != nil else {return}
        
        if let lastCarLocation:CLLocation = TrackingManager.sharedInstance.locationManager.location! {
        
            let carIcon = UIImage(named:"car_icon")
            self.mapView.addAnnotation(lastCarLocation.coordinate,  withImage:carIcon, centerOffset: CGPointMake(0, 0 - (carIcon?.size.height)! / 2))
            
            self.carLatitude = lastCarLocation.coordinate.latitude
            self.carLongitude = lastCarLocation.coordinate.longitude
            
            self.requestLocationButton.setHidden(true)
            self.saveLocationButton.setHidden(false)
            self.setNewButton.setHidden(false)
            self.radarButton.setHidden(true)
        }
        
        

    }
    

    @IBAction func saveCarLocationPressed() {
        
        let carLocationDic:NSDictionary = NSDictionary(dictionary: ["lat":self.carLatitude!, "long":self.carLongitude!]);
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(carLocationDic, forKey: "lastKnowCarLocation")
        userDefaults.synchronize()
        
        self.requestLocationButton.setHidden(true)
        self.saveLocationButton.setHidden(true)
        self.setNewButton.setHidden(false)
        self.radarButton.setHidden(false)
    }
    
    
    @IBAction func resetCarLocation() {
        
        self.requestLocationButton.setHidden(false)
        self.saveLocationButton.setHidden(true)
        self.setNewButton.setHidden(true)
        self.radarButton.setHidden(true)
    
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "lastKnowCarLocation")
        userDefaults.synchronize()
        
        self.carLatitude = nil
        self.carLongitude = nil
        
        self.mapView.removeAllAnnotations()
        
    }
    
    @IBAction func radarButtonPressed() {
    
        self.presentControllerWithName("RadarInterfaceController", context: nil)
    }
    
    // MARK: - TrackingManager Observer methods
    func trackerDidUpdateLocation(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let myLocation:CLLocation = notification.userInfo?["location"] as! CLLocation
            
            self.mapView.removeAllAnnotations()
            
            let myIcon:UIImage = UIImage(named: "target_dot_dark")!
            self.mapView.addAnnotation(myLocation.coordinate,  withImage:myIcon, centerOffset: CGPointMake(0, 0))
            
            let span = MKCoordinateSpanMake(0.001, 0.001)
            var coordRegion = MKCoordinateRegionMake(myLocation.coordinate, span)
            
            var lastCarLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
            if let lastCarLocationDic:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("lastKnowCarLocation") as? NSDictionary {
                
                lastCarLocation = CLLocation(latitude: lastCarLocationDic["lat"] as! CLLocationDegrees, longitude: lastCarLocationDic["long"] as! CLLocationDegrees)
                let carIcon = UIImage(named:"car_icon")
                self.mapView.addAnnotation(lastCarLocation.coordinate,  withImage:carIcon, centerOffset: CGPointMake(0, 0 - (carIcon?.size.height)! / 2))
                
                coordRegion = TrackingManager.mapRegionForAnnotations([myLocation, lastCarLocation])
                
            }else if (self.carLatitude != nil && self.carLongitude != nil){
                
                lastCarLocation = CLLocation(latitude: self.carLatitude!, longitude: self.carLongitude!)
                let carIcon = UIImage(named:"car_icon")
                self.mapView.addAnnotation(lastCarLocation.coordinate,  withImage:carIcon, centerOffset: CGPointMake(0, 0 - (carIcon?.size.height)! / 2))
                
                coordRegion = TrackingManager.mapRegionForAnnotations([myLocation, lastCarLocation])
            }

            
            self.mapView.setRegion(coordRegion)
        }
    }
    
    
    func trackerDidFailedWithError(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            
            let error:NSError = notification.userInfo?["error"] as! NSError
            let alertView = WKAlertAction(title: "Dissmis", style: WKAlertActionStyle.Destructive){}
            
            self.presentAlertControllerWithTitle("Error", message: error.localizedDescription, preferredStyle: .Alert, actions: [alertView])
        }
    }
    
    
    func trackerDeniedLocationService() {
        
        dispatch_async(dispatch_get_main_queue()) {

            
            let alertHandler:WKAlertActionHandler = {
            
                dispatch_async(dispatch_get_main_queue()){
                    self.requestLocationButton.setHidden(false)
                    self.saveLocationButton.setHidden(true)
                    self.setNewButton.setHidden(true)
                    self.radarButton.setHidden(true)
                }
            }
            
            let alertView = WKAlertAction(title: "OK", style: .Cancel, handler: alertHandler)
            
            self.presentAlertControllerWithTitle(Constants.AlertsTexts.LocationDeniedTitle, message:Constants.AlertsTexts.LocationDeniedText, preferredStyle: .Alert, actions: [alertView])

        }
    }
        
    
    /// MARK: - Segue
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        
        if(segueIdentifier == "MainToRadar"){
            
            saveCarLocationPressed()
    
            return nil
        }
        
        return nil
    }
}
