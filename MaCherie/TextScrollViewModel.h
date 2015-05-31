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

-(void)updateTextScrollViewModel:(NSArray*)theTexts;
-(NSInteger)numberOfTexts;
-(NSString*)textContentAtIndex:(NSInteger)index;
-(NSString*)textIdForTextAtIndex:(NSInteger)index;
-(BOOL)wantsFacebookShareForTextAtIndex:(int)index;
-(Text*)textObjectAtIndex:(NSInteger)index;
-(NSArray*)theTexts;

@end
