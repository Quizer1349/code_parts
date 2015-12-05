//
//  LangChangeViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 09.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class LangChangeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var listOfLocals:[String] = NSBundle.mainBundle().preferredLocalizations
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "change language".localizedWithComment("").capitalizedString
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackChooseLangScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listOfLocals.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.ChooseLangCell, forIndexPath: indexPath) 
        
        let localeCode:String = listOfLocals[indexPath.row]
        
        let locale:NSLocale = NSLocale(localeIdentifier: localeCode)
        
        cell.textLabel?.text = locale.displayNameForKey(NSLocaleIdentifier, value: locale.localeIdentifier)
        
        
        if(locale.localeIdentifier == localeCode){
        
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

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
