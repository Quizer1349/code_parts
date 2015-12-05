//
//  AppDelegate.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 01.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //MARK: - App lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        /*Set initial controller*/
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var rootController:UINavigationController
        
        if(CurrentUser.isUserLoged()){
            
            rootController = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllersId.MainVCId) as! UINavigationController
            
        }else{
            
            rootController = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllersId.SignUpVCId) as! UINavigationController
        }
        
        if let window = self.window{
            window.tintColor = Constants.Appearance.GlobalTintColor
            window.backgroundColor = UIColor.whiteColor()
            window.rootViewController = rootController
            window.makeKeyAndVisible()
        }
        
        /*App appearance*/
        UINavigationBar.appearance().barTintColor = Constants.Appearance.GlobalTintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        /*Crashlytics*/
        Fabric.with([Crashlytics.self()])

        /*Parse.com*/
        Parse.setApplicationId(Constants.Parse_com.AppID, clientKey: Constants.Parse_com.ClientID)
        
        /*APNS settings and tracking*/
        registerForPushNotificationsCustom(application, launchOptions: launchOptions)
        trackRecievedPushNotification(application, launchOptions: launchOptions)
        
        /*Googla Analytics*/
        let gai = GAI.sharedInstance()
        
        let tracker = gai.trackerWithTrackingId(Constants.GoogleAnalytics.TrackID)
        gai.defaultTracker = tracker
        
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Error  // remove before app release
        
        /*MailChimp*/
        ChimpKit.sharedKit().apiKey = Constants.MailChimp.ApiKey
        
        /*Cache settings*/
        let URLCache = NSURLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: "cache")
        NSURLCache.setSharedURLCache(URLCache)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {

        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - APNS methods
    
    func registerForPushNotificationsCustom(application : UIApplication , launchOptions: [NSObject: AnyObject]?){
    
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Alert], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func trackRecievedPushNotification(application : UIApplication , launchOptions: [NSObject: AnyObject]?){
    
        let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
        if noPushPayload != nil{
            PushHandler.sharedInstance.handlePushNotification(noPushPayload as! [NSObject : AnyObject], isAppActive:false)
        }
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        
        installation.setDeviceTokenFromData(deviceToken)
        installation.setValue("apns", forKey: Constants.Parse_com.UserPushType)
        
        installation.saveInBackground()
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //PFPush.handlePush(userInfo)
        PushHandler.sharedInstance.handlePushNotification(userInfo, isAppActive:application.applicationState == UIApplicationState.Active)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    //MARK: - Transitions
    func transitionToMainNavigationController(){
    
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let mainNavVC:UINavigationController = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllersId.MainVCId) as! UINavigationController
        
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromRight, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            self.window!.rootViewController = mainNavVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                
        })
    }
    
    func transitionToSignUpNavigationController(){
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let signUpNavVC:UINavigationController = storyboard.instantiateViewControllerWithIdentifier(Constants.ViewControllersId.SignUpVCId) as! UINavigationController
        
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: {
            let oldState: Bool = UIView.areAnimationsEnabled()
            UIView.setAnimationsEnabled(false)
            self.window!.rootViewController = signUpNavVC
            UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                
        })
    }
    
    
//    //The iOS 7-only handler
//    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        if application.applicationState == .Inactive {
//            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
//        }
//    }


}

