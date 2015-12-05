//
//  Rule.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 23.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rule : NSManagedObject

@property (nonatomic, retain) NSNumber * ruleId;
@property (nonatomic, strong) NSString * ruleTitle;
@property (nonatomic, strong) NSString * ruleDescriprion;
@property (nonatomic, retain) NSString * trueImage;
@property (nonatomic, retain) NSString * falseImage;

@end
