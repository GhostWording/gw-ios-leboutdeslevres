//
//  LBDLCollectionViewModel.m
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "LBDLCollectionViewModel.h"

@interface LBDLCollectionViewModel () {
    NSMutableArray *textsArray;
    NSMutableArray *imageArray;
    NSMutableArray *theImagesAndTexts;
    NSNumber *customNumberOfResults;
}

@end

@implementation LBDLCollectionViewModel

-(id)init {
    if (self = [super init]) {
        textsArray = [NSMutableArray array];
        imageArray = [NSMutableArray array];
        theImagesAndTexts = nil;
        customNumberOfResults = nil;
    }
    
    return self;
}

-(id)initCollectionViewModelWithTexts:(NSArray*)texts andImages:(NSArray*)images {
    if (self = [super init]) {
        textsArray = [[NSMutableArray alloc] initWithArray:texts];
        NSLog(@"Texts is: %d", textsArray.count);
        imageArray = [[NSMutableArray alloc] initWithArray:images];
        NSLog(@"images is: %d", images.count);
        theImagesAndTexts = [NSMutableArray array];
        customNumberOfResults = [NSNumber numberWithInt:textsArray.count + images.count];
        [self randomizeTextsWithNumResults:customNumberOfResults];
    }
    
    return self;
}

-(void)randomizeTextsWithNumResults:(NSNumber *)numResults {
    customNumberOfResults = numResults;
    [theImagesAndTexts removeAllObjects];
    
    NSMutableArray *tmpTexts = [[NSMutableArray alloc] initWithArray:textsArray];
    NSMutableArray *tmpImages = [[NSMutableArray alloc] initWithArray:imageArray];
    
    for (int i = 0; i < numResults.intValue && i < (textsArray.count + imageArray.count); i++) {
        
        if (rand() % 2 == 0 && tmpTexts.count != 0) {
            int index = rand() % tmpTexts.count;
            [theImagesAndTexts addObject:[tmpTexts objectAtIndex:index]];
            [tmpTexts removeObjectAtIndex:index];
            
        }
        else if(tmpImages.count != 0) {
            int index = rand() % tmpImages.count;
            [theImagesAndTexts addObject:[tmpImages objectAtIndex:index]];
            [tmpImages removeObjectAtIndex:index];
        }
        
    }
    
}

-(NSArray *)randomImagesAndTexts {
    return theImagesAndTexts;
}

-(NSInteger)allResults {
    return textsArray.count + imageArray.count;
}

-(NSInteger)numResults {
    if (customNumberOfResults != nil) {
        return [customNumberOfResults intValue];
    }
    
    return textsArray.count + imageArray.count;
}

-(void)setNumberOfResults:(NSNumber*)numResults {
    customNumberOfResults = numResults;
}

@end
