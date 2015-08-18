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
#import "ServerComm.h"
#import "Text.h"
#import "Image.h"
#import "TextObject.h"
#import "TextFilter.h"
#import "UserDefaults.h"
#import "GWDataManager.h"
#import "GWText.h"
#import "ConstantsManager.h"
#import "NSArray+Extension.h"
//#import <GWFramework/GWFramework.h>


@interface RootViewModel () {
    DataManager *dataMan;
    NSArray *specialOccasionTextArray;
    NSArray *specialOccasionImageArray;
    NSString *selectedIntentionSlug;
}

@end

@implementation RootViewModel

@synthesize isSpecialOccasionIntentionChosen, isLoadingImages;

-(id)init {
    if (self = [super init]) {
        
        dataMan = [[DataManager alloc] init];
        specialOccasionTextArray = nil;
        specialOccasionImageArray = nil;
        isSpecialOccasionIntentionChosen = NO;
        isLoadingImages = NO;
        _numSpecialOccasionImages = 10;
        _numSpecialOccasionTexts = 10;
        _isShowingRatingView = NO;
        
    }
    
    return self;
}

/* Used for adding texts to intentions, and calculating the odds of the texts to show per intention. **/
-(NSMutableArray*)theIntentions {
    NSMutableArray *tmpIntention = [NSMutableArray array];
    
    [tmpIntention addObject:[IntentionObject intentionJoke]];
    [tmpIntention addObject:[IntentionObject intentionAFewWordsForYou]];
    [tmpIntention addObject:[IntentionObject intentionFacebookStatus]];
    [tmpIntention addObject:[IntentionObject intentionPositiveThoughts]];
    [tmpIntention addObject:[IntentionObject intentionIThinkOfYou]];
    [tmpIntention addObject:[IntentionObject intentionILoveYou]];
    [tmpIntention addObject:[IntentionObject intentionIMissYou]];
    [tmpIntention addObject:[IntentionObject intentionThankYou]];
    [tmpIntention addObject:[IntentionObject intentionThereIsSomethingMissing]];
    [tmpIntention addObject:[IntentionObject intentionSurpriseMe]];
    [tmpIntention addObject:[IntentionObject intentionIWantYou]];
    [tmpIntention addObject:[IntentionObject intentionILikeYou]];
    return tmpIntention;
}


# pragma mark - First launch view

-(BOOL)minimumImagesAndTextsToDownloadWithNumTexts:(int)numTexts withNumImages:(int)numImages {
    
    GWDataManager *theDataMan = [[GWDataManager alloc] init];
    
    if (theDataMan.fetchNumTexts >= numTexts && theDataMan.fetchNumImages >= numImages) {
        return YES;
    }
    
    return NO;
}


#pragma mark - Special Occasion getters and setters


-(void)downloadTextsForArea:(NSString *)theArea withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    NSLog(@"downloading intentions");
    
    GWDataManager *theDataMan = [[GWDataManager alloc] init];
    
    [theDataMan downloadIntentionsWithArea:theArea withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *intentionIds, NSError *error) {
       
        NSLog(@"downlaod intention response");
        
        GWDataManager *newDataMan = [[GWDataManager alloc] init];
        
        NSArray *allIntentions = [newDataMan fetchIntentionsOnBackgroundThread];
        //NSLog(@"all intentions: %@", allIntentions);
        NSArray *slugsFromArray = [allIntentions valueForKey:@"slugPrototypeLink"];
        
        if (error) {
            block(nil, error);
            return ;
        }
        
        GWDataManager *anotherDataMan = [[GWDataManager alloc] init];
        [anotherDataMan downloadTextsWithArea:theArea withIntentionSlugs:slugsFromArray withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *textIds, NSError *error) {
            NSLog(@"downloading texts on main thread in text ids: %@", textIds);
            block(textIds, error);
        }];
        
    }];
    
    
}


-(void)downloadImagesForRecipient:(NSString *)theRecipientId withNum:(NSInteger)numImages withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    GWDataManager *theDataManager = [[GWDataManager alloc] init];
    [theDataManager downloadImagesAndPersistWithRecipientId:theRecipientId withNumImagesToDownload:numImages withCompletion:^(NSArray *theImageIds, NSError *error)  {
        
        NSLog(@"the number of images downloaded: %d, the number of images to download: %d", (int)theImageIds.count, (int)numImages);
        block(theImageIds, error);
        
    }];
    
}


-(void)setRandomTextForIntention:(NSString *)intentionSlug withNum:(int)num {
    
    GWDataManager *theDataManger = [[GWDataManager alloc] init];
    
    specialOccasionTextArray = [theDataManger fetchTextsForIntentionSlug:intentionSlug withCulture:[UserDefaults currentCulture]];
    selectedIntentionSlug = intentionSlug;
    
}

-(void)setRandomTextForSpecialOccasionTexts:(NSArray*)theTexts {
    specialOccasionTextArray = theTexts;
}

-(void)setRandomTextForIntention:(NSString *)intentionSlug andNum:(int)num andFilter:(TextFilter*)theFilter {
    
    NSLog(@"intention slug is: %@", intentionSlug);
    
    GWDataManager *theDataManger = [[GWDataManager alloc] init];
    
    specialOccasionTextArray = [theDataManger fetchTextsForIntentionSlug:intentionSlug withCulture:[UserDefaults currentCulture]];
    selectedIntentionSlug = intentionSlug;
    
    NSLog(@"count before filter: %d", (int)specialOccasionTextArray.count);
    
    if (theFilter) {
        specialOccasionTextArray = [theFilter filterTextsFromArray:specialOccasionTextArray];
        NSLog(@"count after filter: %d", (int)specialOccasionTextArray.count);
    }
    
}



-(void)setRandomImageForCurrentIntention:(NSArray *)imagesForIntention withNum:(int)num {
    specialOccasionImageArray = imagesForIntention;
}

-(void)fetchTextsForIntention:(NSString *)theIntention withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    
    GWDataManager *theDataManger = [[GWDataManager alloc] init];
    NSArray *textsForIntention = [theDataManger fetchTextsForIntentionSlug:theIntention withCulture:[UserDefaults currentCulture]];
    
    TextFilter *textFilter = [[TextFilter alloc] init];
    
    if (textsForIntention.count > 100) {
        
        specialOccasionTextArray = [textFilter filterTextsFromArray:textsForIntention];
        selectedIntentionSlug = theIntention;
        
        block(textsForIntention, nil);
        
        // MARK: Download texts nonetheless to make sure we've got the latest ones?
        
    }
    else {
        NSLog(@"get data for intention");
        [theDataManger downloadTextsWithArea:[ConstantsManager sharedInstance].specialOccasionArea withIntentionSlug:theIntention withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *textIds, NSError *error) {
            
            NSLog(@"finished downloading texts");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                GWDataManager *returnedData = [[GWDataManager alloc] init];
                NSArray *downloadedTextsForIntention = [returnedData fetchTextsForIntentionSlug:theIntention withCulture:[UserDefaults currentCulture]];
                specialOccasionTextArray = [textFilter filterTextsFromArray:downloadedTextsForIntention];
                selectedIntentionSlug = theIntention;
                NSLog(@"downloaded texts for intention after filter: %d", (int)specialOccasionTextArray.count);
                block(downloadedTextsForIntention, error);
            });
            
        }];
    }
     
}

-(void)fetchImagesForIntention:(NSString *)theIntention withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    GWDataManager *downloadImagesNotAvailable = [[GWDataManager alloc] init];
    
    // download the image paths
    
    [downloadImagesNotAvailable downloadImagePathsWithRelativePath:theIntention withCompletion:^(NSArray *theImagePaths, NSError *error) {
        
        NSLog(@"image paths are: %d", (int)theImagePaths.count);
        
        GWDataManager *anotherDataMan = [[GWDataManager alloc] init];
        
        // remove the iamge paths of the images we have stored and store them in a separate array
        NSArray *allImages = [anotherDataMan fetchImagesOnBackgroundThread];
        NSArray *imagePathsLeft = [anotherDataMan removeImagePathsInArray:theImagePaths withImagesToRemove:allImages];
        
        if (imagePathsLeft.count == 0) {
            NSLog(@"image paths left is zero");
            NSArray *randomImagePaths = [NSArray randomIndexesFromArray:theImagePaths withNumRandomIndexes:10];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *imagesToReturn = [anotherDataMan  fetchImagesWithImagePaths:randomImagePaths];
                block(imagesToReturn, nil);
            });
            
            return ;
        }
        else {
            
            NSLog(@"image paths are not zero");
            
            NSArray *randomImages = [anotherDataMan randomIndexesFromArray:imagePathsLeft withNumRandomIndexes:10];
            
            [anotherDataMan downloadImagesWithUrls:randomImages withCompletion:^(NSArray *theImagePaths, NSError *error) {
                
                GWDataManager *newDownloadDataMan = [[GWDataManager alloc] init];
                
                
                if (theImagePaths.count < 10) {
                    
                    int numImagePathsLeft = 10 - (int)theImagePaths.count;
                    
                    NSArray *imagePathsLeftAfterDownload = [newDownloadDataMan removeImagePathsInArray:imagePathsLeft withImagePathsToRemove:theImagePaths];
                    NSArray *extraImagePaths = [NSArray randomIndexesFromArray:imagePathsLeftAfterDownload withNumRandomIndexes:numImagePathsLeft];
                    
                    theImagePaths = [theImagePaths arrayByAddingObjectsFromArray:extraImagePaths];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSArray *imagesToReturn = [newDownloadDataMan fetchImagesWithImagePaths:theImagePaths];
                    block(imagesToReturn, nil);
                    
                });
                
            }];
        }
        
        
    }];
    
}

-(BOOL)textsExistForIntention:(NSString *)theIntention {
    
    return [dataMan textsExistForIntention:theIntention];
}

-(NSArray*)specialOccasionTexts {
    
    IntentionObject *tmpIntention = [[IntentionObject alloc] initWithIntentionSlug:selectedIntentionSlug andLabel:@"" andDefaultWeight:1.0 andUserWeight:1.0];
    
    NSMutableArray *mutableIntention = [[NSMutableArray alloc] initWithObjects:tmpIntention, nil];
    NSLog(@"selected intention slug is: %@", selectedIntentionSlug);
    NSLog(@"special occations texts array is: %d", (int)specialOccasionTextArray.count);
    [self addTexts:specialOccasionTextArray toIntention:mutableIntention];
    
    NSLog(@"mutable intentions are: %d", (int)tmpIntention.textsForIntention.count);
    
    [self setupTextWeight:mutableIntention];
    
    NSMutableArray *textsToReturn = [NSMutableArray array];
    
    NSLog(@"number of special occasions texts: %d and special occasion text array: %d", _numSpecialOccasionImages, (int)specialOccasionTextArray.count);
    
    for (int i = 0; i < _numSpecialOccasionTexts && i < specialOccasionTextArray.count; i++) {
        NSLog(@"going through array");
        TextObject *randomText = [self chooseRandomTextForIntention:tmpIntention];
        [textsToReturn addObject:randomText.text];
        [tmpIntention.textsForIntention removeObject:randomText];
    }
    

    
    return textsToReturn;
}

-(NSArray*)specialOccasionImages {
    NSMutableArray *specialOccasionImagesToReturn = [NSMutableArray array];
    NSMutableArray *specialOccasionImages = [[NSMutableArray alloc] initWithArray:specialOccasionImageArray];
    
    for (int i = 0; i < specialOccasionImageArray.count && i < _numSpecialOccasionImages; i++) {
        int randomPos = rand() % specialOccasionImages.count;
        GWImage *currentImage = [specialOccasionImages objectAtIndex:randomPos];
        [specialOccasionImagesToReturn addObject:currentImage];
        [specialOccasionImages removeObjectAtIndex:randomPos];
    }
    
    return specialOccasionImagesToReturn;
}

#pragma mark - Image Fetching 

-(NSArray*)randomImagesWithNum:(int)numImages {
    return [dataMan randomImagesForNumberOfImages:numImages];
}

// image fetching by adding two images from text image urls
// to the last two images, if the texts have image urls, if
// we have images that correspond to that url and we don't have
// them in the image scroll view already.
-(NSArray*)randomImagesWithImagesBasedOnTexts:(NSArray*)theTexts WithNum:(int)numImages {
    NSLog(@"special random Images with num: %d", numImages);
    GWDataManager *randomImagesDataMan = [[GWDataManager alloc] init];
    NSArray *allRandomImages = [randomImagesDataMan fetchRandomImagesWithNum:numImages];
    NSLog(@"special random iamges with count: %d", (int)allRandomImages.count);
    return allRandomImages;
    //return [dataMan randomImagesWithSpecialImagesForTexts:theTexts withNumImages:numImages];
}

#pragma mark - Text Filtering and Fetching

-(NSArray*)randomtTextWithNum:(int)numTexts {
    
    //NSArray *texts = [dataMan allTexts];
    GWDataManager *theDataManager = [[GWDataManager alloc] init];
    NSArray *texts = [theDataManager fetchTextsForCulture:[UserDefaults currentCulture]];
    
    TextFilter *theFilter = [[TextFilter alloc] init];
    
    texts = [theFilter filterTextsFromArray:texts];
    
    NSLog(@"Adding texts: %d", (int)texts.count);
    
    NSMutableArray *intentions = [self theIntentions];
    
    [self addTexts:texts toIntention:intentions];
    
    // compute the weight of the texts if we want to do it once and not for every intention
    NSLog(@"setup texts");
    
    [self setupTextWeight:intentions];
    
    NSLog(@"computing texts to return");
    
    NSMutableArray *textsToReturn = [NSMutableArray array];
    
    for (int i = 0; i < numTexts && texts.count != 0; i++) {
        
        IntentionObject *randomIntention = [self randomIntentionWithIntentions:intentions];
        
        TextObject *randomObject = [self chooseRandomTextForIntention:randomIntention];

        if (randomObject != nil) {
            [textsToReturn addObject:randomObject.text];
            [randomIntention.textsForIntention removeObject:randomObject];
        }
        
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
        
    }
    
    float randFloat = [self randomFloatBetween:0.0f and:totalWeight];
    
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
        
        GWText *currentText = [theTexts objectAtIndex:i];
        
        for (int k = 0; k < availableIntentions.count; k++) {
            
            IntentionObject *currentIntention = [availableIntentions objectAtIndex:k];

            if ([currentText.intentionLabel isEqualToString:currentIntention.intentionSlug]) {
                //NSLog(@"is equal: %@, %@", currentIntention.intentionSlug, currentText.intentionLabel);
                TextObject *textObj = [[TextObject alloc] initWithWeight:1.0 andText:currentText];
                [currentIntention.textsForIntention addObject:textObj];
                break;
            }
        }
        
    }
}

@end
