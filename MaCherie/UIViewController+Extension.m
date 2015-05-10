//
//  UIViewController+Extension.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UIViewController+Extension.h"

#define maxHeight 600

@implementation UIViewController (Extension)

+(CGFloat)heightForText:(NSString *)theText andWidth:(CGFloat)theWidth andFont:(UIFont *)theFont
{
    if (theText) {
        
        CGSize size = CGSizeMake(theWidth, maxHeight);
        
        CGRect newRect = [theText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: theFont } context:nil];
        
        return newRect.size.height;
    }
    
    return 0;
}

@end
