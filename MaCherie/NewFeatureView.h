//
//  NewFeatureView.h
//  JePenseAToi
//
//  Created by Mathieu Skulason on 29/03/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kPagingType,
    kNextButtonType
} NewFeatureViewType;

@interface NewFeatureView : UIView <UIScrollViewDelegate>

-(id)initWithFrame:(CGRect)frame withType:(NewFeatureViewType)theType;

-(void)addItemWithTitle:(NSString*)theTitle andSubtitle:(NSString*)theSubtitle andImage:(NSString*)theImageNAme;

-(void)willDismissViewWithCompletion:(void (^)(void))block;

@end
