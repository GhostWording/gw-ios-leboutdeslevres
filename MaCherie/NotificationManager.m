//
//  NotificationManager.m
//  MaCherie
//
//  Created by Mathieu Skulason on 12/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NotificationManager.h"

@implementation NotificationManager

-(void)scheduleNotification:(int)hour andMinute:(int)minutes {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertBody = @"chaque jour un refrain nouveau";
    
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComposition = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    if (dateComposition.hour > hour) {
        [dateComposition setDay:dateComposition.day +1];
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    else if(dateComposition.hour == hour && dateComposition.minute > minutes) {
        [dateComposition setDay:dateComposition.day + 1];
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    else {
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    
    NSDate *fireDate = [calendar dateFromComponents:dateComposition];
    
    NSLog(@"fire date is: %@", fireDate);
    
    notification.fireDate = fireDate;
    notification.repeatInterval = NSCalendarUnitDay;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}

@end
