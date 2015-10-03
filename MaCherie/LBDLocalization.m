//
//  LBDLocalization.m
//  MaCherie
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "LBDLocalization.h"
#import "GWLocalizedBundle.h"

@implementation LBDLocalization

+(NSString*)LBDLocalizedStringForKey:(NSString *)key {
    return [[GWLocalizedBundle GWBundle] localizedStringForKey:key value:@"Value not found in JPT" table:@"LBDLocalizedStrings"];
}

@end
