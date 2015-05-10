//
//  TextScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextScrollView : UIControl

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

-(id)initWithFrame:(CGRect)frame andTexts:(NSArray*)textArray;

-(void)setFont:(UIFont*)newTextFont;
-(NSString*)selectedText;

@end
