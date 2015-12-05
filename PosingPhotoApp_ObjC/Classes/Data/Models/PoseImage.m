//
//  PoseImage.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PoseImage.h"

@implementation PoseImage

- (instancetype)initWithPath:(NSString *)path {
    
    self = [self init];
    
    if (self) {
        self.path = path;
        self.image = [UIImage imageWithContentsOfFile:path];
        self.fileName = [self getFilenameFromPath];
    }
    
    return self;
}

- (NSString *)getFilenameFromPath {

    if(!self.path)
        return nil;
    
    NSMutableString *imageName = [[[self.path lastPathComponent] stringByDeletingPathExtension] mutableCopy];
    return [imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
}

#pragma mark -
#pragma mark - Check photo orientation

+(BOOL)isLandscapePhoto:(UIImage *)image{
    
    DLog(@"isLandscapePhoto image - %@", NSStringFromCGSize(CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage))));
    
    if (CGImageGetHeight(image.CGImage) < CGImageGetWidth(image.CGImage)) {
        return YES;
    }
    
    return NO;
}

@end
