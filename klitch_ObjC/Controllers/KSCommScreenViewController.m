//
//  KSCommScreenViewController.m
//  klitch
//
//  Created by admin on 17.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSCommScreenViewController.h"
#import "KSApiClient+Communities.h"
#import "KSApiClient+Payment.h"
#import "KSMyCommsViewController.h"
#import "Constants.h"
#import "KSSubscriptionHelper.h"

@interface KSCommScreenViewController ()

@end

@implementation KSCommScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.needPay = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Customize Image
    self.commImageView.layer.borderWidth = 2.0f;
    self.commImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.commImageView.layer.cornerRadius = 5.0f;
    self.commImageView.layer.masksToBounds = YES;
    
    //Set data
    self.commNameLabel.text = self.commData[@"name"];
    self.commTextView .text = self.commData[@"description"];
    [[KSApiClient sharedClient] setImageForCommWithId:self.commData[@"id"]
                                     placeholderImage:nil
                                         forImageView:self.commImageView];
    self.needPay = [self.commData[@"is_paid"] boolValue];
    
    [KSSubscriptionHelper validateCommAdding:self.commData];
//    [self checkSubscription];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinPressed:(id)sender{
    
    [self checkSubscription];
}

+ (void) validateCommAdding:(NSDictionary *)comm{
    

}

- (void) checkSubscription{
        //1. check subscriptions
        //if available subscription is present - we should add a community
        //else we should check if community is paid
        //if comm is paid then we should show payment screen
        //else we should check date of registration (there are 2 month of free comm using)
        //if free period is activated we should add comm
        //else we should check a count of users communities (should be only 1 free comunity)
        //if there 0 available comm, then we should add com
        //else we should show message with variants (pay, remove others, exit)
    
    [[KSApiClient sharedClient] getSubscribtionsWithBlock:^(NSArray *response, NSError *error) {
        
        if(!error && response && response.count > 0){
                //have available subscription
            [self addCommunity];
        }else if(!error && response){
                //haven't any subscriptions
            if([[self.commData objectForKey:@"is_paid"] boolValue]){
                    //comm is paid
                    //should show a payment screen
                [self performSegueWithIdentifier:@"payment" sender:self];
            }else{
                    //comm is free
                [KSSubscriptionHelper isTwoMonthFreePeriodEndedWithBlock:^(NSDictionary *response, NSError *error) {
                    if(![response[@"isEnded"] boolValue]){
                            //the free period is activated
                        [self addCommunity];
                    }else{
                        [[KSApiClient sharedClient] getMembershipCommunitiesWithBlock:
                         ^(NSArray *response, NSError *error) {
                             if(response){
                                 if(response.count > 0){
                                         //we should show notification
                                     [self performSegueWithIdentifier:@"payment" sender:self];
                                 }else{
                                         //we should add comm
                                     [self addCommunity];
                                 }
                             } else if (error){
                                     //show error
                                 NSLog(@"%@", error);
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                 [alertView show];
                             }
                         }];
                    }
                }];
            }
        }else{
                //get an error
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

- (void) addCommunity{
    [[KSApiClient sharedClient] createMembershipWithCommId: self.commData[@"id"] withBlock:^(BOOL result, NSError *error) {
        
        if(result){
            
            KSMyCommsViewController *myCommsViewController = (KSMyCommsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:(NSString *)id_MyCommsVC];
            [self.navigationController pushViewController:myCommsViewController animated:YES];
        }
        else{
            
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (IBAction)cancelPressed:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}
@end
