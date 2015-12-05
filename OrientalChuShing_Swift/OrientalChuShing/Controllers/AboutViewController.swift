//
//  AboutViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
