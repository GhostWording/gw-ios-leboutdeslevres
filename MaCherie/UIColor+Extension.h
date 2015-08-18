//
//  UIColor+Extension.h
//  Gloops
//
//  Created by Mathieu Skulason on 24/04/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

// UI Color Service functions
+(NSString *)hexValuesFromUIColor:(UIColor *)color;
+(UIColor *)colorWithHexString:(NSString *)hexString;

+(UIColor*)appBlueColor;
+(UIColor*)appLightGrayColor;
+(UIColor*)appLightOverlayColor;

@end
