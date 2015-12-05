//
//  Favorites.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 21.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Pose;

@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * dressType;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) Pose *favsPose;

+ (BOOL)isAlreadyInFavsImageNamed:(NSString *)imageName forPose:(Pose *)pose;

+ (void)addFavoriteImage:(NSString *)imageName withPose:(Pose *)pose andDressType:(NSString *)dressType;
+ (void)removeFavoriteImage:(NSString *)imageName withPose:(Pose *)pose andDressType:(NSString *)dressType;

+ (UIImage *)getImageForFavItem:(Favorites *)favItem;
+ (NSString *)getImagePathForFavItem:(Favorites *)favItem;
@end
