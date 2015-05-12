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

@interface ImageScrollView () <UIScrollViewDelegate> {
    ImageScrollViewModel *model;
    NSMutableArray *imageSubviewsArray;
    UIScrollView *imageScrollView;
    UIPageControl *pageControl;
    NSInteger numPages;
    NSInteger currentPage;
}

@end

@implementation ImageScrollView

-(id)initWithFrame:(CGRect)frame andImages:(NSArray *)imageArray {
    
    if (self = [super initWithFrame:frame]) {
        model = [[ImageScrollViewModel alloc] initWithArray:imageArray];
        
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
        [self addSubview:pageControl];
        
        numPages = 0;
        currentPage = 0;
        
        imageSubviewsArray = [[NSMutableArray alloc] init];
        
        [self populateScrollView:model.numberOfImages];
        
    }
    return self;
}

-(void)updateImages:(NSArray *)images {
    
    for (UIView *view in imageSubviewsArray) {
        [view removeFromSuperview];
    }
    
    model = [[ImageScrollViewModel alloc] initWithArray:images];
    
    numPages = 0;
    currentPage = 0;
    pageControl.numberOfPages = images.count;
    
    [self populateScrollView:model.numberOfImages];
}

-(void)populateScrollView:(NSInteger)numberOfImages {
    for (int i = 0; i < numberOfImages; i++) {
        [self addImageAtIndex:i];
    }
}

-(void)addImageAtIndex:(int)index {
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(index * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = [model imageAtIndex:index];
    [imageScrollView addSubview:imgView];
    [imageSubviewsArray addObject:imgView];
    
    numPages++;
    
    imageScrollView.contentSize = CGSizeMake(numPages * CGRectGetWidth(self.frame), CGRectGetHeight(imageScrollView.frame));
}

-(UIImage*)selectedImage {
    return [model imageAtIndex:currentPage];
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
