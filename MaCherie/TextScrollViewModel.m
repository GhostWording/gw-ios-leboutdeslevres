//
//  TextScrollViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextScrollViewModel.h"
#import "GWText.h"

@interface TextScrollViewModel () {
    NSMutableArray *texts;
}

@end

@implementation TextScrollViewModel

-(id)initWithTextArray:(NSArray *)theTexts {
    if (self = [super init]) {
        if (theTexts != nil) {
            texts = [[NSMutableArray alloc] initWithArray:theTexts];
        }
        else {
            theTexts = [NSMutableArray array];
        }
    }
    return self;
}

-(void)updateTextScrollViewModel:(NSArray *)theTexts {
    texts = [[NSMutableArray alloc] initWithArray:theTexts];
}

-(NSInteger)numberOfTexts {
    return texts.count;
}

-(NSString*)textContentAtIndex:(NSInteger)index {
    
    if (index < texts.count) {
        
        GWText *text = [texts objectAtIndex:index];
        
        //NSLog(@"text intention label is: %@", text.intentionLabel);
        
        return text.content;
    }
    else {
        
        NSLog(@"ERROR: index is out of bounds: %lu", (long unsigned)index);
        return nil;
    }
    
    return nil;
}

-(NSString*)textIdForTextAtIndex:(NSInteger)index {
    if (index < texts.count) {
        GWText *text = [texts objectAtIndex:index];
        NSLog(@"the text id: %@", text.textId);
        return text.textId;
    }
    else {
        
        NSLog(@"ERROR: index is out of bounds");
        return nil;
    }
}

-(GWText*)textObjectAtIndex:(NSInteger)index {
    if (index < texts.count) {
        GWText *text = [texts objectAtIndex:index];
        return text;
    }
    
    return nil;
}

-(NSArray*)theTexts {
    return texts;
}

-(BOOL)wantsFacebookShareForTextAtIndex:(int)index {
    
    //NSLog(@"wants facebook share");
    
    if (index < texts.count) {
        Text *text = [texts objectAtIndex:index];
        
        //NSLog(@"impersonal is: %@", text.impersonal);
        if (![text.impersonal isEqualToString:@"false"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
