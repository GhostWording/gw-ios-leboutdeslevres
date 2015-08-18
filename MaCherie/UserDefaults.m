//
//  UserDefaults.m
//  MaCherie
//
//  Created by Mathieu Skulason on 06/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UserDefaults.h"
#import "NSString+RandomString.h"

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

+(NSString*)userUniqueId {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"uniqueId"] == nil) {
        
        NSLog(@"user unique id");
        [[NSUserDefaults standardUserDefaults] setValue:[NSString generateRandStringWithLength:8] forKey:@"uniqueId"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"uniqueId"];
}


+(NSDate*)dateInstalled {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"installDate"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"installDate"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"installDate"];
}

+(void)setDateInstalled:(NSDate *)installDate {
    [[NSUserDefaults standardUserDefaults] setValue:installDate forKey:@"installDate"];
}


+(NSNumber*)numberOfMessagesSent {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numMessagesSent"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numMessagesSent"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"numMessagesSent"];
}

+(void)incrementNumberOfMessagesSent {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[[UserDefaults numberOfMessagesSent] intValue] + 1] forKey:@"numMessagesSent"];
}


+(NSNumber*)numberOfFacebookShares {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numFacebookShares"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numFacebookShares"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"numFacebookShares"];
}

+(void)incrementNumberOfFacebookShares {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[[UserDefaults numberOfFacebookShares] intValue] + 1] forKey:@"numFacebookShares"];
}

+(NSString*)currentCulture {
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"currentCulture"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:frenchCultureString forKey:@"currentCulture"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"currentCulture"];
    
}

+(void)setCulture:(NSString*)newCulture {
    [[NSUserDefaults standardUserDefaults] setValue:newCulture forKey:@"currentCulture"];
}


+(NSNumber*)firstLaunchOfApp {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"firstLaunch"];
}

+(void)setFirstLaunchOfApp:(BOOL)firstLaunch {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:firstLaunch] forKey:@"firstLaunch"];
}

+(NSNumber*)hasRatedApp {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"hasRatedApp"] == nil) {
        return [NSNumber numberWithBool:NO];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"hasRatedApp"];
}

+(void)hasRatedApp:(NSNumber*)hasRated {
    [[NSUserDefaults standardUserDefaults] setValue:hasRated forKey:@"hasRatedApp"];
}

+(NSNumber*)timeSpentInApp {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"timeSpentInApp"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:0] forKey:@"timeSpentInApp"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"timeSpentInApp"];
}

+(void)increaseTimeBy:(NSNumber *)timeToIncreaseBy {
    NSNumber *number = (NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:@"timeSpentInApp"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:[number floatValue] + [timeToIncreaseBy floatValue]] forKey:@"timeSpentInApp"];
}

+(NSNumber*)numberOfTextRefreshes {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshes"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numTextRefreshes"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshes"];
}

+(void)increaseNumberOfTextRefreshes {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshes"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numTextRefreshes"];
    }
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshes"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:([number intValue] + 1)] forKey:@"numTextRefreshes"];
}

+(NSNumber*)numberOfTextRefreshesByUser {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshesByUser"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numTextRefreshesByUser"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshesByUser"];
}

+(void)increaseNumberOfTextRefreshesByUser {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshesByUser"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numTextRefreshesByUser"];
    }
    
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"numTextRefreshesByUser"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:([number intValue] + 1)] forKey:@"numTextRefreshesByUser"];
}

+(NSNumber*)numberOfImageRefreshesByUser {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"numImageRefreshesByUser"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"numImageRefreshesByUser"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"numImageRefreshesByUser"];
}

+(void)increaseNumberOfImageRefreshesByUser {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[[self numberOfImageRefreshesByUser] intValue] + 1] forKey:@"numImageRefreshesByUser"];
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


+(NSNumber*)hasPressedIntentionButton {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"hasPressedIntention"] == nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"hasPressedIntention"];
    }
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"hasPressedIntention"];
}

+(void)setHasPressedIntentionButton:(BOOL)hasPressedIntention {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:hasPressedIntention] forKey:@"hasPressedIntention"];
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
