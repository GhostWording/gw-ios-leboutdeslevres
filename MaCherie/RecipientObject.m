//
//  RecipientObject.m
//  MaCherie
//
//  Created by Mathieu Skulason on 11/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "RecipientObject.h"

@implementation RecipientObject

@synthesize recipientId;
@synthesize recipientName;
@synthesize recipientType;
@synthesize gender;

-(id)initWithRecipientId:(NSString*)theRecipientId andRecipientName:(NSString*)theRecipientName andRecipientId:(kRecipientType)theRecipientType {
    
    if (self = [super init]) {
        recipientId = theRecipientId;
        recipientName = theRecipientName;
        recipientType = theRecipientType;
        gender = @"I";
    }
    
    return self;
}

-(id)initWithRecipientId:(NSString *)theRecipientId andRecipientName:(NSString *)theRecipientName andRecipientId:(kRecipientType)theRecipientType andGender:(NSString*)theGender {
    RecipientObject *initializedClass = [[[self class] alloc] initWithRecipientId:theRecipientId andRecipientName:theRecipientName andRecipientId:theRecipientType];
    initializedClass.gender = theGender;
    
    return initializedClass;
}

+(instancetype)recipientSweetheartFemale {
    return [[[self class] alloc] initWithRecipientId:@"9E2D23" andRecipientName:@"Ma chérie" andRecipientId:kRecipientTypeSweetheartFemale andGender:@"F"];
}

+(instancetype)recipientSweetheartMale {
    return [[[self class] alloc] initWithRecipientId:@"9E2D23" andRecipientName:@"Mon chéri" andRecipientId:kRecipientTypeSweetheartMale andGender:@"H"];
}

+(instancetype)recipientCloseFriends {
    return [[[self class] alloc] initWithRecipientId:@"3B9BF2" andRecipientName:@"Mes amis" andRecipientId:kRecipientTypeCloseFriends];
}

+(instancetype)recipientMother {
    return [[[self class] alloc] initWithRecipientId:@"64C63D" andRecipientName:@"Maman" andRecipientId:kRecipientTypeMother andGender:@"F"];
}

+(instancetype)recipientFather {
    return [[[self class] alloc] initWithRecipientId:@"64C63D" andRecipientName:@"Papa" andRecipientId:kRecipientTypeFather andGender:@"H"];
}

+(instancetype)recipientSister {
    return [[[self class] alloc] initWithRecipientId:@"87F524" andRecipientName:@"Ma soeur" andRecipientId:kRecipientTypeSister andGender:@"F"];
}

+(instancetype)recipientBrother {
    return [[[self class] alloc] initWithRecipientId:@"87F524" andRecipientName:@"Mon frère" andRecipientId:kRecipientTypeBrother andGender:@"H"];
}

+(instancetype)recipientLongLostFriends {
    return [[[self class] alloc] initWithRecipientId:@"2B4F14" andRecipientName:@"Perdu(e) de vue" andRecipientId:kRecipientTypeLongLostFriends];
}

+(instancetype)recipientLoveInterestFemale {
    return [[[self class] alloc] initWithRecipientId:@"47B7E9" andRecipientName:@"La femme qui me plaît" andRecipientId:kRecipientTypeLoveInterestFemale andGender:@"F"];
}

+(instancetype)recipientLoveInterestMale {
    return [[[self class] alloc] initWithRecipientId:@"47B7E9" andRecipientName:@"L'homme qui me plaît" andRecipientId:kRecipientTypeLoveInterestMale andGender:@"H"];
}

+(instancetype)recipientProNetwork {
    return [[[self class] alloc] initWithRecipientId:@"35AE93" andRecipientName:@"Boulot" andRecipientId:kRecipientTypeProNetwork];
}

+(instancetype)recipientFamilyYoungsters {
    return [[[self class] alloc] initWithRecipientId:@"420A3E" andRecipientName:@"Enfant, neveux, filleul" andRecipientId:kRecipientTypeFamilyYoungsters];
}

+(instancetype)recipientDistantRelatives {
    return [[[self class] alloc] initWithRecipientId:@"BCA601" andRecipientName:@"Famille éloignée" andRecipientId:kRecipientTypeDistantRelatives];
}

+(instancetype)recipientOtherFriends {
    return [[[self class] alloc] initWithRecipientId:@"6E7DFB" andRecipientName:@"Amis divers" andRecipientId:kRecipientTypeOtherFriends];
}

@end
