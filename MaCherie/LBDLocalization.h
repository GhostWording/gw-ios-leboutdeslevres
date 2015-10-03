//
//  LBDLocalization.h
//  MaCherie
//
//  Created by Mathieu Skulason on 15/09/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LBDLocalizedString(key, comment) [LBDLocalization LBDLocalizedStringForKey:(key)]

@interface LBDLocalization : NSObject

+(NSString*)LBDLocalizedStringForKey:(NSString *)key;

@end
