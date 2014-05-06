//
//  KSCustomViewController.h
//  klitch
//
//  Created by admin on 14.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSSideMenu.h"

@interface KSCustomViewController : UIViewController

@property (nonatomic, assign) BOOL menuIsVisible;
@property (nonatomic, strong) KSSideMenu *sideMenu;

- (void)addSideMenu;
- (void)menuButtonPressed;
@end
