//
//  JSONResponseSerializerWithData.h
//  klitch
//
//  Created by admin on 21.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer
@end
