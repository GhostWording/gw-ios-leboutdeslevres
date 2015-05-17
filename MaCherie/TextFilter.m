//
//  TextFilter.m
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextFilter.h"
#import "Text.h"
#import "UserDefaults.h"

@implementation TextFilter

@synthesize senderGender = _senderGender;

-(id)initWithSenderGender:(NSString *)senderGender {
    if (self = [super init]) {
        _senderGender = senderGender;
    }
    
    return self;
}


-(NSArray*)filterTextsFromArray:(NSArray *)theTexts {
    
    NSLog(@"array before filter is: %d", theTexts.count);
    
    NSMutableArray *filteredTextArray = [NSMutableArray array];
    
    for (int i = 0; i < theTexts.count; i++) {
        Text *theText = [theTexts objectAtIndex:i];
        
        if ([[UserDefaults userGender] intValue] == kGenderMale) {
            if ([self tuOuVousCompatible:theText.politeForm] && [self genderCompatible:theText.target andFilter:@"F"] && [self senderCompatible:theText.sender andFilter:@"F"]) {
                [filteredTextArray addObject:theText];
            }
        }
        else if([[UserDefaults userGender] intValue] == kGenderFemale) {
            if ([self tuOuVousCompatible:theText.politeForm] && [self genderCompatible:theText.target andFilter:@"H"] && [self senderCompatible:theText.sender andFilter:@"F"]) {
                [filteredTextArray addObject:theText];
            }
        }
        else {
            if ([self tuOuVousCompatible:theText.politeForm]) {
                [filteredTextArray addObject:theText];
            }
        }
        
    }
    
    NSLog(@"array after filter is: %d", filteredTextArray.count);
    
    return filteredTextArray;
}

-(BOOL)tuOuVousCompatible:(NSString*)politeForm {
    
    if (![politeForm isEqualToString:@"V"]) {
        return YES;
    }

    return NO;
}

#pragma mark - Sub Filtering Functions

-(BOOL)compatible:(NSString *)textValue andFilter:(NSString *)filterValue
{
    if ([textValue isEqualToString:filterValue] || [textValue isEqualToString:@"I"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)genderCompatible:(NSString *)textValue andFilter:(NSString *)filterValue
{
    if ([self compatible:textValue andFilter:filterValue] || (![textValue isEqualToString:@"P"] && [filterValue isEqualToString:@"N"]) || ([textValue isEqualToString:@"N"] && ![filterValue isEqualToString:@"P"]) )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)senderCompatible:(NSString *)textValue andFilter:(NSString *)filterValue
{
    return ([textValue isEqualToString:@"P"] || [self genderCompatible:textValue andFilter:filterValue] || ![textValue isEqualToString:@""] || ![filterValue isEqualToString:@""]);
}

@end
