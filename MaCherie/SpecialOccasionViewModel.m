//
//  SpecialOccasionViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 11/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "SpecialOccasionViewModel.h"
#import "IntentionObject.h"
#import "RecipientObject.h"
#import "UserDefaults.h"
#import "Image.h"
#import "GWDataManager.h"
#import "GWIntention.h"
#import "GWImage.h"
#import "NSString+RandomString.h"
#import <UIKit/UIKit.h>

@interface SpecialOccasionViewModel () {
    NSArray *intentions;
    NSArray *intentionImages;
    NSArray *recipients;
    GWDataManager *dataMan;
    NSURLSessionDataTask *sessionDataTask;
    
    NSString *currentArea;
}

@end

@implementation SpecialOccasionViewModel

-(id)initWithIntentions:(NSArray*)theIntetions andRecipients:(NSArray*)theRecipients {
    if (self = [super init]) {
        intentions = theIntetions;
        recipients = theRecipients;
    }
    
    return self;
}

-(instancetype)initWithArea:(NSString*)theArea withCulture:(NSString *)theCulture {
    
    if (self = [super init]) {
        
        dataMan = [[GWDataManager alloc] init];
        currentArea = theArea;
        intentions = [dataMan fetchIntentionsWithAreaName:theArea withIntentionsIds:nil];// [dataMan fetchIntentionsWithArea:theArea withCulture:theCulture];
        NSLog(@"intentions are: %@", intentions);
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrderInArea" ascending:YES];
        intentions = [intentions sortedArrayUsingDescriptors:@[sortDescriptor]];
        intentions = [self removeDuplicateIntentions:intentions];
        [self reloadIntentionImages];
        sessionDataTask = nil;
    }
    
    return self;
}

-(GWIntention*)intentionAtIndex:(NSInteger)theIndex {
    if (theIndex < intentions.count) {
        GWIntention *intention = [intentions objectAtIndex:theIndex];
        return intention;
    }
    
    return nil;
}

-(NSInteger)numberOfIntentions {
    return intentions.count;
}

-(NSInteger)numberOfIntentionImages {
    return intentionImages.count;
}

-(UIImage*)imageForIntentionAtIndex:(NSInteger)theIndex {
    
    if (theIndex < intentionImages.count) {
        
        return [intentionImages objectAtIndex:theIndex];
        
    }
    
    return nil;
}


-(RecipientObject*)recipientAtIndex:(NSInteger)theIndex {
    if (theIndex < recipients.count) {
        RecipientObject *recipient = [recipients objectAtIndex:theIndex];
        return recipient;
    }
    
    return nil;
}

-(NSInteger)numberOfRecipients {
    return recipients.count;
}

-(RecipientObject*)sweetheartBasedOnUserDefaults {
    
    if ([[UserDefaults userGender] intValue] == kGenderMale) {
        return [RecipientObject recipientSweetheartFemale];
    }
    else if([[UserDefaults userGender] intValue] == kGenderFemale) {
        return [RecipientObject recipientSweetheartMale];
    }
    
    return [RecipientObject recipientSweetheartFemale];
}

-(void)fetchIntentionsForArea:(NSString *)theArea withCulture:(NSString*)theCulture withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    if (sessionDataTask == nil) {
        
        sessionDataTask = [dataMan downloadIntentionsWithArea:theArea withCulture:theCulture withCompletion:^(NSArray *intentionIds, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                sessionDataTask = nil;
                
                if (error == nil) {
                    intentions = [dataMan fetchIntentionsWithAreaName:theArea withIntentionsIds:nil];
                    NSLog(@"The intentions are: %@", intentions);
                }
                
                block(intentionIds, error);
                
            });
            
        }];
        
    }
    
}

-(void)reloadIntentionsWithArea:(NSString *)theArea withCulture:(NSString *)theCulture {
    intentions = [dataMan fetchIntentionsWithAreaName:theArea withIntentionsIds:nil]; //[dataMan fetchIntentionsWithArea:theArea withCulture:theCulture];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrderInArea" ascending:YES];
    intentions = [intentions sortedArrayUsingDescriptors:@[sortDescriptor]];
    intentions = [self removeDuplicateIntentions:intentions];
}

-(void)reloadIntentionImages {
    
    NSArray *imagePaths = [self mediaUrlsFromIntentions:intentions];
    NSArray *theGWImages = [dataMan fetchImagesWithImagePaths:imagePaths];
    
    NSMutableArray *images = [NSMutableArray array];

    for (NSString *imagePath in imagePaths) {
        
        for (GWImage *image in theGWImages) {
            if ([image.imageId isEqualToString:imagePath] == YES) {
                [images addObject:[UIImage imageWithData:image.imageData]];
                break ;
            }
        }
    }
    
    intentionImages = images;
    
}

-(void)downloadImagesWithCompletion:(void (^)(NSError *))completion {
    
    [completion copy];
    
    if (intentions.count != 0) {
        
        NSMutableArray *theImageUrls = [self mediaUrlsFromIntentions:intentions];
        NSArray *images = [dataMan fetchImagesWithImagePaths:theImageUrls];
        
        if (theImageUrls.count != images.count) {
            theImageUrls = [self removeCommonPathsForPersistedImages:theImageUrls withImages:images];
        }
        else {
            // we had all the images all along no need to download them
            return ;
        }
        
        __weak typeof (self) wSelf = self;
        [dataMan downloadImagesWithUrls:theImageUrls isRelativeURL:YES withCompletion:^(NSArray *theImages, NSError *theError) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [wSelf reloadIntentionsWithArea:currentArea withCulture:[UserDefaults currentCulture]];
                [wSelf reloadIntentionImages];
                completion(theError);
            });
            
        }];
        
    }
    else {
        
        __weak typeof (self) wSelf = self;
        [self fetchIntentionsForArea:currentArea withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *theIntentions, NSError *error) {
            
            [wSelf reloadIntentionsWithArea:currentArea withCulture:[UserDefaults currentCulture]];
            [wSelf downloadImagesWithCompletion:completion];
            
        }];
    }
    
}

#pragma mark - Helpers

-(NSMutableArray*)removeCommonPathsForPersistedImages:(NSArray*)theURLs withImages:(NSArray*)theImages {
    
    NSMutableArray *urlsForImagesNotPersisted = [NSMutableArray arrayWithArray:theURLs];
    
    for (NSString *imagePath in theURLs) {
        for (GWImage *image in theImages) {
            
            if ([imagePath isEqualToString:image.imageId] == YES) {
                [urlsForImagesNotPersisted removeObjectIdenticalTo:imagePath];
            }
            
        }
    }
    
    return urlsForImagesNotPersisted;
}

-(NSMutableArray*)mediaUrlsFromIntentions:(NSArray*)theIntentions {
    
    NSMutableArray *array = [NSMutableArray array];
    NSArray *allImages = [dataMan fetchImages];
    
    // only download images that exist
    for (GWIntention *theIntention in theIntentions) {
        if (theIntention.mediaUrl != nil) {
            [array addObject:[theIntention.mediaUrl removeImageBaseURLFromString]];
        }else {
            int randPos = arc4random_uniform((int)allImages.count);
            GWImage *currentImage = [allImages objectAtIndex:randPos];
            [array addObject:currentImage.imageId];
        }
    }
    
    return array;
}

-(NSArray*)removeDuplicateIntentions:(NSArray*)theIntentions {
    NSMutableArray *uniqueIntentions = [NSMutableArray array];
    
    for (GWIntention *theIntention in theIntentions) {
        
        BOOL hasFoundIntention = NO;
        for (int i = 0; i < uniqueIntentions.count; i++) {
            GWIntention *compIntention = [uniqueIntentions objectAtIndex:i];
            if ([compIntention.intentionId isEqualToString:theIntention.intentionId]) {
                hasFoundIntention = YES;
                break;
            }
        }
        
        if (hasFoundIntention == NO) {
            [uniqueIntentions addObject:theIntention];
        }
        
    }
    
    return uniqueIntentions;
    
}

@end
