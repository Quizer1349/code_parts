//
//  PGAppDelegate.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 12.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGAppDelegate.h"
#import <CoreData/CoreData.h>
#import "Rule.h"
#import "Pose.h"
#import "GAITracker.h"
#import "GAI.h"
#import "GAIFields.h"
#import "PGShareConfig.h"
#import "SHKConfiguration.h"
#import "PGMainViewController.h"
#import "RMStoreKeychainPersistence.h"
#import "SHKFacebook.h"
#import "LanguageManager.h"
#import "Locale.h"
#import "PGNavigationController.h"
#import <AppodealAds/Appodeal.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "IAPHelper.h"

@import CoreLocation;
@import SystemConfiguration;
@import AVFoundation;
@import ImageIO;

#import <Pushwoosh/PushNotificationManager.h>

@interface PGAppDelegate () <PushNotificationDelegate>

@end



@implementation PGAppDelegate{

    id<RMStoreReceiptVerificator> _receiptVerificator;
    RMStoreKeychainPersistence *_persistence;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self navigationBarCustomization];
    
    //Config app language
    [self languageSetup];
    [self getCurrentLocalization];

    /*Fabric*/
    [Fabric with:@[CrashlyticsKit]];

    
    /*Appodeal*/
    [Appodeal initWithAppId:@"7639b2063987fa0f20a9c987a088436d353ac0e4c093fae8" adTypes:INTERSTITIAL autoCache:NO];
    [Appodeal isLoaded:INTERSTITIAL];
    
    
    /*APNS registration*/
    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    
    
    //Prepare Data
    [self setRulesDefaultData];
    [self setPosesFreeContent];
    
    //Google Analitics
    [self googleAnaliticsConfiguration];
    
    //ShareKit configuration
    DefaultSHKConfigurator *configurator = [[PGShareConfig alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showRateAlertAfterTimesOpened"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Set First launch date
    NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"RFStartDate"];
    if(!start){
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *now = [NSDate date];
        //NSDate *now = [dateFormatter dateFromString:@"2015-07-16"];
        [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"RFStartDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Attach an observer to the payment queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[IAPHelper sharedInstance]];
    
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{

    NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
    return orientations;
}


-(NSString *)getCurrentLocalization {
    
    NSString *localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *curLangCode = [NSLocale componentsFromLocaleIdentifier:localeCode];
    
    [[NSUserDefaults standardUserDefaults] setObject:[curLangCode objectForKey:@"kCFLocaleLanguageCodeKey"] forKey:CURRENT_KEY_LANGUAGE_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return [curLangCode objectForKey:@"kCFLocaleLanguageCodeKey"];
}

- (void)languageSetup {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    LanguageManager *languageManager = [LanguageManager sharedLanguageManager];
    
    // Check whether the language code has already been set.
    if (![userDefaults stringForKey:DEFAULTS_KEY_LANGUAGE_CODE]) {
        
        DLog(@"No language set - trying to find the right setting for the device locale.");
        
        NSLocale *currentLocale = [NSLocale currentLocale];
        
        // Iterate through available localisations to find the matching one for the device locale.
        for (Locale *localisation in languageManager.availableLocales) {
            
            if ([localisation.languageCode caseInsensitiveCompare:[currentLocale objectForKey:NSLocaleLanguageCode]] == NSOrderedSame) {
                
                [languageManager setLanguageWithLocale:localisation];
                break;
            }
        }
        
        // If the device locale doesn't match any of the available ones, just pick the first one.
        if (![userDefaults stringForKey:DEFAULTS_KEY_LANGUAGE_CODE]) {
            
            DLog(@"Couldn't find the right localisation - using default.");
            [languageManager setLanguageWithLocale:languageManager.availableLocales[0]];
        }
    }
    else {
        
        DLog(@"The language has already been set :)");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [SHKFacebook handleDidBecomeActive];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Save data if appropriate
    [SHKFacebook handleWillTerminate];
    
    // Remove the observer
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: [IAPHelper sharedInstance]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSString* scheme = [url scheme];
    
    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]]) {
        return [SHKFacebook handleOpenURL:url sourceApplication:sourceApplication];
    }
    
    
    return YES;
}

#pragma mark -
#pragma mark - Custom methods

- (void)loadMainView {
    
    if (IS_IPAD()) {
        UINavigationController *navVC = [[UIStoryboard storyboardWithName:const_fileName_ipadStoryboard bundle:nil] instantiateInitialViewController];
        self.window.rootViewController = navVC;
        
        //[self.window makeKeyAndVisible];
        
    }else{
        UINavigationController *navVC = [[UIStoryboard storyboardWithName:const_fileName_iphoneStoryboard bundle:nil] instantiateInitialViewController];
        self.window.rootViewController = navVC;
        //[self.window makeKeyAndVisible];
    }
    //[self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:NULL];
}

#pragma mark -
#pragma mark - Nav Bar Customization
- (void) navigationBarCustomization {
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000) forBarMetrics:UIBarMetricsDefault];
}

#pragma mark -
#pragma mark - Core Data getters
- (NSManagedObjectModel *)managedObjectModel {
    
    if(nil != _managedObjectModel)
        return _managedObjectModel;
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)coordinator {
    if(nil != _coordinator)
        return _coordinator;
    
    NSURL *storeURL = [[[[NSFileManager defaultManager]
                         URLsForDirectory:NSDocumentDirectory
                         inDomains:NSUserDomainMask]
                        lastObject]
                       URLByAppendingPathComponent:@"BasicApplication.sqlite"];
    
    _coordinator = [[NSPersistentStoreCoordinator alloc]
                    initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error = nil;
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    NSError *error2 = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error2];
    NSManagedObjectModel *destinationModel = [_coordinator managedObjectModel];
    BOOL pscCompatible = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    
    BOOL isFirstTimelaunch = ![[NSUserDefaults standardUserDefaults] boolForKey:@"is_app_was_launched_before"];
    
    if(!pscCompatible || isFirstTimelaunch) {
        if(![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:options
                                               error:&error]){
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self deleteAllObjects];
    }else{
    
        if(![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:options
                                               error:&error]){
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
    
    return _coordinator;
}

-(void)deleteAllObjects{

    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:const_coreData_posesEntity inManagedObjectContext:self.managedObjectContext]];
    [fetch setIncludesSubentities:NO];
    NSArray * result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    if (result.count > 0) {
        for (id pose in result)
            [self.managedObjectContext deleteObject:pose];
    }
    
    if (![self.managedObjectContext save:nil]) {
        DLog(@"Error deleting");
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"is_app_was_launched_before"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if(nil != _managedObjectContext)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *storeCoordinator = self.coordinator;
    
    if(nil != storeCoordinator){
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark -
#pragma mark - Data preparation
- (void) setRulesDefaultData {
    
    //Is already stored
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:const_coreData_rulesEntity inManagedObjectContext:self.managedObjectContext]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    
    if(count == NSNotFound) {
        DLog(@"Rule - self.managedObjectContext countForFetchRequest:request error:&err - %@", [err localizedDescription]);
    }
    
    if (count > 0) {
        return;
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RulesDefaultData" ofType:@"plist"];
    
    NSArray *rulesStoredArray = [[NSArray alloc] initWithContentsOfFile:path];

    for (NSDictionary *storedRule in rulesStoredArray) {
        Rule *ruleObj = [NSEntityDescription insertNewObjectForEntityForName:const_coreData_rulesEntity
                                                              inManagedObjectContext:self.managedObjectContext];
        ruleObj.ruleId          = [storedRule objectForKey:@"id"];
        ruleObj.ruleTitle       = [storedRule objectForKey:@"ruleTitle"];
        ruleObj.ruleDescriprion = [storedRule objectForKey:@"ruleDescriprion"];
        
        NSString *deviceType = [NSString string];
        if(Is3_5Inches()) {
            deviceType = @"iphone4";
        }else if (IS_IPAD()){
            deviceType = @"ipad";
        }else{
            deviceType = @"iphone5";
        }
        
        ruleObj.trueImage = [NSString stringWithFormat:@"%@-full-%@" , [storedRule objectForKey:@"trueImage"], deviceType];
        ruleObj.falseImage = [NSString stringWithFormat:@"%@-full-%@" , [storedRule objectForKey:@"falseImage"], deviceType];

        //DLog(@"rule - %@", ruleObj);
    }
    
    if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:nil]){
        DLog(@"Unresolved error!");
        abort();
    }

}

- (void) setPosesFreeContent {
    //Is already stored
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:const_coreData_posesEntity inManagedObjectContext:self.managedObjectContext]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&err];
    
    if(count == NSNotFound) {
        DLog(@"Pose - self.managedObjectContext countForFetchRequest:request error:&err - %@", [err localizedDescription]);
    }
    
    if (count > 0) {
        return;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:const_fileName_freeContentBundleName ofType:@"plist"];
    
    NSArray *posesStoredArray = [[NSArray alloc] initWithContentsOfFile:path];
    
    for (NSDictionary *storedPose in posesStoredArray) {
        Pose *poseObj = [NSEntityDescription insertNewObjectForEntityForName:const_coreData_posesEntity
                                                      inManagedObjectContext:self.managedObjectContext];
        poseObj.poseId     = [storedPose objectForKey:@"poseId"];
        poseObj.poseTitle  = [storedPose objectForKey:@"poseTitle"];
        poseObj.poseImage  = [storedPose objectForKey:@"poseImage"];
        poseObj.posePath   = [storedPose objectForKey:@"posePath"];
        poseObj.mainPose   = [storedPose objectForKey:@"mainPose"];
        poseObj.dressCount = [storedPose objectForKey:@"dressCount"];
        poseObj.order      = [storedPose objectForKey:@"order"];
        poseObj.isSubPose  = [NSNumber numberWithBool:[[storedPose objectForKey:@"mainPose"] length] > 0];
        poseObj.isFree     = [[storedPose objectForKey:@"isFree"] boolValue];
        //DLog(@"pose - %@", poseObj);
    }
    
    if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:nil]){
        DLog(@"Unresolved error!");
        abort();
    }
}

#pragma mark -
#pragma mark - Push Notifications
// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    DLog(@"Push notification received");
}


#pragma mark -
#pragma mark - Google Analitics
-(void)googleAnaliticsConfiguration {

    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_TRACKING_ID];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];

    [[GAI sharedInstance] setDefaultTracker:tracker];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [[GAI sharedInstance] setOptOut:YES];
            break;
        case 1:
            [[GAI sharedInstance] setOptOut:NO];
            break;
            
        default:
            break;
    }
}


@end
