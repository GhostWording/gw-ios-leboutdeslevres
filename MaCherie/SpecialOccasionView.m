//
//  SpecialOccasionView.m
//  MaCherie
//
//  Created by Mathieu Skulason on 08/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "SpecialOccasionView.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "SpecialOccasionViewModel.h"
#import "IntentionObject.h"
#import "RecipientObject.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "GWIntention.h"
#import "UserDefaults.h"
#import "ConstantsManager.h"

@interface SpecialOccasionView () <UITableViewDataSource, UITableViewDelegate> {
    UIView *headerBorder;
    GWIntention *selectedIntention;
    RecipientObject *selectedRecipient;
    SpecialOccasionViewModel *viewModel;
    SelectionBlock selectionBlock;
}

@end

@implementation SpecialOccasionView

@synthesize specialOccasionTableView, recipientsTableView;
@synthesize header;
@synthesize headerLabel;

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 4.0;
        self.layer.borderColor = [UIColor appBlueColor].CGColor;
        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.layer.masksToBounds = YES;
        
        selectedIntention = nil;
        selectedRecipient = nil;
        
        selectionBlock = nil;
        
        //NSArray *recipients = @[[RecipientObject recipientSweetheartFemale], [RecipientObject recipientSweetheartMale], [RecipientObject recipientCloseFriends], [RecipientObject recipientMother], [RecipientObject recipientFather], [RecipientObject recipientSister], [RecipientObject recipientBrother], [RecipientObject recipientLongLostFriends], [RecipientObject recipientLoveInterestFemale], [RecipientObject recipientLoveInterestMale], [RecipientObject recipientProNetwork], [RecipientObject recipientFamilyYoungsters], [RecipientObject recipientDistantRelatives], [RecipientObject recipientOtherFriends]];
        
        viewModel = [[SpecialOccasionViewModel alloc] initWithArea:[ConstantsManager sharedInstance].specialOccasionArea withCulture:[UserDefaults currentCulture]];
        
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 60)];
        header.backgroundColor = [UIColor appLightGrayColor];
        header.layer.masksToBounds = YES;
        [self addSubview:header];
        
        headerBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(header.frame)-2, CGRectGetWidth(self.frame), 2)];
        headerBorder.backgroundColor = [UIColor appBlueColor];
        [header addSubview:headerBorder];
        
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) * 0.1, 5, CGRectGetWidth(self.frame)*0.8, 50)];
        headerLabel.numberOfLines = 0;
        headerLabel.font = [UIFont helveticaNeueWithSize:16.0];
        headerLabel.text = @"Occasions spéciales";
        headerLabel.textColor = [UIColor appBlueColor];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        [header addSubview:headerLabel];
        
        specialOccasionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(header.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(header.frame)) style:UITableViewStylePlain];
        specialOccasionTableView.delegate = self;
        specialOccasionTableView.dataSource = self;
        [self addSubview:specialOccasionTableView];
        
        recipientsTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame), CGRectGetHeight(header.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(header.frame)) style:UITableViewStylePlain];
        recipientsTableView.delegate = self;
        recipientsTableView.dataSource = self;
        [self addSubview:recipientsTableView];
        
    }
    
    return self;
}

#pragma mark - Block

-(void)selectedIntentionAndRecipient:(SelectionBlock)block {
    selectionBlock = block;
}

#pragma mark - Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (tableView == recipientsTableView) {
        return 0;
    }
    
    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([viewModel numberOfIntentions] == 0) {
        
        [viewModel fetchIntentionsForArea:[ConstantsManager sharedInstance].specialOccasionArea withCulture:[UserDefaults currentCulture] withCompletion:^(NSArray *theIntentionIds, NSError *error) {
            
            [specialOccasionTableView reloadData];
            
        }];
        
    }
    
    if (tableView == specialOccasionTableView) {
        return [viewModel numberOfIntentions];
    }
    else if (tableView == recipientsTableView) {
        return [viewModel numberOfRecipients];
    }
    
    return 0;
}


#pragma mark - Table View Data Source

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifier"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor appBlueColor];
        cell.textLabel.font = [UIFont helveticaNeueWithSize:15.0];
    }
    
    if (tableView == specialOccasionTableView) {
        GWIntention *currentIntention = [viewModel intentionAtIndex:indexPath.row];
        NSLog(@"intention image path is: %@", currentIntention.imagePath);
        cell.textLabel.text = currentIntention.label;
    }
    else if(tableView == recipientsTableView) {
        RecipientObject *recipient = [viewModel recipientAtIndex:indexPath.row];
        cell.textLabel.text = recipient.recipientName;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did choose row");
    
    if (tableView == specialOccasionTableView) {
        selectedIntention = [viewModel intentionAtIndex:indexPath.row];
        selectedRecipient = [viewModel sweetheartBasedOnUserDefaults];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_SPECIAL_INTENTION withAction:GA_ACTION_CELL_SELECTION withLabel:selectedIntention.slugPrototypeLink wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_CELL_SELECTION actionLocation:GA_SCREEN_SPECIAL_OCCASION targetType:@"Command" targetId:@"SelectedIntention" targetParameter:selectedIntention.slugPrototypeLink];
        
        if (!selectedIntention.impersonal) {
            
            selectionBlock(selectedIntention, [viewModel sweetheartBasedOnUserDefaults]);
            
        }
        else {
            
            selectionBlock(selectedIntention, [viewModel sweetheartBasedOnUserDefaults]);
        }
    }
    /*
    else if(tableView == recipientsTableView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            recipientsTableView.frame = CGRectMake(CGRectGetWidth(self.frame), 0, CGRectGetWidth(recipientsTableView.frame), CGRectGetHeight(recipientsTableView.frame));
        }];
        
        RecipientObject *selectedRecipient = [viewModel recipientAtIndex:indexPath.row];
        
        if (selectedIntention != nil && selectedRecipient != nil && selectionBlock) {
            selectionBlock(selectedIntention, selectedRecipient);
        }
        
    }
    */
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(GWIntention*)selectedIntention {
    return selectedIntention;
}

-(RecipientObject*)selectedRecipient {
    return selectedRecipient;
}


@end
