//
//  TextScrollViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Text.h"

@interface TextScrollViewModel : NSObject

// initializer for Text objects in an array
-(id)initWithTextArray:(NSArray*)theTexts;

-(NSInteger)numberOfTexts;
-(NSString*)textContentAtIndex:(NSInteger)index;

@end