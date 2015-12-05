//
//  KSMapViewController.h
//  klitch
//
//  Created by admin on 26.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSCustomViewController.h"

@interface KSMapViewController : KSCustomViewController

@property(strong, nonatomic) NSString *viewTitle;
@property (strong, nonatomic) NSDictionary *commData;
@property(strong, nonatomic) NSArray *onlineUsersMarkers;
@property(strong, nonatomic) NSArray *readyUsersMarkers;
@property(strong, nonatomic) NSArray *waitingUsersMarkers;
@property(strong, nonatomic) NSDictionary *userDirection;


-(void) refreshData;
@end
