//
//  SignUpViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 08.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController, UITextFieldDelegate {

    
    @IBOutlet weak var formWrapperView: UIView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!

    @IBOutlet weak var siteAdressLabel: UILabel!
    
    var userLatitude:Double?
    var userLongitude:Double?
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUIElements()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startLocationMonitoring()
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackSignUpScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let locationManager = LocationManager.sharedInstance
        locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: - Location service
    func startLocationMonitoring(){
        
        /*Start Location Service*/
        let locationManager = LocationManager.sharedInstance
        locationManager.showVerboseMessage = false
        locationManager.autoUpdate = true
        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) -> () in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if(error == nil){
                    
                    self.userLatitude = latitude;
                    self.userLongitude = longitude;
                }
            })
            
        }
    }
    
    
    // MARK: - Setup UI
    func setupUIElements(){
    
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "NavBarTitleLogo"))
        self.view.backgroundColor = Constants.Appearance.GlobalTintColor
        
        self.siteAdressLabel.text = Constants.AppData.AppBusinessSite
        
        let attrNamePlaceholderText = NSAttributedString(string:"First name".localizedWithComment(""), attributes:[NSForegroundColorAttributeName: Constants.Appearance.GlobalTintColor])
        self.firstNameField.attributedPlaceholder = attrNamePlaceholderText
        self.firstNameField.textColor = Constants.Appearance.GlobalTintColor
        
        let attrEmailPlaceholderText = NSAttributedString(string:"Email".localizedWithComment(""), attributes:[NSForegroundColorAttributeName: Constants.Appearance.GlobalTintColor])
        self.emailField.attributedPlaceholder = attrEmailPlaceholderText
        self.emailField.textColor = Constants.Appearance.GlobalTintColor
        
        
        self.signUpBtn.setTitle("Sign up".localizedWithComment("").uppercaseString, forState: .Normal)
        self.signUpBtn.backgroundColor = Constants.Appearance.GlobalTintColor
        self.signUpBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        self.skipBtn.setTitle("Skip".localizedWithComment(""), forState: .Normal)
        self.skipBtn.backgroundColor = UIColor.clearColor()
        self.skipBtn.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapOnView:")
        self.view.addGestureRecognizer(tapGesture)
        
        if(Constants.SettingsList.IsSettingsVisisble){
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavBarSettings") , style: UIBarButtonItemStyle.Plain, target: self, action: "navBarSettingsPressed")
        }
    }
    
    
    // MARK: - UI actions
    func tapOnView(sender:UIView){
    
        for subview in formWrapperView.subviews{
        
            if(subview.isKindOfClass(UITextField) && subview.isFirstResponder()){
            
                subview.resignFirstResponder()
            }
        }
    }
    
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
    
        if validateAllfields(firstNameField, emailField){
        
            DataManager.sharedInstance.signupUser(fistName: firstNameField.text, email: emailField.text, latitude:self.userLatitude, longitude:self.userLongitude)
            
            goToMainNavigationController()
        }
    }
    

    @IBAction func skipBtnPressed(sender: AnyObject) {
    
        goToMainNavigationController()
    }
    
    func navBarSettingsPressed(){
    
        self.performSegueWithIdentifier(Constants.Segues.SignUpToSettings, sender: self)
    }
    
    
    // MARK: - Text fields validation
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    func isValidFirstName(fistName:String) -> Bool {
    
        return fistName.characters.count > 0
    }
    
    
    func validateAllfields(textFields:UITextField...) -> Bool{
    
        for textField in textFields{
        
            if textField == emailField {
                
                if(!self.isValidEmail(textField.text!)){

                    markFieldAsNotValid(textField)
                    
                    return false
                }
                
            } else if textField == firstNameField{
                
                if(!self.isValidFirstName(textField.text!)){
                    
                    markFieldAsNotValid(textField)
                    return false
                }
            }
        }
        
        return true
    }
    
    
    func markFieldAsNotValid(textField:UITextField){
    
        textField.text = ""
        var fieldErrorString = ""
        
        if textField == emailField{
        
            fieldErrorString = "*" + "Incorrect Email".localizedWithComment("") + "*"
        
        }else if textField == firstNameField{
        
            fieldErrorString = "*" + "Name can`t be empty".localizedWithComment("") + "*"
        }
        
        let attrEmailPlaceholderText = NSAttributedString(string:fieldErrorString, attributes:[NSForegroundColorAttributeName: Constants.Appearance.GlobalTintColor])
        textField.attributedPlaceholder = attrEmailPlaceholderText

        textField.becomeFirstResponder()
    }
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == emailField {
        
            
            self.view.endEditing(true)
            
        } else if textField == firstNameField{
            
            emailField.becomeFirstResponder()
            
        }
        
        validateAllfields(textField)
        
        return true
    }
    
    // MARK: - Navigation
    
    func goToMainNavigationController(){
    
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.transitionToMainNavigationController()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
