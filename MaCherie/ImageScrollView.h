//
//  ImageScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDataSource, ImageScrollViewDelegate;


@interface ImageScrollView : UIControl

@property (nonatomic, weak) id <ImageScrollViewDataSource> imageScrollViewDataSource;
@property (nonatomic, weak) id <ImageScrollViewDelegate> imageScrollViewDelegate;

-(id)initWithFrame:(CGRect)frame andImages:(NSArray*)imageArray;

-(UIImage*)selectedImage;
-(NSString*)selectedImageId;
-(void)reloadData;
-(void)reloadDataAnimated:(BOOL)animated;

-(void)shakeAnimateScrollViewAfterTime:(float)theTime;

@end

@protocol ImageScrollViewDelegate <NSObject>

-(void)refreshImagesPressedWithImageScrollView:(ImageScrollView*)theScrollView;

@end

@protocol ImageScrollViewDataSource <NSObject>

-(NSArray*)updateImageScrollViewImages;

@end
