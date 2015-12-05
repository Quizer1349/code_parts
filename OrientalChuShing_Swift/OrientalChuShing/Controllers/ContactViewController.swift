//
//  ContactViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit
import MessageUI

class ContactViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    private var navBarHairlineImageView:UIImageView?
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBarHairlineImageView  = self.findHairlineImageViewUnder(self.navigationController!.navigationBar)
        
        self.setupUIElements()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navBarHairlineImageView?.hidden = true
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackContactUsScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navBarHairlineImageView?.hidden = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Setup UI elements
    private func findHairlineImageViewUnder(view:UIView) -> UIImageView?{
    
        if(view.isKindOfClass(UIImageView) && view.bounds.size.height <= 1.0){
            return view as? UIImageView;
        }
        
        for subview:UIView in view.subviews {
        
            let imageView:UIImageView? = self.findHairlineImageViewUnder(subview)
            
            if imageView != nil{
                return imageView!
            }
        }
        
        return nil
    }
    
    func setupUIElements() {
        
        self.callButton.backgroundColor = Constants.Appearance.GlobalTintColor
        self.emailButton.backgroundColor = Constants.Appearance.GlobalTintColor
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : paragraph]
        
        let attrsForEmailAndPhone = [NSFontAttributeName : UIFont.systemFontOfSize(14.0), NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : paragraph]
        
        let callTitle = NSMutableAttributedString(string: "Call us".localizedWithComment(""), attributes:attrs)
        let emailTitle = NSMutableAttributedString(string: "Email us".localizedWithComment(""), attributes:attrs)
        
        let phoneString = NSAttributedString(string: ":\n" + Constants.AppData.AppBusinessPhone, attributes:attrsForEmailAndPhone)
        let emailString = NSAttributedString(string: ":\n" + Constants.AppData.AppBusinessEmail, attributes:attrsForEmailAndPhone)
        
        callTitle.appendAttributedString(phoneString)
        emailTitle.appendAttributedString(emailString)
        
        self.callButton.setAttributedTitle(callTitle, forState: UIControlState.Normal)
        self.emailButton.setAttributedTitle(emailTitle, forState: UIControlState.Normal)


    }
    
    // MARK: - Buttons actions
    @IBAction func callButtonPressed(sender: AnyObject) {
        
        let phoneNumber = Constants.AppData.AppBusinessPhone.stringByReplacingOccurrencesOfString(" ", withString: "")
        let phone = "tel://" + phoneNumber;
        let url:NSURL = NSURL(string:phone)!;
        
        if(UIApplication.sharedApplication().canOpenURL(url)){
        
            UIApplication.sharedApplication().openURL(url);
        }
    }
    
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
    
        let picker = MFMailComposeViewController()
        picker.setToRecipients([Constants.AppData.AppBusinessEmail])
        picker.mailComposeDelegate = self
        picker.setSubject(Constants.LocalStrings.mailContactUsSubject.localizedWithComment(""))
        
        picker.navigationBar.tintColor = UIColor.whiteColor()
        picker.navigationBar.barTintColor = UIColor.whiteColor()
        
        if(MFMailComposeViewController.canSendMail()){
        
            
            picker.navigationBar.barTintColor = Constants.Appearance.GlobalTintColor
            picker.navigationBar.tintColor = UIColor.whiteColor()
            picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
            
            self.presentViewController(picker, animated: true, completion: nil)
            
        }else{
        
            let alertVC = UIAlertController(title: Constants.LocalStrings.sendEmailErrorTitle.localizedWithComment(""),
                                            message: Constants.LocalStrings.sendEmailErrorText.localizedWithComment(""),
                                            preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertVC.addAction(alertAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            return
        }
        

    }
    
    // MARK: - MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
