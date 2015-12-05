//
//  RadarInterfaceController.swift
//  MyCarRadar
//
//  Created by Alex Sklyarenko on 14.09.15.
//  Copyright © 2015 itinarray. All rights reserved.
//

import WatchKit
import Foundation
import CoreGraphics


class RadarInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    // MARK: -  Properties
    var timer:NSTimer? = nil
    

    @IBOutlet var targetDotImage: WKInterfaceImage!
    
    let lastCarLocationDic:NSDictionary = NSUserDefaults.standardUserDefaults().objectForKey("lastKnowCarLocation") as! NSDictionary
    var lastCarLocation:CLLocation? = nil
    
    var dotAlpha:CGFloat = 0
    var radarHandAngle:CGFloat = 0
    
    var heading:Double = 0
    var distance:Double = 0
    
    var isDotInvisible:Bool = true

    var radarCycles = 0
    
    // MARK: - Localized String Convenience
    var interfaceTitleWalking: String {
        return NSLocalizedString("Keep walking...", comment: "")
    }
    
    var interfaceTitleBack: String {
        return NSLocalizedString("Tap to go back", comment: "")
    }
    
    var alertDissmisBtn: String {
        return NSLocalizedString("Dissmis", comment: "")
    }
    
    var alertErrorTitle: String {
        return NSLocalizedString("Error", comment: "")
    }
    
    
    // MARK: - Interface Controller
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        blinkOut()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.06, target: self, selector: "blinkOut", userInfo: nil, repeats: true)
        timer!.fire()
                
        lastCarLocation = CLLocation(latitude: lastCarLocationDic["lat"] as! CLLocationDegrees, longitude: lastCarLocationDic["long"] as! CLLocationDegrees)
        
        setTitle(interfaceTitleWalking)

    }
    

    override func willActivate() {
        super.willActivate()
        
        self.addObserverForTrackingManager()
    }

    
    override func didAppear() {

        super.didAppear()
    }

    
    override func willDisappear() {
        super.willDisappear()
        
        self.removeObserverForTrackingManager()

        timer?.invalidate()
        timer = nil
        
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

    
    // MARK: - TrackingManager Observer methods
    func trackerDidUpdateLocation(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
           if let currentLocation:CLLocation = notification.userInfo?["location"] as? CLLocation{
                
                let distance:CLLocationDistance = currentLocation.distanceFromLocation(self.lastCarLocation!)
                print("Distance to car: \(distance)")
                
                let curentCourse:Double = currentLocation.valueForKey("course") as! Double
                print("Direction of moving: \(curentCourse)")
                
                let heading = self.calculateHeading(currentLocation.coordinate, distLoc: (self.lastCarLocation?.coordinate)!)
                print("HEADING- \(heading)")
                
                self.distance = distance
                self.heading = heading + curentCourse
            }
        }
    }
    

    func trackerDidFailedWithError(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            
            let error:NSError = notification.userInfo?["error"] as! NSError
            let alertView = WKAlertAction(title: self.alertDissmisBtn, style: WKAlertActionStyle.Destructive){}
            
            self.presentAlertControllerWithTitle(self.alertErrorTitle, message: error.localizedDescription, preferredStyle: .Alert, actions: [alertView])
        }
    }
    
    func trackerDeniedLocationService() {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            
            let alertView = WKAlertAction(title: "OK", style: .Cancel){}
            self.presentAlertControllerWithTitle(Constants.AlertsTexts.LocationDeniedTitle, message:Constants.AlertsTexts.LocationDeniedText, preferredStyle: .Alert, actions: [alertView])
        }
    }

    

    // MARK: - Heading calculation
    func RAD_TO_DEG(r:Double) ->Double{return r * 180 / M_PI}
    
    func calculateHeading(currentLocation:CLLocationCoordinate2D , distLoc:CLLocationCoordinate2D) -> Double{
        
        let coord1:CLLocationCoordinate2D = currentLocation;
        let coord2:CLLocationCoordinate2D = distLoc;
        
        let deltaLong = log(tan(coord1.latitude / 2 + M_PI / 4) / tan(coord2.latitude / 2 + M_PI / 4));
        let yComponent = abs(coord2.longitude - coord1.longitude);
        
        let radians = atan2(yComponent, deltaLong);
        
        let degrees = RAD_TO_DEG(radians) + 360;
        
        return fmod(degrees, 360);
        
    }
    
    
    // MARK: - UI + animation
    func redrawDisplay(){
    
        let screenSize = CGSizeMake(WKInterfaceDevice.currentDevice().screenBounds.width / 2, WKInterfaceDevice.currentDevice().screenBounds.height / 2 - 19)
        
        var targetX:CGFloat = 0
        var targetY:CGFloat = 0
        
        var targetSizeWidth:CGFloat = 17.0
        var radius:CGFloat = 0.0
        
        switch true{
        
        case distance < 1:
            targetSizeWidth = 17
            radius = CGFloat(0)
            
        case (distance > 10 && distance < 20):
            targetSizeWidth = 15
            radius = CGFloat(33 - 30)
            
        case (distance > 20 && distance < 30):
            targetSizeWidth = 13
            radius = CGFloat(33 - 25)
            
        case (distance > 30 && distance < 50):
            targetSizeWidth = 11
            radius = CGFloat(33 - 20)
            
        case (distance > 50 && distance < 60):
            targetSizeWidth = 9
            radius = CGFloat(33 - 15)
            
        case (distance > 60 && distance < 70):
            targetSizeWidth = 7
            radius = CGFloat(33 - 10)
            
        case (distance > 70 && distance < 80):
            targetSizeWidth = 5
            radius = CGFloat(33 - 5)
            
        case (distance > 80):
            targetSizeWidth = 3
            radius = CGFloat(33)
            
        default:
            break
        }
        
        let centerX:CGFloat = screenSize.width / 2
        let centerY:CGFloat = screenSize.width / 2
        
        targetX = centerX + (radius * CGFloat(cos(heading * M_PI / 180)))
        targetY = centerY + (radius * CGFloat(sin(heading * M_PI / 180)))
        
        
        // Radar Drawing
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(screenSize.width, screenSize.width), false, 4.0)
        
        
        let radarSize = CGSizeMake(screenSize.width, screenSize.width)
        RadarDrawer.drawRadarImage(radarHandAngle: self.radarHandAngle, distanceText: "\(round(distance))m", size: radarSize)
        
        // Raget Dot Drawing
        let dotImage = UIImage(named:"target_dot")
        let imageRect = CGRectMake(targetX - (targetSizeWidth / 2), targetY - (targetSizeWidth / 2), targetSizeWidth, targetSizeWidth)
        dotImage?.drawInRect(imageRect, blendMode: .Normal, alpha: self.dotAlpha)
        
        let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        self.targetDotImage.setImage(resultingImage)
    }
    
    
    func blinkOut(){
        
        if(self.isDotInvisible){
        
            dotAlpha = self.dotAlpha + 0.033
        }else{
        
            dotAlpha = self.dotAlpha - 0.033
        }

        if dotAlpha <=  0{
            self.isDotInvisible = true
        }else if dotAlpha >=  1{
            self.isDotInvisible = false
        }
        
        
        
        radarHandAngle = self.radarHandAngle - 5
        
        if radarHandAngle == -360{
            radarHandAngle = 0
            self.radarCycles++
        }
        
        if(self.radarCycles != 0 && self.radarCycles % 2 == 0){
        
            self.setTitle(self.interfaceTitleBack)
        }else{
            
            self.setTitle(self.interfaceTitleWalking)
        }
    
        self.redrawDisplay()
    }
}
