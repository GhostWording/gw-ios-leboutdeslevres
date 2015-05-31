//
//  NavigationSlideAnimator.m
//  MaCherie
//
//  Created by Mathieu Skulason on 30/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "NavigationSlideAnimator.h"

@interface NavigationSlideAnimator ()  {
    float transitionDuration;
}

@end

@implementation NavigationSlideAnimator

-(id)init {
    if (self = [super init]) {
        [self setupAnimator];
    }
    
    return self;
}

-(id)initWithTransitionDuration:(float)theDuration {
    if (self = [super init]) {
        [self setupAnimator];
        transitionDuration = theDuration;
    }
    
    return self;
}

-(void)setupAnimator {
    transitionDuration = 1.0;
}

#pragma mark - View Controller Delegate

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSLog(@"Slider Navigation animation transition duration");
    return transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = transitionContext.containerView;
    
    NSLog(@"Slider Navigation animation transition");
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *toView = toVC.view;
    UIView *fromView = fromVc.view;
    
    
    if (toVC.isBeingPresented) {
        
        UIView *snapshot = [toView snapshotViewAfterScreenUpdates:YES];
        [container addSubview:snapshot];
        
        snapshot.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
        CGRect finalFrame = CGRectMake(0, 0, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
        
        [UIView animateWithDuration:transitionDuration animations:^{
            snapshot.frame = finalFrame;
            NSLog(@"animating");
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                [snapshot removeFromSuperview];
                [transitionContext completeTransition:NO];
                return;
            }
            
            [snapshot removeFromSuperview];
            [container addSubview:toView];
            
            [transitionContext completeTransition:YES];
        }];
        
        
    } else {
        
        UIView *snapshot = [fromView snapshotViewAfterScreenUpdates:YES];
        [container addSubview:snapshot];
        [fromView removeFromSuperview];
        //toView.frame = CGRectMake(0, 0, CGRectGetWidth(toView.frame), CGRectGetHeight(toView.frame));
        
        CGRect finalFrame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0, CGRectGetWidth(snapshot.frame), CGRectGetHeight(snapshot.frame));
        
        [UIView animateWithDuration:transitionDuration animations:^{
            snapshot.frame = finalFrame;
            NSLog(@"Transitioning out animation");
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled]) {
                [snapshot removeFromSuperview];
                [transitionContext completeTransition:NO];
                return;
            }
            
            [snapshot removeFromSuperview];
            
            [transitionContext completeTransition:YES];
        }];
    }
    
}

@end
