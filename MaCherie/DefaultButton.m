//
//  DefaultButton.m
//  MaCherie
//
//  Created by Mathieu Skulason on 04/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "DefaultButton.h"
#import "UIColor+Extension.h"


@implementation DefaultButton


-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 16.0f;
        self.layer.borderColor = [UIColor appBlueColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        [self setTitleColor:[UIColor appBlueColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        
        
        _buttonSelectedBackgroundColor = [UIColor appBlueColor];
        _buttonBackgroundColor = [UIColor whiteColor];
        
        _buttonBorderColor = [UIColor clearColor];
        _buttonBorderSelectedColor = [UIColor clearColor];
        
    }
    
    return self;
}


-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (self.isSelected) {
        self.layer.backgroundColor = _buttonSelectedBackgroundColor.CGColor;
        self.layer.borderColor = _buttonBorderSelectedColor.CGColor;
    } else {
        self.layer.backgroundColor = _buttonBackgroundColor.CGColor;
        self.layer.borderColor = _buttonBorderColor.CGColor;
    }
    
}

-(void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
    
    if (self.selected == NO) {
        self.layer.backgroundColor = _buttonBackgroundColor.CGColor;
    }
}

-(void)setButtonSelectedBackgroundColor:(UIColor *)buttonSelectedBackgroundColor {
    _buttonSelectedBackgroundColor = buttonSelectedBackgroundColor;
    
    if (self.selected == YES) {
        self.layer.backgroundColor = _buttonSelectedBackgroundColor.CGColor;
    }
    
}


@end
