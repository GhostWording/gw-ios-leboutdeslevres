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

-(BOOL)textsExistForIntention:(NSString*)theIntention;
-(NSArray*)textsForIntention:(NSString*)theIntention;

// this gives us a filtered array of texts based on the gender in the user defaults
-(NSArray*)allTextsFilteredWithUserDefaults;
-(NSArray*)randomTextsForGender:(NSString*)gender numTexts:(NSInteger)numTexts;

// Images
-(NSArray*)randomImagesForNumberOfImages:(NSInteger)numImages;
-(NSArray*)randomImagesWithSpecialImagesForTexts:(NSArray*)theTexts withNumImages:(NSInteger)numImages;
-(NSArray*)allImages;

// container of image names for a specific intention

-(NSInteger)numTexts;
-(NSInteger)numImages;

@end
