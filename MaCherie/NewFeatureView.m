//
//  NewFeatureView.m
//  JePenseAToi
//
//  Created by Mathieu Skulason on 29/03/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NewFeatureView.h"
#import "UIColor+extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import <Chameleon.h>
#import "LBDLocalization.h"
#import "UserDefaults.h"

@interface NewFeatureView ()
{
    UIScrollView *featureScrollView;
    UIScrollView *bottomScrollView;
    UIPageControl *pageControl;
    UIView *bottomView;
    UIButton *doneButton;
    UIButton *nextButton;
    float contentWidth;
    int numPages;
    
    void (^_dismissBlock)(void);
}

@end

@implementation NewFeatureView

-(id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withType:kPagingType];
}

-(id)initWithFrame:(CGRect)frame withType:(NewFeatureViewType)theType
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        featureScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(frame), CGRectGetHeight(frame)*0.72 - 20)];
        [featureScrollView setContentSize:CGSizeMake(CGRectGetWidth(featureScrollView.frame), CGRectGetHeight(featureScrollView.frame))];
        featureScrollView.pagingEnabled = YES;
        featureScrollView.showsVerticalScrollIndicator = NO;
        featureScrollView.showsHorizontalScrollIndicator = NO;
        featureScrollView.delegate = self;
        contentWidth = 0;
        [self addSubview:featureScrollView];
        
        bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(featureScrollView.frame), CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetMaxY(featureScrollView.frame))];
        bottomView.backgroundColor = [UIColor appBlueColor];
        [self addSubview:bottomView];
        
        bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bottomView.frame), CGRectGetHeight(bottomView.frame))];
        bottomScrollView.pagingEnabled = YES;
        bottomScrollView.showsVerticalScrollIndicator = NO;
        bottomScrollView.showsHorizontalScrollIndicator = NO;
        bottomScrollView.delegate = self;
        [bottomView addSubview:bottomScrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(bottomView.frame)*0.8, CGRectGetWidth(bottomView.frame), CGRectGetHeight(bottomView.frame)*0.2)];
        [pageControl setNumberOfPages:0];
        [bottomView addSubview:pageControl];
        
        nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextButton.backgroundColor = [UIColor c_appFacebookBlueColor];
        nextButton.titleLabel.font = [UIFont helveticaNeueMediumWitihSize:20.0];
        nextButton.frame = CGRectMake(CGRectGetWidth(bottomView.frame) / 2.0 - 40, CGRectGetHeight(bottomView.frame) - 50, 80, 40);
        nextButton.layer.cornerRadius = 4.0;
        nextButton.layer.masksToBounds = YES;
        [nextButton setTitle:LBDLocalizedString(@"<LBDLTutorialNextScreen>", nil) forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextItem:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:nextButton];
        
        if (theType != kPagingType) {
            pageControl.alpha = 0.0;
        }
        if (theType != kNextButtonType) {
            nextButton.alpha = 0.0;
        }
        
        doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        doneButton.frame = CGRectMake(CGRectGetWidth(bottomView.frame) - 80, CGRectGetHeight(bottomView.frame)*0.74, 60, 40);
        doneButton.backgroundColor = [UIColor c_appFacebookBlueColor];
        doneButton.layer.cornerRadius = 4.0;
        doneButton.layer.masksToBounds = YES;
        doneButton.alpha = 0.0;
        [doneButton setTitle:@"Ok" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton.titleLabel setFont:[UIFont helveticaNeueMediumWitihSize:26.0]];
        [doneButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [doneButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bottomView addSubview:doneButton];
        
        contentWidth = 0;
        numPages = 0;
        
    }
    
    return self;
}

-(void)addItemWithTitle:(NSString*)theTitle andSubtitle:(NSString*)theSubtitle andImage:(NSString*)theImageNAme
{
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth, CGRectGetHeight(bottomView.frame)*0.15, CGRectGetWidth(bottomView.frame), 25)];
    titleLabel.text = theTitle;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont arialBoldWithSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bottomScrollView addSubview:titleLabel];
    
    
    if (theSubtitle != nil) {
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentWidth + CGRectGetWidth(bottomView.frame)*0.1, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(bottomView.frame)*0.8, CGRectGetHeight(bottomView.frame)*0.3)];
        subtitleLabel.text = theSubtitle;
        subtitleLabel.textColor = [UIColor whiteColor];
        subtitleLabel.font = [UIFont arialWithSize:16];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.numberOfLines = 4;
        subtitleLabel.adjustsFontSizeToFitWidth = YES;
        subtitleLabel.minimumScaleFactor = 0.92;
        [bottomScrollView addSubview:subtitleLabel];
        
        if ([UIScreen mainScreen].bounds.size.width == 414.0f || [UIScreen mainScreen].bounds.size.width == 375.0f) {
            subtitleLabel.font = [UIFont arialWithSize:21];
        }
    }
    
    if ([UIScreen mainScreen].bounds.size.width == 414.0f || [UIScreen mainScreen].bounds.size.width == 375.0f) {
        titleLabel.font = [UIFont arialBoldWithSize:24];
    }
    
    if (theImageNAme != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:theImageNAme]];
        imageView.frame = CGRectMake(contentWidth, 0, CGRectGetWidth(self.frame), CGRectGetHeight(featureScrollView.frame));
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [featureScrollView addSubview:imageView];
    }
    
    contentWidth += bottomView.frame.size.width;
    numPages++;
    [pageControl setNumberOfPages:numPages];
    bottomScrollView.contentSize = CGSizeMake(contentWidth, bottomScrollView.frame.size.height);
    featureScrollView.contentSize = CGSizeMake(contentWidth, featureScrollView.frame.size.height);
    
}

-(void)nextItem:(UIButton*)theButton {
    
    int page = round(bottomScrollView.contentOffset.x/bottomScrollView.frame.size.width);
    
    if (page < numPages - 1) {
        
        [bottomScrollView setContentOffset:CGPointMake(bottomScrollView.contentOffset.x + CGRectGetWidth(bottomScrollView.frame), bottomScrollView.contentOffset.y) animated:YES];

    }
    else {
        [self dismissView];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == bottomScrollView) {
        featureScrollView.contentOffset = CGPointMake(bottomScrollView.contentOffset.x, featureScrollView.contentOffset.y);
    }
    else if(scrollView == featureScrollView) {
        bottomScrollView.contentOffset = CGPointMake(featureScrollView.contentOffset.x, bottomScrollView.contentOffset.y);
    }
    
    int page = round(scrollView.contentOffset.x/scrollView.frame.size.width);
    
    if (page == numPages - 1 && nextButton.alpha == 1.0f) {
        
        [nextButton setTitle:@"Ok" forState:UIControlStateNormal];
        
        /*
        [UIView animateWithDuration:0.3 animations:^{
            
            nextButton.alpha = 0.0f;
            //doneButton.alpha = 1.0f;
            
        }];
         */
        
    }
    else if(page != numPages - 1) {
        
        [nextButton setTitle:LBDLocalizedString(@"<LBDLTutorialNextScreen>", nil) forState:UIControlStateNormal];
        
        /*
        [UIView animateWithDuration:0.3 animations:^{
            nextButton.alpha = 1.0f;
            //doneButton.alpha = 0.0f;
        }];
         */
    }
    
    [pageControl setCurrentPage:page];
}

-(void)dismissView
{
    if (_dismissBlock) {
        _dismissBlock();
    }
    
    [UserDefaults setTutorialShown:YES];
    [self removeFromSuperview];
}

-(void)willDismissViewWithCompletion:(void (^)(void))block {
    
    _dismissBlock = [block copy];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
