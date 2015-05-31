//
//  RootViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RootViewModel : NSObject

-(NSArray*)randomtTextWithNum:(int)numTexts;
-(NSArray*)randomImagesWithNum:(int)numImages;
-(NSArray*)randomImagesWithImagesBasedOnTexts:(NSArray*)theTexts WithNum:(int)numImages;

@end
