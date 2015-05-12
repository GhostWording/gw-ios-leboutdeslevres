//
//  NotificationManager.h
//  MaCherie
//
//  Created by Mathieu Skulason on 12/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationManager : NSObject

-(void)scheduleNotification:(int)hour andMinute:(int)minutes;

@end
