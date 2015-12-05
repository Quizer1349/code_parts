//
//  PGPageConentViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 01.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGPageConentViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *imageFile;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *descriptionText;

@property (weak, nonatomic) IBOutlet UIImageView *favoritesIcon;
@property (weak, nonatomic) IBOutlet UIImageView *tipsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;

@property (weak, nonatomic) IBOutlet UIImageView *stepImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *textLayerImage;


@end
