//
//  PGShareButtonsView.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 15.12.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGShareButtonsView.h"

@implementation PGShareButtonsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -
#pragma mark - Gestures handler
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (![hitView isKindOfClass:[UIButton class]])
    {
        return nil;
    }
    else
    {
        return hitView;
    }
}

@end
