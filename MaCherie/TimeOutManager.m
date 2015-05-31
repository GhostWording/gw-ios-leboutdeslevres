//
//  TimeOutManager.m
//  MaCherie
//
//  Created by Mathieu Skulason on 18/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TimeOutManager.h"

@interface TimeOutManager () {
    float elapsedTime;
    CompletionBlock completionBlock;
    BOOL pause;
    BOOL deactivated;
}

@end

@implementation TimeOutManager

@synthesize idleTimer = _idleTimer;

-(id)init {
    if (self = [super init]) {
        _idleTimer = 10.0f;
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:0.1];
        completionBlock = nil;
        pause = NO;
        deactivated = NO;
    }
    return self;
}

-(void)updateTime {
    
    if (!pause && !deactivated) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:0.1];
        elapsedTime += 0.1f;
        
        if (elapsedTime >= 10.0f) {
            if (completionBlock) {
                elapsedTime = 0.0f;
                completionBlock(YES);
            }
        }
    }
}

-(void)pauseTime {
    if (!deactivated) {
        pause = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

-(void)startTime {
    if (!deactivated) {
        pause = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:0.1];
    }
}

-(void)restartTime {
    if (!deactivated) {
        pause = NO;
        elapsedTime = 0.0f;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:0.1];
    }
}

-(void)timeElapsedWithCompletion:(CompletionBlock)block {
    if (!deactivated) {
        completionBlock = block;
    }
    
}

-(void)deactivate {
    deactivated = YES;
}


+(instancetype)shareTimeOutManager {
    static dispatch_once_t once;
    static id shareTimeOutInstance;
    dispatch_once(&once, ^{
        shareTimeOutInstance = [[self alloc] init];
    });
    return shareTimeOutInstance;
}

@end
