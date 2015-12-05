//
//  PlaceDetailesViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 03.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit
import MessageUI
import MapKit

class PlaceDetailesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var hoursTableTitle: UILabel!
    @IBOutlet weak var hoursTableView: UITableView!
    
    @IBOutlet weak var placeTitleLabel: UILabel!
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var directionMapBtn: UIButton!
    
    @IBOutlet weak var tableBottomSpace: NSLayoutConstraint!
    
    var place:Place!
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUIElements()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackPlaceScreenName + " " + place.title)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Setup UI
    func setupUIElements() {
        
        self.title = "Details".localizedWithComment("")
        
        self.placeTitleLabel.text = self.place.title
        
        self.phoneBtn.backgroundColor = Constants.Appearance.GlobalTintColor
        self.emailBtn.backgroundColor = Constants.Appearance.GlobalTintColor
        
        self.directionMapBtn.setTitle("Get Direction".localizedWithComment(""), forState: .Normal)
        self.directionMapBtn.backgroundColor = Constants.Appearance.GlobalTintColor
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : paragraph]
        
        let phoneBtnTitle = NSAttributedString(string: "Call Us".localizedWithComment(""), attributes:attrs)
        let emailBtnTitle = NSAttributedString(string: "Email Us".localizedWithComment(""), attributes:attrs)
        
        self.phoneBtn.setAttributedTitle(phoneBtnTitle, forState: UIControlState.Normal)
        self.emailBtn.setAttributedTitle(emailBtnTitle, forState: UIControlState.Normal)
        
        self.hoursTableTitle.text = "Working Hours".localizedWithComment("")
        
        //Fix table height for iphone4
        if(UIScreen.mainScreen().bounds.height == 480){
        
            self.tableBottomSpace.constant = 20;
        }
        
        
    }
    
    
    // MARK: - Buttons Actions
    
    @IBAction func phoneBtnPressed(sender: AnyObject) {
        let phoneNumber = Constants.AppData.AppBusinessPhone.stringByReplacingOccurrencesOfString(" ", withString: "")
        let phone = "tel://" + phoneNumber;
        let url:NSURL = NSURL(string:phone)!;
        
        if(UIApplication.sharedApplication().canOpenURL(url)){
            
            UIApplication.sharedApplication().openURL(url);
        }
    }
    
    
    @IBAction func emailBtnPressed(sender: AnyObject) {
        
        let picker = MFMailComposeViewController()
        picker.setToRecipients([self.place.email])
        picker.mailComposeDelegate = self
        picker.setSubject("To " + self.place.title)
        
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
    
    //Not used
    @IBAction func showOnMapBtnPressed(sender: AnyObject) {
    
        self.performSegueWithIdentifier(Constants.Segues.PlaceDetailesToMap, sender: sender)
    }
    
    
    @IBAction func directionBtnPressed(sender: AnyObject) {
    
        let locationManager:LocationManager = LocationManager.sharedInstance
        
        let destCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.place!.latitude, longitude: self.place!.longitude)
        let coordinates:CLLocation = CLLocation(latitude: self.place!.latitude, longitude: self.place!.longitude)
        locationManager.reverseGeocodeLocationWithCoordinates(coordinates) { (reverseGecodeInfo, placemark, error) -> Void in
            
            
            if((error) != nil){
                
               let desitnationPlacemark = MKPlacemark(coordinate: destCoordinates, addressDictionary: nil)
                let destinationEmpty:MKMapItem = MKMapItem(placemark: desitnationPlacemark)
                
                MKMapItem.openMapsWithItems([destinationEmpty], launchOptions:[MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:true])
                
                
                return
            }
            
            let desitnationPlacemark = MKPlacemark(placemark: placemark!)
            let destination:MKMapItem = MKMapItem(placemark: desitnationPlacemark)
            
            MKMapItem.openMapsWithItems([destination],
                launchOptions:[MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:true])
        }
        
        //self.performSegueWithIdentifier(Constants.Segues.PlaceDetailesToMap, sender: sender)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:WorkingHoursTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.WorkingHoursCell) as! WorkingHoursTableViewCell
        
        let day:String = Constants.AppData.AppWeekDaysArray[indexPath.row] as! String
       
        cell.dayLabel.text = day.localizedWithComment("") + ":"
        cell.hoursLabel.text =  self.place.workingHours[day]!;
        
        return cell
        
    }
    
    
    // MARK: - MFMailComposeViewControllerDelegate Method
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return tableView.frame.size.height / 7
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == Constants.Segues.PlaceDetailesToMap){
            
            let mapVC:MapViewController = segue.destinationViewController as! MapViewController
            mapVC.title = self.place.title
            mapVC.place = self.place
            
            if(sender === self.directionMapBtn){
                
                mapVC.isDirection = true
            }
        }
    }


}
