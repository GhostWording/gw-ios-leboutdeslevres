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
@synthesize impersonal;


-(id)initWithIntentionSlug:(NSString *)theSlug andLabel:(NSString *)theLabel andDefaultWeight:(float)theDefaulWeight andUserWeight:(float)theUserWeight {
    if (self = [super init]) {
        self.intentionSlug = theSlug;
        self.intentionLabel = theLabel;
        self.defaultWeight = theDefaulWeight;
        self.userWeight = theUserWeight;
        self.textsForIntention = [NSMutableArray array];
        self.impersonal = NO;
    }
    
    return self;
}

#pragma mark -

+(instancetype)intentionJoke {
    return [[[self class] alloc] initWithIntentionSlug:@"jokes" andLabel:@"Joke of the day" andDefaultWeight:0.4f andUserWeight:1];
}

+(instancetype)intentionAFewWordsForYou {
    return [[[self class] alloc] initWithIntentionSlug:@"a-few-words-for-you" andLabel:@"A few words for you" andDefaultWeight:1.0f andUserWeight:1];
}

+(instancetype)intentionFacebookStatus {
    IntentionObject *tmpIntention = [[[self class] alloc] initWithIntentionSlug:@"facebook-status" andLabel:@"Statuts Facebook" andDefaultWeight:0.3f andUserWeight:1];
    tmpIntention.impersonal = YES;
    return tmpIntention;
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
    return [[[self class] alloc] initWithIntentionSlug:@"thank-you" andLabel:@"Merci" andDefaultWeight:0.2f andUserWeight:1];
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
    return [[[self class] alloc] initWithIntentionSlug:@"I-like-you" andLabel:@"Tu me plais" andDefaultWeight:1.0 andUserWeight:1];
}

#pragma mark - Special Occasion Intentions

+(instancetype)intentionHappyBirthday {
    return [[[self class ] alloc] initWithIntentionSlug:@"happy-birthday" andLabel:@"Joyeux anniversaire" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionIAmLate {
    IntentionObject *tmpIntention = [[[self class] alloc] initWithIntentionSlug:@"I-am-late" andLabel:@"Je suis en retard" andDefaultWeight:1.0 andUserWeight:1.0];
    tmpIntention.impersonal = YES;
    return tmpIntention;
}

+(instancetype)intentionStopTheWorld {
    IntentionObject *tmpIntention = [[[self class] alloc] initWithIntentionSlug:@"stop-the-world" andLabel:@"Arrêtez le monde" andDefaultWeight:1.0 andUserWeight:1.0];
    tmpIntention.impersonal = YES;
    return tmpIntention;
}

+(instancetype)intentionNoThankYou {
    return [[[self class] alloc] initWithIntentionSlug:@"no-thank-you" andLabel:@"Non merci" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionComeBackToMe {
    return [[[self class] alloc] initWithIntentionSlug:@"come-back-to-me" andLabel:@"Reviens-moi" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionIAmLeavingYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-am-leaving-you" andLabel:@"Je te quitte" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionCondolences {
    return [[[self class] alloc] initWithIntentionSlug:@"condolences" andLabel:@"Condoléances" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionIAmSorry {
    return [[[self class] alloc] initWithIntentionSlug:@"sorry" andLabel:@"Pardon" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionIAmHereForYou {
    return [[[self class] alloc] initWithIntentionSlug:@"I-am-here-for-you" andLabel:@"Je suis là pour toi" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionCelebrateTheOccasion {
    return [[[self class] alloc] initWithIntentionSlug:@"celebrate-the-occasion" andLabel:@"Bonne fête" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionHappyNewYear {
    return [[[self class] alloc] initWithIntentionSlug:@"happy-new-year" andLabel:@"Bonne année" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionHumorousInsults {
    IntentionObject *tmpIntention = [[[self class] alloc] initWithIntentionSlug:@"humorous-insults" andLabel:@"Insultes polies" andDefaultWeight:1.0 andUserWeight:1.0];
    tmpIntention.impersonal = YES;
    return tmpIntention;
}

+(instancetype)intentionGoodMorning {
    return [[[self class] alloc] initWithIntentionSlug:@"good-morning" andLabel:@"Bonjour" andDefaultWeight:1.0 andUserWeight:1.0];
}

+(instancetype)intentionGoodNight {
    return [[[self class] alloc] initWithIntentionSlug:@"good-night" andLabel:@"Bonne nuit" andDefaultWeight:1.0 andUserWeight:1.0];
}

@end
