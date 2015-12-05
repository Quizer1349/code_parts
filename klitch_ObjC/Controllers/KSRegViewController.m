//
//  KSRegViewController.m
//  klitch
//
//  Created by Alex on 13.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSRegViewController.h"
#import "KSActivationViewController.h"
#import "KSApiClient.h"
#import "Constants.h"

@interface KSRegViewController () <UITextFieldDelegate>

@end



@implementation KSRegViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.regButton.enabled = YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.phoneField.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - buttons actions

- (IBAction)regButtonPressed:(id)sender{
    
    if([self.phoneField.text length] > 0){
        
        //Disable button for next press
        self.regButton.enabled = NO;
        
        KSApiClient *apiClient = [KSApiClient sharedClient];

        [self.activityIndicatorView startAnimating];
        
        [apiClient registerUserWithName:[NSString string] andPhone:self.phoneField.text withBlock:^(NSDictionary *response, NSError *error){
            if (response) {
                [self.activityIndicatorView stopAnimating];
                //[apiClient generateCryptoWithPin:response[@"pin"] andPinSalt:response[@"pin_salt"]];
                UIStoryboard *Main = [UIStoryboard storyboardWithName:@"Reg" bundle:nil];
                
                KSActivationViewController *ActivationViewController = (KSActivationViewController *)[Main instantiateViewControllerWithIdentifier:@"activationVC"];
                
                ActivationViewController.phoneNumber = self.phoneField.text;
                ActivationViewController.pinCode = response[@"pin"];
                
                //Create User defaults
                NSDictionary *userProfile = @{(NSString *)const_userPrifileNameKey: [NSString string], (NSString *)const_userPrifilePhoneKey: self.phoneField.text};
                
                [[NSUserDefaults standardUserDefaults] setObject:userProfile
                                                              forKey:(NSString *)const_userPrifileKey];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //Go to activation
                [self.navigationController pushViewController:ActivationViewController animated:YES];
                
            } else if(error){
                
                //Enable button
                self.regButton.enabled = YES;
                
                [self.activityIndicatorView stopAnimating];
                
                NSString *decodedString = [[NSString alloc] initWithData:error.userInfo[@"JSONResponseSerializerWithDataKey"]
                                                                encoding:NSUTF8StringEncoding];
                NSLog(@"Server error - %@",decodedString);
                
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка соединения" message:@"Ошибка соединения" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                [errorAlert show];
            }        
        }];
    }else{
        UIAlertView *emptyFieldsAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Заполните все поля!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyFieldsAlert show];
    }
}

- (IBAction)backButtonPressed:(id)sender {

}

- (IBAction)nextField:(id)sender{
    
    [self.phoneField becomeFirstResponder];

}

-(IBAction)backgroundTap:(id)sender{
    
    [self.phoneField resignFirstResponder];
}

#pragma mark -
#pragma mark - Text field delegated phone formatter

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    
//    int length = [self getLength:textField.text];
//    
//    if(length == 12)
//    {
//        if(range.length == 0)
//            return NO;
//    }
//    if(length == 2)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"%@ ",num];
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:0]];
//    }
//    
//    
//    else if(length == 5)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"%@ (%@) ", [num  substringToIndex:2],[num substringFromIndex:2]];
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@ ",[num substringToIndex:2]];
//    }
//    else if(length == 8)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"%@ (%@) %@-",[num  substringToIndex:2],[num substringWithRange:NSMakeRange(2, 3)], [num substringFromIndex:5]];
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@ (%@) %@",[num  substringToIndex:2],[num substringWithRange:NSMakeRange(2, 3)], [num substringFromIndex:5]];
//    }
//    
//    return YES;
//}


/** 
-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 12)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-12];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
}
 **/

@end

