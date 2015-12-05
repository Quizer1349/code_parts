//
//  PushHandler.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 08.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class PushHandler: NSObject {
 
    let appDelegate:AppDelegate!
    
    class var sharedInstance : PushHandler {
        struct Static {
            static let instance : PushHandler = PushHandler()
        }
        return Static.instance
    }
    
    private override init() {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    
    func handlePushNotification(userInfo: [NSObject : AnyObject], isAppActive:Bool = false){
    
        let pushTitle:String = (userInfo["title"] as? String)!
        
        if let hyperlink: String = userInfo["hyperlink"] as? String{
            
            if(hyperlink.characters.count > 0){
                
                if isAppActive{
                    
                    showPushAlert(title: pushTitle, hyperlink: hyperlink)
                }else{
                    
                    handlePushWithHyperlink(hyperlink)
                }
            }
        }
    
    }
    
    
    func handlePushWithHyperlink(hyperlink: String){
        
        showWebBrowserWithHyperlink(hyperlink)
    }
    
    
    func showWebBrowserWithHyperlink(hyperlink:String!){
        
        let navVC:UINavigationController = self.appDelegate.window!.rootViewController as! UINavigationController
        
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let webBrowserVC:WebBrowserViewController = storyboard.instantiateViewControllerWithIdentifier(WebBrowserViewController.classNameToString) as! WebBrowserViewController
        webBrowserVC.hyperlink = hyperlink
        
        let newNavController = UINavigationController(rootViewController: webBrowserVC)
        
        navVC.topViewController!.presentViewController(newNavController, animated: true, completion: nil)
    }
    
    private func showPushAlert(title title:String, hyperlink:String){
    
        let alertVC = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertCancelAction = UIAlertAction(title: "Cancel".localizedWithComment(""), style: UIAlertActionStyle.Cancel, handler: nil)
        alertVC.addAction(alertCancelAction)
        
        let alertShowAction = UIAlertAction(title: "Show".localizedWithComment(""), style: UIAlertActionStyle.Default){ (alertShowAction) -> Void in
            self.handlePushWithHyperlink(hyperlink)
        }
        alertVC.addAction(alertShowAction)
        
        let navVC:UINavigationController = self.appDelegate.window!.rootViewController as! UINavigationController
        navVC.topViewController!.presentViewController(alertVC, animated: true, completion: nil)
    }
    
}
