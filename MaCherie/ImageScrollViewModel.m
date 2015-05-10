//
//  ImageScrollViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ImageScrollViewModel.h"
#import "Image.h"

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

-(NSInteger)numberOfImages {
    return images.count;
}

-(UIImage*)imageAtIndex:(NSInteger)index {
    
    if (index >= images.count) {
        return nil;
    }
    
    Image *img = [images objectAtIndex:index];
    return [UIImage imageWithData:img.imageData];
}

@end
