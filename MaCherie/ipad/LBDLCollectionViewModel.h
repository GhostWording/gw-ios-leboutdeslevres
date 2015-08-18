//
//  LBDLCollectionViewModel.h
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBDLCollectionViewModel : NSObject

-(id)initCollectionViewModelWithTexts:(NSArray*)texts andImages:(NSArray*)images;
-(void)setImages:(NSArray*)images;
-(void)setTexts:(NSArray*)texts;

-(void)randomizeTextsWithNumResults:(NSNumber*)numResults;
-(void)randomizeTexts;
-(NSArray *)randomImagesAndTexts;

-(NSInteger)allResults;

// to set the custom number of results we want
-(NSInteger)numResults;
-(void)setNumberOfResults:(NSNumber*)numResults;

@end
