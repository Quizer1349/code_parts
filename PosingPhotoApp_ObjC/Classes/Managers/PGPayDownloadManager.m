//
//  PGPayDownloadManager.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 08.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGPayDownloadManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import "ZipArchive.h"
#import "MISAlertController.h"



@interface PGPayDownloadManager(){

    __block float _progress;
}

@property (nonatomic, strong) NSMutableArray *collection;

@end



@implementation PGPayDownloadManager


+ (PGPayDownloadManager *)shared {

    static PGPayDownloadManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PGPayDownloadManager alloc] init];
        
        
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

+ (NSString *) payContentBundlePath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *payBundlePath = [[PGPayDownloadManager downloadableContentPath] stringByAppendingPathComponent:F(@"%@.bundle", const_fileName_payContentBundleName)];
    if([fileManager fileExistsAtPath:payBundlePath]){
        
        return payBundlePath;
    }else{
        
        return @"";
    }
}


+(BOOL)isPayContentAvailable{
    
    BOOL result = NO;
    
    BOOL wasLoaded = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *payBundlePath = [[PGPayDownloadManager downloadableContentPath] stringByAppendingPathComponent:F(@"%@.bundle", const_fileName_payContentBundleName)];
    BOOL filesAvailable = [fileManager fileExistsAtPath:payBundlePath];
    
    if(wasLoaded && filesAvailable){
        
        result = YES;
    }
    
    return result;
}


+ (NSString *) downloadableContentPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    directory = [directory stringByAppendingPathComponent:@"Downloads"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:directory] == NO) {
        
        NSError *error;
        if ([fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            DLog(@"Error: Unable to create directory: %@", error);
        }
        
        NSURL *url = [NSURL fileURLWithPath:directory];
        // exclude downloads from iCloud backup
        if ([url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error] == NO) {
            DLog(@"Error: Unable to exclude directory from backup: %@", error);
        }
    }
    
    return directory;
}



-(id) init {
    
    self = [super init];
    if (self) {
        
        AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                        identityPoolId:CognitoIdentityPoolId];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                             credentialsProvider:credentialsProvider];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        self.collection = [NSMutableArray new];
    }
    return self;
}

- (void)listObjects:(id)sender {
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    listObjectsRequest.bucket = S3BucketNamePay;
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"listObjects failed: [%@]", task.error);
        } else {
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            for (AWSS3Object *s3Object in listObjectsOutput.contents) {
                NSString *downloadingFilePath = [[PGFreeDownloadManager downloadableContentPath] stringByAppendingPathComponent:s3Object.key];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                
                AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                downloadRequest.bucket = S3BucketNamePay;
                downloadRequest.key = s3Object.key;
                downloadRequest.downloadingFileURL = downloadingFileURL;
                
                if(self.collection.count == 0){
                
                    [self.collection addObject:downloadRequest];
                    
                }else if(![self.collection containsObject:downloadRequest]){
                    BOOL hasKay = NO;
                    for (AWSS3TransferManagerDownloadRequest *request in self.collection) {
                        if([request.key isEqualToString:downloadRequest.key]){
                            hasKay = YES;
                        }
                    }
                    if(!hasKay)
                        [self.collection addObject:downloadRequest];
                }

            }
            
            [self downloadPayContent];
        }
        return nil;
    }];

}

-(void)downloadPayContent{
    
    NSString *downloadRequestKey = F(@"%@.zip" ,[self currentDeviceType]);
    NSString *downloadingFilePath = [[PGPayDownloadManager downloadableContentPath] stringByAppendingPathComponent:downloadRequestKey];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = S3BucketNamePay;
    downloadRequest.key = downloadRequestKey;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    if (!_isDownloading) {
        [self download:downloadRequest];
    }
}
                 
 - (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest {
     
     if(self.rootVC && [self.rootVC respondsToSelector:@selector(downloadManagerDidStartDownload)]){
         
         [self.rootVC downloadManagerDidStartDownload];
         _isDownloading = YES;
     }else{
         
         [self showProgress];
     }
     
     downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
         
         __weak PGPayDownloadManager *weakSelf = self;
         dispatch_async(dispatch_get_main_queue(), ^{
             if (totalBytesExpectedToWrite > 0) {
                 _progress = (float)(((double) totalBytesWritten / totalBytesExpectedToWrite) * 0.50f);
                 
                 if(weakSelf.rootVC){
                     
                     [weakSelf.rootVC downloadManagerDidUpdateDownloadProgressTo:_progress];
                 }else{
                     
                     [weakSelf.threadProgressView setProgress:_progress animated:YES];
                 }
                 DLog(@"Free content downloading RUNING with progress - %f", _progress);
             }
         });
     };
     
     switch (downloadRequest.state) {
         case AWSS3TransferManagerRequestStateNotStarted:
         case AWSS3TransferManagerRequestStatePaused:
         {
             AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
             [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
                 if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
                     && task.error.code == AWSS3TransferManagerErrorPaused) {
                     
                     
                 } else if (task.error) {
                     
                     __weak PGPayDownloadManager *weakSelf = self;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if(weakSelf.rootVC && [weakSelf.rootVC respondsToSelector:@selector(downloadManagerDidStopDownloadWithErro:)]){

                             [weakSelf.rootVC downloadManagerDidStopDownloadWithErro:task.error];
                             _isDownloading = NO;
                         }else{
                             
                             [weakSelf hideProgress];
                         }
                     });
                     
                 } else {
                     [self setDownloadState:downloadRequest];
                     
                 }
                 return nil;
             }];
         }
             break;
             
         case AWSS3TransferManagerRequestStateRunning:{
             
             
             DLog(@"Pay content downloading RUNING with progress - %f", _progress);
         }
             break;
             
         default:
             break;
     }
 }
 
 
 -(void)setDownloadState:(AWSS3TransferManagerDownloadRequest *)request{
     
     
     switch (request.state) {
         case AWSS3TransferManagerRequestStateNotStarted:
         case AWSS3TransferManagerRequestStatePaused:
             
             DLog(@"Pay content downloading POUSED");
             break;
             
         case AWSS3TransferManagerRequestStateCanceling:
             _isDownloading = NO;
             DLog(@"Pay content downloading CANCELED");
             break;
             
         case AWSS3TransferManagerRequestStateCompleted:
             
             DLog(@"Pay content downloading COMPLETED");
             
             if(self.rootVC){
                 if([self.rootVC respondsToSelector:@selector(downloadManagerDidStopDownload)])
                     [self.rootVC downloadManagerDidStopDownload];
             }
             
             [self unZipFile:request.downloadingFileURL];
             break;
             
             
         default:
             break;
     }
 }
 
 -(void)unZipFile:(NSURL*)downloadURL {
     
     NSString *path = [downloadURL path];
     ZipArchive *zipArchive = [[ZipArchive alloc] init];
     
     __weak PGPayDownloadManager *weakSelf = self;
     float leftProgress = _progress;
     zipArchive.progressBlock = ^ (int percentage, int filesProcessed, unsigned long numFiles){

         _progress = ((1.0 - leftProgress) * (percentage / 100.f) + leftProgress);
         dispatch_async(dispatch_get_main_queue(), ^{
             DLog(@"UNPACKING RUNING with progress - %f", _progress);
             if(weakSelf.rootVC){
                 
                 [weakSelf.rootVC downloadManagerDidUpdateDownloadProgressTo:_progress];
             }else{
                 
                 [weakSelf.threadProgressView setProgress:_progress animated:YES];
             }
         });
     };
     [zipArchive UnzipOpenFile:path];
     
     if(self.rootVC){
         if([self.rootVC respondsToSelector:@selector(downloadManagerDidStartUnpacking)])
             [self.rootVC downloadManagerDidStartUnpacking];
     }
     
     if([zipArchive UnzipFileTo:[path stringByDeletingLastPathComponent] overWrite:YES]){
         
         [zipArchive UnzipCloseFile];
         
         //Remove archive
         NSFileManager *fileManager = [NSFileManager defaultManager];
         [fileManager removeItemAtPath:[downloadURL path] error:NULL];
         
         [self hideProgress];
         
         if(self.rootVC){
             if([self.rootVC respondsToSelector:@selector(downloadManagerDidStopUnpacking)])
                 [self.rootVC downloadManagerDidStopUnpacking];
         }
         
     }else{
         
         MISAlertController *alertController = [MISAlertController alertControllerWithTitle:[NSLocalizedString(@"Content unpacking error", @"") capitalizedString]
                                                                                    message:@""
                                                                             preferredStyle:UIAlertControllerStyleAlert];
         
         MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:nil];
         
         [alertController addAction:cancelAction];
         [alertController showInViewController:self.rootVC animated:YES];
         
     }
     
     _isDownloading = NO;
     
 }
 
 
 -(NSString *)currentDeviceType {
     
     NSString *deviceKey = [[NSString alloc] init];
     
     if(IS_IPAD()){
         deviceKey = @"ipad";
     }else if(Is3_5Inches()){
         
         deviceKey = @"iphone4";
     }else{
         
         deviceKey = @"iphone5";
     }
     
     return deviceKey;
 }

 
 - (void) showProgress{
     
     if(!self.dowloadProgressView){
         
         self.dowloadProgressView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, [self screenSizeOrientationIndependent].width, [self screenSizeOrientationIndependent].height)];
         
         self.dowloadProgressView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
         self.dowloadProgressView.userInteractionEnabled = YES;
         
         [self.rootVC.view addSubview:self.dowloadProgressView];
         
         self.threadProgressView = [MRProgressOverlayView showOverlayAddedTo:self.rootVC.view animated:YES];
         [self.threadProgressView setMode:MRProgressOverlayViewModeDeterminateCircular];
         // _threadProgressView.progress = 0.0;
         [self.threadProgressView setTitleLabelText:NSLocalizedString(@"Loading ...", nil)];
         
         [self.dowloadProgressView addSubview:_threadProgressView];
         self.threadProgressView.center = _dowloadProgressView.center;
     }
     
     self.dowloadProgressView.hidden = NO;
     [self.rootVC.view bringSubviewToFront:self.dowloadProgressView];
 }
 
 -(void)hideProgress{
     
     dispatch_async(dispatch_get_main_queue(), ^{
         if(self.dowloadProgressView){
             
             _dowloadProgressView.hidden = YES;
             [MRProgressOverlayView dismissAllOverlaysForView:self.rootVC.view animated:YES];
         }
     });
 }
 
@end
