//
//  IntentionModeView.m
//  MaCherie
//
//  Created by Mathieu Skulason on 13/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "IntentionModeView.h"
#import "IntentionModeViewModel.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "GWImage.h"
#import "GWIntention.h"

@interface IntentionModeView () <UIScrollViewDelegate> {
    IntentionModeViewModel *_viewModel;
    UIScrollView *_contentView;
    NSMutableArray *_imageViews;
    
    void (^_intentionBlock)(GWIntention *theIntention);
}

@end

@implementation IntentionModeView

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _viewModel = [[IntentionModeViewModel alloc] init];
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1, 0, CGRectGetWidth(self.frame) * 0.8, CGRectGetHeight(self.frame))];
        _contentView.delegate = self;
        _contentView.pagingEnabled = YES;
        _contentView.clipsToBounds = NO;
        [self addSubview:_contentView];
        
        _imageViews = [NSMutableArray array];
        
        
        // Setup the properties of the objects
        _textColor = [UIColor appBlueColor];
        _borderColor = [UIColor appBlueColor];
        
        if ([UIScreen mainScreen].bounds.size.height == 480.0f) {
            _font = [UIFont helveticaNeueMediumWitihSize:12.0];
        }
        else {
            _font = [UIFont helveticaNeueMediumWitihSize:16.0];
        }
        
        
        __weak typeof (self) wSelf = self;
        
        [_viewModel downloadIntentionDataWithCompletion:^(NSError *theError) {
            [wSelf reloadData];
        }];
        
        
    }
    
    return self;
}

-(void)reloadData {
    
    [_viewModel randomizeData];
    
    for (UIImageView *imageView in _imageViews) {
        [imageView removeFromSuperview];
    }
    
    float widthBetween = 30;
    
    float width = (CGRectGetWidth(self.frame) - 2*widthBetween) / 3.0;
    
    if (width > CGRectGetHeight(self.frame) * 0.7) {
        width = CGRectGetHeight(self.frame) * 0.7;
        widthBetween = (CGRectGetWidth(self.frame) - 3 * width) / 2.0;
    }
    
    if ([UIScreen mainScreen].bounds.size.height == 480.0) {
        for (int i = 0; i < 3 && i <= [_viewModel numRandomIntentionImages]; i = i + 2) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0 + i*width + i*widthBetween, 0, width, width);
            [button setImage:[_viewModel randomIntentionImageAtIndex:i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(intentionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = width / 2.0;
            button.layer.borderWidth = 2.0;
            button.layer.borderColor = _borderColor.CGColor;
            button.layer.masksToBounds = YES;
            button.tag = i;
            [self addSubview:button];
            [_imageViews addObject:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(button.frame) - width / 2.0 - widthBetween / 2.0 + 2, CGRectGetMaxY(button.frame) + 2, width + widthBetween - 4, CGRectGetHeight(self.frame) * 0.2)];
            label.font = _font;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = _textColor;
            label.minimumScaleFactor = 0.45;
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [_viewModel randomIntentionNameAtIndex:i];
            [self addSubview:label];
            [_imageViews addObject:label];
        }
    }
    else {
        for (int i = 0; i < 3 && i <= [_viewModel numRandomIntentionImages]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0 + i*width + i*widthBetween, 0, width, width);
            [button setImage:[_viewModel randomIntentionImageAtIndex:i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(intentionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = width / 2.0;
            button.layer.borderWidth = 2.0;
            button.layer.borderColor = _borderColor.CGColor;
            button.layer.masksToBounds = YES;
            button.tag = i;
            [self addSubview:button];
            [_imageViews addObject:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(button.frame) - width / 2.0 - widthBetween / 2.0 + 2, CGRectGetMaxY(button.frame), width + widthBetween - 4, CGRectGetHeight(self.frame) * 0.2)];
            label.font = _font;
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = _textColor;
            label.minimumScaleFactor = 0.65;
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [_viewModel randomIntentionNameAtIndex:i];
            [self addSubview:label];
            [_imageViews addObject:label];
        }
    }
    
}


#pragma mark - Theme Choosing and blocks

-(void)intentionButtonPressed:(UIButton*)theButton {
    if ([_viewModel isSpecialIntentionAtIndex:theButton.tag] == YES) {
        [_viewModel setIsSpecialIntention:YES];
        
        if (_intentionBlock != nil) {
            _intentionBlock([_viewModel intentionAtIndex:theButton.tag]);
        }
        
    }
    else {
        [_viewModel setIsSpecialIntention:NO];
        
        if (_intentionBlock != nil) {
            _intentionBlock([_viewModel intentionAtIndex:theButton.tag]);
        }
        
    }
}

-(void)intentionChosenWithCompletion:(void (^)(GWIntention *))block {
    
    _intentionBlock = [block copy];
    
}

-(void)themeChosenWithCompletion:(void (^)(NSString *))block {
    //_themeCompletion = [block copy];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
