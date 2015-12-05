//
//  LibraryAPI.h
//  BlueLibrary
//
//  Created by Алекс Скляр on 13.05.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryAPI : NSObject

+ (LibraryAPI *)sharedInstance;

- (NSArray *)getAlbums;

- (void)addAlbum:(id)album atIndex:(int)index;

- (void)deleteAlbumAtIndex:(int)index;

- (void)saveAlbums;

@end
