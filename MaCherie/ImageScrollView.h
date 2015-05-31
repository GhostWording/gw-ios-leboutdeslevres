//
//  ImageScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDataSource;


@interface ImageScrollView : UIControl

@property (nonatomic, weak) id <ImageScrollViewDataSource> imageScrollViewDataSource;

-(id)initWithFrame:(CGRect)frame andImages:(NSArray*)imageArray;

-(UIImage*)selectedImage;
-(NSString*)selectedImageId;
-(void)reloadData;
-(void)reloadDataAnimated:(BOOL)animated;

@end


@protocol ImageScrollViewDataSource <NSObject>

-(NSArray*)updateImageScrollViewImages;

@end
