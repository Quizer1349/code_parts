//
//  KSRegViewController.h
//  klitch
//
//  Created by Alex on 13.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCustomViewController.h"

@interface KSRegViewController : KSCustomViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *regButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;


- (IBAction)regButtonPressed:(id)sender;
- (IBAction)nextField:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
