//
//  PGPayDownloadManager.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 08.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PGPayDownloadManagerDeleagte;


@interface PGPayDownloadManager : NSObject


@property (nonatomic, weak)   UIViewController <PGPayDownloadManagerDeleagte> *rootVC;
@property (strong, nonatomic)   MRProgressOverlayView * threadProgressView;
@property (strong, nonatomic)   UIView *dowloadProgressView;

@property (nonatomic)   BOOL isDownloading;

+ (PGPayDownloadManager *)shared;

+ (BOOL)isPayContentAvailable;

+ (NSString *) downloadableContentPath;
+ (NSString *) payContentBundlePath;

- (void)listObjects:(id)sender;
- (void)downloadPayContent;

@end


@protocol PGPayDownloadManagerDeleagte <NSObject>

-(void)downloadManagerDidStartDownload;
-(void)downloadManagerDidStopDownload;
-(void)downloadManagerDidStopDownloadWithErro:(NSError *)error;

-(void)downloadManagerDidUpdateDownloadProgressTo:(CGFloat)progress;

-(void)downloadManagerDidStartUnpacking;
-(void)downloadManagerDidStopUnpacking;

@end