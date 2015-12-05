//
//  PGPageForDowloadViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 02.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGPageForDowloadViewController.h"

@interface PGPageForDowloadViewController ()

@end

@implementation PGPageForDowloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLable.text = self.titleText;
    self.textLabel.text = self.descriptionText;
    
    [self.titleLable sizeToFit];
    [self.textLabel sizeToFit];
    
    self.textLabel.center = CGPointMake(self.textLayerImage.center.x, self.textLayerImage.center.y);
    self.titleLable.center = CGPointMake(CGRectGetMidX(self.textLabel.frame), self.textLabel.frame.origin.y - self.titleLable.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
