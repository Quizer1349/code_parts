//  klitch
//
//  Created by admin on 14.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSCustomViewController.h"

@interface KSActivationViewController : KSCustomViewController
{
    NSString *_phoneNumber;
    NSString *_pinCode;
}


@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *actCodeField;
@property (weak, nonatomic) IBOutlet UIButton *activationButton;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *pinCode;
@property (weak, nonatomic) IBOutlet UILabel *pinCodeLabel;

- (IBAction)activateButtonPressed:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
