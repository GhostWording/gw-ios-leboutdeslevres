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

@protocol LBDLCollectionViewDelegate, LBDLCollectionViewDataSource;

@interface LBDLCollectionView : UICollectionView

@property (nonatomic, weak) id <LBDLCollectionViewDelegate> selectionDelegate;
@property (nonatomic, weak) id <LBDLCollectionViewDataSource> imageAndTextDataSource;


-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout andTexts:(NSArray*)theTexts andImages:(NSArray*)theImages;
-(Image*)selectedImage;
-(Text*)selectedText;
-(void)resetSelection;
-(void)updateData;

@end

@protocol LBDLCollectionViewDelegate <NSObject>

-(void)selectedImage:(Image*)theImage andSelectedText:(Text*)theText;

@end

@protocol LBDLCollectionViewDataSource <NSObject>

-(NSArray*)updateTextsCollectionViewDataSource;
-(NSArray*)updateImagesCollectionViewDataSource;

@end