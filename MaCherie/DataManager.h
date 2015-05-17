//
//  DataManager.h
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

-(NSArray*)allTexts;

// this gives us a filtered array of texts based on the gender in the user defaults
-(NSArray*)allTextsFilteredWithUserDefaults;

-(NSArray*)randomTextsForGender:(NSString*)gender numTexts:(NSInteger)numTexts;
-(NSArray*)randomImagesForNumberOfImages:(NSInteger)numImages;

-(NSInteger)numTexts;
-(NSInteger)numImages;

@end
