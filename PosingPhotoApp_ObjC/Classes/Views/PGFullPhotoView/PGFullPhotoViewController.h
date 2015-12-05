//
//  PGFullPhotoViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 24.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGFullPhotoViewController : UIViewController

@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, strong) NSDictionary *imagesDictionary;
@property (nonatomic, assign) int currentPhoto;

@end
