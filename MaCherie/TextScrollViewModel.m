//
//  TextScrollViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextScrollViewModel.h"

@interface TextScrollViewModel () {
    NSMutableArray *texts;
}

@end

@implementation TextScrollViewModel

-(id)initWithTextArray:(NSArray *)theTexts {
    if (self = [super init]) {
        texts = [[NSMutableArray alloc] initWithArray:theTexts];
    }
    return self;
}

-(NSInteger)numberOfTexts {
    return texts.count;
}

-(NSString*)textContentAtIndex:(NSInteger)index {
    
    if (index < texts.count) {
        Text *text = [texts objectAtIndex:index];
        return text.content;
    }
    else {
        NSLog(@"ERROR: index is out of bounds");
        return nil;
    }
    
    return nil;
}

@end
