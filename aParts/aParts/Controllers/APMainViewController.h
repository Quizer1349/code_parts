//
//  APViewController.h
//  aParts
//
//  Created by admin on 09.04.14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FXBlurView;

@interface APMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBarItem;
@property (strong, nonatomic) IBOutlet UISearchBar *searchFieldBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (strong, nonatomic) IBOutlet FXBlurView *blurVIew;
//@property (weak, nonatomic) IBOutlet UIImageView *backImage;

-(IBAction)displaySearchBar:(id)sender;

@end
