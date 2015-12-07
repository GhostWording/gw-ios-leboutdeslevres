//
//  CustomAnalytics.m
//  MaCherie
//
//  Created by Mathieu Skulason on 30/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "CustomAnalytics.h"
#import "UserDefaults.h"

#define AREA @"SweetheartDaily"

@implementation CustomAnalytics

+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if (self = [super init]) {
        
    }
    return self;
}

-(void)postActionWithType:(NSString*)actionType actionLocation:(NSString*)actionLocation targetType:(NSString*)targetType targetId:(NSString*)targetId targetParameter:(NSString*)targetParameter
{
    
    NSString *uniqueId = [UserDefaults userUniqueId];
    NSString *versionNumber = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    NSString *facebookId = [UserDefaults facebookUserId];
    
    NSURL  *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://gw-usertracking.azurewebsites.net/userevent?ActionType=%@&ActionLocation=%@&TargetParameter=%@&TargetType=%@&TargetId=%@&AreaId=%@&DeviceId=%@&VersionNumber=%@&FacebookId=%@&OsVersion=%@", actionType, actionLocation, targetParameter, targetType, targetId, AREA, uniqueId, versionNumber, facebookId, @"iOS"]];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error: Unable to post action: %@", error.userInfo);
         }
         else
         {
             NSLog(@"posted action with response: %@", response);
         }
     }];
}

@end
