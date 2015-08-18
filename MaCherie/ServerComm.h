//
//  ServerComm.h
//  MaCherie
//
//  Created by Mathieu Skulason on 07/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^ErrorCompletionBlock)(BOOL finished, NSError *error);

@interface ServerComm : NSObject

-(void)downloadTexts;
-(void)downloadTextsWithCompletion:(void (^)(BOOL finished, NSError *error))block;

-(void)downloadTextsForIntention:(NSString*)intentionSlug withCompletion:(ErrorCompletionBlock)block;

-(void)downloadNumImages:(int)numImages withCompletion:(void (^)(BOOL finished, NSError *error))block;
-(void)downloadImageIdsForIntention:(NSString*)theIntention withComplection:(void (^)(BOOL finished, NSArray *imageIds, NSError *error))block;
-(void)downloadImagesNotAvailableWithPaths:(NSMutableArray*)imagePaths withNumImages:(int)numImages withCompletion:(void (^)(BOOL finished, NSError *error))block;

@end
