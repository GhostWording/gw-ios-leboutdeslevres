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
        self.layer.cornerRadius = 6.0f;
        self.layer.borderColor = [UIColor appBlueColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        [self setTitleColor:[UIColor appBlueColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
    }
    
    return self;
}


-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (self.isSelected) {
        self.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    } else {
        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    
}


@end
