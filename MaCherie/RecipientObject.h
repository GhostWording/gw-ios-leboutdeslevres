//
//  RecipientObject.h
//  MaCherie
//
//  Created by Mathieu Skulason on 11/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNoRecipientType,
    kRecipientTypeSweetheartFemale,
    kRecipientTypeSweetheartMale,
    kRecipientTypeCloseFriends,
    kRecipientTypeMother,
    kRecipientTypeFather,
    kRecipientTypeSister,
    kRecipientTypeBrother,
    kRecipientTypeLongLostFriends,
    kRecipientTypeLoveInterestFemale,
    kRecipientTypeLoveInterestMale,
    kRecipientTypeProNetwork,
    kRecipientTypeFamilyYoungsters,
    kRecipientTypeDistantRelatives,
    kRecipientTypeOtherFriends
} kRecipientType;


@interface RecipientObject : NSObject

@property (nonatomic, strong) NSString *recipientId;
@property (nonatomic, strong) NSString *recipientName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, readwrite) kRecipientType recipientType;

-(id)initWithRecipientId:(NSString*)theRecipientId andRecipientName:(NSString*)theRecipientName andRecipientId:(kRecipientType)theRecipientType;

+(instancetype)recipientSweetheartFemale;
+(instancetype)recipientSweetheartMale;
+(instancetype)recipientCloseFriends;
+(instancetype)recipientMother;
+(instancetype)recipientFather;
+(instancetype)recipientSister;
+(instancetype)recipientBrother;
+(instancetype)recipientLongLostFriends;
+(instancetype)recipientLoveInterestFemale;
+(instancetype)recipientLoveInterestMale;
+(instancetype)recipientProNetwork;
+(instancetype)recipientFamilyYoungsters;
+(instancetype)recipientDistantRelatives;
+(instancetype)recipientOtherFriends;

@end
