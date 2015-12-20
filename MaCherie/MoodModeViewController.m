//
//  MoodModeViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 19/11/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "MoodModeViewController.h"
#import "MoodModeViewModel.h"
#import "UIColor+Extension.h"
#import "GWImage.h"
#import "UIFont+ArialAndHelveticaNeue.h"

@interface MoodModeViewController () <UIScrollViewDelegate> {
    MoodModeViewModel *_viewModel;
    UIScrollView *_contentView;
    
    NSMutableArray *_imageViews;
    NSMutableArray *_themeImages;
    
    void (^_themeCompletion)(NSString *theTheme);
}

@end

@implementation MoodModeViewController

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _viewModel = [[MoodModeViewModel alloc] init];
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1, 0, CGRectGetWidth(self.frame) * 0.8, CGRectGetHeight(self.frame))];
        _contentView.delegate = self;
        _contentView.pagingEnabled = YES;
        _contentView.clipsToBounds = NO;
        [self addSubview:_contentView];
        
        _imageViews = [NSMutableArray array];
        
        //self.backgroundColor = [UIColor c_darkOverlayColor];
        
        __weak typeof (self) wSelf = self;
        [_viewModel downloadThemesWithCompletion:^(NSArray *theImages, NSError *theError) {
            
            [wSelf reloadData];
            
        }];
        
        /*
        UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.15, CGRectGetHeight(self.frame) * 0.1, CGRectGetWidth(self.frame) * 0.7, 50)];
        appTitle.text = @"Mood mode";
        appTitle.textAlignment = NSTextAlignmentCenter;
        appTitle.textColor = [UIColor appBlueColor];
        appTitle.font = [UIFont noteworthyBoldWithSize:34];
        [self addSubview:appTitle];
         */
        
    }
    
    return self;
}

-(void)reloadData {
    
    [_viewModel reset];
    
    for (UIImageView *imageView in _imageViews) {
        [imageView removeFromSuperview];
    }
    
    float widthBetween = 5;
    
    float width = (CGRectGetWidth(self.frame) - 2*widthBetween) / 3.0;
    
    if (width > CGRectGetHeight(self.frame) * 0.7) {
        width = CGRectGetHeight(self.frame) * 0.7;
        widthBetween = (CGRectGetWidth(self.frame) - 3 * width) / 2.0;
    }
    
    for (int i = 0; i < 3 && i <= [_viewModel numThemeImages]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0 + i*width + i*widthBetween, 0, width, width);
        [button setImage:[_viewModel randomImageThemeAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(themeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = width / 2.0;
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = [UIColor appBlueColor].CGColor;
        button.layer.masksToBounds = YES;
        button.tag = i;
        [self addSubview:button];
        [_imageViews addObject:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame), width, CGRectGetHeight(self.frame) * 0.3)];
        label.font = [UIFont helveticaNeueMediumWitihSize:13.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor appBlueColor];
        label.minimumScaleFactor = 0.65;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = [_viewModel randomThemeNameAtIndex:i];
        [self addSubview:label];
        [_imageViews addObject:label];
    }
    
    /*
    float width = CGRectGetWidth(self.frame) / 4.0 - 40;
    
    if (width > CGRectGetHeight(self.frame) * 0.7) {
        width = CGRectGetHeight(self.frame) * 0.7;
    }
    
    if ([_viewModel numThemeImages] > 0) {
        UIButton *firstButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstButton.frame = CGRectMake(0, 0, width, width);
        [firstButton setImage:[_viewModel imageThemeAtIndex:0] forState:UIControlStateNormal];
        firstButton.layer.cornerRadius = width / 2.0;
        firstButton.layer.borderWidth = 2.0;
        firstButton.layer.borderColor = [UIColor appBlueColor].CGColor;
        firstButton.layer.masksToBounds = YES;
        [self addSubview:firstButton];
        [_imageViews addObject:firstButton];
        
        UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(firstButton.frame), CGRectGetMaxY(firstButton.frame) + 2, width, CGRectGetHeight(self.frame) * 0.3 - 2)];
        firstLabel.font = [UIFont helveticaNeueMediumWitihSize:13.0];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        firstLabel.textColor = [UIColor appBlueColor];
        firstLabel.adjustsFontSizeToFitWidth = YES;
        firstLabel.text = [_viewModel themeNameAtIndex:0];
        [self addSubview:firstLabel];
        [_imageViews addObject:firstLabel];
    }
    
    if([_viewModel numThemeImages] > 1) {
        UIButton *secondButton = [UIButton buttonWithType:UIButtonTypeCustom];
        secondButton.frame = CGRectMake(CGRectGetWidth(self.frame) / 2.0 - width / 2.0, 0, width, width);
        [secondButton setImage:[_viewModel imageThemeAtIndex:1] forState:UIControlStateNormal];
        secondButton.layer.cornerRadius = width / 2.0;
        secondButton.layer.borderWidth = 2.0;
        secondButton.layer.borderColor = [UIColor appBlueColor].CGColor;
        secondButton.layer.masksToBounds = YES;
        [self addSubview:secondButton];
        [_imageViews addObject:secondButton];
        
        UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(secondButton.frame), CGRectGetMaxY(secondButton.frame) + 2, width, CGRectGetHeight(self.frame) * 0.3 - 2)];
        secondLabel.font = [UIFont helveticaNeueMediumWitihSize:13.0];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.textColor = [UIColor appBlueColor];
        secondLabel.adjustsFontSizeToFitWidth = YES;
        secondLabel.text = [_viewModel themeNameAtIndex:1];
        [self addSubview:secondLabel];
        [_imageViews addObject:secondLabel];
    }
    
    if([_viewModel numThemeImages] > 2) {
        UIButton *thirdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdButton.frame = CGRectMake(CGRectGetWidth(self.frame) - width, 0, width, width);
        [thirdButton setImage:[_viewModel imageThemeAtIndex:2] forState:UIControlStateNormal];
        thirdButton.layer.cornerRadius = width / 2.0;
        thirdButton.layer.borderWidth = 2.0;
        thirdButton.layer.borderColor = [UIColor appBlueColor].CGColor;
        thirdButton.layer.masksToBounds = YES;
        [self addSubview:thirdButton];
        [_imageViews addObject:thirdButton];
        
        UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(thirdButton.frame), CGRectGetMaxY(thirdButton.frame) + 2, width, CGRectGetHeight(self.frame) * 0.3 - 2)];
        thirdLabel.font = [UIFont helveticaNeueMediumWitihSize:13.0];
        thirdLabel.textAlignment = NSTextAlignmentCenter;
        thirdLabel.textColor = [UIColor appBlueColor];
        thirdLabel.adjustsFontSizeToFitWidth = YES;
        thirdLabel.text = [_viewModel themeNameAtIndex:2];
        [self addSubview:thirdLabel];
        [_imageViews addObject:thirdLabel];
        
    }
     */
    
    //[self insertImages];
    
    /*
    for (int i = 0; i < _themeImages.count; i++) {
        [self insertImageAtIndex:i];
    }
     
    [_contentView setContentSize:CGSizeMake(CGRectGetWidth(_contentView.frame) * _imageViews.count, CGRectGetHeight(_contentView.frame))];
     */
}

-(void)insertImages {
    
    // if the themes are odd we have to add one row to it
    int numRows = (int) [_viewModel numThemeImages] / 2 + ([_viewModel numThemeImages] % 2);
    
    for (int i = 0; i < numRows; i++) {
        
        UIButton *themeButtonColOne = [UIButton buttonWithType:UIButtonTypeCustom];
        themeButtonColOne.frame = CGRectMake(CGRectGetWidth(self.frame) * 0.25 - 50, CGRectGetHeight(self.frame) * 0.17 + 140 * i + 50, 100, 100);
        [themeButtonColOne setImage:[_viewModel imageThemeAtIndex:i * 2] forState:UIControlStateNormal];
        themeButtonColOne.layer.cornerRadius = CGRectGetWidth(themeButtonColOne.frame) / 2.0;
        themeButtonColOne.layer.borderWidth = 2.0;
        themeButtonColOne.layer.borderColor = [UIColor appBlueColor].CGColor;
        themeButtonColOne.layer.masksToBounds = YES;
        [self addSubview:themeButtonColOne];
        
        UILabel *themeNameColOne = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(themeButtonColOne.frame), CGRectGetMaxY(themeButtonColOne.frame), CGRectGetWidth(themeButtonColOne.frame), 40)];
        themeNameColOne.text = [_viewModel themeNameAtIndex:i * 2];
        themeNameColOne.font = [UIFont helveticaNeueBoldWithSize:14.0];
        themeNameColOne.textColor = [UIColor appBlueColor];
        themeNameColOne.textAlignment = NSTextAlignmentCenter;
        [self addSubview:themeNameColOne];
        
        if (i * 2 + 1 <= [_viewModel numThemeImages]) {
            UIButton *themeButtonColTwo = [UIButton buttonWithType:UIButtonTypeCustom];
            themeButtonColTwo.frame = CGRectMake(CGRectGetWidth(self.frame) * 0.75 - 50, CGRectGetHeight(self.frame) * 0.17 + 140 * i + 50, 100, 100);
            [themeButtonColTwo setImage:[_viewModel imageThemeAtIndex:i * 2 + 1] forState:UIControlStateNormal];
            themeButtonColTwo.layer.cornerRadius = CGRectGetWidth(themeButtonColTwo.frame) / 2.0;
            themeButtonColTwo.layer.borderWidth = 2.0;
            themeButtonColTwo.layer.borderColor = [UIColor appBlueColor].CGColor;
            themeButtonColTwo.layer.masksToBounds = YES;
            [self addSubview:themeButtonColTwo];
            
            UILabel *themeNameColTwo = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(themeButtonColTwo.frame), CGRectGetMaxY(themeButtonColTwo.frame), CGRectGetWidth(themeButtonColTwo.frame), 40)];
            themeNameColTwo.text = [_viewModel themeNameAtIndex:i * 2 + 1];
            themeNameColTwo.font = [UIFont helveticaNeueBoldWithSize:14.0];
            themeNameColTwo.textColor = [UIColor appBlueColor];
            themeNameColTwo.textAlignment = NSTextAlignmentCenter;
            [self addSubview:themeNameColTwo];
        }
        
    }
    
}

-(void)insertImageAtIndex:(int)theIndex {
    
    GWImage *image = [_themeImages objectAtIndex:theIndex];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:image.imageData]];
    imageView.frame = CGRectMake(CGRectGetWidth(_contentView.frame) * theIndex + CGRectGetWidth(_contentView.frame) * 0.07, 0, CGRectGetWidth(_contentView.frame)* 0.86, CGRectGetHeight(_contentView.frame));
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = 4.0;
    [_contentView addSubview:imageView];
    
    [_imageViews addObject:imageView];
    
}


#pragma mark - Theme Choosing and blocks

-(void)themeButtonPressed:(UIButton *)theButton {
    
    if ([_viewModel isRandomThemeAtIndex:theButton.tag] == YES) {
        if (_themeCompletion != nil) {
            [_viewModel setIsRandomTheme:YES];
            _themeCompletion(@"Random");
        }
    }
    else {
        if (_themeCompletion != nil) {
            [_viewModel setIsRandomTheme:NO];
            _themeCompletion([_viewModel randomThemePathAtIndex:theButton.tag]);
        }
    }
    
}

-(void)themeChosenWithCompletion:(void (^)(NSString *))block {
    _themeCompletion = [block copy];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
