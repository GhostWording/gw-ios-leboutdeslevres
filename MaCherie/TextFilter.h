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
@property (nonatomic, strong) NSString *politeForm;
@property (nonatomic, strong) NSString *recipientTypeTag;

// not in use we use the user defaults valus directly in the filtering text function below
-(id)initWithSenderGender:(NSString*)senderGender andPoliteForm:(NSString*)thePoliteform andRecipientTypeTag:(NSString*)theRecipientTypeTag;

-(NSArray*)filterTextsFromArray:(NSArray*)theTexts;
-(NSArray*)filterTextsFromFitlerPresets:(NSArray*)theTexts;
-(NSArray*)filterTextsFromArray:(NSArray *)theTexts andPoliteForm:(NSString*)thePoliteForm andRecipientTypeTag:(NSString*)theRecipientTypeTag andSenderGender:(NSString*)theSenderGender;
-(NSArray*)filterTextsFromArray:(NSArray *)theTexts andPoliteForm:(NSString*)thePoliteForm andRecipientTypeTag:(NSString*)theRecipientTypeTag andSenderGender:(NSString*)theSenderGender andUserGender:(NSString*)theUserGender;

@end
