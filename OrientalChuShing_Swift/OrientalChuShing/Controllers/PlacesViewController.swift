//
//  PlacesViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class PlacesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

   
    @IBOutlet weak var tableView: UITableView!
    var placesArray:[Place] = NSArray() as! [Place]
    
    var selectedIndex:Int = 0
    
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.placesArray = DataManager.sharedInstance.getAllPlaces() as! [Place]
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startLocationMonitoring()
        
        /*Google analytics*/
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: Constants.GoogleAnalytics.trackFindLocationScreenName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let locationManager = LocationManager.sharedInstance
        locationManager.stopUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location service
    func startLocationMonitoring(){
    
        /*Start Location Service*/
        let locationManager = LocationManager.sharedInstance
        locationManager.showVerboseMessage = false
        locationManager.autoUpdate = true
        locationManager.startUpdatingLocationWithCompletionHandler { (latitude, longitude, status, verboseMessage, error) -> () in
                       
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(Constants.kMyCoordinatesUpdatedNotification, object:nil, userInfo:["latitude":latitude, "longitude":longitude])
            })
            
        }
    }

    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.placesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:PlaceTableViewCell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.PlaceListCell) as! PlaceTableViewCell

        
        let placeObj:Place! = self.placesArray[indexPath.row] as Place
        
        if let place = placeObj{
            
            cell.place = place
        }

        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedIndex = indexPath.row
        
        self.performSegueWithIdentifier(Constants.Segues.PlacesToPlaceDetailes, sender: self)
        
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let segueId:String! = segue.identifier
        
        switch segueId{
            
        case Constants.Segues.PlacesToPlaceDetailes:
            
            let placeDetailedVC:PlaceDetailesViewController = segue.destinationViewController as! PlaceDetailesViewController
            placeDetailedVC.place = self.placesArray[self.selectedIndex]
           
        default:
            break
        }


    }

    
    

}
