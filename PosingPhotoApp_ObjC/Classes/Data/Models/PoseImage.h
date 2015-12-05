//
//  PoseImage.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoseImage : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *fileName;


- (instancetype)initWithPath:(NSString *)path;

+(BOOL)isLandscapePhoto:(UIImage *)image;

@end
