//
//  PGCircuitView.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 19.11.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGCircuitView.h"

@interface PGCircuitView (){

     NSMutableArray *fingers;
}

@end

@implementation PGCircuitView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

-(void)baseInit {
    
    self.frame = CGRectMake(X(self), Y(self), WIDTH(self), DEVICE_HEIGHT);
    DLog(@"self.frame = %@", NSStringFromCGRect(self.frame));
    self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
    //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView setTintColor:[UIColor whiteColor]];
    
    [self addSubview:self.imageView];
    
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
    [self.imageView addGestureRecognizer:twoFingerPinch];
    
    UIPanGestureRecognizer *dragGesure = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerDrag:)];
    dragGesure.maximumNumberOfTouches = 1;
    [self.imageView addGestureRecognizer:dragGesure];
    
}


-(void)setImage:(UIImage *)image {
    
    self.isMirrored = NO;
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *)image {

    return self.imageView.image;
}

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)gesture {

    [self adjustAnchorPointForGestureRecognizer:gesture];
    
//    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
//        if (gesture.scale >0.5f && gesture.scale < 2.5f) {
//            if (self.isMirrored) {
//                [gesture view].transform = CGAffineTransformMakeScale(- 1.0, 1.0);
//            }else{
//                [gesture view].transform = CGAffineTransformMakeScale(1.0, 1.0);
//            }
//            [gesture view].transform = CGAffineTransformScale([[gesture view] transform], [gesture scale], [gesture scale]);
//            [gesture setScale:1];
//
//        }
//    }
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        if (gesture.scale >0.5f && gesture.scale < 2.5f) {
            [gesture view].transform = CGAffineTransformScale([[gesture view] transform], [gesture scale], [gesture scale]);
            [gesture setScale:1];
        }
    }
}

- (void)oneFingerDrag:(UIPanGestureRecognizer *)gesture {
   
    UIView *piece = [gesture view];
    
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gesture setTranslation:CGPointZero inView:[piece superview]];
    }
    
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}


@end
