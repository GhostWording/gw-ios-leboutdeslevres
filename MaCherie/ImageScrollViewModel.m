//
//  ImageScrollViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ImageScrollViewModel.h"
#import "Image.h"
#import "GWImage.h"

@interface ImageScrollViewModel () {
    NSMutableArray *images;
}

@end

@implementation ImageScrollViewModel

-(id)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        images = [[NSMutableArray alloc] initWithArray:array];
    }
    
    return self;
}

-(void)updateModelWithArray:(NSArray *)array {
    images = [[NSMutableArray alloc] initWithArray:array];
}

-(NSInteger)numberOfImages {
    NSLog(@"image count is: %lu", (unsigned long)images.count);
    return images.count;
}

-(UIImage*)imageAtIndex:(NSInteger)index {
    
    if (index >= images.count) {
        return nil;
    }
    
    GWImage *img = [images objectAtIndex:index];
    return [UIImage imageWithData:img.imageData];
}

-(NSString*)imageNameAtIndex:(NSInteger)index {
    
    GWImage *img = [images objectAtIndex:index];
    
    NSArray *separatedString = [img.imageId componentsSeparatedByString:@"/"];
    
    NSString *imageName = [separatedString objectAtIndex:separatedString.count - 1];
    NSLog(@"the image name: %@", imageName);
    
    return imageName;
    
}

@end
