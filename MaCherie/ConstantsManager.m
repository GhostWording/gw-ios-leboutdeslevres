//
//  ConstantsManager.m
//  MaCherie
//
//  Created by Mathieu Skulason on 09/08/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ConstantsManager.h"

@implementation ConstantsManager

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
        _area = @"LipTip";
        _specialOccasionArea = @"LipTipSpecial";
    }
    
    return self;
}

@end
