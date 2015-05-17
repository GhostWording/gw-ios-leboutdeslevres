//
//  TextScrollView.m
//  MaCherie
//
//  Created by Mathieu Skulason on 09/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextScrollView.h"
#import "TextScrollViewModel.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "NSString+TextHeight.h"
#import "UIColor+Extension.h"

@interface TextScrollView () <UIScrollViewDelegate> {
    TextScrollViewModel *model;
    NSMutableArray *scrollViewContents;
    NSInteger numPages;
    NSInteger currentPage;
}

@end

@implementation TextScrollView

@synthesize textFont;
@synthesize textScrollView;
@synthesize pageControl;

-(id)initWithFrame:(CGRect)frame andTexts:(NSArray *)textArray {
    if (self = [super initWithFrame:frame]) {
        
        textFont = [UIFont noteworthyBoldWithSize:21.0];
        model = [[TextScrollViewModel alloc] initWithTextArray:textArray];
        scrollViewContents = [[NSMutableArray alloc] init];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
        pageControl.numberOfPages = textArray.count;
        pageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
        [self addSubview:pageControl];
        
        
        textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        textScrollView.pagingEnabled = YES;
        textScrollView.showsHorizontalScrollIndicator = NO;
        textScrollView.showsVerticalScrollIndicator = NO;
        textScrollView.bounces = NO;
        textScrollView.delegate = self;
        
        [self addSubview:textScrollView];
        
        numPages = 0;
        currentPage = 0;
        
        [self populateScrollView:textArray];
    }
    
    return self;
}

-(void)updateTexts:(NSArray*)theTexts {
    
    for (UIView *view in scrollViewContents) {
        [view removeFromSuperview];
    }
    
    model = [[TextScrollViewModel alloc] initWithTextArray:theTexts];
    
    currentPage = 0;
    numPages = 0;
    pageControl.numberOfPages = theTexts.count;
    
    [self populateScrollView:theTexts];
}

-(void)populateScrollView:(NSArray*)textArray {
    for (int i = 0; i < textArray.count; i++) {
        [self addTextAtIndex:i];
    }
}

-(void)addTextAtIndex:(int)index {
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(index*CGRectGetWidth(self.frame) + CGRectGetWidth(self.frame)*0.1, 20, CGRectGetWidth(self.frame)*0.8, CGRectGetHeight(self.frame) - 20)];
    textLabel.font = textFont;
    textLabel.text = [model textContentAtIndex:index];
    textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"Text is: %@", [model textContentAtIndex:index]);
    textLabel.textColor = [UIColor blackColor];
    
    NSLog(@"number of lines: %f", CGRectGetHeight(textLabel.frame) / textFont.lineHeight);
    
    textLabel.numberOfLines = CGRectGetHeight(textLabel.frame) / textFont.lineHeight;
    textLabel.minimumScaleFactor = 0.7;
    
    [textScrollView addSubview:textLabel];
    [scrollViewContents addObject:textLabel];
    
    numPages++;
    
    textScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(pageControl.frame));
}

-(void)setFont:(UIFont *)newTextFont {
    textFont = newTextFont;
    
    for (UILabel *label in scrollViewContents) {
        label.font = textFont;
    }
    
}

-(NSString*)selectedText {
    return [model textContentAtIndex:currentPage];
}

#pragma mark - 
#pragma mark Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float position = scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    
    int pos = roundf(position);
    
    pageControl.currentPage = pos;
    currentPage = pos;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
