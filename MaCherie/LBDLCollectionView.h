//
//  LBDLCollectionView.h
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"
#import "Text.h"

//@class Image, Text;

@protocol LBDLCollectionViewDelegate;

@interface LBDLCollectionView : UICollectionView

@property (nonatomic, strong) id <LBDLCollectionViewDelegate> selectionDelegate;

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout andTexts:(NSArray*)theTexts andImages:(NSArray*)theImages;
-(void)resetSelection;

@end

@protocol LBDLCollectionViewDelegate <NSObject>

-(void)selectedImage:(Image*)theImage andSelectedText:(Text*)theText;

@end