//
//  PGFavsTableCell.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 21.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGFavsTableCell.h"
#import "iCarousel.h"
#import "Favorites.h"
#import "Pose.h"
#import "PoseImage.h"
#import "UIImage+Resize.h"

@interface PGFavsTableCell()<iCarouselDelegate, iCarouselDataSource>

@end


@implementation PGFavsTableCell

- (void)awakeFromNib {
    
    //configure carousel
    self.imgScroller.type = iCarouselTypeCustom;
    self.imgScroller.delegate = self;
    
    if (Is3_5Inches()) {
        self.imgScroller.frame = CGRectMake(X(self.imgScroller), Y(self.imgScroller), WIDTH(self.imgScroller) - 23.f, 125.f);
        self.shareMenu.frame = CGRectMake(X(self.shareMenu), Y(self.imgScroller) + 123.f, WIDTH(self.shareMenu), HEIGHT(self.shareMenu));
        
        self.leftArrow.center = CGPointMake(self.leftArrow.center.x, self.imgScroller.center.y);
        self.rightArrow.center = CGPointMake(self.rightArrow.center.x, self.imgScroller.center.y);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)leftArrowPressed:(id)sender {

    NSInteger nextIndex = self.imgScroller.currentItemIndex - 1;
    
    if(nextIndex >= 0 && nextIndex <= self.imagesArray.count){
        [self.imgScroller scrollToItemAtIndex:nextIndex animated:YES];
    }
}

- (IBAction)rightArrowPressed:(id)sender {

    NSInteger nextIndex = self.imgScroller.currentItemIndex + 1;
    
    if(nextIndex >= 0 && nextIndex <= self.imagesArray.count){
        [self.imgScroller scrollToItemAtIndex:nextIndex animated:YES];
    }
}

-(void)setFavsArray:(NSArray *)favsArray {

    if(favsArray.count > 0){
        
        //Sort images by orientation
       _favsArray = [[favsArray sortedArrayUsingComparator:^NSComparisonResult(Favorites *obj1, Favorites *obj2) {
           
           if (![PoseImage isLandscapePhoto:[Favorites getImageForFavItem:obj1]]
                && [PoseImage isLandscapePhoto:[Favorites getImageForFavItem:obj2]]) {
                
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if ([PoseImage isLandscapePhoto:[Favorites getImageForFavItem:obj1]]
                && ![PoseImage isLandscapePhoto:[Favorites getImageForFavItem:obj2]]) {
                
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
            
        }] mutableCopy];
        

        self.imagesArray = [NSMutableArray array];
        for(Favorites *favItem in _favsArray){
            
            UIImage *imageFav = [Favorites getImageForFavItem:favItem];
            if (imageFav) {
                [self.imagesArray addObject:imageFav];
            }
        }
        
        if(self.imagesArray.count > 0){
            
//            //Sort images by orientation
//            self.imagesArray = [[self.imagesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                
//                if (![PoseImage isLandscapePhoto:obj1] && [PoseImage isLandscapePhoto:obj2]) {
//                    return (NSComparisonResult)NSOrderedAscending;
//                }
//                
//                if ([PoseImage isLandscapePhoto:obj1] && ![PoseImage isLandscapePhoto:obj2]) {
//                    return (NSComparisonResult)NSOrderedDescending;
//                }
//                
//                return (NSComparisonResult)NSOrderedSame;
//                
//            }] mutableCopy];
            
            [self.imgScroller reloadData];
            [self.imgScroller setCurrentItemIndex:0];
        }
        
        if(self.imagesArray){
            if(self.imagesArray.count == 1){
                self.shareMenu.shareItem = [SHKItem image:self.imagesArray.lastObject title:NSLocalizedString(self.poseTitleLabel.text, nil)];
            }else if (self.imagesArray.count > 1){
//                NSMutableArray *itemsTempArray = [[NSMutableArray alloc] init];
                
//                for (UIImage *image in self.imagesArray) {
//                    [itemsTempArray addObject:[SHKItem image:image title:NSLocalizedString(self.poseTitleLabel.text, nil)]];
//                }
//                
                //self.shareMenu.shareItemsArray = itemsTempArray;
            }
        }
    }
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {
    
    return (NSInteger)[self.imagesArray count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIImageView *)view {
    
    //create new view if no view is available for recycling
    if (view == nil) {
        
        UIImage *itemImage = self.imagesArray[index];
        __block UIImage *scaledImage = [[UIImage alloc] init];
        if (![PoseImage isLandscapePhoto:itemImage]) {
            
            CGSize imageSize = CGSizeMake(HEIGHT(self.imgScroller) / (DEVICE_HEIGHT / DEVICE_WIDTH),  HEIGHT(self.imgScroller));
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, imageSize.width,  imageSize.height)];
            
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                 scaledImage = [itemImage resizedImageToSize:imageSize];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [view setImage:scaledImage];
                 });
                 
             });
        }else{
            
            CGSize imageSize = CGSizeMake(HEIGHT(self.imgScroller), HEIGHT(self.imgScroller) / (DEVICE_HEIGHT / DEVICE_WIDTH));
            view = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, imageSize.width, imageSize.height)];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                scaledImage = [itemImage resizedImageToSize:imageSize];
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view setImage:scaledImage];
                });
                
            });
            
        }
        
        view.contentMode = UIViewContentModeScaleToFill;
        
        /*Decorate view*/
        [view.layer setBorderColor:[UIColor whiteColor].CGColor];
        [view.layer setBorderWidth:2.f];
        view.layer.masksToBounds = YES;
        
    }else{
        [view setImage:self.imagesArray[index]];
    }
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    
    float itemWidth = [_carousel itemViewAtIndex:_carousel.currentItemIndex].frame.size.width;
    
    CGFloat distance = 75.0f; //number of pixels to move the items away from camera
    CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
    return CATransform3DTranslate(transform, offset * itemWidth, 0.0f, z);
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
                return 100.f;
            }else{
                return value;
            }
            break;
        }
            
    }
}

//-(void)prepareForReuse{
//
//    self.imgScroller = nil;
//    self.poseTitleLabel.text = nil;
//}


#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    if(!self.delegate){
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(cellView:didSelectItemAtIndex:)]){
        [self.delegate cellView:self didSelectItemAtIndex:index];
    }
    
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    
    DLog(@"Index: %@", @(self.imgScroller.currentItemIndex));
    if(!self.delegate){
        return;
    }
    
    if(!self.delegate){
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(cellView:curentItemAtIndex:)]){
        [self.delegate cellView:self curentItemAtIndex:self.imgScroller.currentItemIndex];
    }
    
    self.shareMenu.shareItem = [SHKItem image:self.imagesArray[self.imgScroller.currentItemIndex] title:NSLocalizedString(self.poseTitleLabel.text, nil)];
}

@end
