//
//  SpecialOccasionViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 11/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "SpecialOccasionViewModel.h"
#import "IntentionObject.h"
#import "RecipientObject.h"
#import "ServerComm.h"
#import "DataManager.h"
#import "UserDefaults.h"
#import "Image.h"
#import "GWDataManager.h"

@interface SpecialOccasionViewModel () {
    NSArray *intentions;
    NSArray *recipients;
    GWDataManager *dataMan;
}

@end

@implementation SpecialOccasionViewModel

-(id)initWithIntentions:(NSArray*)theIntetions andRecipients:(NSArray*)theRecipients {
    if (self = [super init]) {
        intentions = theIntetions;
        recipients = theRecipients;
    }
    
    return self;
}

-(instancetype)initWithArea:(NSString*)theArea withCulture:(NSString *)theCulture {
    
    if (self = [super init]) {
        
        dataMan = [[GWDataManager alloc] init];
        intentions = [dataMan fetchIntentionsWithArea:theArea withCulture:theCulture];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrderInArea" ascending:YES];
        intentions = [intentions sortedArrayUsingDescriptors:@[sortDescriptor]];
    }
    
    return self;
}

-(GWIntention*)intentionAtIndex:(NSInteger)theIndex {
    if (theIndex < intentions.count) {
        GWIntention *intention = [intentions objectAtIndex:theIndex];
        return intention;
    }
    
    return nil;
}

-(NSInteger)numberOfIntentions {
    return intentions.count;
}



-(RecipientObject*)recipientAtIndex:(NSInteger)theIndex {
    if (theIndex < recipients.count) {
        RecipientObject *recipient = [recipients objectAtIndex:theIndex];
        return recipient;
    }
    
    return nil;
}

-(NSInteger)numberOfRecipients {
    return recipients.count;
}

-(RecipientObject*)sweetheartBasedOnUserDefaults {
    
    if ([[UserDefaults userGender] intValue] == kGenderMale) {
        return [RecipientObject recipientSweetheartFemale];
    }
    else if([[UserDefaults userGender] intValue] == kGenderFemale) {
        return [RecipientObject recipientSweetheartMale];
    }
    
    return nil;
}

-(void)fetchIntentionsForArea:(NSString *)theArea withCulture:(NSString*)theCulture withCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    [dataMan downloadIntentionsWithArea:theArea withCulture:theCulture withCompletion:^(NSArray *intentionIds, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error != nil) {
                intentions = [dataMan fetchIntentionsWithCulture:theCulture];
            }
            
            block(intentionIds, error);
            
        });
        
    }];
    
}

-(BOOL)textsExistForIntention:(NSString *)theIntention {
    DataManager *datMan = [[DataManager alloc] init];
    return [datMan textsExistForIntention:theIntention];
}

@end