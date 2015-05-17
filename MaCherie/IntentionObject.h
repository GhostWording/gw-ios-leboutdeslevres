//
//  IntentionObject.h
//  MaCherie
//
//  Created by Mathieu Skulason on 14/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

// An object used solely to add texts to corresponding intentions to know their weighting
// for the random choice of texts.

@interface IntentionObject : NSObject

@property (nonatomic, strong) NSString *intentionSlug;
@property (nonatomic, strong) NSString *intentionLabel;
@property (nonatomic, strong) NSMutableArray *textsForIntention;
@property (nonatomic, readwrite) float defaultWeight;
@property (nonatomic, readwrite) float userWeight;

// the slug in the intention object is the same as the intention label in the text object, the naming
// should be changed for the text object.
-(id)initWithIntentionSlug:(NSString*)theSlug andLabel:(NSString*)theLabel andDefaultWeight:(float)theDefaulWeight andUserWeight:(float)theUserWeight;

#pragma mark - One Line Initializers

+(instancetype)intentionJoke;
+(instancetype)intentionAFewWordsForYou;
+(instancetype)intentionFacebookStatus;
+(instancetype)intentionPositiveThoughts;
+(instancetype)intentionIThinkOfYou;
+(instancetype)intentionILoveYou;
+(instancetype)intentionIMissYou;
+(instancetype)intentionThankYou;
+(instancetype)intentionThereIsSomethingMissing;
+(instancetype)intentionSurpriseMe;
+(instancetype)intentionIWantYou;

@end
