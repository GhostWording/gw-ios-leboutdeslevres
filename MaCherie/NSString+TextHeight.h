//
//  NSString+TextHeight.h
//  MaCherie
//
//  Created by Mathieu Skulason on 05/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TextHeight)

-(CGFloat)heightForTextWithdWidth:(CGFloat)theWidth andFont:(UIFont*)theFont;
-(NSString*)lastSeperatedComponentWithSeparator:(NSString*)separator;

@end
