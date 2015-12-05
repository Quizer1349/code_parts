//
//  KSMapDirectionService.h
//  klitch
//
//  Created by Алекс Скляр on 04.03.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSMapDirectionService : NSObject

- (void)setDirectionsQuery:(NSDictionary *)object withSelector:(SEL)selector
              withDelegate:(id)delegate;
- (void)retrieveDirections:(SEL)sel withDelegate:(id)delegate;
- (void)fetchedData:(NSData *)data withSelector:(SEL)selector
       withDelegate:(id)delegate;

@end
