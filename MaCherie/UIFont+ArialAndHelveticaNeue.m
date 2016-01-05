//
//  UIFont+ArialAndHelveticaNeue.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UIFont+ArialAndHelveticaNeue.h"

@implementation UIFont (ArialAndHelveticaNeue)

#pragma mark -
#pragma mark Print Fonts

+(void)printFonts
{
    for (NSString *fontFamilyName in [UIFont familyNames]) {
        NSLog(@"Family name: %@", fontFamilyName);
        NSArray *names = [UIFont fontNamesForFamilyName:fontFamilyName];
        NSLog(@"Font names: %@", names);
    }
}

#pragma mark -
#pragma mark Arial Font

+(instancetype)arialBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-BoldMT" size:size];
}

+(instancetype)arialWithSize:(float)size
{
    return [UIFont fontWithName:@"ArialMT" size:size];
}

+(instancetype)arialItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-ItalicMT" size:size];
}

+(instancetype)arialBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"Arial-BoldItalicMT" size:size];
}

#pragma mark -
#pragma mark Helvetica Neue

+(instancetype)helveticaNeueWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+(instancetype)helveticaNeueItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Italic " size:size];
}

+(instancetype)helveticaNeueBoldWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+(instancetype)helveticaNeueBoldItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:size];
}

+(instancetype)helveticaNeueMediumWitihSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+(instancetype)helveticaNeueMediumItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:size];
}

+(instancetype)helveticaNeueLightWithSize:(float)size
{
    return [UIFont fontWithName:@"" size:size];
}

+(instancetype)helveticaNeueLightItalicWithSize:(float)size
{
    return [UIFont fontWithName:@"" size:size];
}


#pragma mark - 
#pragma mark Noteworthy Font

+(instancetype)noteworthyLightWithSize:(float)size {
    return [UIFont fontWithName:@"Noteworthy-Light" size:size];
}

+(instancetype)noteworthyBoldWithSize:(float)size {
    return [UIFont fontWithName:@"Noteworthy-Bold" size:size];
}

@end
