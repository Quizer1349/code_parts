//
//  PGBuyFullButton.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 22.05.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGBuyFullButton : UIView

@property (strong, nonatomic) IBOutlet UIView *view_iphone;
@property (strong, nonatomic) IBOutlet UIView *view_ipad;
@property (weak, nonatomic) IBOutlet UILabel *textLabelIphone;
@property (weak, nonatomic) IBOutlet UILabel *textLabelIpad;

@end
