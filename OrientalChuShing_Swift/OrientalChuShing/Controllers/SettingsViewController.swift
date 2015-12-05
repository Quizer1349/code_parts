//
//  SettingsViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 09.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings".localizedWithComment("")
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackSettingsScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Constants.SettingsList.MenuItems.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.SettingsMenuItem, forIndexPath: indexPath) 
        
        cell.textLabel?.text = Constants.SettingsList.MenuItems[indexPath.row].localizedWithComment("").capitalizedString
        
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch Constants.SettingsList.MenuItems[indexPath.row]{
        
        case "change language":
            self.performSegueWithIdentifier(Constants.Segues.SettingsToLangChoose, sender: self)
            
        default:
            break
        }
    }
    

    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    

}
