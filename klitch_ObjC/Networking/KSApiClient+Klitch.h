//
//  KSApiClient+Klitch.h
//  klitch
//
//  Created by admin on 03.03.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient.h"

@interface KSApiClient (Klitch)


- (void) createKlitchWithParams:(NSDictionary *)params withBlock:(KSDictionaryCompletionBlock)completion;

- (void) getMyKlitchDataById:(NSString *)klitchId withBlock:(KSDictionaryCompletionBlock)completion;

- (void) deleteKlitchWithId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion;

- (void) finishKlitchWithId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion;

- (void) createMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion;

- (void) setIncomingOfferStatus:(NSString *)status InKlitchId:(NSString *)klitchId
                   andForUserId:(NSString*)userId withBlock:(KSBooleanCompletionBlock)completion;

- (void) getMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSDictionaryCompletionBlock)completion;

- (void) deleteMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion;

- (void) getWaitingHelpKlitchesForCommId:(NSString *)commId waithBlock:(KSArrayCompletionBlock)completion;

- (void) getReadyHelpForMyKlitchWithCommId:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion;

@end
