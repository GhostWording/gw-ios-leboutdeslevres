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

-(void)scheduleRandomNotification {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    for (int i = 0; i < 7; i++) {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.timeZone = [NSTimeZone systemTimeZone];
        localNotif.alertBody = [self randomAlertBody];
        localNotif.fireDate = [self getFireDate:i andHour:[self randomHour] andMinutes:[self randomMinute] withCalendar:calendar];
        localNotif.repeatInterval = NSCalendarUnitMonth;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    
}

-(NSDate*)getFireDate:(int)dayNumber andHour:(int)hour andMinutes:(int)minutes withCalendar:(NSCalendar*)theCalendar {
    
    NSLog(@"the notification hour: %d and minutes: %d", hour, minutes);
    
    NSDate *date = [NSDate date];
    
    NSDateComponents *dateComposition = [theCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    if (dateComposition.hour > hour) {
        [dateComposition setDay:dateComposition.day +1 + dayNumber];
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    else if(dateComposition.hour == hour && dateComposition.minute > minutes) {
        [dateComposition setDay:dateComposition.day + 1 + dayNumber];
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    else {
        [dateComposition setDay:dateComposition.day + dayNumber];
        [dateComposition setHour:hour];
        [dateComposition setMinute:minutes];
    }
    
    return [theCalendar dateFromComponents:dateComposition];
}

-(int)randomHour {
    return arc4random_uniform(9) + 9;
}

-(int)randomMinute {
    return arc4random_uniform(59);
}

-(NSString*)randomAlertBody {
    NSArray *array = [NSArray arrayWithObjects:@"L'aventure est sous l'écran", @"Les mots que l'on garde nous hantent", @"Il était une fois…", @"50%% de réduction sur les voyelles", @"Les mots envoyés reviennent plus joyeux", @"Miaou ", @"Osez!", @"Faites-lui plaisir!", @"Faites-vous plaisir!", @"Les mots sont des clés, évadez - vous !", @"Affinité, amitié, photos et bébés chats", @"Les mots pour le dire", @"Un jour il sera trop tard", @"L'art de faire plaisir", @"Baisers, poèmes ou dentifrice, pourquoi choisir?", @"Pensez à surprendre !", @"L'amour passe par les yeux et les oreilles", @"\"Qu'on dise il osa trop mais l'audace était belle…\"", @"A la main une fleur qui brille, à la bouche un refrain nouveau", @"Changez-vous la vie, trouvez les mots qui donnent envie !", @"Les mots sur le bout de la langue, l'inspiration au bout des doigts", @"Donnez une vie à vos envies", @"Du bout de la langue au bout des doigts", @"Mettez une griffe à votre patte", @"Les mots qui touchent à fleur d'écran", @"La voie tactile de l'idée au mot", @"A la recherche des mots perdus", @"Les mots neufs créent de nouvelles occasions", nil];
    
    return  [array objectAtIndex:arc4random_uniform( (int)array.count)];
    
}

@end
