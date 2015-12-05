//
//  PersistencyManager.h
//  BlueLibrary
//
//  Created by Алекс Скляр on 13.05.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistencyManager : NSObject

- (NSArray *)getAlbums;

- (void)addAlbum:(id)album atIndex:(NSUInteger)index;

- (void)deleteAlbumAtIndex:(NSUInteger)index;

- (void)saveImage:(UIImage *)image filename:(NSString *)filename;

- (UIImage *)getImage:(NSString *)filename;

- (void)saveAlbums;

@end
