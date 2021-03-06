//
//  AppDelegate.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificationManager.h"
#import "UserDefaults.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
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
    RootViewModel *viewModel;
    
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"did finish launching");
    viewModel = [[RootViewModel alloc] init];
        
    [Fabric with:@[CrashlyticsKit]];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (settings.types != UIUserNotificationTypeNone) {
            [UserDefaults setAcceptedSystemNotifications:YES];
        }
        else {
            [UserDefaults setAcceptedSystemNotifications:NO];
        }
        
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
        [UserDefaults setFacebookUserId:[FBSDKAccessToken currentAccessToken].userID];
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
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
        UIUserNotificationSettings *notificaitonSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if ([[UserDefaults acceptedNotifications] boolValue] == YES && notificaitonSettings.types != UIUserNotificationTypeNone) {
            NotificationManager *notifMan = [[NotificationManager alloc] init];
            [notifMan scheduleRandomNotification];
        }
        else {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
    }
    else if ([[UserDefaults acceptedNotifications] boolValue] == YES) {
        NotificationManager *notifMan = [[NotificationManager alloc] init];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [notifMan scheduleRandomNotification];
    }
    else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    [UserDefaults setLastActiveDate:[NSDate date]];
    
    
    NSLog(@"scheduled notification: %lu", (unsigned long)[[UIApplication sharedApplication] scheduledLocalNotifications].count);
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // MARK: here we set the welcome texts to no, if we want to change these conditions we will have to remove this or edit
    [UserDefaults setWelcomeTextsShow:YES];
    [UserDefaults setWelcomeImagesShown:YES];
    
    UIViewController *rootVC = self.window.rootViewController.presentedViewController;
    if ([rootVC isKindOfClass:[RootViewController class]]) {
        [(RootViewController*)rootVC showViewDataWhenAppBecomesActive];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UserDefaults setTimeSpentInAppLSinceLaunch:0];
    
    [[CustomAnalytics sharedInstance] postActionWithType:@"AppFocus" actionLocation:@"AppLaunch" targetType:@"" targetId:@"" targetParameter:@""];
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:@"AppLaunch" withLabel:@"AppFocus" wtihValue:nil];

    NSLog(@"did become active");
    
    
    GWDataManager *downloadIntentions = [[GWDataManager alloc] init];
    [downloadIntentions downloadIntentionsWithArea:[ConstantsManager sharedInstance].specialOccasionArea withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *intentionIds, NSError *error) {
        
    }];
    
    [viewModel downloadImagesForRecipient:@"9E2D23" withNum:20 withCompletion:^(NSArray *theImageIds, NSError *error) {
        
        __weak typeof (self) wSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wSelf performSelector:@selector(downloadAdditionalImages) withObject:nil afterDelay:10];
        });
        
    }];
    
    NSLog(@"did become active");
    
    [viewModel downloadTextsForArea:[ConstantsManager sharedInstance].area withCompletion:^(NSArray *allTexts, NSError *error) {
        
        NSLog(@"all texts downloaded");
        
    }];
    
    
    // Call the 'activateApp' method to log an app event for use
    // in analytics and advertising reporting.
    [FBSDKAppEvents activateApp];
    
    didFinishLaunching = NO;
    
    [self performSelector:@selector(increaseTimeSpentInApp) withObject:nil afterDelay:1.0];
}


-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    NSLog(@"registering user notifications");
    
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        NSLog(@"wants notifications");
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"UserWantsNotifications" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"UserWantsNotifications" targetParameter:@""];
        
        [UserDefaults setAcceptedSystemNotifications:YES];
    }
    else {
        NSLog(@"does not want notifications");
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"UserDoesNotWantNotifications" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"UserDoesNotWantNotifications" targetParameter:@""];
        
        [UserDefaults setAcceptedSystemNotifications:NO];
        
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Download control And continous app calls

-(void)increaseTimeSpentInApp {
    
    [UserDefaults increaseTimeSpentInAppSinceLaunchBy:[NSNumber numberWithFloat:1.0]];
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

@end
