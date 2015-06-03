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
#import "TimeOutManager.h"
#import "BoxedActivityIndicatorView.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"

@interface TextScrollView () <UIScrollViewDelegate> {
    TextScrollViewModel *model;
    BoxedActivityIndicatorView *activityIndicator;
    NSMutableArray *scrollViewContents;
    NSInteger numPages;
    NSInteger currentPage;
}

@end

@implementation TextScrollView

@synthesize textFont;
@synthesize textScrollView;
@synthesize pageControl;
@synthesize shareDelegate;

-(id)initWithFrame:(CGRect)frame andTexts:(NSArray *)textArray {
    if (self = [super initWithFrame:frame]) {
        
        textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        textScrollView.pagingEnabled = YES;
        textScrollView.showsHorizontalScrollIndicator = NO;
        textScrollView.showsVerticalScrollIndicator = NO;
        textScrollView.bounces = NO;
        textScrollView.delegate = self;
        
        [self addSubview:textScrollView];
        
        textFont = [UIFont noteworthyBoldWithSize:19.0];
        model = [[TextScrollViewModel alloc] initWithTextArray:textArray];
        scrollViewContents = [[NSMutableArray alloc] init];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
        pageControl.numberOfPages = textArray.count;
        pageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
        [pageControl addTarget:self action:@selector(pageIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl];
        
        // add it on top of all the other views
        activityIndicator = [[BoxedActivityIndicatorView alloc] init];
        activityIndicator.frame = CGRectMake(CGRectGetWidth(self.frame) / 2.0 - 40, CGRectGetHeight(self.frame) / 2.0 - 40, 80, 80);
        [self addSubview:activityIndicator];
        
        numPages = 0;
        currentPage = 0;
        
        [self populateScrollView:model.numberOfTexts];
    }
    
    return self;
}

#pragma mark - Page Indicator Touch Events

-(void)pageIndicatorPressed:(UIPageControl*)thePageControl {
    [textScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * thePageControl.currentPage, 0) animated:YES];
}

#pragma mark - Scroll View Content Update Methods

-(void)populateScrollView:(NSInteger)numTexts {
    for (int i = 0; i < numTexts; i++) {
        [self addTextAtIndex:i];
    }
    
    if (numTexts != 0) {
        [self addLastPageAtIndex:(int)numTexts];
    }
    
    [activityIndicator fadeOutWithCompletion:^(BOOL completion) {
        
    }];
}

-(void)addTextAtIndex:(int)index {
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(index*CGRectGetWidth(self.frame) + CGRectGetWidth(self.frame)*0.1, 20, CGRectGetWidth(self.frame)*0.8, CGRectGetHeight(self.frame) - 20)];
    textLabel.font = textFont;
    textLabel.text = [model textContentAtIndex:index];
    textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"Text is: %@", [model textObjectAtIndex:index]);
    textLabel.textColor = [UIColor blackColor];
    
    //NSLog(@"number of lines: %f", CGRectGetHeight(textLabel.frame) / textFont.lineHeight);
    
    textLabel.numberOfLines = CGRectGetHeight(textLabel.frame) / (textFont.lineHeight + 2);
    textLabel.minimumScaleFactor = 0.7;
    
    [textScrollView addSubview:textLabel];
    [scrollViewContents addObject:textLabel];
    
    numPages++;
    
    textScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(pageControl.frame));
}

-(void)addLastPageAtIndex:(int)index {
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame) * 0.15 + CGRectGetWidth(self.frame) * index, CGRectGetHeight(self.frame) * 0.15, CGRectGetWidth(self.frame) * 0.3, CGRectGetWidth(self.frame) * 0.3);
    [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [textScrollView addSubview:refresh];
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + 20, CGRectGetWidth(self.frame) * 0.8, 50)];
    refreshLabel.textColor = [UIColor appBlueColor];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.font = [UIFont helveticaNeueBoldWithSize:17.0];
    refreshLabel.text = @"Nouveaux textes";
    [textScrollView addSubview:refreshLabel];
    
    numPages++;
    
    textScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(textScrollView.frame));
    
}

#pragma mark - Getters and Setters

-(void)setFont:(UIFont *)newTextFont {
    textFont = newTextFont;
    
    for (UILabel *label in scrollViewContents) {
        label.font = textFont;
    }
    
}

-(BOOL)wantsFacebookShareForCurrentText {
    return [model wantsFacebookShareForTextAtIndex:(int)currentPage];
}

-(NSString*)selectedText {
    if (currentPage < model.numberOfTexts) {
        return [model textContentAtIndex:currentPage];
    }
    
    return nil;
}

-(NSString*)selectedTextId {
    
    if (currentPage < model.numberOfTexts) {
        return [model textIdForTextAtIndex:currentPage];
    }
    
    return nil;
    
}

-(NSArray*)theTexts {
    return [model theTexts];
}

#pragma mark - Reload Data

-(void)reloadData {
    if (_textScrollViewDataSource) {
        [model updateTextScrollViewModel:[_textScrollViewDataSource updateTextsScrollViewTexts]];
    }
    
    for (UIView *view in scrollViewContents) {
        [view removeFromSuperview];
    }
    
    numPages = 0;
    currentPage = 0;
    pageControl.numberOfPages = model.numberOfTexts;
    pageControl.currentPage = 0;
    
    // need to call this so that the first text gets a button to "share"
    // its content if it is share-able.
    [shareDelegate textFacebookShareCompatible:[self wantsFacebookShareForCurrentText]];
    
    [self populateScrollView:model.numberOfTexts];
}

-(void)reloadDataAnimated:(BOOL)animated {
    if (animated) {
        [activityIndicator fadeInWithCompletion:^(BOOL completion) {
            if (completion) {
                [self reloadData];
            }
        }];
    }
    else {
        [self reloadData];
    }
}

#pragma mark - 
#pragma mark Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    float position = scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    
    int pos = roundf(position);
    
    if (pos != pageControl.currentPage) {
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_INTERACTION withAction:GA_ACTION_SCROLLING withLabel:GA_LABEL_TEXT_SWIPE wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:@"Swipe" actionLocation:@"TextScrollView" targetType:@"Text" targetId:@"" targetParameter:@""];
    }
    
    if (pos != numPages - 1) {
        pageControl.currentPage = pos;
        currentPage = pos;
    }
    
    [shareDelegate textFacebookShareCompatible:[self wantsFacebookShareForCurrentText]];
    
}


#pragma makr - Text Scroll View Delegate

-(void)refreshButtonPressed {
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_INTERACTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"RefreshTexts" wtihValue:nil];
    [[CustomAnalytics sharedInstance] postActionWithType:@"RefreshTexts" actionLocation:@"TextScrollView" targetType:@"Text" targetId:@"" targetParameter:@""];
    
    [self reloadDataAnimated:YES];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
