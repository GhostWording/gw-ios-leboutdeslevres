//
//  IntentionModeView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 13/12/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWIntention;

@interface IntentionModeView : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *borderColor;

-(void)intentionChosenWithCompletion:(void (^)(GWIntention *theImages))block;

@end
