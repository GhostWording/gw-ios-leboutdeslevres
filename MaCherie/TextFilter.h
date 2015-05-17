//
//  TextFilter.h
//  MaCherie
//
//  Created by Mathieu Skulason on 16/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextFilter : NSObject

@property (nonatomic, strong) NSString *senderGender;

// not in use we use the user defaults valus directly in the filtering text function below
-(id)initWithSenderGender:(NSString*)senderGender;

-(NSArray*)filterTextsFromArray:(NSArray*)theTexts;

@end
