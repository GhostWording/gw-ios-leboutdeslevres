//
//  TextCollectionViewCell.m
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TextCollectionViewCell.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"

@implementation TextCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.frame)- 20, CGRectGetHeight(self.frame) - 20)];
        _textLabel.numberOfLines = 0;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor appBlueColor];
        _textLabel.font = [UIFont noteworthyBoldWithSize:16.0];
        [self addSubview:_textLabel];
    }
    
    return self;
}

-(void)animateIntoBorder {
    
    [self.layer removeAnimationForKey:@"originalCornerRadius"];
    [self.layer removeAnimationForKey:@"borderWidthFadeOut"];
    
    self.layer.borderWidth = 4.0;
    self.layer.borderColor = [UIColor appBlueColor].CGColor;
    
    [CATransaction begin];
    CABasicAnimation *borderWidthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    borderWidthAnimation.fromValue = @0;
    borderWidthAnimation.toValue = @4;
    borderWidthAnimation.duration = 0.4;
    borderWidthAnimation.removedOnCompletion = NO;
    borderWidthAnimation.fillMode = kCAFillModeForwards;
    
    [CATransaction setCompletionBlock:^{
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        basicAnimation.fromValue = @0;
        basicAnimation.toValue = @15;
        basicAnimation.duration = 0.6;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.fillMode = kCAFillModeForwards;
        
        [self.layer addAnimation:basicAnimation forKey:@"shrinkCornerRadius"];
    }];
    
    [self.layer addAnimation:borderWidthAnimation forKey:@"borderWidthFadeIn"];
    [CATransaction commit];
}

-(void)animateOutBorder {
    NSLog(@"animating out");
    
    [self.layer removeAnimationForKey:@"shrinkCornerRadius"];
    [self.layer removeAnimationForKey:@"borderWidthFadeIn"];
    
    [CATransaction begin];
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    basicAnimation.fromValue = @15;
    basicAnimation.toValue = @0;
    basicAnimation.duration = 0.6;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    
    [CATransaction setCompletionBlock:^{
        
        CABasicAnimation *borderWidthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        borderWidthAnimation.fromValue = @4;
        borderWidthAnimation.toValue = @0;
        borderWidthAnimation.duration = 0.4;
        borderWidthAnimation.removedOnCompletion = NO;
        borderWidthAnimation.fillMode = kCAFillModeForwards;
        
        [self.layer addAnimation:borderWidthAnimation forKey:@"borderWidthFadeOut"];
    }];
    
    [self.layer addAnimation:basicAnimation forKey:@"originalCornerRadius"];
    [CATransaction commit];
}

-(void)resetCell {
    [self.layer removeAnimationForKey:@"shrinkCornerRadius"];
    [self.layer removeAnimationForKey:@"originalCornerRadius"];
    [self.layer removeAnimationForKey:@"borderWidthFadeOut"];
    [self.layer removeAnimationForKey:@"borderWidthFadeIn"];
    self.layer.borderWidth = 0.0;
    self.layer.borderColor = [UIColor clearColor].CGColor;
}

@end
