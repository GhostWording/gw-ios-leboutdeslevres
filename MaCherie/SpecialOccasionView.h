//
//  SpecialOccasionView.h
//  MaCherie
//
//  Created by Mathieu Skulason on 08/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntentionObject.h"
#import "RecipientObject.h"

@class GWIntention;

typedef void (^SelectionBlock)(GWIntention *selectedIntention, RecipientObject *selectedRecipient);

@interface SpecialOccasionView : UIControl

@property (nonatomic, strong) UITableView *specialOccasionTableView, *recipientsTableView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UILabel *headerLabel;

-(void)selectedIntentionAndRecipient:(SelectionBlock)block;
-(RecipientObject*)selectedRecipient;
-(GWIntention*)selectedIntention;

@end
