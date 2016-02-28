//
//  IntentionModeViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 13/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "IntentionModeViewModel.h"
#import "GWDataManager.h"
#import "ConstantsManager.h"
#import "UserDefaults.h"
#import "GWIntention.h"
#import "GWImage.h"
#import "NSArray+Extension.h"


// used to represent the data for the image and intention name in the same object
@interface IntentionImageData : NSObject

@property (nonatomic, strong) GWIntention *intention;
@property (nonatomic, strong) GWImage *image;

@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) NSString *normalIntentionString;

@end

@implementation IntentionImageData

@end



@interface IntentionModeViewModel () {
    NSArray *_intentions;
    NSMutableArray *_images;
    
    NSArray *_imageAndIntentionData;
    
    NSMutableArray *_randomImageAndIntentionData;
}

@end

@implementation IntentionModeViewModel

-(void)downloadIntentionDataWithCompletion:(void (^)(NSError *))block {
    [block copy];
    
    GWDataManager *dataMan = [[GWDataManager alloc] init];
    
    self.isSpecialIntention = NO;
    
    NSArray *fetchedIntentions = [dataMan fetchIntentionsWithAreaName:[ConstantsManager sharedInstance].specialOccasionArea withIntentionsIds:nil];
    fetchedIntentions = [self intentionsWithMediaFromIntentionArray:fetchedIntentions];
    _intentions = fetchedIntentions;
    
    NSMutableArray *relativePaths = [NSMutableArray arrayWithArray:[self mediaUrlForIntentionArray:fetchedIntentions]];
    NSArray *imagesForPaths = [dataMan fetchImagesWithImagePaths:relativePaths];
    _images = [NSMutableArray arrayWithArray:imagesForPaths];
    
    if (relativePaths.count == imagesForPaths.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            _imageAndIntentionData = [self createImageAndIntentionDataWithImages:_images intentions:_intentions];
            [self randomizeData];
            block(nil);
            
        });
        
        return ;
    }
    
    for (GWImage *image in imagesForPaths) {
        for (int i = 0; i < relativePaths.count; i++) {
            NSString *relativePathImageId = [relativePaths objectAtIndex:i];

            if ([[self imageIdWithPrefixForPath:image.imageId] isEqualToString:relativePathImageId]) {
                [relativePaths removeObject:relativePathImageId];
                break;
            }
            
        }
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [dataMan downloadImagesWithUrls:relativePaths isRelativeURL:NO withCompletion:^(NSArray *theImageIds, NSError *theError) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                GWDataManager *fetchDataMan = [[GWDataManager alloc] init];
                NSArray *restOfImages = [fetchDataMan fetchImagesWithImagePaths:theImageIds];
                [_images addObjectsFromArray:restOfImages];
                
                _imageAndIntentionData = [self createImageAndIntentionDataWithImages:_images intentions:_intentions];
                
                [self randomizeData];
                block(theError);
                
                
            });
        }];
    });
    
}

-(void)randomizeData {
    _randomImageAndIntentionData = [NSMutableArray arrayWithArray:[NSArray randomIndexesFromArray:_imageAndIntentionData withNumRandomIndexes:4]];
    
    if (_isSpecialIntention == YES) {
        IntentionImageData *intImgDat = [[IntentionImageData alloc] init];
        intImgDat.normalImage = [UIImage imageNamed:@"randomImage.png"];
        intImgDat.normalIntentionString = @"Normal";
        [_randomImageAndIntentionData insertObject:intImgDat atIndex:0];
        
    }
}

#pragma mark - Getters and Setters 

-(NSInteger)numRandomIntentionImages {
    return _randomImageAndIntentionData.count;
}

-(UIImage*)randomIntentionImageAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _randomImageAndIntentionData.count) {
        return nil;
    }
    
    IntentionImageData *intImgData = [_randomImageAndIntentionData objectAtIndex:theIndex];
    
    if (intImgData.image != nil) {
        return [UIImage imageWithData:intImgData.image.imageData];
    }
    
    return intImgData.normalImage;
}

-(NSString*)randomIntentionNameAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _randomImageAndIntentionData.count) {
        return nil;
    }
    
    IntentionImageData *intImgData = [_randomImageAndIntentionData objectAtIndex:theIndex];
    
    if (intImgData.intention != nil) {
        return intImgData.intention.label;
    }
    
    return intImgData.normalIntentionString;
}

#pragma mark - Composed Data Creation

-(NSArray*)createImageAndIntentionDataWithImages:(NSArray*)theImages intentions:(NSArray*)theIntentions {
    
    NSMutableArray *array = [NSMutableArray array];
    for (GWIntention *currentIntention in theIntentions) {
        GWImage *image = [self findImageForIntention:currentIntention inImages:theImages];
        if (image != nil) {
            IntentionImageData *intImgData = [[IntentionImageData alloc] init];
            intImgData.image = image;
            intImgData.intention = currentIntention;
            [array addObject:intImgData];
        }
    }
    return array;
}

-(GWImage*)findImageForIntention:(GWIntention*)theIntention inImages:(NSArray*)theImages {
    
    for (GWImage *image in theImages) {
        
        if ([[self imageIdWithPrefixForPath:image.imageId] isEqualToString:theIntention.mediaUrl]) {
            return image;
        }
        
    }
    
    return nil;
}

#pragma mark - String Id helpers

-(NSString*)imageIdWithPrefixForPath:(NSString*)thePath {
    return [NSString stringWithFormat:@"%@%@", @"http://gw-static.azurewebsites.net", thePath];
}

#pragma mark - Intention Class Helpers

-(NSArray*)intentionsWithMediaFromIntentionArray:(NSArray*)theIntentionArray {
    
    NSMutableArray *intentionsWithMedia = [NSMutableArray array];
    for (GWIntention *currentIntention in theIntentionArray) {
        if (currentIntention.mediaUrl.length != 0 && currentIntention.mediaUrl != nil) {
            [intentionsWithMedia addObject:currentIntention];
        }
    }
    return intentionsWithMedia;
}

-(NSArray*)mediaUrlForIntentionArray:(NSArray*)theIntentionArray {
    
    NSMutableArray *mediaUrlArray = [NSMutableArray array];
    for (GWIntention *imageId in theIntentionArray) {
        [mediaUrlArray addObject:imageId.mediaUrl];
    }
    
    return mediaUrlArray;
    
}

-(GWIntention*)intentionAtIndex:(NSInteger)theIndex {
    if (theIndex >= _randomImageAndIntentionData.count) {
        return nil;
    }
    
    IntentionImageData *intImgDat = [_randomImageAndIntentionData objectAtIndex:theIndex];
    
    if (intImgDat.intention == nil) {
        return nil;
    }
    
    return intImgDat.intention;
}

-(BOOL)isSpecialIntentionAtIndex:(NSInteger)theIndex {
    if (theIndex >= _randomImageAndIntentionData.count) {
        return NO;
    }
    
    IntentionImageData *intentionImage = [_randomImageAndIntentionData objectAtIndex:theIndex];
    
    if (intentionImage.normalImage != nil) {
        return YES;
    }
    
    return NO;
}

@end
