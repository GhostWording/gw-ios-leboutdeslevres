//
//  TextObject.h
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Text.h"

// this class is used to add a weight property to the managed object class 'Text'
// this is used to compute the random text based on weighting of the sortby

@interface TextObject : NSObject

-(id)initWithWeight:(float)theWeight andText:(Text*)theText;

@property (nonatomic, readwrite) float weight;
@property (nonatomic, strong) Text *text;

@end
