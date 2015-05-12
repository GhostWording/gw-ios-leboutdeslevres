//
//  UIImage+RenderViewToImage.m
//  MaCherie
//
//  Created by Mathieu Skulason on 05/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "UIImage+RenderViewToImage.h"

@implementation UIImage (RenderViewToImage)

+(UIImage*)imageByRenderingView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 1.0);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end