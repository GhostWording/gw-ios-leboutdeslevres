//
//  RootViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextFilter, IntentionObject, RecipientObject;

@interface RootViewModel : NSObject

@property (nonatomic, readwrite) BOOL isSpecialOccasionIntentionChosen;
@property (nonatomic, readwrite) BOOL isLoadingImages;
@property (nonatomic, readwrite) BOOL isShowingRatingView;

@property (nonatomic, readwrite) int numSpecialOccasionTexts;
@property (nonatomic, readwrite) int numSpecialOccasionImages;

-(void)setRandomTextForSpecialOccasionTexts:(NSArray*)theTexts withFilter:(TextFilter*)theFilter;
-(void)setRandomTextForIntention:(NSString*)intentionSlug withNum:(int)num;
-(void)setRandomImageForCurrentIntention:(NSArray *)imagesForIntention withNum:(int)num;


-(void)downloadTextsForArea:(NSString*)theArea withCompletion:(void (^)(NSArray *theTexts, NSError *error))block;
-(void)downloadImagesForRecipient:(NSString*)theRecipientId withNum:(NSInteger)numImages withCompletion:(void (^)(NSArray *theImageIds, NSError *error))block;


-(BOOL)minimumImagesAndTextsToDownloadWithNumTexts:(int)numTexts withNumImages:(int)numImages;

-(BOOL)textsExistForIntention:(NSString*)theIntention;
-(void)fetchTextsForIntention:(NSString*)theIntention withCompletion:(void (^)(NSArray *theTexts, NSError *error))block;
-(void)fetchImagesForIntention:(NSString*)theIntention withCompletion:(void (^)(NSArray *theImages, NSError *error))block;
-(NSArray*)specialOccasionTexts;
-(NSArray*)specialOccasionImages;

-(NSArray*)randomtTextWithNum:(int)numTexts;
-(NSArray*)randomImagesWithNum:(int)numImages;
-(NSArray*)randomImagesWithImagesBasedOnTexts:(NSArray*)theTexts WithNum:(int)numImages;

-(NSString*)addImagePathToSMS:(NSString*)theImage relativePath:(NSString*)theRelativePath;

@end
