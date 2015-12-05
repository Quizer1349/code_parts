//
//  Pose.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 01.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pose : NSManagedObject

@property (nonatomic, retain) NSString * poseTitle;
@property (nonatomic, retain) NSString * poseImage;
@property (nonatomic, retain) NSString * posePath;
@property (nonatomic, retain) NSNumber * isSubPose;
@property (nonatomic, retain) NSString * mainPose;
@property (nonatomic, retain) NSNumber * poseId;
@property (nonatomic, retain) NSNumber * dressCount;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic) BOOL isFree;

@end
