//
//  ViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 01.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var siteAdressLabel: UILabel!
    
    var menuElements:[String] = Constants.AppData.MenuMenuItems
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "NavBarTitleLogo"))
        //self.view.backgroundColor = Constants.Appearance.GlobalTintColor
        
        self.siteAdressLabel.text = Constants.AppData.AppBusinessSite
        
        
        if(Constants.SettingsList.IsSettingsVisisble){
        
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavBarSettings") , style: UIBarButtonItemStyle.Plain, target: self, action: "navBarSettingsPressed")
        }
        
        if(!CurrentUser.isUserLoged()){
            menuElements.append("Sign up".localizedWithComment(""))
        }
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackMainScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UI actions
    func navBarSettingsPressed(){
        
        self.performSegueWithIdentifier(Constants.Segues.MainToSettings, sender: self)
    }
    

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menuElements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Constants.TableCells.MainMenuCell)
        
        cell.textLabel?.text = menuElements[indexPath.row].localizedWithComment("")

        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.01
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return self.tableView.frame.size.height / CGFloat(menuElements.count)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.row{
        case 0:
            self.performSegueWithIdentifier(Constants.Segues.MainToMenu, sender: self)
        
        case 1:
            self.performSegueWithIdentifier(Constants.Segues.MainToPlaces, sender: self)
            
        //case 2:
        //    self.performSegueWithIdentifier(Constants.Segues.MainToAboutUs, sender: self)
            
        case 2:
            self.performSegueWithIdentifier(Constants.Segues.MainToContactUs, sender: self)
            
        case 3:
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.transitionToSignUpNavigationController()
            
        default:
            break
        }
        
    }
    
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let segueId:String! = segue.identifier
        
        switch segueId{
        
        case Constants.Segues.MainToMenu:
            
            let menuVC:MenuViewController! = segue.destinationViewController as! MenuViewController
            menuVC.title = Constants.AppData.MenuMenuItems[0].localizedWithComment("").capitalizedString
            
        case Constants.Segues.MainToPlaces:
            
            let placesVC:PlacesViewController! = segue.destinationViewController as! PlacesViewController
            placesVC.title = Constants.AppData.MenuMenuItems[1].localizedWithComment("")
         
//        case Constants.Segues.MainToAboutUs:
//            
//            var aboutVC:AboutViewController! = segue.destinationViewController as! AboutViewController
//            aboutVC.title = Constants.AppData.MenuMenuItems[2].localizedWithComment("").capitalizedString
            
        case Constants.Segues.MainToContactUs:
            
            let contactVC:ContactViewController! = segue.destinationViewController as! ContactViewController
            contactVC.title = Constants.AppData.MenuMenuItems[2].localizedWithComment("").capitalizedString
            
        default:
            break
        }
    }

}

