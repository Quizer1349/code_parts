//
//  Constants.h
//  klitch
//
//  Created by Kirill Matskevich on 2/26/14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject


#pragma mark
#pragma mark divece constants

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)

#pragma mark
#pragma mark UI constants
extern const float const_ui_sideMenuWidth;
extern const NSString * const const_ui_backgrPortrate;

#pragma mark
#pragma mark cells ids
extern const NSString * const const_cellId_menuItem1;
extern const NSString * const const_cellId_menuItem2;
extern const NSString * const const_cellId_menuItem3;
extern const NSString * const const_cellId_menuItem4;
extern const NSString * const const_cellId_menuItem5;

extern const NSString * const const_cellId_searchResult;

#pragma mark
#pragma mark keys for localizable strings
extern const NSString * const const_locStr_MainTitle;

#pragma mark
#pragma mark id for ViewControllers from storyBoard
extern const NSString * const const_vcId_mainVC;
extern const NSString * const const_vcId_mapVC;
extern const NSString * const const_vcId_mainSearchVC;






#pragma mark
#pragma mark User data
extern const NSString * const const_userHeadersKey;

#pragma mark
#pragma mark User Profile
extern const NSString * const const_userPrifileKey;
extern const NSString * const const_userPrifileNameKey;
extern const NSString * const const_userPrifilePhoneKey;

extern const NSString * const const_userPrifileSettingsKey;
extern const NSString * const const_userPrifileVisibleKey;
extern const NSString * const const_userPrifileAllowKey;
extern const NSString * const const_userPrifileRadiusKey;

typedef enum {
	PTNewKlitch = 0,
    PTNewOffer,
    PTChangedOffer
} PushType;

#pragma mark
#pragma mark notification for KSApiClient activation keys
extern const NSString * const const_ActivationDataKey;
extern const NSString * const const_RegistrationIDKey;
extern const NSString * const const_PinSaltKey;
extern const NSString * const const_Key;
extern const NSString * const const_EncryptedKey;
extern const NSString * const const_PinHashKey;
extern const NSString * const const_TempSaltKey;
extern const NSString * const const_HeaderKey;
extern const NSString * const const_HeaderTempSalt;

#pragma mark
#pragma mark Google API key for maps fw
extern const NSString * const const_GoogleMapsApiKey;

#pragma mark
#pragma mark keys for properties of community object
extern const NSString * const const_SettingsIsFilled;

#pragma mark
#pragma mark id for ViewControllers from storyBoard
extern const NSString * const id_CommOptionsVC;
extern const NSString * const id_CreateKlitchVC;
extern const NSString * const id_MainWaitingHelpVC;
extern const NSString * const id_MyCommsVC;
extern const NSString * const id_MyKlitchVC;


#pragma mark
#pragma mark keys for NSUSerDefaults
extern const NSString * const key_HasSubscription;
extern const NSString * const key_SubscriptionDate;

@end
