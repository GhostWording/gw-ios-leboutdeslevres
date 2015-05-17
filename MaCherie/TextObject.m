//
//  TextObject.m
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextObject.h"

@implementation TextObject

-(id)init {
    
    if (self = [super init]) {
        weight = 0.0f;
        text = nil;
    }
    
    return self;
}

-(id)initWithWeight:(float)theWeight andText:(Text*)theText {
    
    if (self = [super init]) {
        weight = theWeight;
        text = theText;
    }
    
    return self;
}

@synthesize weight;
@synthesize text;

@end
