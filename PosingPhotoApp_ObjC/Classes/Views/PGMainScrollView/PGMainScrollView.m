//
//  PGMainScrollView.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 20.11.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGMainScrollView.h"

@implementation PGMainScrollView

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch *touch = [touches anyObject];
    
    if(touch.phase == UITouchPhaseMoved)
    {
        return NO;
    }
    else
    {
        return [super touchesShouldBegin:touches withEvent:event inContentView:view];
    }
}

-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
