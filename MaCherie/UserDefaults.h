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

@interface UserDefaults : NSObject

+(NSNumber*)userAgeSegment;
+(void)setUserAgeSegment:(NSNumber*)ageSegment;

+(NSNumber*)userGender;
+(void)setUserGender:(NSNumber*)gender;

+(NSNumber*)userWantsNotification;
+(void)setUserWantsNotification:(BOOL)wantsNotification;



@end
