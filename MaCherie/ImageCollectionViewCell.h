//
//  ImageCollectionViewCell.h
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 31/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

-(void)animateIntoBorder;
-(void)animateOutBorder;
-(void)resetCell;

@end
