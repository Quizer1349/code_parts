//
//  PGPageForDowloadViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 02.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGPageForDowloadViewController : UIViewController

@property NSUInteger pageIndex;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *descriptionText;
@property (weak, nonatomic) IBOutlet UIImageView *textLayerImage;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@end
