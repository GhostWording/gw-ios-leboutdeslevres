//
//  TextFilter.m
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextFilter.h"
#import "Text.h"
#import "GWText.h"
#import "UserDefaults.h"
#import "TagId.h"
#import "GWTag.h"

@implementation TextFilter

@synthesize senderGender = _senderGender;
@synthesize recipientTypeTag = _recipientTypeTag;
@synthesize politeForm = _politeForm;

-(id)initWithSenderGender:(NSString *)senderGender andPoliteForm:(NSString *)thePoliteform andRecipientTypeTag:(NSString *)theRecipientTypeTag{
    if (self = [super init]) {
        _senderGender = senderGender;
        _politeForm = thePoliteform;
        _recipientTypeTag = theRecipientTypeTag;
    }
    
    return self;
}

-(NSArray*)filterTextsFromFitlerPresets:(NSArray *)theTexts {
    
    NSMutableArray *filteredTextArray = [NSMutableArray array];
    
    for (int i = 0; i < theTexts.count; i++) {
        Text *theText = [theTexts objectAtIndex:i];
        
        if ([self tuOuVousCompatible:theText.politeForm andFilter:_politeForm] && [self senderCompatible:theText.sender andFilter:_senderGender] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:_recipientTypeTag] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
            NSLog(@"found object that matches");
            [filteredTextArray addObject:theText];
        }
        else {
            NSLog(@"does not match");
        }
        
    }
    
    return filteredTextArray;
}

-(NSArray*)filterTextsFromArray:(NSArray *)theTexts andPoliteForm:(NSString *)thePoliteForm andRecipientTypeTag:(NSString *)theRecipientTypeTag andSenderGender:(NSString *)theSenderGender {
    
    NSMutableArray *filteredTextArray = [NSMutableArray array];
    
    for (int i = 0; i < theTexts.count; i++) {
        Text *theText = [theTexts objectAtIndex:i];
        
        if ([self tuOuVousCompatible:theText.politeForm andFilter:thePoliteForm] && [self senderCompatible:theText.target andFilter:theSenderGender] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:theRecipientTypeTag] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
            NSLog(@"found object that matches");
            [filteredTextArray addObject:theText];
        }
        else {
            NSLog(@"does not match");
        }
        
    }
    
    return filteredTextArray;
}

-(NSArray*)filterTextsFromArray:(NSArray *)theTexts andPoliteForm:(NSString *)thePoliteForm andRecipientTypeTag:(NSString *)theRecipientTypeTag andSenderGender:(NSString *)theSenderGender andUserGender:(NSString *)theUserGender {
    NSMutableArray *filteredTextArray = [NSMutableArray array];
    
    for (int i = 0; i < theTexts.count; i++) {
        Text *theText = [theTexts objectAtIndex:i];
        
        if (theUserGender) {
            if ([self tuOuVousCompatible:theText.politeForm andFilter:thePoliteForm] && [self senderCompatible:theText.target andFilter:theSenderGender] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:theRecipientTypeTag] && [self genderCompatible:theText.sender andFilter:theUserGender] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
                [filteredTextArray addObject:theText];
            }
        }
        else {
            if ([self tuOuVousCompatible:theText.politeForm andFilter:thePoliteForm] && [self senderCompatible:theText.target andFilter:theSenderGender] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:theRecipientTypeTag] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
                [filteredTextArray addObject:theText];
            }
        }
    }
    
    return filteredTextArray;
}

-(NSArray*)filterTextsFromArray:(NSArray *)theTexts {
    
    NSLog(@"array before filter is: %lu", (unsigned long)theTexts.count);
    
    NSMutableArray *filteredTextArray = [NSMutableArray array];
    
    for (int i = 0; i < theTexts.count; i++) {
        GWText *theText = [theTexts objectAtIndex:i];
        
        if ([[UserDefaults userGender] intValue] == kGenderMale) {
            if ([self tuOuVousCompatible:theText.politeForm] && [self genderCompatible:theText.target andFilter:@"F"] && [self senderCompatible:theText.sender andFilter:@"H"] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:@"9E2D23"] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
                [filteredTextArray addObject:theText];
            }
        }
        else if([[UserDefaults userGender] intValue] == kGenderFemale) {
            if ([self tuOuVousCompatible:theText.politeForm] && [self genderCompatible:theText.target andFilter:@"H"] && [self senderCompatible:theText.sender andFilter:@"F"] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:@"9E2D23"] && [UserDefaults currentCulture]) {
                [filteredTextArray addObject:theText];
            }
        }
        else {
            if ([self tuOuVousCompatible:theText.politeForm] && [self matchesRecipientTypeTag:[theText.tagIds array] andFilter:@"9E2D23"] && [theText.culture isEqualToString:[UserDefaults currentCulture]]) {
                [filteredTextArray addObject:theText];
            }
        }
        
    }
    
    NSLog(@"array after filter is: %lu", (unsigned long)filteredTextArray.count);
    
    return filteredTextArray;
}

-(BOOL)tuOuVousCompatible:(NSString *)textValue andFilter:(NSString *)filterValue {
    
    return ([self compatible:textValue andFilter:filterValue] || ([textValue isEqualToString:@"P"] && [filterValue isEqualToString:@"V"]));
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
    
    if (([textValue isEqualToString:@"P"] || [self genderCompatible:textValue andFilter:filterValue])) {
        return YES;
    }
    
    return NO;
    
    //return ([textValue isEqualToString:@"P"] || [self genderCompatible:textValue andFilter:filterValue] || ![textValue isEqualToString:@""] || ![filterValue isEqualToString:@""]);
}

-(BOOL)matchesRecipientTypeTag:(NSArray *)tagIds andFilter:(NSString *)filterValue {
    
    for (GWTag *tag in tagIds) {
        if ([tag.tagId isEqualToString:filterValue]) {
            return YES;
        }
    }
    
    
    return NO;
}

@end
