//
//  NSString+RandomString.m
//  MaCherie
//
//  Created by Mathieu Skulason on 31/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NSString+RandomString.h"

@implementation NSString (RandomString)

+(NSString*)generateRandStringWithLength:(int)length
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    
    NSMutableString *string = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        u_int32_t pos = arc4random()%[alphabet length];
        unichar c = [alphabet characterAtIndex:pos];
        
        [string appendFormat:@"%C", c];
    }
    
    
    return string;
}

-(NSString*)removeImageBaseURLFromString {
    
    NSMutableString *mutableImageId = [[NSMutableString alloc] initWithString:self];
    if ([self hasPrefix:@"http://gw-static.azurewebsites.net"]) {
        [mutableImageId deleteCharactersInRange:NSMakeRange(0, [NSString stringWithFormat:@"http://gw-static.azurewebsites.net"].length)];
    }
    
    return mutableImageId;
}


@end
