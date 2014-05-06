//
//  KSMapViewController.m
//  klitch
//
//  Created by admin on 26.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UIViewController+MJPopupViewController.h"
#import "KSMapDirectionService.h"
#import "KSApiClient+Klitch.h"
#import "KSApiClient+Users.h"
#import "KSPopupCreateHelpOfferViewController.h"
#import "KSPopupApprowedRequestViewController.h"


@interface KSMapViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate,
                                  KSPopupCreateHelpOfferDelegate, KSPopupApprowedRequestDelegate> {
    
    GMSMapView *mapView_;
    NSMutableArray *waypoints_;
    NSMutableArray *waypointStrings_;
    CLLocationManager * locationManager;
    BOOL _isWaitingHelpMarkers;
}
@end

@implementation KSMapViewController

- (void)loadView {
    

    //Current location
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    // Create a GMSCameraPosition that tells the map to display the
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:locationManager.location.coordinate.latitude
                                 longitude:locationManager.location.coordinate.longitude
                                 zoom:2];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    //Elements control
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    
    mapView_.delegate = self;
    self.view = mapView_;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
       
    //Set navigation item title
    if(self.viewTitle){
        //Set adaptive title font size
        UILabel* titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
        titleLabel.text = self.viewTitle;
        titleLabel.textColor = [UIColor colorWithRed:(72.0/255.0) green:(72.0/255.0) blue:(72.0/255.0) alpha:1.0f];;
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
        titleLabel.backgroundColor =[UIColor clearColor];
        titleLabel.adjustsFontSizeToFitWidth=YES;
        self.navigationItem.titleView=titleLabel;
    }
    
    if(self.userDirection.count > 0){
    
        CLLocationDegrees latitudeCLL = [self.userDirection[@"latitude"] doubleValue];
        CLLocationDegrees longitudeCLL = [self.userDirection[@"longitude"] doubleValue];
        
        [self createDirectionFromPoint:locationManager.location.coordinate
                               ToPoint:CLLocationCoordinate2DMake(latitudeCLL, longitudeCLL)];
    }
    
    if(self.onlineUsersMarkers.count > 0){
       
        [self addMarkersOnMap:self.onlineUsersMarkers];
        
    } else if (self.readyUsersMarkers.count > 0){
        
        [self addMarkersOnMap:self.readyUsersMarkers];
        
    } else if (self.waitingUsersMarkers.count > 0){
        
        NSLog(@"All markers - %@", self.waitingUsersMarkers);

        _isWaitingHelpMarkers = YES;
        [self addMarkersOnMap:self.waitingUsersMarkers];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    mapView_.delegate = nil;
    mapView_ = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - Add maker on map method

- (void) addMarkersOnMap:(NSArray *)objects{

    
    for(NSDictionary * markerData in objects){
        
        if(![markerData[@"visible"] boolValue]){
            continue;
        }
            
        GMSMarker *marker = [[GMSMarker alloc] init];
    

        CLLocationDegrees latitudeCLL = [markerData[@"latitude"] doubleValue];
        CLLocationDegrees longitudeCLL = [markerData[@"longitude"] doubleValue];
        
        marker.position = CLLocationCoordinate2DMake(latitudeCLL, longitudeCLL);
        
        if(_isWaitingHelpMarkers){
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        }else{
            marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
        }
        
        //Calculate data
        float distance = [[KSApiClient sharedClient] calculateDistanceToPointWithLatitude:markerData[@"latitude"]
                                                                              andLongitude:markerData[@"longitude"]];
        
        NSString *distanceString = [NSString stringWithFormat:@"%dкм", (int)distance];
        
        NSDateFormatter *dateFormatter=[NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
        NSString *serverDateString = [NSString
                                      stringWithFormat:@"%@", markerData[@"expires"]];
        
        NSDate *klitchDate=[dateFormatter dateFromString:serverDateString];
        
        NSDateFormatter *dfTime = [NSDateFormatter new];
        [dfTime setDateFormat:@"HH:mm"];
        NSString *klitchTime=[dfTime stringFromDate:klitchDate];
        
        NSMutableDictionary *markerDataCalc = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               distanceString, @"distance",
                                               klitchTime, @"klitch_time", nil];
        
        [markerDataCalc addEntriesFromDictionary:markerData[@"request"]];
        [markerDataCalc addEntriesFromDictionary:markerData];
        
        marker.title = markerData[@"nick"];
        marker.userData = markerDataCalc;
        
        marker.map = mapView_;
    }
}

#pragma mark
#pragma mark - GMSMapViewDelegate markers taping

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    // Animate to the marker
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0f];
    
    GMSCameraPosition *camera =
    [[GMSCameraPosition alloc] initWithTarget:marker.position
                                         zoom:10
                                      bearing:50
                                 viewingAngle:60];
    
    [mapView animateToCameraPosition:camera];
    [CATransaction commit];
    
    if (_isWaitingHelpMarkers) {
        [self tapWaitingHelpMarker:marker];
    }
    else{
         mapView_.selectedMarker = marker;
    }
    
    
    // The Tap has been handled so return YES
    return YES;
}

#pragma mark
#pragma mark - Add direction path on map method
- (void)createDirectionFromPoint:(CLLocationCoordinate2D)fromPoint ToPoint:(CLLocationCoordinate2D)coordinate {
    
    waypoints_ = [NSMutableArray new];
    waypointStrings_ = [NSMutableArray new];
   
    //Current position
    CLLocationCoordinate2D curentPosition = locationManager.location.coordinate;
    
    //Destination
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(
                                                                 coordinate.latitude,
                                                                 coordinate.longitude);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
    marker.map = mapView_;
    
    [waypoints_ addObjectsFromArray:@[[GMSMarker markerWithPosition:curentPosition], marker]];
    
    NSString *curentPositionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                curentPosition.latitude,curentPosition.longitude];
    
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                coordinate.latitude,coordinate.longitude];
    
    [waypointStrings_ addObjectsFromArray:@[curentPositionString, positionString]];
    
    if(waypoints_.count > 1){
        NSString *sensor = @"false";
        NSArray *parameters = [NSArray arrayWithObjects:sensor, waypointStrings_,
                               nil];
        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
                                                          forKeys:keys];
        KSMapDirectionService *mds=[[KSMapDirectionService alloc] init];
        SEL selector = @selector(addDirections:);
        [mds setDirectionsQuery:query
                   withSelector:selector
                   withDelegate:self];
    }
}

- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [NSDictionary new];
    @try {
        routes = [json objectForKey:@"routes"][0];

    }
    @catch (NSException * e) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Проверьте настройки геолокации!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 1.0f;
    polyline.strokeColor = [UIColor redColor];
    polyline.map = mapView_;
}


#pragma mark
#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка GPS" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

#pragma mark
#pragma mark - Show waitng help popup

- (void) tapWaitingHelpMarker:(GMSMarker *)marker {
    
    NSLog(@"Tapped marker - %@" , marker.userData);
    
    if([marker.userData[@"status"] isEqualToString:@"finished"] ||
       [marker.userData[@"status"] isEqualToString:@"cancelled"] ||
       !marker.userData[@"request_id"]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Этот клич уже не активный!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        return;
    }
    
    if(![marker.userData[@"offer_made"] isKindOfClass:[NSNull class]] && ![marker.userData[@"has_offer"] boolValue]) {
        
        KSPopupCreateHelpOfferViewController *popupVC = [[KSPopupCreateHelpOfferViewController alloc] initWithNibName:@"popupWaitingHelp" bundle:nil];
        
        popupVC.requestData = marker.userData;
        popupVC.calculatedData = marker.userData;
        
        popupVC.hasOfferStatus = YES;
        
        popupVC.delegate = self;
        
        [self presentPopupViewController:popupVC animationType:MJPopupViewAnimationFade];
        return;
        
        
    }
    
    if([marker.userData[@"offer_made"] isKindOfClass:[NSNull class]]){
        
        KSPopupCreateHelpOfferViewController *popupVC = [[KSPopupCreateHelpOfferViewController alloc] initWithNibName:@"popupWaitingHelp" bundle:nil];
        
        popupVC.requestData = marker.userData;
        popupVC.calculatedData = marker.userData;
        popupVC.delegate = self;
        
        [self presentPopupViewController:popupVC animationType:MJPopupViewAnimationFade];
        return;
        
    }
    NSLog(@"Marker Userdata - %@", marker.userData);
    [[KSApiClient sharedClient] getMyOfferForKlitchId:marker.userData[@"request_id"] withBlock:
     ^(NSDictionary *response, NSError *error) {
         if(response){
             NSLog(@"Response for request click - %@", response);
             if([response[@"status"] isEqualToString:@"accepted"]){
                 
                 KSPopupApprowedRequestViewController *popupApprowedVC = [[KSPopupApprowedRequestViewController alloc] initWithNibName:@"popupApprowedRequestViewController" bundle:nil];
                 
                 popupApprowedVC.requestData = marker.userData;
                 popupApprowedVC.delegate = self;
                 
                 [self presentPopupViewController:popupApprowedVC animationType:MJPopupViewAnimationFade];
                 
             }else if([response[@"status"] isEqualToString:@"cancelled"]){
                 
                 KSPopupCreateHelpOfferViewController *popupVC = [[KSPopupCreateHelpOfferViewController alloc] initWithNibName:@"popupWaitingHelp" bundle:nil];
                 
                 popupVC.cancelledStatus = YES;
                 popupVC.requestData = marker.userData;
                 popupVC.calculatedData = marker.userData;
                 popupVC.delegate = self;
                 
                 [self presentPopupViewController:popupVC animationType:MJPopupViewAnimationFade];
                 
             }else {
                 
                 KSPopupCreateHelpOfferViewController *popupVC = [[KSPopupCreateHelpOfferViewController alloc] initWithNibName:@"popupWaitingHelp" bundle:nil];
                 
                 popupVC.waitingStatus = YES;
                 popupVC.requestData = marker.userData;
                 popupVC.calculatedData = marker.userData;
                 popupVC.delegate = self;
                 
                 [self presentPopupViewController:popupVC animationType:MJPopupViewAnimationFade];
             }
             
         } else if (error){
             
             NSLog(@"%@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}

#pragma mark -
#pragma mark - Popup delegeted

- (void)cancelButtonPressed:(KSPopupCreateHelpOfferViewController *)KSPopupCreateHelpOfferViewController {
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void)yesButtonPresses:(KSPopupCreateHelpOfferViewController *)KSPopupCreateHelpOfferVC {
    
    [[KSApiClient sharedClient] createMyOfferForKlitchId:KSPopupCreateHelpOfferVC.requestData[@"request_id"] withBlock:
     ^(BOOL result, NSError *error) {
         if (result) {

             [KSPopupCreateHelpOfferVC setOfferStatusWaiting];
             
             KSPopupCreateHelpOfferVC.requestData[@"offer_made"] = KSPopupCreateHelpOfferVC.requestData[@"request_id"];
             
             [self refreshData];
         }
         else if (error){
             NSLog(@"%@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}

- (void)deleteOfferPressed:(KSPopupCreateHelpOfferViewController *)KSPopupCreateHelpOfferVC {
    
    [[KSApiClient sharedClient] deleteMyOfferForKlitchId:KSPopupCreateHelpOfferVC.requestData[@"offer_made"] withBlock:
     ^(BOOL result, NSError *error) {
         if (result) {
             
             [KSPopupCreateHelpOfferVC setOfferStatusNew];
             
             KSPopupCreateHelpOfferVC.requestData[@"offer_made"] = [NSNull null];
             
             [self refreshData];
         }
         else if (error){
             NSLog(@"%@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
    
}

- (void)deleteAprowedOfferPressed:(KSPopupApprowedRequestViewController*)KSPopupApprowedRequestVC {
    
    [[KSApiClient sharedClient] deleteMyOfferForKlitchId:KSPopupApprowedRequestVC.requestData[@"offer_made"] withBlock:
     ^(BOOL result, NSError *error) {
         if (result) {
             
             KSPopupApprowedRequestVC.requestData[@"offer_made"] = [NSNull null];
             
             [self refreshData];
             
             [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
         }
         else if (error){
             NSLog(@"%@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
    
}

-(void)directionMapButtonPressed:(KSPopupApprowedRequestViewController *)KSPopupApprowedRequestVC{
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    KSMapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
    
    NSMutableString * viewTitleString = [NSMutableString stringWithString:@"Маршрут к "];
    [viewTitleString appendString:(NSString *)KSPopupApprowedRequestVC.requestData[@"nick"]];
    
    mapVC.viewTitle = [viewTitleString uppercaseString];
    mapVC.userDirection = @{@"latitude": KSPopupApprowedRequestVC.requestData[@"latitude"],
                            @"longitude": KSPopupApprowedRequestVC.requestData[@"longitude"]};
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

- (void)refreshData
{
    [[KSApiClient sharedClient] getWaitingUsersForCommID:self.commData[@"id"] withBlock:
     ^(NSArray *response, NSError *error) {
         if(response){
                          NSLog(@"All markers - %@", self.waitingUsersMarkers);
             
             _isWaitingHelpMarkers = YES;
             [mapView_ clear];
             [self addMarkersOnMap:response];
             
         } else if (error){
             
             NSLog(@"%@", error);
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}

@end
