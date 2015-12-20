//
//  MoodModeViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 19/11/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodModeViewModel : NSObject

-(void)downloadThemesWithCompletion:(void (^)(NSArray *theImages, NSError *theError))block;

-(void)reset;

-(NSInteger)numThemeImages;
-(UIImage*)imageThemeAtIndex:(NSInteger)theIndex;
-(NSString*)themeNameAtIndex:(NSInteger)theIndex;

-(NSInteger)numRandomThemeImages;
-(UIImage*)randomImageThemeAtIndex:(NSInteger)theIndex;
-(NSString*)randomThemeNameAtIndex:(NSInteger)theIndex;
-(NSString*)randomThemePathAtIndex:(NSInteger)theIndex;

//
-(BOOL)isRandomThemeAtIndex:(NSInteger)theIndex;
-(void)setIsRandomTheme:(BOOL)isRandomTheme;

@end
