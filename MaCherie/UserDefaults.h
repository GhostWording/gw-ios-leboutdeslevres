//
//  UserDefaults.h
//  MaCherie
//
//  Created by Mathieu Skulason on 06/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kAgeNone,
    kAgeLessThan17,
    kAgeBetween18And39,
    kAgeBetween40And64,
    kAgeOver65
} AgeSegment;

typedef enum {
    kGenderNone,
    kGenderFemale,
    kGenderMale
} Gender;


static NSString *frenchCultureString = @"fr-FR";
static NSString *englishCultureString = @"en-EN";
static NSString *spanishCultureString = @"es-ES";

@interface UserDefaults : NSObject

+(NSString*)userUniqueId;

+(NSDate*)dateInstalled;
+(void)setDateInstalled:(NSDate*)installDate;

+(NSString*)currentCulture;
+(void)setCulture:(NSString*)newCulture;

+(NSNumber*)firstLaunchOfApp;
+(void)setFirstLaunchOfApp:(BOOL)firstLaunch;

+(NSDate*)lastTimeAskedForNotificationPermission;
+(void)setLastTimeAskedForNotificationPermission:(NSDate*)lastTimeDate;

+(NSNumber*)acceptedNotifications;
+(void)setAcceptedNotifications:(BOOL)acceptedNotification;

+(NSNumber*)accpetedSystemNotifications;
+(void)setAcceptedSystemNotifications:(BOOL)acceptedNotification;

+(NSNumber*)hasRatedApp;
+(void)hasRatedApp:(NSNumber*)hasRated;

+(NSNumber*)hasViewedSettings;
+(void)setHasViewedSettings:(NSNumber*)hasViewed;

+(NSNumber*)numberOfMessagesSent;
+(void)incrementNumberOfMessagesSent;

+(NSNumber*)numberOfFacebookShares;
+(void)incrementNumberOfFacebookShares;

+(NSNumber*)numberOfTextRefreshes;
+(void)increaseNumberOfTextRefreshes;

+(NSNumber*)numberOfTextRefreshesByUser;
+(void)increaseNumberOfTextRefreshesByUser;

+(NSNumber*)numberOfImageRefreshesByUser;
+(void)increaseNumberOfImageRefreshesByUser;

+(NSNumber*)timeSpentInAppSinceLaunch;
+(void)setTimeSpentInAppLSinceLaunch:(float)timeSpentInApp;
+(void)increaseTimeSpentInAppSinceLaunchBy:(NSNumber*)timeToIncreaseBy;

+(NSNumber*)timeSpentInApp;
+(void)increaseTimeBy:(NSNumber*)timeToIncreaseBy;

+(NSNumber*)userAgeSegment;
+(void)setUserAgeSegment:(NSNumber*)ageSegment;

+(NSNumber*)userGender;
+(void)setUserGender:(NSNumber*)gender;

+(NSNumber*)userWantsNotification;
+(void)setUserWantsNotification:(BOOL)wantsNotification;

+(NSNumber*)hasPressedIntentionButton;
+(void)setHasPressedIntentionButton:(BOOL)hasPressedIntention;

// get the hour and minutes separately
+(int)notificationHour;
+(void)setNotificationHour:(int)hour;
+(int)notificationMinutes;
+(void)setNotificationMinutes:(int)minutes;

// currently not in use for simplicities sake
+(NSDate*)notificationTime;
+(void)setNotificationTime:(NSDate*)notificationTime;



@end
