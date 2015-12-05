//
//  MenuViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadWebViewRequest()
    }
    
    
    override func viewDidLayoutSubviews() {
        self.activityIndicator.color = Constants.Appearance.GlobalTintColor
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackMenuWebScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    // MARK: - loadWebViewRequest
    private func loadWebViewRequest(){
        
        let menuURLRequest = NSMutableURLRequest(URL: Constants.URLs.MenuUrl, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15)
        
        menuURLRequest.addValue("private", forHTTPHeaderField: "Cache-Control")
        
        self.webView.loadRequest(menuURLRequest)
    }
    

    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {

        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.activityIndicator.stopAnimating()
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.activityIndicator.stopAnimating()
        
        let alertVC = UIAlertController(title: Constants.LocalStrings.networkErrorTitle.localizedWithComment(""),
                                        message: Constants.LocalStrings.networkErrorText.localizedWithComment(""),
                                        preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertVC.addAction(alertAction)
        
        self.presentViewController(alertVC, animated: true, completion: nil)
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
