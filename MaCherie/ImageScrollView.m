//
//  ImageScrollView.m
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ImageScrollView.h"
#import "DataManager.h"
#import "ImageScrollViewModel.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "BoxedActivityIndicatorView.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "LBDLocalization.h"
#import "MoodModeViewController.h"
#import "UserDefaults.h"

@interface ImageScrollView () <UIScrollViewDelegate> {
    BOOL isLoadingData;
    UIView *swipeViewForScroll;
    NSMutableArray *imageSubviewsArray;
    UIScrollView *imageScrollView;
    UIPageControl *pageControl;
    NSInteger numPages;
    NSInteger currentPage;
    int shakeRepeatCount;
    BoxedActivityIndicatorView *activityIndicator;
    MoodModeViewController *moodModeView;
}

@end

@implementation ImageScrollView

-(id)initWithFrame:(CGRect)frame andImages:(NSArray *)imageArray {
    
    if (self = [super initWithFrame:frame]) {
        NSLog(@"before model");
        _viewModel = [[ImageScrollViewModel alloc] initWithArray:imageArray];
        NSLog(@"after model");
        
        self.backgroundColor = [UIColor whiteColor];
        
        swipeViewForScroll = nil;
        
        imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        imageScrollView.pagingEnabled = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.showsVerticalScrollIndicator = NO;
        imageScrollView.delegate = self;
        imageScrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageScrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20)];
        pageControl.numberOfPages = imageArray.count + 1;
        pageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
        [pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl];
        
        numPages = 0;
        currentPage = 0;
        shakeRepeatCount = 0;
        isLoadingData = NO;
        
        imageSubviewsArray = [[NSMutableArray alloc] init];
        
        [self populateScrollView:_viewModel.numberOfImages];
        
        activityIndicator = [[BoxedActivityIndicatorView alloc] init];
        activityIndicator.frame = CGRectMake(CGRectGetMidX(self.frame) - 40, CGRectGetMidY(self.frame) - 40, 80, 80);
        [self addSubview:activityIndicator];
        
        // we should just allocate it once as we do not want the image scroll view to reload the themes on every reload
        // of the image data
        moodModeView = [[MoodModeViewController alloc] init];
        moodModeView.frame = CGRectZero;
        
    }
    return self;
}

#pragma mark - Page Control Tap

-(void)pageControlTapped:(UIPageControl*)thePageControl {
    [imageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * thePageControl.currentPage, 0) animated:YES];
}

#pragma mark - Animations

-(void)shakeAnimateScrollViewAfterTime:(float)theTime {
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
            if (shakeRepeatCount < 5) {
                [self performSelector:@selector(shakeAnimateScrollView) withObject:nil afterDelay:1];
            }
            else {
                NSLog(@"finished shake repeating");
                [self showScrollMessage];
            }
        });
    }];
    [imageScrollView.layer addAnimation:bounceAnimation forKey:@"shake"];
    [CATransaction commit];

    
}

-(void)showScrollMessage {
    NSLog(@"showing scrollView");
    swipeViewForScroll = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    swipeViewForScroll.backgroundColor = [UIColor clearColor];
    swipeViewForScroll.userInteractionEnabled = NO;
    swipeViewForScroll.alpha = 0.0f;
    swipeViewForScroll.hidden = NO;
    [imageScrollView addSubview:swipeViewForScroll];
    
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

#pragma mark - Loading and Updating View

-(void)populateScrollView:(NSInteger)numberOfImages {
    
    for (UIView *view in imageScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    for (int i = 0; i < numberOfImages; i++) {
        [self addImageAtIndex:i];
    }
    
    if (numberOfImages != 0) {
        [self addLastPageAtIndex:(int)numberOfImages];
    }
}

-(void)addImageAtIndex:(int)index {
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(index * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.layer.masksToBounds = YES;
    imgView.image = [_viewModel imageAtIndex:index];
    [imageScrollView addSubview:imgView];
    [imageSubviewsArray addObject:imgView];
    
    numPages++;
    
    imageScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(imageScrollView.frame));
}

-(void)addLastPageAtIndex:(int)index {
    
    /*
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    //refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame)*0.2 + CGRectGetWidth(self.frame) * index, CGRectGetHeight(self.frame) * 0.15, CGRectGetWidth(self.frame) * 0.4, CGRectGetWidth(self.frame) * 0.4);
    refresh.frame = CGRectMake(CGRectGetWidth(self.frame) * index + CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.17, CGRectGetHeight(self.frame)*0.1, CGRectGetHeight(self.frame) * 0.34, CGRectGetHeight(self.frame) * 0.34);
    [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[imageScrollView addSubview:refresh];
    
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame)*index, CGRectGetMaxY(refresh.frame), CGRectGetWidth(self.frame) * 0.8, CGRectGetHeight(self.frame) * 0.09)];
    refreshLabel.textColor = [UIColor appBlueColor];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.font = [UIFont helveticaNeueBoldWithSize:17.0];
    refreshLabel.text = LBDLocalizedString(@"<LBDLNewImages>", nil);
    //[imageScrollView addSubview:refreshLabel];
    */
    __weak typeof (self) wSelf = self;
    
    if ([[UserDefaults numberOfImageRefreshesByUser] intValue] > 1) {
        
        moodModeView.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame) * 0.26 + CGRectGetWidth(self.frame) * index,  CGRectGetHeight(self.frame) * 0.08, CGRectGetWidth(self.frame) * 0.52, 100);
        [moodModeView reloadData];
        [moodModeView themeChosenWithCompletion:^(NSString *themePath) {
            if ([wSelf.imageScrollViewDelegate respondsToSelector:@selector(refreshImageWithImageScrollView:withThemePath:)]) {
                [activityIndicator fadeInWithCompletion:^(BOOL completed) {
                    
                }];
                [wSelf.imageScrollViewDelegate refreshImageWithImageScrollView:self withThemePath:themePath];
            }
        }];
        [imageScrollView addSubview:moodModeView];
        
    }
    else {
        moodModeView.frame = CGRectMake(0, CGRectGetHeight(self.frame) * 0.2, 0, 0);
    }
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    //refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame)*0.2 + CGRectGetWidth(self.frame) * index, CGRectGetHeight(self.frame) * 0.15, CGRectGetWidth(self.frame) * 0.4, CGRectGetWidth(self.frame) * 0.4);
    refresh.frame = CGRectMake(CGRectGetWidth(self.frame) * index + CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.17, CGRectGetMaxY(moodModeView.frame) + CGRectGetHeight(self.frame) * 0.04, CGRectGetHeight(self.frame) * 0.34, CGRectGetHeight(self.frame) * 0.34);
    [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [imageScrollView addSubview:refresh];
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
        refresh.frame = CGRectMake(CGRectGetWidth(self.frame) * index + CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.17, CGRectGetMaxY(moodModeView.frame), CGRectGetHeight(self.frame) * 0.34, CGRectGetHeight(self.frame) * 0.34);
    }
    else {
        refresh.frame = CGRectMake(CGRectGetWidth(self.frame) * index + CGRectGetMidX(self.frame) - CGRectGetHeight(self.frame) * 0.17, CGRectGetMaxY(moodModeView.frame) + CGRectGetHeight(self.frame) * 0.05, CGRectGetHeight(self.frame) * 0.34, CGRectGetHeight(self.frame) * 0.34);
    }
    
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame)*index, CGRectGetMaxY(refresh.frame) + 3, CGRectGetWidth(self.frame) * 0.8, CGRectGetHeight(self.frame) * 0.09)];
    refreshLabel.textColor = [UIColor appBlueColor];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.font = [UIFont helveticaNeueBoldWithSize:17.0];
    refreshLabel.text = LBDLocalizedString(@"<LBDLNewImages>", nil);
    [imageScrollView addSubview:refreshLabel];
    
    numPages++;
    
    imageScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(imageScrollView.frame));
}

-(NSInteger)numberOfPages {
    return _viewModel.numberOfImages;
}

-(UIImage*)selectedImage {
    if (currentPage < _viewModel.numberOfImages) {
        return [_viewModel imageAtIndex:currentPage];
    }
    
    return nil;
}

-(NSString*)selectedImageId {
    if (currentPage < _viewModel.numberOfImages) {
        return [_viewModel imageNameAtIndex:currentPage];
    }
    
    return nil;
}

-(NSString*)selectedImagePath {
    if (currentPage < _viewModel.numberOfImages) {
        return [_viewModel imagePathAtIndex:currentPage];
    }
    
    return nil;
}

#pragma mark - Data Reloading

-(void)reloadData {
    
    if (_imageScrollViewDataSource) {
        [_viewModel updateModelWithArray:[_imageScrollViewDataSource updateImageScrollViewImages]];
    }
    
    for (UIView *view in imageSubviewsArray) {
        [view removeFromSuperview];
    }
    
    // need to reset the number of images
    numPages = 0;
    currentPage = 0;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = _viewModel.numberOfImages + 1;
    
    [self populateScrollView:_viewModel.numberOfImages];
    
    [activityIndicator fadeOutWithCompletion:^(BOOL completed) {
        if (completed) {
            isLoadingData = NO;
        }
    }];
}

-(void)reloadDataAnimated:(BOOL)animated {
    
    if ( animated && !isLoadingData ) {
        [activityIndicator fadeInWithCompletion:^(BOOL completed) {
            if (completed) {
                isLoadingData = YES;
                [self reloadData];

            }
        }];
    }
    else if (!isLoadingData ) {
        isLoadingData = YES;
        [self reloadData];
    }
}

-(void)fadeInLoaderWithCompletion:(void (^)(BOOL))block {
    [block copy];
    
    [activityIndicator fadeInWithCompletion:block];
}

-(void)fadeOutLoaderWithCompletion:(void (^)(BOOL))block {
    [block copy];
    
    [activityIndicator fadeOutWithCompletion:block];
}

#pragma mark - 
#pragma mark Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakeAnimateScrollView) object:nil];
    
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
    
    // to send image scroll events
    if (pos != pageControl.currentPage) {
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_INTERACTION withAction:GA_ACTION_SCROLLING withLabel:GA_LABEL_IMAGE_SWIPE wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:@"Swipe" actionLocation:@"ImageScrollView" targetType:@"Image" targetId:@"" targetParameter:@""];
        
    }
    
    /*
    if (pos != numPages - 1) {
        pageControl.currentPage = pos;
    }*/
    
    pageControl.currentPage = pos;
    currentPage = pos;
    
}

#pragma mark Image Scroll View Delegate

-(void)refreshButtonPressed {
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_INTERACTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"RefreshImages" wtihValue:nil];
    [[CustomAnalytics sharedInstance] postActionWithType:@"RefreshImages" actionLocation:@"ImageScrollView" targetType:@"Image" targetId:@"" targetParameter:@""];
    
    
    //[self reloadDataAnimated:YES];
    [_imageScrollViewDelegate refreshImagesPressedWithImageScrollView:self];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
