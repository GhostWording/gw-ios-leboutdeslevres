//
//  TextCollectionViewCell.h
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

-(void)animateIntoBorder;
-(void)animateOutBorder;
-(void)resetCell;

@end
