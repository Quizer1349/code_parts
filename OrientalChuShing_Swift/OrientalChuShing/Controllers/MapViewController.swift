//
//  MapViewController.swift
//  OrientalChuShing
//
//  Created by Alex Sklyarenko on 03.09.15.
//  Copyright (c) 2015 itinarray. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var place:Place? = nil
    
    let regionRadius: CLLocationDistance = 1000
    
    var isDirection:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // set initial location of Place
        if(self.place != nil){
        
            let initialLocation = CLLocation(latitude: self.place!.latitude, longitude: self.place!.longitude)
            centerMapOnLocation(initialLocation)
            
            let anotation = MKPointAnnotation()
            anotation.coordinate = CLLocationCoordinate2D(latitude: self.place!.latitude, longitude: self.place!.longitude)
            anotation.title = self.place?.title
            anotation.subtitle = self.place?.address
            mapView.addAnnotation(anotation)
            
            if(isDirection){
                calculateDirectionFromToPlace()
            }
        }

    }

    func calculateDirectionFromToPlace(){
    
        let destCoordinates:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.place!.latitude, longitude: self.place!.longitude)
        let desitnationPlacemark = MKPlacemark(coordinate: destCoordinates, addressDictionary: nil)
        let destination:MKMapItem = MKMapItem(placemark: desitnationPlacemark)
        
       // MKMapItem.openMapsWithItems([destination], launchOptions:[MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:true])
        
        let request:MKDirectionsRequest = MKDirectionsRequest()
        
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destination
        
        request.transportType = MKDirectionsTransportType.Automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            
            if error == nil {
                
                self.showRoute(response!)
            }
            else{
                
                print("trace the error \(error?.localizedDescription)")
                
            }
        })
    }
    
    func showRoute(response:MKDirectionsResponse){
        for route in response.routes {
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            let routeSeconds = route.expectedTravelTime
            let routeDistance = route.distance
            print("distance between two points is \(routeSeconds) and \(routeDistance)")
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
     
        
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if(isDirection){
        
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let curCoordinates:CLLocationCoordinate2D = userLocation.coordinate
                self.mapView.setCenterCoordinate(curCoordinates, animated: true)
            }
        }

    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if(overlay.isKindOfClass(MKPolyline)){
            
            let poliline:MKPolyline = overlay as! MKPolyline
            let polilineRender:MKPolylineRenderer = MKPolylineRenderer(polyline: poliline)
            
            polilineRender.strokeColor = Constants.Appearance.GlobalTintColor
            
            return polilineRender
            
        }else{
        
            return MKOverlayRenderer()
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
