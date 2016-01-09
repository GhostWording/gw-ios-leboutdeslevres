//
//  ImageScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageScrollViewModel.h"

@protocol ImageScrollViewDataSource, ImageScrollViewDelegate;


@interface ImageScrollView : UIControl

@property (nonatomic, strong) ImageScrollViewModel *viewModel;

@property (nonatomic, weak) id <ImageScrollViewDataSource> imageScrollViewDataSource;
@property (nonatomic, weak) id <ImageScrollViewDelegate> imageScrollViewDelegate;

-(id)initWithFrame:(CGRect)frame andImages:(NSArray*)imageArray;

-(NSInteger)numberOfPages;
-(UIImage*)selectedImage;
-(NSString*)selectedImageId;
-(NSString*)selectedImagePath;
-(void)reloadData;
-(void)reloadDataAnimated:(BOOL)animated;

-(void)fadeInLoaderWithCompletion:(void (^)(BOOL finished))block;
-(void)fadeOutLoaderWithCompletion:(void (^)(BOOL finished))block;

-(void)shakeAnimateScrollViewAfterTime:(float)theTime;

@end

@protocol ImageScrollViewDelegate <NSObject>

-(void)refreshImagesPressedWithImageScrollView:(ImageScrollView*)theScrollView;

-(void)refreshImageWithImageScrollView:(ImageScrollView*)theImageScrollView withThemePath:(NSString*)theThemePath;

@end

@protocol ImageScrollViewDataSource <NSObject>

-(NSArray*)updateImageScrollViewImages;

@end
