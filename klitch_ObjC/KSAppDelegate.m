//
//  KSAppDelegate.m
//  klitch
//
//  Created by admin on 13.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSAppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"
#import "KSApiClient+Profile.h"
#import "KSNavigator.h"

@interface KSAppDelegate() <CLLocationManagerDelegate>

@end

#define CHANGING_DISTANCE_TRIGGER 100.0
#define STATUS_SENDING_TIMER 120.0

@implementation KSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Is user registered
    UINavigationController *rootVC = nil;
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_userHeadersKey];
    if(userData != nil)
        self.storyBoard = [UIStoryboard storyboardWithName:@"App" bundle:nil];
    else
        self.storyBoard = [UIStoryboard storyboardWithName:@"Reg" bundle:nil];
    
    rootVC = [self.storyBoard instantiateInitialViewController];
    
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        [KSNavigator navigateToHelpScreen:((UINavigationController *)self.window.rootViewController) storyBoard:self.storyBoard params:notification[@"comm"]];
    }
    
    //Debug tool
    [Crashlytics startWithAPIKey:@"2e985959b2ef5d14f6488e937f4fa18eace99f21"];
    
    //Google Maps API key
    [GMSServices provideAPIKey:(NSString *)const_GoogleMapsApiKey];
    
    if (nil == self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.distanceFilter = CHANGING_DISTANCE_TRIGGER;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //for testing kCLLocationAccuracyBest
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.lastChangedPosition = [[NSMutableArray alloc] init];
    
    // Start the long-running task and return immediately for Onlibe status sending.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSRunLoop currentRunLoop] addTimer:[self createTimer] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
    
    return YES;
}

#pragma mark - APS push notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[NSUserDefaults standardUserDefaults] stringForKey: @"push_id"])
    {
        if (![[[NSUserDefaults standardUserDefaults] stringForKey: @"push_id"] isEqualToString: token])
        {
            [[NSUserDefaults standardUserDefaults] setObject: token forKey: @"push_id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject: token forKey: @"push_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //user allowed push. react accordingly.
    }
    NSLog(@"System token - %@", deviceToken);
    NSLog(@"Cleaned token - %@", token);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification: %@", userInfo);
    if (application.applicationState != UIApplicationStateActive) {
        [KSNavigator navigateToHelpScreen:((UINavigationController *)self.window.rootViewController) storyBoard:self.storyBoard params:userInfo[@"comm"]];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark
#pragma mark - Timer Status sender
-(void) setStatusOnline:(NSTimer *)timer {
    
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_userHeadersKey];
    if(userData == nil){
        return;
    }
        
    NSDictionary *location = [NSDictionary new];
    if(!self.lastChangedPosition.lastObject){
        location = [[[NSUserDefaults standardUserDefaults] objectForKey:@"last_location"] lastObject];
    }else{
        location = self.lastChangedPosition.lastObject;
    }
    
    [[KSApiClient sharedClient] sendCurrnetLocation:location withBlock:
     ^(BOOL result, NSError *error) {
         if(result){
             NSDate *now = [NSDate date];
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             dateFormatter.dateFormat = @"hh:mm:ss";
             [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Location was sent at by timer : %@",[dateFormatter stringFromDate:now]);
             });
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Status sending error - %@", error);
             });
         }
     }];
    
}

#pragma mark
#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_userHeadersKey];
    if(userData == nil){
        return;
    }
    
    CLLocation *currentLocation = [locations lastObject];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];

    [self.lastChangedPosition setObject:@{@"latitude":latitude, @"longitude":longitude}  atIndexedSubscript:0];
    
    [self saveInUserDefaultsLastLocation:self.lastChangedPosition];
    
    [[KSApiClient sharedClient] sendCurrnetLocation:self.lastChangedPosition.firstObject withBlock:
    ^(BOOL result, NSError *error) {
        if(result){
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"hh:mm:ss";
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Location was sent at : %@",[dateFormatter stringFromDate:now]);
            });

        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"last_location"] && self.lastChangedPosition) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка GPS" message:@"Проверьте настройки геолокации!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    });
}


- (NSTimer *) createTimer{
    
    if(!self.timer){
        self.timer = [NSTimer timerWithTimeInterval:STATUS_SENDING_TIMER target:self selector:@selector(setStatusOnline:) userInfo:nil repeats:YES];
    }
    
    return self.timer;

}

#pragma mark
#pragma mark - Other
- (void) saveInUserDefaultsLastLocation:(NSMutableArray  *)lastLocation {

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"last_location"]){
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"last_location"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSUserDefaults standardUserDefaults] setObject:lastLocation forKey: @"last_location"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
