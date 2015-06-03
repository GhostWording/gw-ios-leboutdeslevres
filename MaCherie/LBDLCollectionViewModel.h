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

-(void)randomizeTextsWithNumResults:(NSNumber*)numResults;
-(NSArray *)randomImagesAndTexts;

-(NSInteger)allResults;

-(NSInteger)numResults;
-(void)setNumberOfResults:(NSNumber*)numResults;

@end
