//
//  PGAppDelegate.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 12.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


- (void)loadMainView;

@end
