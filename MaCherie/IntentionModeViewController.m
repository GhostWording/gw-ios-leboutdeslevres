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
#import <MBProgressHUD.h>

#import "IntentionImageAndTextCollectionViewCell.h"

@interface IntentionModeViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource> {

    UICollectionView *_intentionCollectionView;
    SpecialOccasionViewModel *_viewModel;
    void (^_selectedIntentionBlock)(GWIntention *theIntention);
    MBProgressHUD *_progress;
}

@end

@implementation IntentionModeViewController
-(id)init {
    if (self = [super init]) {
        
        
    }
    
    return self;
}

-(void)viewDidLoad {
    
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
    closeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 40, 20 + 6, 24, 24);
    [closeButton setTintColor:[UIColor whiteColor]];
    [closeButton setImage:[UIImage imageNamed:@"cancelWhite.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    closeButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [self.view addSubview:closeButton];
    
    
    // creating the collection view
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _intentionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64) collectionViewLayout:flowLayout];
    _intentionCollectionView.delegate = self;
    _intentionCollectionView.dataSource = self;
    _intentionCollectionView.backgroundColor = [UIColor whiteColor];
    [_intentionCollectionView registerClass:[IntentionImageAndTextCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    [self.view addSubview:_intentionCollectionView];
    
    _progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _viewModel = [[SpecialOccasionViewModel alloc] initWithArea:[ConstantsManager sharedInstance].area withCulture:[UserDefaults currentCulture]];
    
    
    if ([_viewModel numberOfIntentionImages] != 0) {
        [_progress hide:YES];
    }
    
    [_viewModel downloadImagesWithCompletion:^(NSError *error) {
        
        [_progress hide:YES];
        
        if (error == nil) {
            [_viewModel reloadIntentionsWithArea:[ConstantsManager sharedInstance].area withCulture:[UserDefaults currentCulture]];
            [_intentionCollectionView reloadData];
        }
        
    }];
    
    [_viewModel reloadIntentionsWithArea:[ConstantsManager sharedInstance].area withCulture:[UserDefaults currentCulture]];
    [_intentionCollectionView reloadData];
    
}

-(void)selectedIntentionChosenWithCompletion:(void (^)(GWIntention *theImages))block {
    _selectedIntentionBlock = [block copy];
}

#pragma mark - Collection View Delegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float height = CGRectGetWidth(self.view.frame) / 2.0;
    return CGSizeMake(height, height + 20);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


#pragma mark - Collection view Data Source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_viewModel numberOfIntentions];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GWIntention *intention = [_viewModel intentionAtIndex:indexPath.section + indexPath.row];
    
    IntentionImageAndTextCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text = intention.label;
    cell.titleLabel.font = [UIFont helveticaNeueBoldWithSize:14.0];
    cell.titleLabel.textColor = [UIColor c_darkGrayTextColor];
    cell.titleLabel.adjustsFontSizeToFitWidth = YES;
    cell.titleLabel.minimumScaleFactor = 0.7;
    
    UIImage *intentionImage = [_viewModel imageForIntentionAtIndex:indexPath.row];
    if (intentionImage != nil) {
        cell.imageView.image = intentionImage;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.layer.masksToBounds = YES;
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
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
