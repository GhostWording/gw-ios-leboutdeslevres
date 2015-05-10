//
//  ImageScrollViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageScrollViewModel : NSObject

// takes in an array of Image objects
-(id)initWithArray:(NSArray*)array;

-(NSInteger)numberOfImages;
-(UIImage*)imageAtIndex:(NSInteger)index;

@end
