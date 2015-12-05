//
//  PGPageConentViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 01.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGPageConentViewController.h"

@interface PGPageConentViewController ()

@end

@implementation PGPageConentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(Is3_5Inches()){
        
        self.stepImageView.frame = CGRectMake(self.stepImageView.frame.origin.x, self.stepImageView.frame.origin.y, self.stepImageView.frame.size.width, self.stepImageView.frame.size.height - 50.f);
        self.textLayerImage.center = CGPointMake(self.textLayerImage.center.x, self.textLayerImage.center.y - 50.f);
        self.titleLable.center = CGPointMake(self.titleLable.center.x, self.titleLable.center.y - 50.f);
        self.textLabel.center = CGPointMake(self.textLabel.center.x, self.textLabel.center.y - 50.f);
        self.tipsIcon.center = CGPointMake(self.tipsIcon.center.x, self.tipsIcon.center.y - 50.f);
        self.favoritesIcon.center = CGPointMake(self.favoritesIcon.center.x, self.favoritesIcon.center.y - 50.f);
        self.photoIcon.center = CGPointMake(self.photoIcon.center.x, self.photoIcon.center.y - 50.f);
    }
    
    UIImage *pageImage = [UIImage imageNamed:self.imageFile];
    self.stepImageView.image = pageImage;
    self.titleLable.text = self.titleText;
    self.textLabel.text = self.descriptionText;
    
    if (self.pageIndex == 3) {
        self.tipsIcon.hidden = NO;
        self.favoritesIcon.hidden = YES;
        self.photoIcon.hidden = YES;
    }else if(self.pageIndex == 5){
        self.tipsIcon.hidden = YES;
        self.favoritesIcon.hidden = NO;
        self.photoIcon.hidden = YES;
    }else if(self.pageIndex == 4){
        self.tipsIcon.hidden = YES;
        self.favoritesIcon.hidden = YES;
        self.photoIcon.hidden = NO;
    }else{
        self.tipsIcon.hidden = YES;
        self.favoritesIcon.hidden = YES;
        self.photoIcon.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
