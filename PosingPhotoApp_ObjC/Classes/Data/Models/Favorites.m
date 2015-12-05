//
//  Favorites.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 21.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "Favorites.h"
#import "Pose.h"


@implementation Favorites

@dynamic dressType;
@dynamic imageName;
@dynamic favsPose;

+ (BOOL)isAlreadyInFavsImageNamed:(NSString *)imageName forPose:(Pose *)pose {
    
    NSError *error;
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_favsEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageName == %@ AND favsPose == %@", imageName, pose];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesSubentities:YES];
    
    NSArray* returnArray = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        DLog(@"Favorites fetcherror - %@", error.localizedDescription);
        return NO;
    }
    
    return  returnArray.count > 0;
}


+ (void)addFavoriteImage:(NSString *)imageName withPose:(Pose *)pose andDressType:(NSString *)dressType{

    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Favorites *favObj = [NSEntityDescription insertNewObjectForEntityForName:const_coreData_favsEntity
                                                  inManagedObjectContext:appDelegate.managedObjectContext];
    
    favObj.imageName   = imageName;
    favObj.favsPose    = pose;
    favObj.dressType   = dressType;
    

    if([appDelegate.managedObjectContext hasChanges] && ![appDelegate.managedObjectContext save:nil]){
        //NSLog(@"Unresolved error!");
        abort();
    }

}

+ (void)removeFavoriteImage:(NSString *)imageName withPose:(Pose *)pose andDressType:(NSString *)dressType {

    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_favsEntity];
    
    NSPredicate *predicateMainPose = [NSPredicate predicateWithFormat:@"imageName == %@ AND favsPose == %@ AND dressType == %@", imageName, pose, dressType];
    [fetchRequest setPredicate:predicateMainPose];
    
     Favorites *favObj = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] lastObject];
    
    if(favObj){
        [appDelegate.managedObjectContext deleteObject:favObj];
        [appDelegate.managedObjectContext save:nil];
    }
}


-(NSArray *)fetchAllFavsImages {
    
    
    NSError *error;
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_favsEntity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"favId"
                                                                     ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSArray* returnArray = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        DLog(@"Favorites fetcherror - %@", error.localizedDescription);
        return nil;
    }
    
    return returnArray;
    
}

+(UIImage *)getImageForFavItem:(Favorites *)favItem{
    
    NSString *freeContentBundlePath = [PGFreeDownloadManager freeContentBundlePath];
    
    NSString *posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@", favItem.favsPose.posePath, [Favorites deviceType]];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photo/%@/%@@2x.jpg", posePathBeforeDresses, favItem.dressType, favItem.imageName];
    
    UIImage *favImage = [UIImage imageWithContentsOfFile:F(@"%@/%@", freeContentBundlePath, imagePath)];
    
    if(favImage){
    
        return favImage;
    }
    
    /*Pay content*/
    if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        directory = [directory stringByAppendingPathComponent:@"Downloads"];
        directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
        NSBundle *payBundle = [NSBundle bundleWithPath:directory];
        if(payBundle){
            
            NSString *payImagesPath = [NSString stringWithFormat:@"%@/photo/%@/%@@2x.jpg", posePathBeforeDresses, favItem.dressType, favItem.imageName];
            favImage = [UIImage imageWithContentsOfFile:F(@"%@/%@", directory, payImagesPath)];
        }
    }
    
    return favImage;
    
}

+ (NSString *)getImagePathForFavItem:(Favorites *)favItem{

    
    NSString * favImagePath = [[NSString alloc] init];
    
    NSString *freeContentBundlePath = [PGFreeDownloadManager freeContentBundlePath];
    
    NSString *posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@", favItem.favsPose.posePath, [Favorites deviceType]];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/photo/%@/%@.jpg", posePathBeforeDresses, favItem.dressType, favItem.imageName];
    
    UIImage *favImage = [UIImage imageWithContentsOfFile:F(@"%@/%@", freeContentBundlePath, imagePath)];
    
    if(favImage){
        favImagePath = F(@"%@/%@", freeContentBundlePath, imagePath);
        return favImagePath;
    }
    
    /*Pay content*/
    if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        directory = [directory stringByAppendingPathComponent:@"Downloads"];
        directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
        NSBundle *payBundle = [NSBundle bundleWithPath:directory];
        if(payBundle){
            
            NSString *payImagesPath = [NSString stringWithFormat:@"%@/photo/%@/%@.jpg", posePathBeforeDresses, favItem.dressType, favItem.imageName];
            favImagePath = F(@"%@/%@", directory, payImagesPath);
        }
    }
    
    return favImagePath;
}

+(NSString *)deviceType {
    
    NSString *deviceType = [NSString string];
    
    if(Is3_5Inches()) {
        deviceType = @"iphone4";
    }else if (IS_IPAD()){
        deviceType = @"ipad";
    }else{
        deviceType = @"iphone5";
    }
    
    return deviceType;
}
@end
