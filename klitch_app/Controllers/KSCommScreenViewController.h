//
//  KSCommScreenViewController.h
//  klitch
//
//  Created by admin on 17.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCustomViewController.h"

@interface KSCommScreenViewController : KSCustomViewController

@property (weak, nonatomic) IBOutlet UILabel *commNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *commImageView;
@property (weak, nonatomic) IBOutlet UITextView *commTextView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) NSString *commId;
@property BOOL needPay;
@property (strong, nonatomic) NSDictionary *commData;



- (IBAction)cancelPressed:(id)sender;
- (IBAction)joinPressed:(id)sender;

@end
