//
//  KSApiClient+Profile.h
//  klitch
//
//  Created by admin on 27.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient.h"
#import "KSCompletionBlocks.h"

@interface KSApiClient (Profile)

- (void) sendCurrnetLocation:(NSDictionary *)currentLocation withBlock:(KSBooleanCompletionBlock)completion;

- (void) postProfileData:(NSDictionary *)profileData withBlock:(KSBooleanCompletionBlock)completion;

- (void) getProfileDataWithBlock:(KSDictionaryCompletionBlock)completion;

- (void) getProfileImageWithPaceholderImage:(UIImage *)placeholderImage forImageView:(UIImageView *)imageView;

- (void) uploadProfileImage:(UIImage *)image withBlock:(KSBooleanCompletionBlock)completion;

@end
