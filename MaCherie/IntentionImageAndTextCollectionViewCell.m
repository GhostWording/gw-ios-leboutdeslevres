//
//  IntentionImageAndTextCollectionViewCell.m
//  LeRoiDuStatutFacebook
//
//  Created by Mathieu Skulason on 04/02/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import "IntentionImageAndTextCollectionViewCell.h"

@implementation IntentionImageAndTextCollectionViewCell

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_imageView.frame), CGRectGetWidth(self.frame) - 20, 20)];
        [self addSubview:_titleLabel];
    }
    
    return self;
}

@end
