//
//  BoxedActivityIndicatorView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 28/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoxedActivityIndicatorView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *activityLabel;

-(void)fadeInWithCompletion:(void (^)(BOOL completed))block;
-(void)fadeOutWithCompletion:(void (^)(BOOL completed))block;

@end
