//
//  KSApiClient+Users.h
//  klitch
//
//  Created by admin on 11.03.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient.h"
#import <GoogleMaps/GoogleMaps.h>

@interface KSApiClient (Users)

- (void) setImageForUserWithId:(NSString *)userId andWithCommId:(NSString *)commId placeholderImage:(UIImage *)placeholderImage forImageView:(UIImageView *)imageView;

- (float) calculateDistanceToPointWithLatitude:(NSString *)latitude andLongitude:(NSString *) longitude;

-(void) getOnlineUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion;

-(void) getReadyUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion;

-(void) getWaitingUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion;

-(void) getUserDataForId:(NSString *)userId
               andCommId:(NSString *)commId withBlock:(KSDictionaryCompletionBlock)completion;

@end
