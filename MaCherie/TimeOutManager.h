//
//  TimeOutManager.h
//  MaCherie
//
//  Created by Mathieu Skulason on 18/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(BOOL finished);

@interface TimeOutManager : NSObject

@property (nonatomic, readwrite) float idleTimer;

+(instancetype)shareTimeOutManager;

-(void)timeElapsedWithCompletion:(CompletionBlock)block;
-(void)pauseTime;
-(void)startTime;
-(void)restartTime;
-(void)deactivate;

@end
