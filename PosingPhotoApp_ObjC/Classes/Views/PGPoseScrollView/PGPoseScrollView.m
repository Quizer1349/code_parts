//
//  PGPoseScrollView.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 07.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGPoseScrollView.h"
#import "UIImage+Resize.h"
#import "PoseImage.h"
#import "PGBuyFullButton.h"


#define SCROLL_ITEM_WIDTH (IS_IPAD()) ? 165.f : 80.f
#define IPAD_VIEW_SUFFIX @"-ipad"

@interface PGPoseScrollView ()<iCarouselDataSource, iCarouselDelegate>


@end

@implementation PGPoseScrollView

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
    
    if(IS_IPAD()){
        
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), IPAD_VIEW_SUFFIX] owner:self options:nil];
    }else{
        
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    }
    
    if (!CGRectIsEmpty(self.frame)) {
        [self.view setFrame:self.bounds];
    }else{
        [self setFrame:self.view.frame];
    }

    //configure carousel
    self.scrollerView.type = iCarouselTypeCustom;
    self.scrollerView.delegate = self;
    [self addSubview:self.view];
    
}

//imageArray setter with scaling of image
-(void)setImagesArray:(NSArray *)imagesArray {
    
    if(imagesArray.count < 1){
        return;
    }
   // NSMutableArray *tempImgArray = [NSMutableArray array];
    
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        //Background Thread
//        for (PoseImage *poseImage in imagesArray) {
//            UIImage *scaledImage = [UIImage imageWithImage:poseImage.image scaledToSize:CGSizeMake(SCROLL_ITEM_WIDTH , SCROLL_ITEM_WIDTH * DEVICE_HEIGHT/DEVICE_WIDTH)];
//            [tempImgArray addObject:scaledImage];
//        }
        //dispatch_async(dispatch_get_main_queue(), ^(void){
            _imagesArray = [imagesArray mutableCopy];
    
//    
//            BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
//            if(!_isCircuit){
//                if(!isPurchased){
//                    PoseImage *purchaseImage = [[PoseImage alloc] init];
//                    purchaseImage.image = [UIImage imageNamed:const_fileName_needPurchaseIcon];
//                    [_imagesArray addObject:purchaseImage];
//                }
//            }
    
            [self.scrollerView reloadData];
        //});
  //  });
    
    [self setCurrentIndex:0];
    [self.scrollerView  setCurrentItemIndex:0];

    
}

-(void)setLandscapeMode{
    
    if(_isLandscape){
        return;
    }
    
    for (UIView * view in self.scrollerView.visibleItemViews) {
        [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90))];
    }
}

-(void)setPortraitMode{
    
    if(!_isLandscape){
        return;
    }
    
    for (UIView * view in self.scrollerView.visibleItemViews) {
        [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0))];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {
    
    DLog(@"numberOfItemsInCarousel - %d", (int)[self.imagesArray count]);
    
    return (NSInteger)[self.imagesArray count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIImageView *)view {

    //create new view if no view is available for recycling
    if (view == nil) {
        
        @autoreleasepool {
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCROLL_ITEM_WIDTH, SCROLL_ITEM_WIDTH)];
            
            //__block UIImage *scaledImage = [[UIImage alloc] init];
            //        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
            //        if(isPurchased || index != 5){
            
            float newWidthLand;
            if(IS_IPAD()){
                newWidthLand = 165.f  * ([self.imagesArray[index] image].size.width/[self.imagesArray[index] image].size.height);
            }else{
                newWidthLand = 80.f  * ([self.imagesArray[index] image].size.width/[self.imagesArray[index] image].size.height);
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                __block UIImage *scaledImage;
                if (self.imagesArray.count > index) {
                    if([PoseImage isLandscapePhoto:[self.imagesArray[index] image]]){
                        CGSize scaleLandSize = CGSizeMake(newWidthLand, SCROLL_ITEM_WIDTH);
                        //scaledImage = [UIImage imageWithImage:[self.imagesArray[index] image] scaledToSize:scaleLandSize];
                        scaledImage = [[self.imagesArray[index] image]  resizedImageToSize:scaleLandSize];
                    }else{
                        CGSize scaleLandSize = CGSizeMake(SCROLL_ITEM_WIDTH , SCROLL_ITEM_WIDTH  * DEVICE_HEIGHT/DEVICE_WIDTH);
                        //scaledImage = [UIImage imageWithImage:[self.imagesArray[index] image] scaledToSize:scaleLandSize];
                        scaledImage = [[self.imagesArray[index] image]  resizedImageToSize:scaleLandSize];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if(_isCircuit){
                            [view setImage:[scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                        }else{
                            [view setImage:scaledImage];
                        }
                        
                        scaledImage = nil;
                    });
                }
            });
            
            //        }else{
            //            PGBuyFullButton *buyView = [[PGBuyFullButton alloc] initWithFrame:view.frame];
            //            [view addSubview:buyView];
            //        }
            
            //[view setImage:scaledImage];
            view.contentMode = UIViewContentModeTopRight;
            
            if(self.isCircuit){
                
                UIColor *blackColorTrans = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
                view.backgroundColor = blackColorTrans;
                view.tintColor = [UIColor whiteColor];
            }else{
                
                [view.layer setBorderColor:[UIColor whiteColor].CGColor];
                [view.layer setBorderWidth:(IS_IPAD()) ? 4.f :2.f];
            }
            /*Decorate view*/
            view.layer.cornerRadius = (IS_IPAD()) ? 80 : 40;
            view.layer.masksToBounds = YES;
            
            /*Landscape*/
            if(_isLandscape){
                
                [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90))];
            }else{
                [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0))];
            }
        }
        
    }else{
        view.image = nil;
        float newWidthLand;
        if(IS_IPAD()){
            newWidthLand = 165.f  * ([self.imagesArray[index] image].size.width/[self.imagesArray[index] image].size.height);
        }else{
            newWidthLand = 80.f  * ([self.imagesArray[index] image].size.width/[self.imagesArray[index] image].size.height);
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            __block UIImage *scaledImage;
            if (self.imagesArray.count > index) {
                if([PoseImage isLandscapePhoto:[self.imagesArray[index] image]]){
                    CGSize scaleLandSize = CGSizeMake(newWidthLand, SCROLL_ITEM_WIDTH);
                    //scaledImage = [UIImage imageWithImage:[self.imagesArray[index] image] scaledToSize:scaleLandSize];
                    scaledImage = [[self.imagesArray[index] image]  resizedImageToSize:scaleLandSize];
                }else{
                    CGSize scaleLandSize = CGSizeMake(SCROLL_ITEM_WIDTH , SCROLL_ITEM_WIDTH  * DEVICE_HEIGHT/DEVICE_WIDTH);
                    //scaledImage = [UIImage imageWithImage:[self.imagesArray[index] image] scaledToSize:scaleLandSize];
                    scaledImage = [[self.imagesArray[index] image]  resizedImageToSize:scaleLandSize];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if(_isCircuit){
                        [view setImage:[scaledImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                    }else{
                        [view setImage:scaledImage];
                    }
                    
                    scaledImage = nil;
                });
            }
        });
    }
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    
        CGFloat distance = 75.0f; //number of pixels to move the items away from camera
        CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
        return CATransform3DTranslate(transform, offset * self.scrollerView.itemWidth, 0.0f, z);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
            break;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 0.1f;
            break;
        }
        case iCarouselOptionFadeMax:
        {
            return value;
            break;
        }
        case iCarouselOptionShowBackfaces:
        {
            return NO;
            break;
        }
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            if(value == 30){
                return 20.f;
            }else{
                return value;
            }
            break;
        }
            
    }
}


#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    if(!self.delegate){
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(scrollView:didSecetItemAtIndex:)]){
        [self.delegate scrollView:self didSecetItemAtIndex:index];
    }

}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    
    DLog(@"Index: %@", @(self.scrollerView.currentItemIndex));
    
    self.currentIndex = self.scrollerView.currentItemIndex;
    
    if(!self.delegate){
        return;
    }
    
    
    if([self.delegate respondsToSelector:@selector(scrollView:curentItemAtIndex:)]){
        [self.delegate scrollView:self curentItemAtIndex:self.scrollerView.currentItemIndex];
    }
}


@end
