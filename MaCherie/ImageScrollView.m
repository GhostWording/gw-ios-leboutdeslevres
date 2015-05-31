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
#import "TimeOutManager.h"
#import "BoxedActivityIndicatorView.h"

@interface ImageScrollView () <UIScrollViewDelegate> {
    ImageScrollViewModel *model;
    BOOL isLoadingData;
    NSMutableArray *imageSubviewsArray;
    UIScrollView *imageScrollView;
    UIPageControl *pageControl;
    NSInteger numPages;
    NSInteger currentPage;
    BoxedActivityIndicatorView *activityIndicator;
}

@end

@implementation ImageScrollView

-(id)initWithFrame:(CGRect)frame andImages:(NSArray *)imageArray {
    
    if (self = [super initWithFrame:frame]) {
        NSLog(@"before model");
        model = [[ImageScrollViewModel alloc] initWithArray:imageArray];
        NSLog(@"after model");
        
        imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        imageScrollView.pagingEnabled = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.showsVerticalScrollIndicator = NO;
        imageScrollView.delegate = self;
        [self addSubview:imageScrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20)];
        pageControl.numberOfPages = imageArray.count;
        pageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
        [pageControl addTarget:self action:@selector(pageControlTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pageControl];
        
        numPages = 0;
        currentPage = 0;
        isLoadingData = NO;
        
        imageSubviewsArray = [[NSMutableArray alloc] init];
        
        [self populateScrollView:model.numberOfImages];
        
        activityIndicator = [[BoxedActivityIndicatorView alloc] init];
        activityIndicator.frame = CGRectMake(CGRectGetMidX(self.frame) - 40, CGRectGetMidY(self.frame) - 40, 80, 80);
        [self addSubview:activityIndicator];
        
    }
    return self;
}

#pragma mark - Page Control Tap

-(void)pageControlTapped:(UIPageControl*)thePageControl {
    [imageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame) * thePageControl.currentPage, 0) animated:YES];
}

#pragma mark - Loading and Updating View

-(void)populateScrollView:(NSInteger)numberOfImages {
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
    imgView.image = [model imageAtIndex:index];
    [imageScrollView addSubview:imgView];
    [imageSubviewsArray addObject:imgView];
    
    numPages++;
    
    imageScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(imageScrollView.frame));
}

-(void)addLastPageAtIndex:(int)index {
    
    UIButton *refresh = [UIButton buttonWithType:UIButtonTypeCustom];
    refresh.frame = CGRectMake(CGRectGetMidX(self.frame) - CGRectGetWidth(self.frame)*0.2 + CGRectGetWidth(self.frame) * index, CGRectGetHeight(self.frame) * 0.15, CGRectGetWidth(self.frame) * 0.4, CGRectGetWidth(self.frame) * 0.4);
    [refresh setBackgroundImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [imageScrollView addSubview:refresh];
    
    
    UILabel *refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1 + CGRectGetWidth(self.frame)*index, CGRectGetMaxY(refresh.frame) + 40, CGRectGetWidth(self.frame) * 0.8, 50)];
    refreshLabel.textColor = [UIColor appBlueColor];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.font = [UIFont helveticaNeueBoldWithSize:17.0];
    refreshLabel.text = @"Nouvelles images";
    [imageScrollView addSubview:refreshLabel];
    
    numPages++;
    
    imageScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(imageScrollView.frame));
}

-(UIImage*)selectedImage {
    if (currentPage < model.numberOfImages) {
        return [model imageAtIndex:currentPage];
    }
    
    return nil;
}

-(NSString*)selectedImageId {
    if (currentPage < model.numberOfImages) {
        return [model imageNameAtIndex:currentPage];
    }
    
    return nil;
}

#pragma mark - Data Reloading

-(void)reloadData {
    
    if (_imageScrollViewDataSource) {
        [model updateModelWithArray:[_imageScrollViewDataSource updateImageScrollViewImages]];
    }
    
    for (UIView *view in imageSubviewsArray) {
        [view removeFromSuperview];
    }
    
    // need to reset the number of images
    numPages = 0;
    currentPage = 0;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = model.numberOfImages;
    
    [self populateScrollView:model.numberOfImages];
    
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

#pragma mark - 
#pragma mark Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    float position = scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    int pos = roundf(position);
    
    if (pos != numPages - 1) {
        pageControl.currentPage = pos;
        currentPage = pos;
    }
}

#pragma mark Image Scroll View Delegate

-(void)refreshButtonPressed {
    
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
