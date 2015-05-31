//
//  GoogleAnalyticsCommunication.h
//  MaCherie
//
//  Created by Mathieu Skulason on 30/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AnalyticsConstants.h"

@interface GoogleAnalyticsCommunication : NSObject

+(instancetype)sharedInstance;

-(void)sendEventWithCategory:(NSString*)eventCategory withAction:(NSString*)eventAction withLabel:(NSString*)eventLabel wtihValue:(NSNumber*)eventValue;
-(void)setScreenName:(NSString*)screenName;

@end
