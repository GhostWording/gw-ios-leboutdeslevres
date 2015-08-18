//
//  NSArray+Extension.m
//  MaCherie
//
//  Created by Mathieu Skulason on 12/08/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

+(NSArray*)randomIndexesFromArray:(NSArray*)theArray withNumRandomIndexes:(NSInteger)numRandomIndexes {
    
    if (numRandomIndexes >= theArray.count) {
        return theArray;
    }
    
    NSMutableArray *allRandomImages = [NSMutableArray arrayWithArray:theArray];
    NSMutableArray *randomImages = [NSMutableArray array];
    
    while (randomImages.count != numRandomIndexes && allRandomImages.count != 0) {
        int position = arc4random_uniform((int)allRandomImages.count);
        [randomImages addObject:[allRandomImages objectAtIndex:position]];
        [allRandomImages removeObjectAtIndex:position];
    }
    
    return randomImages;
}

@end
