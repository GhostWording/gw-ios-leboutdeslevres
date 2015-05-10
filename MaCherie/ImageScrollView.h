//
//  ImageScrollView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIControl

-(id)initWithFrame:(CGRect)frame andImages:(NSArray*)imageArray;

-(UIImage*)selectedImage;

@end
