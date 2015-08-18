//
//  NSArray+Extension.h
//  MaCherie
//
//  Created by Mathieu Skulason on 12/08/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

/* Returns random indexes form the given array without duplicates, if the number of random indexes is higher than the size of the array, the array is returned. **/
+(NSArray*)randomIndexesFromArray:(NSArray*)theArray withNumRandomIndexes:(NSInteger)numRandomIndexes;

@end
