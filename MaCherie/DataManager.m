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

-(NSArray*)allTexts {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    return allTexts;
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
        TextObject *textObj = [[TextObject alloc] initWithWeight:1.0 andText:text];
        [mutatedTexts addObject:textObj];
    }
    
    return mutatedTexts;
}

-(NSArray*)randomTextsForGender:(NSString *)gender numTexts:(NSInteger)numTexts {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    NSMutableArray *mutableTexts = [[NSMutableArray alloc] initWithArray:allTexts];
    
    NSLog(@"all texts: %lu", (unsigned long)allTexts.count);
    
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

-(NSInteger)numTexts {
    NSArray *textsArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    return textsArray.count;
}

-(NSInteger)numImages {
    NSArray *imagesArray = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
    return imagesArray.count;
}

@end
