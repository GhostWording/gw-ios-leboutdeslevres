//
//  IntentionModeViewController.m
//  LeRoiDuStatutFacebook
//
//  Created by Mathieu Skulason on 19/01/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import "IntentionModeViewController.h"
#import "SpecialOccasionViewModel.h"
#import "GWIntention.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "LBDLocalization.h"
#import "ConstantsManager.h"
#import "UserDefaults.h"

@interface IntentionModeViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_intentionTableView;
    SpecialOccasionViewModel *_viewModel;
    void (^_selectedIntentionBlock)(GWIntention *theIntention);
}

@end

@implementation IntentionModeViewController

-(id)init {
    if (self = [super init]) {
        
        
    }
    
    return self;
}

-(void)viewDidLoad {
    
    _viewModel = [[SpecialOccasionViewModel alloc] initWithArea:[ConstantsManager sharedInstance].area withCulture:[UserDefaults currentCulture]];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
    header.backgroundColor = [UIColor appBlueColor];
    [self.view addSubview:header];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - (CGRectGetWidth(self.view.frame) * 0.5 - 70), 18, CGRectGetWidth(self.view.frame) - 70*2, 46)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont helveticaNeueBoldWithSize:17.0];
    headerLabel.text = LBDLocalizedString(@"<LBDLSpecialOccasionsTitle>", nil);
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.minimumScaleFactor = 0.7;
    [header addSubview:headerLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 32, 20 + 12, 18, 18);
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImage:[UIImage imageNamed:@"cancelWhite.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    _intentionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
    _intentionTableView.delegate = self;
    _intentionTableView.dataSource = self;
    [self.view addSubview:_intentionTableView];
    
    if ([_intentionTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_intentionTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_intentionTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_intentionTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_viewModel reloadIntentionsWithArea:[ConstantsManager sharedInstance].area withCulture:[UserDefaults currentCulture]];
    [_intentionTableView reloadData];
    
}

-(void)selectedIntentionChosenWithCompletion:(void (^)(GWIntention *theImages))block {
    _selectedIntentionBlock = [block copy];
}

#pragma mark - Delegate & Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_viewModel numberOfIntentions];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        
        cell.textLabel.font = [UIFont helveticaNeueBoldWithSize:16.0];
        cell.textLabel.textColor = [UIColor c_darkGrayTextColor];
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    
    GWIntention *theIntention = [_viewModel intentionAtIndex:indexPath.row];
    
    cell.textLabel.text = theIntention.label;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GWIntention *theIntention = [_viewModel intentionAtIndex:indexPath.row];
    [self dismissViewWithIntention:theIntention];
    
}

#pragma mark - View Navigatoin

-(void)dismissViewWithIntention:(GWIntention*)theIntention {
    [self dismissViewControllerAnimated:YES completion:^{
        _selectedIntentionBlock(theIntention);
    }];
}

-(void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
