//
//  DataManager.m
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"

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

-(NSArray*)randomTextsForGender:(NSString *)gender numTexts:(NSInteger)numTexts {
    
    NSArray *allTexts = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    NSMutableArray *mutableTexts = [[NSMutableArray alloc] initWithArray:allTexts];
    
    NSLog(@"all texts: %d", allTexts.count);
    
    if (gender == nil && allTexts != nil) {
        
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
    
    for (int i = 0; i < numImages; i++) {
        int randomPos = rand() % mutableImageArray.count;
        [tmpRandomImages addObject:[mutableImageArray objectAtIndex:randomPos]];
        [mutableImageArray removeObjectAtIndex:randomPos];
    }
    
    return tmpRandomImages;
    
}

@end
