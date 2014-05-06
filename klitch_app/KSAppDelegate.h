//
//  KSAppDelegate.h
//  klitch
//
//  Created by admin on 13.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface KSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyBoard;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *lastChangedPosition;


@end
