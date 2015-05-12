//
//  UserDefaults.m
//  MaCherie
//
//  Created by Mathieu Skulason on 06/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

-(id)init
{
    if (self = [super init]) {
        // if it is nil
        if ([UserDefaults firstLaunchOfApp] == nil) {
            
            [UserDefaults setFirstLaunchOfApp:YES];
            [UserDefaults setUserAgeSegment:[NSNumber numberWithInt:kAgeNone]];
            [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderNone]];
            [UserDefaults setUserWantsNotification:YES];
            [UserDefaults setNotificationMinutes:0];
            [UserDefaults setNotificationHour:16];
        }
    }
    
    return self;
}

+(NSNumber*)firstLaunchOfApp {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"firstLaunch"];
}

+(void)setFirstLaunchOfApp:(BOOL)firstLaunch {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:firstLaunch] forKey:@"firstLaunch"];
}

+(NSNumber*)userAgeSegment {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"age"];
}

+(void)setUserAgeSegment:(NSNumber*)ageSegment {
    [[NSUserDefaults standardUserDefaults] setInteger:[ageSegment intValue] forKey:@"age"];
}


+(NSNumber*)userGender {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"gender"];
}

+(void)setUserGender:(NSNumber *)gender
{
    return [[NSUserDefaults standardUserDefaults] setInteger:[gender integerValue] forKey:@"gender"];
}


+(NSNumber*)userWantsNotification {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"wantsNotification"];
}

+(void)setUserWantsNotification:(BOOL)wantsNotification {
    return [[NSUserDefaults standardUserDefaults] setBool:wantsNotification forKey:@"wantsNotification"];
}


+(int)notificationHour {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"notificationHour"] intValue];
}

+(void)setNotificationHour:(int)hour {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:hour] forKey:@"notificationHour"];
}

+(int)notificationMinutes {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"notificationMinutes"] intValue];
}

+(void)setNotificationMinutes:(int)minutes {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:minutes] forKey:@"notificationMinutes"];
}

+(NSDate*)notificationTime {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"notificationTime"];
}


+(void)setNotificationTime:(NSDate *)notificationTime {
    [[NSUserDefaults standardUserDefaults] setValue:notificationTime forKey:@"notificationTime"];
}


@end
