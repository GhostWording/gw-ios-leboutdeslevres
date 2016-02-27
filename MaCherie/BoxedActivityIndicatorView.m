//
//  BoxedActivityIndicatorView.m
//  MaCherie
//
//  Created by Mathieu Skulason on 28/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "BoxedActivityIndicatorView.h"

@implementation BoxedActivityIndicatorView

-(id)init {
    
    if (self = [super init]) {
        self.layer.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75].CGColor;
        self.layer.cornerRadius = 6.0f;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator startAnimating];
        _activityLabel = [[UILabel alloc] init];
        
        [self addSubview:_activityLabel];
        [self addSubview:_activityIndicator];
        
        self.hidden = YES;
        self.alpha = 0.0f;
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _activityIndicator.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _activityLabel.frame = CGRectMake(CGRectGetWidth(self.frame)*0.05, CGRectGetHeight(self.frame)*0.7, CGRectGetWidth(self.frame)*0.9, CGRectGetHeight(self.frame)*0.3);
}

-(void)fadeInWithCompletion:(void (^)(BOOL))block {
    [block copy];
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        block(YES);
    }];
}

-(void)fadeOutWithCompletion:(void (^)(BOOL))block {
    [block copy];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
        self.hidden = YES;
    } completion:^(BOOL finished) {
        block(YES);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
