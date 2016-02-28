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
#import "UIFont+MAXRobotoExtension.h"
#import "NSString+TextHeight.h"
#import "UIColor+Extension.h"
#import "BoxedActivityIndicatorView.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "LBDLocalization.h"
#import "IntentionModeView.h"
#import "GWIntention.h"
#import "UserDefaults.h"

@interface TextScrollView () <UIScrollViewDelegate> {
    BoxedActivityIndicatorView *activityIndicator;
    UIView *swipeViewForScroll;
    NSMutableArray *scrollViewContents;
    NSInteger _numPages;
    NSInteger currentPage;
    int shakeRepeatCount;
    BOOL scrollViewHasBeenInteractedWith;
    
    void (^_intentionBlock)(GWIntention *theIntention);
}

@end

@implementation TextScrollView

@synthesize textFont;
@synthesize textScrollView;
@synthesize pageControl;
@synthesize shareDelegate;

-(id)initWithFrame:(CGRect)frame andTexts:(NSArray *)textArray {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        swipeViewForScroll = nil;
        
        textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        textScrollView.pagingEnabled = YES;
        textScrollView.showsHorizontalScrollIndicator = NO;
        textScrollView.showsVerticalScrollIndicator = NO;
        textScrollView.bounces = YES;
        textScrollView.delegate = self;
        textScrollView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:textScrollView];
        
        textFont = [UIFont c_robotoLightWithSize:21.0];
        _viewModel = [[TextScrollViewModel alloc] initWithTextArray:textArray];
        scrollViewContents = [[NSMutableArray alloc] init];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 20)];
        pageControl.numberOfPages = textArray.count + 1;
        pageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
        [pageControl addTarget:self action:@selector(pageIndicatorPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl];
        
        // add it on top of all the other views
        activityIndicator = [[BoxedActivityIndicatorView alloc] init];
        activityIndicator.frame = CGRectMake(CGRectGetWidth(self.frame) / 2.0 - 40, CGRectGetHeight(self.frame) / 2.0 - 40, 80, 80);
        [self addSubview:activityIndicator];
        
        _numPages = 0;
        currentPage = 0;
        shakeRepeatCount = 0;
        scrollViewHasBeenInteractedWith = NO;
        
        [self populateScrollView:_viewModel.numberOfTexts];
        
        [self performSelector:@selector(animateNextPage) withObject:nil afterDelay:10.0];
    }
    
    return self;
}


#pragma mark - Page Indicator Touch Events

-(void)pageIndicatorPressed:(UIPageControl*)thePageControl {
    [textScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * thePageControl.currentPage, 0) animated:YES];
}

#pragma mark - Scroll View Content Update Methods

-(void)populateScrollView:(NSInteger)numTexts {
    
    for (UIView *view in textScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < numTexts; i++) {
        [self addTextAtIndex:i];
    }
    
    if (numTexts != 0) {
        [self addLastPageAtIndex:(int)numTexts];
    }
    
    if (numTexts != 0) {
        // reset the selection after we reload the view
        [shareDelegate scrolledToIndex:0];
    }
    
    [activityIndicator fadeOutWithCompletion:^(BOOL completion) {
        
    }];
}

-(void)addTextAtIndex:(int)index {
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(index*CGRectGetWidth(self.frame) + CGRectGetWidth(self.frame)*0.1, 20, CGRectGetWidth(self.frame)*0.8, CGRectGetHeight(self.frame) - 20)];
    textLabel.font = textFont;
    textLabel.text = [_viewModel textContentAtIndex:index];
    textLabel.textAlignment = NSTextAlignmentCenter;
    //NSLog(@"Text is: %@", [model textObjectAtIndex:index]);
    textLabel.textColor = [UIColor blackColor];
    
    //NSLog(@"number of lines: %f", CGRectGetHeight(textLabel.frame) / textFont.lineHeight);
    
    textLabel.numberOfLines = CGRectGetHeight(textLabel.frame) / (textFont.lineHeight + 2);
    textLabel.minimumScaleFactor = 0.7;
    
    [textScrollView addSubview:textLabel];
    [scrollViewContents addObject:textLabel];
    
    _numPages++;
    
    textScrollView.contentSize = CGSizeMake(_numPages * CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(pageControl.frame));
}

-(void)addLastPageAtIndex:(int)index {
     
    _numPages++;
    
    textScrollView.contentSize = CGSizeMake(_numPages * CGRectGetWidth(self.frame), CGRectGetHeight(textScrollView.frame));
    
    
    if ([[UserDefaults numberOfTextRefreshesByUser] intValue] > 1) {
        
        float page = CGRectGetWidth(self.frame) * index;
        
        if ([UIScreen mainScreen].bounds.size.height == 480.0) {
            
            IntentionModeView *intentionMode = [[IntentionModeView alloc] initWithFrame: CGRectMake(page + CGRectGetWidth(self.frame) / 2.0 - CGRectGetWidth(self.frame) * 0.36, 25, CGRectGetWidth(self.frame) * 0.72, 70)];
            [intentionMode intentionChosenWithCompletion:_intentionBlock];
            [textScrollView addSubview:intentionMode];
            
            UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
            refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.2 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(intentionMode.frame) - 45, CGRectGetHeight(self.frame) * 0.44, CGRectGetHeight(self.frame) * 0.44);
            [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
            [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewContents addObject:refresh];
            [textScrollView addSubview:refresh];
            
            UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + CGRectGetHeight(self.frame) * 0.01, CGRectGetWidth(self.frame) * 0.8, 24)];
            refreshLabel.textColor = [UIColor appBlueColor];
            refreshLabel.textAlignment = NSTextAlignmentCenter;
            refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
            refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
            [scrollViewContents addObject:refreshLabel];
            [textScrollView addSubview:refreshLabel];
        }
        else if([UIScreen mainScreen].bounds.size.height == 568.0) {
            
            IntentionModeView *intentionMode = [[IntentionModeView alloc] initWithFrame: CGRectMake(page + CGRectGetWidth(self.frame) / 2.0 - CGRectGetWidth(self.frame) * 0.42, 28, CGRectGetWidth(self.frame) * 0.84, 80)];
            [intentionMode intentionChosenWithCompletion:_intentionBlock];
            intentionMode.font = [UIFont helveticaNeueMediumWitihSize:14.0];
            [textScrollView addSubview:intentionMode];
            
            UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
            refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.2 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(intentionMode.frame) - 6, CGRectGetHeight(self.frame) * 0.4, CGRectGetHeight(self.frame) * 0.36);
            [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
            [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewContents addObject:refresh];
            [textScrollView addSubview:refresh];
            
            UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + CGRectGetHeight(self.frame) * 0.01, CGRectGetWidth(self.frame) * 0.8, 24)];
            refreshLabel.textColor = [UIColor appBlueColor];
            refreshLabel.textAlignment = NSTextAlignmentCenter;
            refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
            refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
            [scrollViewContents addObject:refreshLabel];
            [textScrollView addSubview:refreshLabel];
        }
        else if([UIScreen mainScreen].bounds.size.height == 667.0) {
            
            IntentionModeView *intentionMode = [[IntentionModeView alloc] initWithFrame:CGRectMake(page + CGRectGetWidth(self.frame) / 2.0 - CGRectGetWidth(self.frame) * 0.4, 25, CGRectGetWidth(self.frame) * 0.8, 95)];
            [intentionMode intentionChosenWithCompletion:_intentionBlock];
            intentionMode.font = [UIFont helveticaNeueMediumWitihSize:16.0];
            [textScrollView addSubview:intentionMode];
            
            UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
            refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.2 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(intentionMode.frame) + 5, CGRectGetHeight(self.frame) * 0.4, CGRectGetHeight(self.frame) * 0.36);
            [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
            [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewContents addObject:refresh];
            [textScrollView addSubview:refresh];
            
            UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + CGRectGetHeight(self.frame) * 0.01, CGRectGetWidth(self.frame) * 0.8, 24)];
            refreshLabel.textColor = [UIColor appBlueColor];
            refreshLabel.textAlignment = NSTextAlignmentCenter;
            refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
            refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
            [scrollViewContents addObject:refreshLabel];
            [textScrollView addSubview:refreshLabel];
            
        }
        else if([UIScreen mainScreen].bounds.size.height == 736.0) {
            
            IntentionModeView *intentionMode = [[IntentionModeView alloc] initWithFrame:CGRectMake(page + CGRectGetWidth(self.frame) / 2.0 - CGRectGetWidth(self.frame) * 0.4, 30, CGRectGetWidth(self.frame) * 0.8, 105)];
            [intentionMode intentionChosenWithCompletion:_intentionBlock];
            intentionMode.font = [UIFont helveticaNeueMediumWitihSize:16.0];
            [textScrollView addSubview:intentionMode];
            
            UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
            refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.2 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(intentionMode.frame) + 7, CGRectGetHeight(self.frame) * 0.4, CGRectGetHeight(self.frame) * 0.36);
            [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
            [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewContents addObject:refresh];
            [textScrollView addSubview:refresh];
            
            UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + CGRectGetHeight(self.frame) * 0.01, CGRectGetWidth(self.frame) * 0.8, 24)];
            refreshLabel.textColor = [UIColor appBlueColor];
            refreshLabel.textAlignment = NSTextAlignmentCenter;
            refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
            refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
            [scrollViewContents addObject:refreshLabel];
            [textScrollView addSubview:refreshLabel];
            
        }
        else {
            IntentionModeView *intentionMode = [[IntentionModeView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame) * 0.3 + CGRectGetWidth(self.frame) * index,  CGRectGetHeight(self.frame) * 0.2, CGRectGetWidth(self.frame) * 0.6, 70)];
            [intentionMode intentionChosenWithCompletion:_intentionBlock];
            [textScrollView addSubview:intentionMode];
            
            UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
            refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.2 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(intentionMode.frame), CGRectGetHeight(self.frame) * 0.4, CGRectGetHeight(self.frame) * 0.36);
            [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
            [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewContents addObject:refresh];
            [textScrollView addSubview:refresh];
            
            UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + CGRectGetHeight(self.frame) * 0.01, CGRectGetWidth(self.frame) * 0.8, 24)];
            refreshLabel.textColor = [UIColor appBlueColor];
            refreshLabel.textAlignment = NSTextAlignmentCenter;
            refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
            refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
            [scrollViewContents addObject:refreshLabel];
            [textScrollView addSubview:refreshLabel];
        }
        
        
    }
    else {
        
        UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
        refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.25 + CGRectGetWidth(self.frame) * index, CGRectGetHeight(self.frame) / 2.0 - CGRectGetHeight(self.frame) * 0.25, CGRectGetHeight(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
        [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
        [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [scrollViewContents addObject:refresh];
        [textScrollView addSubview:refresh];
        
        UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame) * index, CGRectGetMaxY(refresh.frame) + 5, CGRectGetWidth(self.frame) * 0.8, 24)];
        refreshLabel.textColor = [UIColor appBlueColor];
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        refreshLabel.font = [UIFont helveticaNeueBoldWithSize:16];
        refreshLabel.text = LBDLocalizedString(@"<LBDLNewTexts>", nil);
        [scrollViewContents addObject:refreshLabel];
        [textScrollView addSubview:refreshLabel];
        
    }
    
    
}

#pragma mark - Actions

-(void)photoOnlyViewTapped {
    [shareDelegate sendOnlyImage];
}

-(void)editTextViewTapped {
    [shareDelegate writeText];
}


#pragma mark - Animations

-(void)animateNextPage {
    if (currentPage < _numPages - 1) {
        NSLog(@"animating next page");
        currentPage++;
        //pageControl.currentPage = currentPage;
        //[textScrollView setContentOffset:CGPointMake(currentPage * CGRectGetWidth(self.frame), 0) animated:YES];
    }
}

-(void)shakeAnimateScrollViewAftertime:(float)theTime {
    [self performSelector:@selector(shakeAnimateScrollView) withObject:nil afterDelay:theTime];
}

-(void)shakeAnimateScrollView {

    shakeRepeatCount++;
    [CATransaction begin];
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    bounceAnimation.values = @[@0, @-10, @10, @10, @0];
    bounceAnimation.keyTimes = @[@0, @(1.0 / 6.0), @(3.0 / 6.0), @(5.0 / 6.0), @1];
    bounceAnimation.duration = 0.4;
    bounceAnimation.additive = YES;
    bounceAnimation.repeatCount = 2;
    [CATransaction setCompletionBlock:^{
        NSLog(@"completion block");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shakeRepeatCount < 2) {
                [self performSelector:@selector(shakeAnimateScrollView) withObject:nil afterDelay:1];
            }
            else {
                [self showScrollMessage];
            }
        });
    }];
    [textScrollView.layer addAnimation:bounceAnimation forKey:@"shake"];
    [CATransaction commit];
}

-(void)showScrollMessage {
    
    swipeViewForScroll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    swipeViewForScroll.backgroundColor = [UIColor clearColor];
    swipeViewForScroll.userInteractionEnabled = NO;
    swipeViewForScroll.alpha = 0.0f;
    swipeViewForScroll.hidden = NO;
    [textScrollView addSubview:swipeViewForScroll];
    
    UILabel *swipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(swipeViewForScroll.frame) /2.0 - 80, CGRectGetHeight(swipeViewForScroll.frame)/ 2.0 - 20, 210, 50)];
    swipeLabel.layer.cornerRadius = 15.0;
    swipeLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
    swipeLabel.layer.borderWidth = 2.0;
    swipeLabel.layer.borderColor = [UIColor appBlueColor].CGColor;
    swipeLabel.text = LBDLocalizedString(@"<LBDLMakeMeSlide>", nil);
    swipeLabel.textColor = [UIColor appBlueColor];
    swipeLabel.textAlignment = NSTextAlignmentCenter;
    swipeLabel.font = [UIFont noteworthyBoldWithSize:21.0];
    [swipeViewForScroll addSubview:swipeLabel];
    
    UIImageView *leftArrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.03, CGRectGetHeight(self.frame) / 2.0 - 24, 60, 60)];
    leftArrowImage.image = [UIImage imageNamed:@"leftArrow.png"];
    leftArrowImage.contentMode = UIViewContentModeScaleAspectFit;
    [swipeViewForScroll addSubview:leftArrowImage];
    
    [UIView animateWithDuration:0.3 animations:^{
        swipeViewForScroll.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - Getters and Setters

-(void)setFont:(UIFont *)newTextFont {
    textFont = newTextFont;
    
    for (UILabel *label in scrollViewContents) {
        label.font = textFont;
    }
    
}

-(BOOL)wantsFacebookShareForCurrentText {
    return [_viewModel wantsFacebookShareForTextAtIndex:(int)currentPage];
}

-(BOOL)isLastPage {

    if (currentPage == _numPages - 1) {
        return YES;
    }
    
    return NO;
}

-(NSInteger)numberOfPages {
    return _numPages;
}

-(NSString*)selectedText {
    if (currentPage < _viewModel.numberOfTexts) {
        return [_viewModel textContentAtIndex:currentPage];
    }
    
    return nil;
}

-(NSString*)selectedTextId {
    
    if (currentPage < _viewModel.numberOfTexts) {
        return [_viewModel textIdForTextAtIndex:currentPage];
    }
    
    return nil;
    
}

-(NSArray*)theTexts {
    return [_viewModel theTexts];
}

#pragma mark - Reload Data

-(void)reloadData {
    if (_textScrollViewDataSource) {
        [_viewModel updateTextScrollViewModel:[_textScrollViewDataSource updateTextsScrollViewTexts]];
    }
    
    for (UIView *view in scrollViewContents) {
        [view removeFromSuperview];
    }
    
    _numPages = 0;
    currentPage = 0;
    pageControl.numberOfPages = _viewModel.numberOfTexts + 1;
    pageControl.currentPage = 0;
    
    // need to call this so that the first text gets a button to "share"
    // its content if it is share-able.
    if ([shareDelegate respondsToSelector:@selector(textFacebookShareCompatible:)]) {
        [shareDelegate textFacebookShareCompatible:[self wantsFacebookShareForCurrentText]];
    }
    
    [self populateScrollView:_viewModel.numberOfTexts];
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
        
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateNextPage) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakeAnimateScrollView) object:nil];
    scrollViewHasBeenInteractedWith = YES;
    [textScrollView.layer removeAllAnimations];
    
    if (swipeViewForScroll != nil && swipeViewForScroll.alpha == 1.0f) {
        [UIView animateWithDuration:0.5 animations:^{
            swipeViewForScroll.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [swipeViewForScroll removeFromSuperview];
                swipeViewForScroll = nil;
            }
        }];
    }
    
    float position = scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    
    int pos = roundf(position);
    
    if (pos != pageControl.currentPage) {
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_INTERACTION withAction:GA_ACTION_SCROLLING withLabel:GA_LABEL_TEXT_SWIPE wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:@"Swipe" actionLocation:@"TextScrollView" targetType:@"Text" targetId:@"" targetParameter:@""];
    }
    
    pageControl.currentPage = pos;
    currentPage = pos;
    
    if ([shareDelegate respondsToSelector:@selector(textFacebookShareCompatible:)]) {
        [shareDelegate textFacebookShareCompatible:[self wantsFacebookShareForCurrentText]];
    }
    [shareDelegate scrolledToIndex:pos];
    
}


#pragma makr - Text Scroll View Delegate

-(void)refreshButtonPressed {
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_INTERACTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"RefreshTexts" wtihValue:nil];
    [[CustomAnalytics sharedInstance] postActionWithType:@"RefreshTexts" actionLocation:@"TextScrollView" targetType:@"Text" targetId:@"" targetParameter:@""];
    
    if (shareDelegate) {
        [shareDelegate refreshButtonPressed];
    }
    
    [self reloadDataAnimated:YES];
    
}

-(void)intentionChosenWithCompletion:(void (^)(GWIntention *))block {
    _intentionBlock = [block copy];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
