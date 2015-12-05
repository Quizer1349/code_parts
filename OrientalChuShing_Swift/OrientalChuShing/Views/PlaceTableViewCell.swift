//
//  PlaceTableViewCell.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 02.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAdress: UILabel!
    @IBOutlet weak var distanceRange: UILabel!
    @IBOutlet weak var distanceTitle: UILabel!
    
    @IBOutlet weak var distanceActivity: UIActivityIndicatorView!
    
    var place:Place? = nil{
    
        didSet{
        
            self.setUIForPlace()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "myCoordinatesUpdated:", name: Constants.kMyCoordinatesUpdatedNotification, object: nil)

        distanceTitle.text = "distance".localizedWithComment("")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    deinit{
    
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: Constants.kMyCoordinatesUpdatedNotification, object: nil)
        
    }
    
    func setUIForPlace(){
    
        self.placeName.text = self.place?.title
        self.placeAdress.text = self.place?.address
        
    }
    
    func myCoordinatesUpdated(notification: NSNotification){
        
        let userInfo:Dictionary<String,Double!> = notification.userInfo as! Dictionary<String,Double!>
        let latitude:Double = userInfo["latitude"]!
        let longitude:Double = userInfo["longitude"]!
    
        if(latitude != 0 && longitude != 0){
        
            let locationManager = LocationManager.sharedInstance
            let distRangeFloat:Float = locationManager.getDistanceToCoordinates(latitude: self.place?.latitude, longitude: self.place?.longitude)
            
            if(distRangeFloat < Constants.AppData.AppDistanceLimit){
            
                self.distanceActivity.stopAnimating()
                self.distanceRange.text = String(format: "%.1f km", (distRangeFloat/1000))
            }else{
            
                self.distanceActivity.stopAnimating()
                self.distanceRange.text = ">30 km"
            }
            

        }
    }

}
