//
//  NSString+TextHeight.m
//  MaCherie
//
//  Created by Mathieu Skulason on 05/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NSString+TextHeight.h"

const CGFloat maxHeight = 600;

@implementation NSString (TextHeight)

-(CGFloat)heightForTextWithdWidth:(CGFloat)theWidth andFont:(UIFont *)theFont
{
    if (self) {
        
        CGSize size = CGSizeMake(theWidth, maxHeight);
        
        CGRect newRect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName: theFont } context:nil];
        
        return newRect.size.height;
    }
    
    return 0;
}

-(NSString*)lastSeperatedComponentWithSeparator:(NSString*)separator {
    
    NSArray *separatedStrings = [self componentsSeparatedByString:separator];
    
    return [separatedStrings objectAtIndex:separatedStrings.count -1];
    
}

@end
