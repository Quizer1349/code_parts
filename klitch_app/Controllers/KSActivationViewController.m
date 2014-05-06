//
//  KSActivationViewController.m
//  klitch
//
//  Created by admin on 14.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSActivationViewController.h"
#import "KSApiClient.h"
#import "Constants.h"

@interface KSActivationViewController ()

@end

@implementation KSActivationViewController

@synthesize phoneNumber = _phoneNumber;
@synthesize pinCode = _pinCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //Pass phone number to phone phoneNumberText view
    self.phoneNumberLabel.text = [NSString stringWithFormat:self.phoneNumberLabel.text, self.phoneNumber];
    
    //Debug PIN code
    
    //self.pinCodeLabel.text = [NSString stringWithFormat:self.pinCodeLabel.text, self.pinCode];
    //[self.actCodeField setText:[self pinCode]];
    //self.pinCodeLabel.hidden = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)activateButtonPressed:(id)sender {
    
    if([self.actCodeField.text length] > 0){
        
        // Check pin code
        if(![self.pinCode isEqualToString:self.actCodeField.text]){
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка акцивации" message:@"Введен неправильный ПИН!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlert show];
            return;
        }
        
        [[KSApiClient sharedClient] activateUserWithPin:self.actCodeField.text withBlock:^(NSDictionary *response, NSError *error){
            if (response) {
                UIStoryboard *MainApp = [UIStoryboard storyboardWithName:@"App" bundle:nil];
                [self presentViewController:[MainApp instantiateInitialViewController] animated:YES completion:nil];
            } else if(error){
                NSMutableDictionary *dictionaryForUserDefault = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_userPrifileKey] mutableCopy];
                
                if(dictionaryForUserDefault)
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:(NSString *)const_userPrifileKey];
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка акцивации" message:@"Ошибка акцивации" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [errorAlert show];
            }
        }];
    }else{
        UIAlertView *emptyFieldsAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Введите код активации!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyFieldsAlert show];
    }
}

-(IBAction)backgroundTap:(id)sender {
    
    [self.actCodeField resignFirstResponder];
}
@end
