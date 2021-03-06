//
//  DataManager.m
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "TextObject.h"
#import "UserDefaults.h"
#import "TextFilter.h"
#import "Text.h"
#import "Image.h"
#import "NSString+TextHeight.h"

@interface DataManager () {
    NSManagedObjectContext *context;
}

@end

@implementation DataManager

-(id)init {
    if (self = [super init]) {
        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        context = delegate.managedObjectContext;
        
    }
    
    return self;
}

#pragma mark - Data Manager for Texts

-(NSArray*)allTexts {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (Text *currentText in allTexts) {
        if ([currentText.culture isEqualToString:[UserDefaults currentCulture]]) {
            [tmpArray addObject:currentText];
        }
    }
    
    return tmpArray;
}

-(BOOL)textsExistForIntention:(NSString *)theIntention {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Text"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString  stringWithFormat:@"intentionLabel LIKE[c] '%@'", theIntention]];
    [fetchRequest setPredicate:predicate];
    NSArray *textsForIntention = [self textsForIntention:theIntention];
    
    if (textsForIntention.count != 0) {
        return YES;
    }
    
    return NO;
}

-(NSArray*)textsForIntention:(NSString*)theIntention {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Text"];
    NSLog(@"the intention is: %@", theIntention);
    
    NSArray *textsForIntention = [context executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *filteredArr = [NSMutableArray array];
    
    for (int i = 0; i < textsForIntention.count; i++) {
        Text *theText = [textsForIntention objectAtIndex:i];
        
        //NSLog(@"text intention labels is: %@", theText.intentionLabel);
        if ([theText.intentionLabel isEqualToString:theIntention] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
            //NSLog(@"is equal to the intention: %@", theText.intentionLabel);
            [filteredArr addObject:theText];
        }
    }
    
    return filteredArr;
}

-(NSArray*)allTextsFilteredWithUserDefaults {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    TextFilter *textFilter = [[TextFilter alloc] init];
    
    allTexts = [textFilter filterTextsFromArray:allTexts];
    
    return allTexts;
}

-(NSArray*)allMutatedTexts {
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    NSMutableArray *mutatedTexts = [NSMutableArray array];
    
    for (int i = 0; i < allTexts.count; i++) {
        Text *text = [allTexts objectAtIndex:i];
        
        if ([text.culture isEqualToString:[UserDefaults currentCulture]]) {
            //TextObject *textObj = [[TextObject alloc] initWithWeight:1.0 andText:text];
            //[mutatedTexts addObject:textObj];
        }
    }
    
    return mutatedTexts;
}

-(NSArray*)randomTextsForGender:(NSString *)gender numTexts:(NSInteger)numTexts {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    NSMutableArray *mutableTexts = [[NSMutableArray alloc] init];
    
    for (Text *text in allTexts) {
        if ([text.culture isEqualToString:[UserDefaults currentCulture]]) {
            [mutableTexts addObject:text];
        }
    }
    
   // NSLog(@"all texts: %lu", (unsigned long)allTexts.count);
    
    if (gender == nil && allTexts != nil && mutableTexts.count != 0) {
        
        NSMutableArray *tmpRandomTexts = [NSMutableArray array];
        
        for (int i = 0; i < numTexts && i < mutableTexts.count; i++) {
            int randomPos = rand() % mutableTexts.count;
            [tmpRandomTexts addObject:[mutableTexts objectAtIndex:randomPos]];
            [mutableTexts removeObjectAtIndex:randomPos];
        }
        
        return tmpRandomTexts;
        
    }
    
    return nil;
}

-(NSInteger)numTexts {
    NSArray *textsArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (Text *text in textsArray) {
        if ([text.culture isEqualToString:[UserDefaults currentCulture]]) {
            [tmpArray addObject:text];
        }
    }
    
    return tmpArray.count;
}


#pragma mark - Data Manager for Images

-(NSArray*)allImages {
    NSArray *imageArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
    return imageArray;
}


-(NSArray*)randomImagesForNumberOfImages:(NSInteger)numImages {
    
    NSArray *imageArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] initWithArray:imageArray];
    
    NSMutableArray *tmpRandomImages = [NSMutableArray array];
    
    if (mutableImageArray.count == 0) {
        return [NSArray array];
    }
    
    for (int i = 0; i < numImages && i < mutableImageArray.count; i++) {
        int randomPos = rand() % mutableImageArray.count;
        [tmpRandomImages addObject:[mutableImageArray objectAtIndex:randomPos]];
        [mutableImageArray removeObjectAtIndex:randomPos];
    }
    
    return tmpRandomImages;
    
}

-(NSArray*)randomImagesWithSpecialImagesForTexts:(NSArray*)theTexts withNumImages:(NSInteger)numImages {
    
    NSArray *imageArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
    NSMutableArray *mutableImageArray = [[NSMutableArray alloc] initWithArray:imageArray];
    
    // get all the Image Ids of the texts that do have an Image associated with it
    // the image id is the name of the image, which is the last part of the url
    NSMutableArray *textUrls = [NSMutableArray array];
    for (Text *text in theTexts) {
        if (text.imageUrl != nil) {
            //NSLog(@"text url is not nil: %@", text.imageUrl);
            //NSArray *components = [text.imageUrl componentsSeparatedByString:@"/"];
            NSString *textImageId = [text.imageUrl lastSeperatedComponentWithSeparator:@"/"];
            [textUrls addObject:textImageId];
        }
    }
    
    // if we don't have any images return an empty array
    if (mutableImageArray.count == 0) {
        return [NSArray array];
    }
    
    // find the random images
    NSMutableArray *tmpRandomImages = [NSMutableArray array];
    for (int i = 0; i < numImages && i < mutableImageArray.count; i++) {
        int randomPos = rand() % mutableImageArray.count;
        [tmpRandomImages addObject:[mutableImageArray objectAtIndex:randomPos]];
        [mutableImageArray removeObjectAtIndex:randomPos];
    }
    
    // now we need to check if the random images do have an image associated with a text
    int imagesAssociated = 0;
    for (int i = 0; i < textUrls.count; i++) {
        NSString *imageId = [textUrls objectAtIndex:i];
        for (Image *image in tmpRandomImages) {
            NSString *lastSeparatedComponent = [image.imageId lastSeperatedComponentWithSeparator:@"/"];
            if ([imageId isEqualToString:lastSeparatedComponent]) {
                //NSLog(@"image already associated with text");
                imagesAssociated++;
                [textUrls removeObject:imageId];
            }
        }
    }
    
    // if there are less than two images associated with the text, try and find more
    // until we have two to add or simple add none. Base it on the texts that have
    // not been associated with an image
    NSMutableArray *associatedImages = [NSMutableArray array];
    for (NSString *imageId in textUrls) {
        
        if (associatedImages.count + imagesAssociated >= 2) {
            break;
        }
        
        for (Image *image in mutableImageArray) {
            NSString *lastSeparatedComponent = [image.imageId lastSeperatedComponentWithSeparator:@"/"];
            //NSLog(@"image id is: %@ and image is: %@", imageId, lastSeparatedComponent);
            if ([imageId isEqualToString:lastSeparatedComponent]) {
                
                if (associatedImages.count + imagesAssociated >= 2) {
                    break;
                }
                else {
                    //NSLog(@"found associated Image");
                    [associatedImages addObject:image];
                }
            }
        }
    }
    
    // fix for the same picture appearing twice
    NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithArray:associatedImages];
    associatedImages = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
    
    // replace the last 0 - 2 images with the new associated images
    // if any were found
    for (int i = 0; i < associatedImages.count; i++) {
        if (tmpRandomImages.count - 1 - i > 0) {
            //NSLog(@"replacing object at index: %d", (int)(tmpRandomImages.count - 1 - i));
            [tmpRandomImages replaceObjectAtIndex:tmpRandomImages.count - 1 - i withObject:[associatedImages objectAtIndex:i]];
        }
    }
    
    return tmpRandomImages;
    //return nil;
}

-(NSInteger)numImages {
    NSArray *imagesArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
    return imagesArray.count;
}

@end
