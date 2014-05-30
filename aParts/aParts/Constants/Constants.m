//
//  Constants.m
//  klitch
//
//  Created by Kirill Matskevich on 2/26/14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark
#pragma mark UI constants
const float const_ui_sideMenuWidth = 200.f;
const NSString * const const_ui_backgrPortrate = @"background.jpg";


#pragma mark
#pragma mark cells id
const NSString * const const_cellId_menuItem1 = @"parts";
const NSString * const const_cellId_menuItem2 = @"sto";
const NSString * const const_cellId_menuItem3 = @"tires";
const NSString * const const_cellId_menuItem4 = @"gas";
const NSString * const const_cellId_menuItem5 = @"map";

const NSString * const const_cellId_searchResult = @"searchResult";

#pragma mark
#pragma mark keys for localizable strings
const NSString * const const_locStr_MainTitle = @"main";


#pragma mark
#pragma mark id for ViewControllers from storyBoard
const NSString * const const_vcId_mainVC = @"mainVC";
const NSString * const const_vcId_mapVC = @"mapVC";
const NSString * const const_vcId_mainSearchVC = @"mainSearchVC";


#pragma mark
#pragma mark User data
const NSString * const const_userHeadersKey = @"userData";

#pragma mark
#pragma mark User Profile
const NSString * const const_userPrifileKey = @"userProfile";
const NSString * const const_userPrifileNameKey = @"nick";
const NSString * const const_userPrifilePhoneKey = @"phone";

const NSString * const const_userPrifileSettingsKey = @"userSettings";
const NSString * const const_userPrifileVisibleKey = @"visible";
const NSString * const const_userPrifileAllowKey = @"allow";
const NSString * const const_userPrifileRadiusKey = @"sight_radius";

#pragma mark
#pragma mark notification for KSApiClient
const NSString * const const_ActivationDataKey = @"activationData";
const NSString * const const_RegistrationIDKey = @"registration";
const NSString * const const_PinSaltKey = @"pin_salt";
const NSString * const const_Key = @"key";
const NSString * const const_EncryptedKey = @"encrypted_key";
const NSString * const const_PinHashKey = @"pin_hash";
const NSString * const const_TempSaltKey = @"temp_salt";

const NSString * const const_HeaderKey = @"xHashKey";
const NSString * const const_HeaderTempSalt = @"xTempSalt";

#pragma mark
#pragma mark Google API key for maps fw
const NSString * const const_GoogleMapsApiKey = @"AIzaSyAhUptY43XO8TFRddct007s0q5BjRrxnBA";

#pragma mark
#pragma mark keys for properties of community object
const NSString * const const_SettingsIsFilled = @"settings_is_filled";

#pragma mark
#pragma mark keys for NSUSerDefaults
const NSString * const key_HasSubscription = @"key_HasSubscription";
const NSString * const key_SubscriptionDate = @"key_SubscriptionDate";

@end
