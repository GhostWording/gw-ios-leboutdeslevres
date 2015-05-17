//
//  RootViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "RootViewModel.h"
#import "IntentionObject.h"
#import "DataManager.h"
#import "Text.h"
#import "TextObject.h"

@interface RootViewModel () {
    DataManager *dataMan;
    NSMutableArray *intentions;
}

@end

@implementation RootViewModel

-(id)init {
    if (self = [super init]) {
        
        dataMan = [[DataManager alloc] init];
        
        intentions = [NSMutableArray array];
        
        [intentions addObject:[IntentionObject intentionJoke]];
        [intentions addObject:[IntentionObject intentionAFewWordsForYou]];
        [intentions addObject:[IntentionObject intentionFacebookStatus]];
        [intentions addObject:[IntentionObject intentionPositiveThoughts]];
        [intentions addObject:[IntentionObject intentionIThinkOfYou]];
        [intentions addObject:[IntentionObject intentionILoveYou]];
        [intentions addObject:[IntentionObject intentionIMissYou]];
        [intentions addObject:[IntentionObject intentionThankYou]];
        [intentions addObject:[IntentionObject intentionThereIsSomethingMissing]];
        [intentions addObject:[IntentionObject intentionSurpriseMe]];
        [intentions addObject:[IntentionObject intentionIWantYou]];
        
    }
    
    return self;
}

-(NSArray*)randomtTextWithNum:(int)numTexts {
    
    //NSArray *texts = [dataMan allTexts];
    NSArray *texts = [dataMan allTextsFilteredWithUserDefaults];
    
    NSLog(@"Adding texts");
    
    [self addTexts:texts toIntention:intentions];
    
    // compute the weight of the texts if we want to do it once and not for every intention
    NSLog(@"setup texts");
    
    [self setupTextWeight:intentions];
    
    NSLog(@"computing texts to return");
    
    for (IntentionObject *intentionObj in intentions) {
        NSLog(@"intention is: %@ with num texts: %d", intentionObj.intentionSlug, intentionObj.textsForIntention.count);
    }
    
    NSMutableArray *textsToReturn = [NSMutableArray array];
    
    for (int i = 0; i < numTexts; i++) {
        
        IntentionObject *randomIntention = [self randomIntentionWithIntentions:intentions];
        TextObject *randomObject = [self chooseRandomTextForIntention:randomIntention];
        [textsToReturn addObject:randomObject.text];
        
    }
    
    return textsToReturn;
}

-(TextObject*)chooseRandomTextForIntention:(IntentionObject*)theIntention {
    
    float totalWeight = 0;
    
    for (int i = 0; i < theIntention.textsForIntention.count; i++) {
        TextObject *text = [theIntention.textsForIntention objectAtIndex:i];
        totalWeight += text.weight;
    }
    
    float randomFloat = [self randomFloatBetween:0 and:totalWeight];
    
    float weightSoFar = 0.0f;
    for (int i = 0; i < theIntention.textsForIntention.count; i++) {
        TextObject *textObj = [theIntention.textsForIntention objectAtIndex:i];
        
        weightSoFar += textObj.weight;
        
        if (randomFloat < weightSoFar) {
            return textObj;
        }
    }
    
    return nil;
}

-(void)setupTextWeight:(NSArray*)theIntentions {
    
    for (int i = 0; i < theIntentions.count; i++) {
        
        IntentionObject *currentIntention = [theIntentions objectAtIndex:i];
        
        for (int k = 0; k < currentIntention.textsForIntention.count; k++) {

            TextObject *textObj = [currentIntention.textsForIntention objectAtIndex:k];
            
            if ([textObj.text.sortBy intValue] < 30) {
                textObj.weight = 3.0f;
            }
            else if([textObj.text.sortBy intValue] > 999)
            {
                textObj.weight = 0.2f;
            }
            else {
                textObj.weight = 1.0f;
            }
        }
    }
}

-(IntentionObject*)randomIntentionWithIntentions:(NSArray*)availableIntentions {
    float totalWeight = 0;
    
    for (int i = 0; i < availableIntentions.count; i++) {
        IntentionObject *currentIntention = [availableIntentions objectAtIndex:i];
        totalWeight += currentIntention.textsForIntention.count * currentIntention.userWeight * currentIntention.defaultWeight;
        NSLog(@"intention: %@ with weight: %f", currentIntention.intentionSlug, currentIntention.textsForIntention.count * currentIntention.userWeight * currentIntention.defaultWeight);
    }
    
    float randFloat = [self randomFloatBetween:0.0f and:totalWeight];
    NSLog(@"random float is: %f", randFloat);
    
    float weightSoFar = 0;
    for (int i = 0; i < availableIntentions.count; i++) {
        IntentionObject *currentIntention = [availableIntentions objectAtIndex:i];
        weightSoFar += currentIntention.textsForIntention.count * currentIntention.defaultWeight * currentIntention.userWeight;
        
        if (randFloat < weightSoFar) {
            NSLog(@"Chose random intention: %@", currentIntention.intentionSlug);
            return currentIntention;
        }
        
    }
    NSLog(@"ERROR DID NOT FIND RANDOM INTENTION");
    return nil;
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

-(void)addTexts:(NSArray*)theTexts toIntention:(NSMutableArray*)availableIntentions {
    for (int i = 0; i < theTexts.count; i++) {
        
        Text *currentText = [theTexts objectAtIndex:i];
        
        for (int k = 0; k < availableIntentions.count; k++) {
            
            IntentionObject *currentIntention = [availableIntentions objectAtIndex:k];
            
            if ([currentText.intentionLabel isEqualToString:currentIntention.intentionSlug]) {
                TextObject *textObj = [[TextObject alloc] initWithWeight:1.0 andText:currentText];
                [currentIntention.textsForIntention addObject:textObj];
                break;
            }
        }
        
    }
}

@end
