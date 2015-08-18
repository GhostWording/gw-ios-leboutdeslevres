//
//  ImageCollectionViewCell.m
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 31/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "UIColor+Extension.h"

@interface ImageCollectionViewCell () {

}

@end

@implementation ImageCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        //_imageView.layer.cornerRadius = 5.0f;
        _imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
    }
    
    return self;
}

-(void)animateIntoBorder {
    NSLog(@"animate into image");
    
    [self.imageView.layer removeAnimationForKey:@"originalCornerRadius"];
    [self.imageView.layer removeAnimationForKey:@"borderWidthFadeOut"];
    
    self.imageView.layer.borderWidth = 4.0;
    self.imageView.layer.borderColor = [UIColor appBlueColor].CGColor;
    
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
        
        [self.imageView.layer addAnimation:basicAnimation forKey:@"shrinkCornerRadius"];
    }];
    [self.imageView.layer addAnimation:borderWidthAnimation forKey:@"borderWidthFadeIn"];
    [CATransaction commit];
}

-(void)animateOutBorder {
    
    [self.imageView.layer removeAnimationForKey:@"borderWidthFadeIn"];
    [self.imageView.layer removeAnimationForKey:@"shrinkCornerRadius"];
    
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
        
        [self.imageView.layer addAnimation:borderWidthAnimation forKey:@"borderWidthFadeOut"];
    }];
    
    [self.imageView.layer addAnimation:basicAnimation forKey:@"originalCornerRadius"];
    [CATransaction commit];
}

-(void)resetCell {
    [self.imageView.layer removeAnimationForKey:@"shrinkCornerRadius"];
    [self.imageView.layer removeAnimationForKey:@"originalCornerRadius"];
    [self.imageView.layer removeAnimationForKey:@"borderWidthFadeOut"];
    [self.imageView.layer removeAnimationForKey:@"borderWidthFadeIn"];
    
    self.imageView.layer.borderWidth = 0.0;
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
}

@end
