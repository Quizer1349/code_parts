//
//  PGRulesViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface PGRulesViewController : PGViewController <iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (nonatomic, weak) IBOutlet iCarousel *carousel;


- (IBAction)backButtonPressed:(id)sender;

@end
