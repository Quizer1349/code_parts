//
//  WebBrowserViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 08.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class WebBrowserViewController: BaseViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var hyperlink:String = ""
    
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "closeButtonPressed")]

        self.loadWebViewRequest()
    }

    
    override func viewDidLayoutSubviews() {
        
        self.activityIndicator.color = Constants.Appearance.GlobalTintColor
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackPushWebScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Load Web Request
    private func loadWebViewRequest(){
        
        let hyperlinkUrl:NSURL = NSURL(string:self.hyperlink)!
        let hyperlinkURLRequest = NSURLRequest(URL: hyperlinkUrl)
        
        self.webView.loadRequest(hyperlinkURLRequest)
    }
    

    // MARK: - Buttons Actions
    
    func closeButtonPressed(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self.webView, action: "stopLoading")]
    }
    
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.activityIndicator.stopAnimating()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self.webView, action: "reload")]
        self.title = self.webView.stringByEvaluatingJavaScriptFromString("document.title")
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self.webView, action: "reload")]
        self.activityIndicator.stopAnimating()
        
        if (error!.code != NSURLErrorCancelled) {
         
            let alertVC = UIAlertController(title: Constants.LocalStrings.networkErrorTitle.localizedWithComment(""),
                                            message: Constants.LocalStrings.networkErrorText.localizedWithComment(""),
                                            preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alertVC.addAction(alertAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
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
