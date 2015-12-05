//
//  Rule.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 23.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "Rule.h"


@interface Rule (PrimitiveAccessors)
- (NSString *)primitiveRuleTitle;
- (NSString *)primitiveRuleDescriprion;
@end

@implementation Rule

@dynamic ruleId;
@dynamic ruleTitle;
@dynamic ruleDescriprion;
@dynamic trueImage;
@dynamic falseImage;

-(NSString *)ruleTitle {

    [self willAccessValueForKey:@"ruleTitle"];
    NSString *locRuleTitle =  NSLocalizedString([self primitiveRuleTitle], nil);
    [self didAccessValueForKey:@"ruleTitle"];
    return locRuleTitle;
}


- (NSString *)ruleDescriprion {

    [self willAccessValueForKey:@"ruleDescriprion"];
    NSString *locRuleDescriprion =  NSLocalizedString([self primitiveRuleDescriprion], nil);
    [self didAccessValueForKey:@"ruleDescriprion"];
     return locRuleDescriprion;
}

@end
