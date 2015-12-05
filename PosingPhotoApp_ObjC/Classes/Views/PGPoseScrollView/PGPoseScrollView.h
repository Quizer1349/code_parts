//
//  PGPoseScrollView.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 07.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@protocol PGPoseScrollViewDelegate;

@interface PGPoseScrollView : UIView

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundeImageView;
@property (weak, nonatomic) IBOutlet iCarousel *scrollerView;
@property (assign, nonatomic) NSInteger currentIndex;

@property (weak, nonatomic) id<PGPoseScrollViewDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *imagesArray;

@property BOOL isCircuit;
@property BOOL isLandscape;

-(void)setLandscapeMode;
-(void)setPortraitMode;

@end


@protocol PGPoseScrollViewDelegate <NSObject>

@optional

- (void)scrollView:(PGPoseScrollView *)scrollView didSecetItemAtIndex:(NSInteger)index;
- (void)scrollView:(PGPoseScrollView *)scrollView curentItemAtIndex:(NSInteger)index;

@end