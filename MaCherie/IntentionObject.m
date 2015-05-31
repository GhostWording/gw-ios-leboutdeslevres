//
//  IntentionObject.m
//  MaCherie
//
//  Created by Mathieu Skulason on 14/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "IntentionObject.h"

@implementation IntentionObject

@synthesize intentionSlug;
@synthesize intentionLabel;
@synthesize textsForIntention;
@synthesize defaultWeight;
@synthesize userWeight;


-(id)initWithIntentionSlug:(NSString *)theSlug andLabel:(NSString *)theLabel andDefaultWeight:(float)theDefaulWeight andUserWeight:(float)theUserWeight {
    if (self = [super init]) {
        self.intentionSlug = theSlug;
        self.intentionLabel = theLabel;
        self.defaultWeight = theDefaulWeight;
        self.userWeight = theUserWeight;
        self.textsForIntention = [NSMutableArray array];
    }
    
    return self;
}

+(instancetype)intentionJoke {
    return [[[self class] alloc] initWithIntentionSlug:@"jokes" andLabel:@"Joke of the day" andDefaultWeight:0.4f andUserWeight:1];
}

+(instancetype)intentionAFewWordsForYou {
    return [[[self class] alloc] initWithIntentionSlug:@"a-few-words-for-you" andLabel:@"A few words for you" andDefaultWeight:1.0f andUserWeight:1];
}

+(instancetype)intentionFacebookStatus {
    return [[[self class] alloc] initWithIntentionSlug:@"facebook-status" andLabel:@"Thought of the day" andDefaultWeight:0.3f andUserWeight:1];
}

+(instancetype)intentionPositiveThoughts {
    return [[[self class] alloc] initWithIntentionSlug:@"positive-thoughts" andLabel:@"Thought of the day" andDefaultWeight:0.5f andUserWeight:1];
}

+(instancetype)intentionIThinkOfYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-think-of-you" andLabel:@"I think of you" andDefaultWeight:1.0f andUserWeight:1];
}

+(instancetype)intentionILoveYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-love-you" andLabel:@"I love you" andDefaultWeight:1.0f andUserWeight:1];
}

+(instancetype)intentionIMissYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-miss-you" andLabel:@"I miss you" andDefaultWeight:1.0f andUserWeight:1];
}

+(instancetype)intentionThankYou {
    return [[[self class] alloc] initWithIntentionSlug:@"thank-you" andLabel:@"Thank you" andDefaultWeight:0.2f andUserWeight:1];
}

+(instancetype)intentionThereIsSomethingMissing {
    return [[[self class] alloc] initWithIntentionSlug:@"there-is-something-missing" andLabel:@"There is something missing" andDefaultWeight:0.3f andUserWeight:1];
}

+(instancetype)intentionSurpriseMe {
    return [[[self class] alloc] initWithIntentionSlug:@"surprise-me" andLabel:@"Surprise me" andDefaultWeight:0.4f andUserWeight:1];
}

+(instancetype)intentionIWantYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-want-you" andLabel:@"I want you" andDefaultWeight:0.5 andUserWeight:1];
}

+(instancetype)intentionILikeYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-like-you" andLabel:@"I like you" andDefaultWeight:1.0 andUserWeight:1];
}

@end
