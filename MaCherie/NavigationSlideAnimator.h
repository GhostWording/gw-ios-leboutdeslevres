//
//  NavigationSlideAnimator.h
//  MaCherie
//
//  Created by Mathieu Skulason on 30/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NavigationSlideAnimator : NSObject <UIViewControllerAnimatedTransitioning>

-(id)init;
-(id)initWithTransitionDuration:(float)theDuration;

@end
