//
//  RootViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "RootViewModel.h"
#import "IntentionObject.h"
#import "Text.h"
#import "Image.h"
#import "TextObject.h"
#import "TextFilter.h"
#import "UserDefaults.h"
#import "GWDataManager.h"
#import "GWText.h"
#import "GWImage.h"
#import "ConstantsManager.h"
#import "NSArray+Extension.h"
//#import <GWFramework/GWFramework.h>


@interface RootViewModel () {
    NSArray *specialOccasionTextArray;
    NSArray *specialOccasionImageArray;
    NSString *selectedIntentionSlug;
    NSArray *_themeImages;
    NSString *_themePath;
}

@end

@implementation RootViewModel

@synthesize isSpecialOccasionIntentionChosen, isLoadingImages;

-(id)init {
    if (self = [super init]) {
        
        specialOccasionTextArray = nil;
        specialOccasionImageArray = nil;
        _themeImages = nil;
        _userSelectedImages = nil;
        isSpecialOccasionIntentionChosen = NO;
        isLoadingImages = NO;
        _isUserPhotosSelected = NO;
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
    
    [theDataMan downloadAllTextsWithBlockForArea:theArea withCulture:[UserDefaults currentCulture] withCompletion:block];
    
}


-(void)downloadImagesForRecipient:(NSString *)theRecipientId withNum:(NSInteger)numImages withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    GWDataManager *theDataManager = [[GWDataManager alloc] init];
    [theDataManager downloadImagesAndPersistWithRecipientId:theRecipientId withNumImagesToDownload:numImages withCompletion:^(NSArray *theImageIds, NSError *error)  {
        
       
        block(theImageIds, error);
        
    }];
    
}

#pragma mark - Weclome images and text download

-(void)downloadWelcomeTextsWithCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://gw-static-apis.azurewebsites.net/data/liptip/welcometexts.json"]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[UserDefaults currentCulture] forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    __weak typeof (self) wSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data != nil) {
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *prototypeIds = [jsonDict objectForKey:@"PrototypeIds"];
            NSLog(@"number of prototype ids: %@", prototypeIds);
            [wSelf downloadTextsWithPrototypeIds:prototypeIds withCompletion:^(NSArray *theTexts, NSError *theError) {
                NSLog(@"the welcome texts: %@", theTexts);
                TextFilter *newFilter = [[TextFilter alloc] init];
                NSArray *theLaunchTexts = [newFilter filterTextsFromArray:theTexts];
                self.firstLaunchTexts = theLaunchTexts;
                self.firstLaunchError = theError;
                block(theTexts, error);
            }];
            
        }
        else {
            self.firstLaunchError = error;
            block(nil, error);
        }
        
    }];
    
}

-(void)downloadWelcomeImagesWithCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    NSMutableURLRequest *request  = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://gw-static-apis.azurewebsites.net/data/liptip/welcomeimages.json"]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[UserDefaults currentCulture] forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        if (data != nil && error == nil) {
            
            NSDictionary *theImagePathDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *theImagePaths = [theImagePathDict objectForKey:@"ImageUrls"];
            NSMutableArray *imagePathsToDownload = [NSMutableArray arrayWithArray:theImagePaths];
            
            for (int i = 0; i < imagePathsToDownload.count; i++) {
                NSString *imagePath = [imagePathsToDownload objectAtIndex:i];
                if ([imagePath hasSuffix:@"/"] == NO) {
                    imagePath = [NSString stringWithFormat:@"/%@", imagePath];
                    [imagePathsToDownload replaceObjectAtIndex:i withObject:imagePath];
                }
            }
            
            GWDataManager *theDataMan = [[GWDataManager alloc] init];
            NSArray *localImages = [theDataMan fetchImagesOnBackgroundThread];
            
            for (GWImage *currentImage in localImages) {
                for (int i = 0; i < imagePathsToDownload.count; i++) {
                    NSString *currentImagePath = [imagePathsToDownload objectAtIndex:i];
                    if ([currentImage.imageId isEqualToString:currentImagePath]) {
                        [imagePathsToDownload removeObjectAtIndex:i];
                    }
                }
            }
            
            [theDataMan downloadImagesWithUrls:imagePathsToDownload isRelativeURL:YES withCompletion:^(NSArray *theImagePaths, NSError *theError) {
               
                _firstLaunchImageError = theError;
                
                if (theImagePaths != nil && theError == nil) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSArray *theWelcomeImages = [[[GWDataManager alloc] init] fetchImagesWithImagePaths:theImagePaths];
                        
                        
                        _firstLaunchImages = theWelcomeImages;
                        block(_firstLaunchImages, nil);
                    });
                    
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil, theError);
                    });
                }
                
            }];
            
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
               block(nil, error);
            });
        }
    }];
}

-(void)downloadTextsWithPrototypeIds:(NSString*)thePrototypeIds withCompletion:(void (^)(NSArray *theTexts, NSError *error))block {
    [block copy];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.cvd.io/LipTip/text/prototypes/%@/realizations", thePrototypeIds]]];
    
    NSLog(@"prototype ids: %@", thePrototypeIds);
    
    [request setHTTPMethod:@"GET"];
    [request setValue:[UserDefaults currentCulture] forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data != nil) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                NSArray *theTexts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                GWDataManager *theDataMan = [[GWDataManager alloc] init];
                NSArray *fetchedTexts = [theDataMan fetchTextsWithIntentionIds:nil withTag:nil withCulture:[UserDefaults currentCulture]];
                NSMutableArray *textsToReturn = [NSMutableArray array];
                
                for (NSDictionary *theDict in theTexts) {
                    GWText *theText = [theDataMan persistTextOrUpdateWithJson:theDict withArray:fetchedTexts withContext:[[GWCoreDataManager sharedInstance] mainObjectContext]];
                    [textsToReturn addObject:theText];
                }
                
                block(textsToReturn, nil);
                
            });
            
            
        }
        else {
            block(nil, error);
        }
        
        
    }];
    
}

//-(void)setRandomTextForIntention:(NSString *)intentionSlug withNum:(int)num {
//    
//    GWDataManager *theDataManger = [[GWDataManager alloc] init];
//    
//    specialOccasionTextArray = [theDataManger fetchTextsForIntentionSlug:intentionSlug withCulture:[UserDefaults currentCulture]];
//    selectedIntentionSlug = intentionSlug;
//    
//}

-(void)setRandomTextForSpecialOccasionTexts:(NSArray*)theTexts withFilter:(TextFilter *)theFilter{
    
    if (theFilter != nil) {
        specialOccasionTextArray = [theFilter filterTextsFromArray:theTexts];
    }
    else {
        specialOccasionTextArray = theTexts;
    }
}



-(void)setRandomImageForCurrentIntention:(NSArray *)imagesForIntention withNum:(int)num {
    specialOccasionImageArray = imagesForIntention;
}

-(void)fetchTextsForIntentionId:(NSString *)theIntention withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    
    GWDataManager *theDataManger = [[GWDataManager alloc] init];
    NSArray *textsForIntention = [theDataManger fetchTextsWithIntentionIds:@[theIntention] withTag:nil withCulture:[UserDefaults currentCulture]];
    
    TextFilter *textFilter = [[TextFilter alloc] init];
    
    if (textsForIntention.count > 100) {
        
        specialOccasionTextArray = [textFilter filterTextsFromArray:textsForIntention];
        NSArray *intentions = [theDataManger fetchIntentionsWithAreaName:nil withIntentionsIds:@[theIntention]];
        selectedIntentionSlug = [(GWIntention*)[intentions firstObject] slugPrototypeLink];
        
        block(textsForIntention, nil);
        
        // MARK: Download texts nonetheless to make sure we've got the latest ones?
        
    }
    else {
        NSLog(@"get data for intention");
        [theDataManger downloadTextsWithArea:[ConstantsManager sharedInstance].specialOccasionArea withIntentionIds:@[theIntention] withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *textIds, NSError *error) {
            
            NSLog(@"finished downloading texts");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                GWDataManager *returnedData = [[GWDataManager alloc] init];
                NSArray *downloadedTextsForIntention = [returnedData fetchTextsWithIntentionIds:@[theIntention] withTag:nil withCulture:[UserDefaults currentCulture]];
                specialOccasionTextArray = [textFilter filterTextsFromArray:downloadedTextsForIntention];
                specialOccasionTextArray = [textFilter filterTextsFromArray:textsForIntention];
                
                NSArray *intentions = [returnedData fetchIntentionsWithAreaName:nil withIntentionsIds:@[theIntention]];
                selectedIntentionSlug = [(GWIntention*)[intentions firstObject] slugPrototypeLink];
                
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
                        
            NSArray *randomImages = [anotherDataMan randomIndexesFromArray:imagePathsLeft withNumRandomIndexes:10];
            
            [anotherDataMan downloadImagesWithUrls:randomImages isRelativeURL:YES withCompletion:^(NSArray *theImagePaths, NSError *error) {
                
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

-(void)fetchImagesForCurrentThemePathWithCompletion:(void (^)(NSArray *, NSError *))block {
    [self fetchImagesForThemePath:_themePath withCompletion:block];
}

-(void)fetchImagesForThemePath:(NSString *)theThemePath withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    GWDataManager *dataMan = [[GWDataManager alloc] init];
    _themePath = theThemePath;
    
    if ([theThemePath isEqualToString:@"Random"]) {
        
        block(nil, nil);
        return ;
    }
    
    [dataMan downloadImagesAndPersistWithRelativePath:theThemePath withNumImagesToDownload:10 withCompletion:^(NSArray *theImageIds, NSError *theError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (theError == nil) {
                if (theImageIds.count < 10) {
                    NSMutableArray *theImages = [NSMutableArray arrayWithArray:[dataMan fetchImagesWithImagePaths:theImageIds]];
                    
                    NSArray *additionalImages = [dataMan fetchRandomImagesWithPredicate:[NSPredicate predicateWithFormat:@"imageId CONTAINS[cd] %@", theThemePath] withNum:10 - (int)theImageIds.count];
                    [theImages addObjectsFromArray:additionalImages];
                    
                    _themeImages = theImages;
                    block(theImages, nil);
                    
                }
                else {
                    NSArray *theImages = [dataMan fetchImagesWithImagePaths:theImageIds];
                    _themeImages = theImages;
                    block(theImages, nil);
                }
            }
            else {
                block(nil, theError);
            }
        });
        
    }];
    
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

        TextObject *randomText = [self chooseRandomTextForIntention:tmpIntention];
        [textsToReturn addObject:randomText.text];
        [tmpIntention.textsForIntention removeObject:randomText];
    }
    

    
    return textsToReturn;
}

-(NSArray*)themeImages {
    return _themeImages;
}

-(void)setSpecialOccasionImages:(NSArray *)theSpecialOccasionImages {
    _numSpecialOccasionImages = (int)theSpecialOccasionImages.count;
    specialOccasionImageArray = theSpecialOccasionImages;
}

-(NSArray*)specialOccasionImages {
    NSMutableArray *specialOccasionImagesToReturn = [NSMutableArray array];
    NSMutableArray *specialOccasionImages = [[NSMutableArray alloc] initWithArray:specialOccasionImageArray];
    
    if (specialOccasionImageArray.count == 0) {
        return [self randomImagesWithNum:10 ignoringImages:@[] numberOfImagesInDB:10];
        
    }
    
    for (int i = 0; i < specialOccasionImageArray.count && i < _numSpecialOccasionImages; i++) {
        int randomPos = rand() % specialOccasionImages.count;
        GWImage *currentImage = [specialOccasionImages objectAtIndex:randomPos];
        [specialOccasionImagesToReturn addObject:currentImage];
        [specialOccasionImages removeObjectAtIndex:randomPos];
    }
    
    return specialOccasionImagesToReturn;
}

#pragma mark - Image Fetching 

-(NSArray*)randomImagesWithNum:(int)numImages ignoringImages:(NSArray *)theImagesToIgnore numberOfImagesInDB:(int)theNumImagesInDB  {
    GWDataManager *randomImagesDataMan = [[GWDataManager alloc] init];
    return [randomImagesDataMan fetchRandomImagesWithNum:numImages ignoringImages:theImagesToIgnore numberOfImagesInDatabase:theNumImagesInDB];
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

-(NSString*)addImagePathToSMS:(NSString *)theImage relativePath:(NSString *)theRelativePath {
    
    NSString *newString = [NSString stringWithFormat:@"%@ \n\nhttp://gw-static.azurewebsites.net%@", theImage, theRelativePath];
    
    return newString;
}

#pragma mark - Text Filtering and Fetching

-(NSArray*)randomtTextWithNum:(int)numTexts ignoringTexts:(NSArray *)theTextsToIgnore {
    
    //NSArray *texts = [dataMan allTexts];
    GWDataManager *theDataManager = [[GWDataManager alloc] init];
    NSArray *texts = [theDataManager fetchTextsWithIntentionIds:nil withTag:nil withCulture:[UserDefaults currentCulture]];
    
    if (theTextsToIgnore != nil) {
        texts = [self removeTextsFromArray:texts textsToRemove:theTextsToIgnore];
    }
    
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

-(NSArray *)removeTextsFromArray:(NSArray *)theTexts textsToRemove:(NSArray *)theTextsToRemove {
    
    NSMutableArray *newTexts = [NSMutableArray arrayWithArray:theTexts];
    
    for (GWText *textToRemove in theTextsToRemove) {
        
        for (GWText *currentText in theTexts) {
            if ([currentText.textId isEqualToString:textToRemove.textId]) {
                [newTexts removeObject:currentText];
            }
        }
        
    }
    
    return newTexts;
}

@end
