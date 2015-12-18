//
//  IntentionModeViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 13/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GWIntention;

@interface IntentionModeViewModel : NSObject

@property (nonatomic, readwrite) BOOL isSpecialIntention;

-(void)downloadIntentionDataWithCompletion:(void (^)(NSError *theError))block;

-(void)randomizeData;

-(NSInteger)numRandomIntentionImages;
-(UIImage*)randomIntentionImageAtIndex:(NSInteger)theIndex;
-(NSString*)randomIntentionNameAtIndex:(NSInteger)theIndex;

-(GWIntention*)intentionAtIndex:(NSInteger)theIndex;

-(BOOL)isSpecialIntentionAtIndex:(NSInteger)theIndex;

@end
