//
//  AppDelegate.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "AppDelegate.h"
#import "ServerComm.h"
#import "NotificationManager.h"
#import "UserDefaults.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "RootViewController.h"
#import "LoginViewController.h"
#import "iPadRootViewController.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "RootViewModel.h"
#import "ConstantsManager.h"
#import "GWDataManager.h"
#import "GWCoreDataManager.h"

@interface AppDelegate () {
    // bool for first time we launch the view
    BOOL didFinishLaunching;
    ServerComm *comm;
    RootViewModel *viewModel;
    
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"did finish launching");
    comm = [[ServerComm alloc] init];
    viewModel = [[RootViewModel alloc] init];
    
    [UserDefaults setCulture:frenchCultureString];
    
    [Fabric with:@[CrashlyticsKit]];
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    // seed the random generator
    srand((unsigned int)time(NULL));
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [FBSDKLoginButton class];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RootViewController *rootController = [storyboard instantiateViewControllerWithIdentifier:@"rootViewController"];
    LoginViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"is there an existing access token");
        self.window.rootViewController = rootController;
    }
    else {
        NSLog(@"does not have existing token");
        self.window.rootViewController = loginController;
    }
    
    //self.window.rootViewController = rootController;
    
    /*
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        
        RootViewController *rootController = [storyboard instantiateViewControllerWithIdentifier:@"rootViewController"];
        self.window.rootViewController = rootController;
        
    } else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        iPadRootViewController *rootController = [[iPadRootViewController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = rootController;
        
    }*/
    
    didFinishLaunching = YES;
    
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[GWCoreDataManager sharedInstance] saveContext];
    
    if ([[UserDefaults userWantsNotification] boolValue] == YES) {
        NotificationManager *notifMan = [[NotificationManager alloc] init];
        [notifMan scheduleRandomNotification];
    }
    else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    /*
    NotificationManager *notifMan = [[NotificationManager alloc] init];
    [notifMan scheduleNotification:[UserDefaults notificationHour] andMinute:[UserDefaults notificationMinutes]];
    */
    
    NSLog(@"scheduled notification: %lu", (unsigned long)[[UIApplication sharedApplication] scheduledLocalNotifications].count);
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[CustomAnalytics sharedInstance] postActionWithType:@"AppFocus" actionLocation:@"AppLaunch" targetType:@"" targetId:@"" targetParameter:@""];
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:@"AppLaunch" withLabel:@"AppFocus" wtihValue:nil];

    NSLog(@"did become active");
    
    
    GWDataManager *downloadIntentions = [[GWDataManager alloc] init];
    [downloadIntentions downloadIntentionsWithArea:[ConstantsManager sharedInstance].specialOccasionArea withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *intentionIds, NSError *error) {
        
    }];
    
    [viewModel downloadImagesForRecipient:@"9E2D23" withNum:20 withCompletion:^(NSArray *theImageIds, NSError *error) {
        
        __weak typeof (self) wSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf performSelector:@selector(downloadAdditionalImages) withObject:nil afterDelay:20.0];
        });
        
    }];
    
    [viewModel downloadTextsForArea:[ConstantsManager sharedInstance].area withCompletion:^(NSArray *allTexts, NSError *error) {
        
        NSLog(@"all texts downloaded");
        
    }];
    
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBAppEvents activateApp];
    
    // bool variable to make sure the view will appear method won't be called when we launch the app
    // but we need it when it becomes active
    NSLog(@"did become active");
    if (!didFinishLaunching) {
        NSLog(@"did finish launching");
        [self.window.rootViewController viewWillAppear:YES];
    }
    
    didFinishLaunching = NO;
    
    [self performSelector:@selector(increaseTimeSpentInApp) withObject:nil afterDelay:1.0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Download control And continous app calls

-(void)increaseTimeSpentInApp {
    
    [UserDefaults increaseTimeBy:[NSNumber numberWithFloat:1.0f]];
    [self performSelector:@selector(increaseTimeSpentInApp) withObject:nil afterDelay:1.0];
    
}

-(void)downloadAdditionalImages {
    
    [viewModel downloadImagesForRecipient:@"9E2D23" withNum:20 withCompletion:^(NSArray *theImageIds, NSError *error) {
        
        __weak typeof (self) wSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf performSelector:@selector(downloadAdditionalImages) withObject:nil afterDelay:20.0];
        });
        
        
    }];
    
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "konta.JePenseAToi" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES
                              };
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
   
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType]];
    
    return _managedObjectContext;
    
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSLog(@"saving context");
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



@end
