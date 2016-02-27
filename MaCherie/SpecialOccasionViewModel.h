//
//  SpecialOccasionViewModel.h
//  MaCherie
//
//  Created by Mathieu Skulason on 11/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IntentionObject, RecipientObject, GWIntention;

@interface SpecialOccasionViewModel : NSObject

/* **/
-(id)initWithIntentions:(NSArray*)theIntetions andRecipients:(NSArray*)theRecipients;

/* **/
-(instancetype)initWithArea:(NSString*)theArea withCulture:(NSString *)theCulture;

-(GWIntention*)intentionAtIndex:(NSInteger)theIndex;
-(NSInteger)numberOfIntentions;
-(NSInteger)numberOfIntentionImages;

-(UIImage*)imageForIntentionAtIndex:(NSInteger)theIndex;

-(RecipientObject*)recipientAtIndex:(NSInteger)theIndex;
-(NSInteger)numberOfRecipients;

-(RecipientObject*)sweetheartBasedOnUserDefaults;

-(void)fetchIntentionsForArea:(NSString*)theArea withCulture:(NSString*)theCulture withCompletion:(void (^)(NSArray *theIntentions, NSError *error))block;

-(void)reloadIntentionsWithArea:(NSString *)theArea withCulture:(NSString *)theCulture;

-(void)downloadImagesWithCompletion:(void (^)(NSError *error))completion;
@end
