//
//  RootViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GWIntention.h"

@class TextFilter, IntentionObject, RecipientObject;

@interface RootViewModel : NSObject

@property (nonatomic, readwrite) BOOL isSpecialOccasionIntentionChosen;
@property (nonatomic, readwrite) BOOL isLoadingImages;
@property (nonatomic, readwrite) BOOL isShowingRatingView;
@property (nonatomic, readwrite) BOOL isUserPhotosSelected;
@property (nonatomic, readwrite) BOOL isViewingTheme;

@property (nonatomic, readwrite) int numSpecialOccasionTexts;
@property (nonatomic, readwrite) int numSpecialOccasionImages;

@property (nonatomic, strong) GWIntention *selectedSpecialOccasionIntention;

@property (nonatomic, strong) NSArray *userSelectedImages;

@property (nonatomic, strong) NSArray *firstLaunchTexts;
@property (nonatomic, strong) NSArray *firstLaunchImages;
@property (nonatomic, strong) NSError *firstLaunchError;
@property (nonatomic, strong) NSError *firstLaunchImageError;

-(void)setRandomTextForSpecialOccasionTexts:(NSArray*)theTexts withFilter:(TextFilter*)theFilter;
-(void)setRandomTextForIntention:(NSString*)intentionSlug withNum:(int)num;
-(void)setRandomImageForCurrentIntention:(NSArray *)imagesForIntention withNum:(int)num;


-(void)downloadTextsForArea:(NSString*)theArea withCompletion:(void (^)(NSArray *theTexts, NSError *error))block;
-(void)downloadImagesForRecipient:(NSString*)theRecipientId withNum:(NSInteger)numImages withCompletion:(void (^)(NSArray *theImageIds, NSError *error))block;

-(void)downloadWelcomeTextsWithCompletion:(void (^)(NSArray *theTexts, NSError *error))block;
-(void)downloadWelcomeImagesWithCompletion:(void (^)(NSArray *theImages, NSError *error))block;


-(BOOL)minimumImagesAndTextsToDownloadWithNumTexts:(int)numTexts withNumImages:(int)numImages;

-(void)fetchTextsForIntention:(NSString*)theIntention withCompletion:(void (^)(NSArray *theTexts, NSError *error))block;
-(void)fetchImagesForIntention:(NSString*)theIntention withCompletion:(void (^)(NSArray *theImages, NSError *error))block;

-(void)fetchImagesForThemePath:(NSString*)theThemePath withCompletion:(void (^)(NSArray *theImages, NSError *error))block;
-(void)fetchImagesForCurrentThemePathWithCompletion:(void (^)(NSArray *theImages, NSError *error))block;
-(NSArray*)specialOccasionTexts;
-(void)setSpecialOccasionImages:(NSArray*)theSpecialOccasionImages;
-(NSArray*)specialOccasionImages;
-(NSArray*)themeImages;

-(NSArray*)randomtTextWithNum:(int)numTexts ignoringTexts:(NSArray *)theTextsToIgnore;
-(NSArray*)randomImagesWithNum:(int)numImages ignoringImages:(NSArray *)theImagesToIgnore numberOfImagesInDB:(int)theNumImagesInDB;
-(NSArray*)randomImagesWithImagesBasedOnTexts:(NSArray*)theTexts WithNum:(int)numImages;

-(NSString*)addImagePathToSMS:(NSString*)theImage relativePath:(NSString*)theRelativePath;

@end
