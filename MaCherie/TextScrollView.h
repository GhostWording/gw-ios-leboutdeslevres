//
//  TextScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TextScrollViewDelegate <NSObject>

-(void)textFacebookShareCompatible:(BOOL)shareCompatibility;

@end

@protocol TextScrollViewDataSource;


@interface TextScrollView : UIControl

@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) id <TextScrollViewDelegate> shareDelegate;
@property (nonatomic, weak) id <TextScrollViewDataSource> textScrollViewDataSource;

-(id)initWithFrame:(CGRect)frame andTexts:(NSArray*)textArray;

-(void)setFont:(UIFont*)newTextFont;
-(NSString*)selectedText;
-(NSString*)selectedTextId;
-(NSArray*)theTexts;
-(BOOL)wantsFacebookShareForCurrentText;
-(void)reloadData;
-(void)reloadDataAnimated:(BOOL)animated;

@end


@protocol TextScrollViewDataSource <NSObject>

-(NSArray*)updateTextsScrollViewTexts;

@end
