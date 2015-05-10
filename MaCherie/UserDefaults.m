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
        
    }
    
    return self;
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



@end
