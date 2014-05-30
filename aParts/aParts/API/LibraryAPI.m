//
//  LibraryAPI.m
//  BlueLibrary
//
//  Created by Алекс Скляр on 13.05.14.
//  Copyright (c) 2014 Eli Ganem. All rights reserved.
//

#import "LibraryAPI.h"
#import "PersistencyManager.h"
#import "HTTPClient.h"

@interface LibraryAPI (){
    
    PersistencyManager * persistencyManager;
    HTTPClient * httpClient;
    BOOL isOnline;
}
@end

@implementation LibraryAPI

- (id)init{
    
    self = [super init];
    if (self)
    {
        persistencyManager = [[PersistencyManager alloc] init];
        httpClient = [[HTTPClient alloc] init];
        isOnline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadImage:)
                                                     name:@"BLDownloadImageNotification"
                                                   object:nil];
    }
    return self;
}

+ (LibraryAPI *)sharedInstance {
    // 1
    static LibraryAPI * _sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Fasad methods

- (NSArray *)getAlbums {
    return [persistencyManager getAlbums];
}

- (void)addAlbum:(id)album atIndex:(int)index {
    [persistencyManager addAlbum:album atIndex:index];
    if (isOnline)
    {
        //[httpClient postRequest:@"/api/addAlbum" body:[album description]];
    }
}

- (void)deleteAlbumAtIndex:(int)index {
    [persistencyManager deleteAlbumAtIndex:index];
    if (isOnline)
    {
        //[httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

- (void)downloadImage:(NSNotification *)notification {
    // 1
    NSString * coverUrl = notification.userInfo[@"coverUrl"];
    UIImageView * imageView = notification.userInfo[@"imageView"];
    
    // 2
    imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    
    if (imageView.image == nil){
    	// 3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * image = [httpClient downloadImage:coverUrl];
            
            // 4
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
}

- (void)saveAlbums {
    
    [persistencyManager saveAlbums];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
