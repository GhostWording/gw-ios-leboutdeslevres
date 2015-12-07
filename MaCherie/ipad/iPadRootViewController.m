//
//  ViewController.m
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 31/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "iPadRootViewController.h"
#import "ImageCollectionViewCell.h"
#import "LBDLCollectionView.h"
#import "RootiPadViewModel.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "NSString+TextHeight.h"
#import "UIView+RenderViewToImage.h"
#import "UserDefaults.h"
#import "DefaultButton.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "BoxedActivityIndicatorView.h"

const int numTextsToLoad = 60;
const int numImagesToLoad = 20;

@interface iPadRootViewController () <LBDLCollectionViewDelegate, LBDLCollectionViewDataSource> {
    RootiPadViewModel *model;
    
    UIView *headerView;
    UIView *selectionView;
    UIView *firstLaunView;
    UIView *loadDataView;
    UIView *settingsPopOverView;
    LBDLCollectionView *collectionView;
}

@end

@implementation iPadRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    model = [[RootiPadViewModel alloc] init];
    firstLaunView = nil;
    loadDataView = nil;
    selectionView = nil;
    
    // add the header view
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 68)];
    headerView.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = CGRectMake(15, 30, 28, 28);
    [settingsButton setImage:[UIImage imageNamed:@"settingsBlue.png"] forState:UIControlStateNormal];
    [headerView addSubview:settingsButton];
    
    UIButton *alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    alertButton.frame = CGRectMake(CGRectGetMaxX(settingsButton.frame) + 20, 28, 32, 32);
    [alertButton setImage:[UIImage imageNamed:@"alarmButton.png"] forState:UIControlStateNormal];
    [headerView addSubview:alertButton];
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(CGRectGetWidth(headerView.frame) - 60, 26, 36, 36);
    [refreshButton setImage:[UIImage imageNamed:@"refreshIcon.png"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(updateView) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:refreshButton];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 100, 26, 200, 36)];
    headerTitle.textColor = [UIColor appBlueColor];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = @"Le Bout des lèvres";
    headerTitle.font = [UIFont noteworthyBoldWithSize:23.0];
    [headerView addSubview:headerTitle];
    
    // bottom line
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - 2, CGRectGetWidth(self.view.frame), 10)];
    separator.backgroundColor = [UIColor appBlueColor];
    [headerView addSubview:separator];
    
    [self.view addSubview:headerView];
    
    //settingsPopOverView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(settingsButton.frame), <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)]
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *collectionViewLAyout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLAyout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    collectionView = [[LBDLCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(headerView.frame)) collectionViewLayout:collectionViewLAyout andTexts:[model randomtTextWithNum:60] andImages:[model randomImagesWithNum:60]];
    collectionView.selectionDelegate = self;
    collectionView.imageAndTextDataSource = self;
    [self.view addSubview:collectionView];
    
    
    UserDefaults *defaults = [[UserDefaults alloc] init];
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        [self createFirstLaunView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Update Data and Update Data Source

-(NSArray*)updateImagesCollectionViewDataSource {
    NSLog(@"updating image data sources");
    return [model randomImagesWithNum:numImagesToLoad];
}

-(NSArray*)updateTextsCollectionViewDataSource {
    NSLog(@"updating texts data sources");
    return [model randomtTextWithNum:numTextsToLoad];
}

-(void)updateView {
    [collectionView updateData];
}

#pragma mark - Launc Views and Handling

-(void)createFirstLaunView {
    [firstLaunView removeFromSuperview];
    firstLaunView = nil;
    
    firstLaunView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    firstLaunView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
    [self.view addSubview:firstLaunView];
    
    UILabel *genderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(firstLaunView.frame) * 0.3, CGRectGetWidth(firstLaunView.frame), 40)];
    genderTitleLabel.textColor = [UIColor appBlueColor];
    genderTitleLabel.font = [UIFont noteworthyBoldWithSize:32];
    genderTitleLabel.text = @"Je suis";
    genderTitleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:genderTitleLabel];
    
    DefaultButton *maleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) - 150, CGRectGetMidY(firstLaunView.frame) - 45, 90, 90)];
    [maleButton setImage:[UIImage imageNamed:@"maleGender.png"] forState:UIControlStateNormal];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateHighlighted];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateSelected];
    [maleButton addTarget:self action:@selector(maleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:maleButton];
    
    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(maleButton.frame), CGRectGetMaxY(maleButton.frame) + 20, CGRectGetWidth(maleButton.frame), 32)];
    maleLabel.font = [UIFont noteworthyBoldWithSize:23.0];
    maleLabel.text = @"Homme";
    maleLabel.textColor = [UIColor appBlueColor];
    maleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:maleLabel];
    
    DefaultButton *femaleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) + 60, CGRectGetMidY(firstLaunView.frame) - 45, 90, 90)];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGender.png"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateHighlighted];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateSelected];
    [femaleButton addTarget:self action:@selector(femaleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:femaleButton];
    
    UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(femaleButton.frame), CGRectGetMaxY(femaleButton.frame) + 20, CGRectGetWidth(femaleButton.frame), 32)];
    femaleLabel.font = [UIFont noteworthyBoldWithSize:23.0];
    femaleLabel.text = @"Femme";
    femaleLabel.textColor = [UIColor appBlueColor];
    femaleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:femaleLabel];
}

-(void)dismissFirstLaunView {
    /*
    DataManager *dataMAn = [[DataManager alloc] init];
    
    [UserDefaults setFirstLaunchOfApp:NO];
    [UserDefaults setDateInstalled:[NSDate date]];
    
    if ([dataMAn numTexts] >= numTextsToLoad && [dataMAn numImages] >= numImagesToLoad) {
        [UIView animateWithDuration:0.3 animations:^{
            firstLaunView.alpha = 0.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadData];
            });
        }];
    }
    else {
        [self createLoadingDataView];
        loadDataView.frame = CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(loadDataView.frame), CGRectGetHeight(loadDataView.frame));
        [UIView animateWithDuration:0.3 animations:^{
            firstLaunView.frame = CGRectMake(-CGRectGetWidth(firstLaunView.frame), CGRectGetMinY(firstLaunView.frame), CGRectGetWidth(firstLaunView.frame), CGRectGetHeight(firstLaunView.frame));
            loadDataView.frame = CGRectMake(0, 0, CGRectGetWidth(loadDataView.frame), CGRectGetHeight(loadDataView.frame));
        } completion:^(BOOL finished) {
            [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
        }];
    }*/
}

-(void)isSufficientResourcesDownloaded {
    
    /*
    DataManager *dataMan = [[DataManager alloc] init];
    
    if ([dataMan numTexts] >= numTextsToLoad && [dataMan numImages] >= numImagesToLoad) {
        
        [UIView animateWithDuration:0.3 animations:^{
            loadDataView.alpha = 0.0f;
        }completion:^(BOOL completion) {
            NSLog(@"sufficient resources");
            [collectionView updateData];
        }];
    }
    else {
        [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
    }
     */
}

-(void)createLoadingDataView {
    [loadDataView removeFromSuperview];
    loadDataView = nil;
    
    loadDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(firstLaunView.frame), CGRectGetHeight(firstLaunView.frame))];
    loadDataView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
    [self.view addSubview:loadDataView];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(CGRectGetMidX(loadDataView.frame) - 25, CGRectGetHeight(loadDataView.frame) * 0.39, 50, 50);
    [loadDataView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    UILabel *downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(loadDataView.frame) * 0.1, CGRectGetHeight(loadDataView.frame) * 0.5, CGRectGetWidth(loadDataView.frame) * 0.8, 65)];
    downloadingLabel.font = [UIFont noteworthyBoldWithSize:26.0];
    downloadingLabel.text = @"Téléchargement en cours...";
    downloadingLabel.textColor = [UIColor appBlueColor];
    downloadingLabel.textAlignment = NSTextAlignmentCenter;
    downloadingLabel.numberOfLines = 2;
    [loadDataView addSubview:downloadingLabel];
}

#pragma mark - Gender Selection

-(void)maleButtonPressed:(DefaultButton*)button {
    [button setSelected:YES];
    [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderMale]];
    
    [self performSelector:@selector(dismissFirstLaunView) withObject:nil afterDelay:0.3];
}

-(void)femaleButtonPressed:(DefaultButton*)button {
    [button setSelected:YES];
    [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderFemale]];
    
    [self performSelector:@selector(dismissFirstLaunView) withObject:nil afterDelay:0.3];
}

#pragma mark - Selection Delegate

-(void)selectedImage:(Image *)theImage andSelectedText:(Text *)theText {
    
    NSLog(@"selected image");
    [self createSelectionViewWithImage:theImage andText:theText];
}

#pragma mark - Create Selection View

-(void)createSelectionViewWithImage:(Image*)theImage andText:(Text*)theText {
    
    NSLog(@"creating selection view");
    
    UIImage *createdImage = [self createImageToSendWithImage:[UIImage imageWithData:theImage.imageData] andText:theText.content];
    
    if (!selectionView) {
        NSLog(@"selection view");
        selectionView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(headerView.frame))];
        selectionView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        selectionView.alpha = 0.0f;
        [self.view addSubview:selectionView];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(selectionView.frame) * 0.1, CGRectGetHeight(selectionView.frame) * 0.1, CGRectGetWidth(selectionView.frame) * 0.8, CGRectGetHeight(selectionView.frame) * 0.8)];
        imageview.image = createdImage;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview.layer.masksToBounds = YES;
        [selectionView addSubview:imageview];
        
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        customButton.frame = CGRectMake(CGRectGetWidth(selectionView.frame)  - 100, 15, 80, 80);
        [customButton addTarget:self action:@selector(dismissSelectionView) forControlEvents:UIControlEventTouchUpInside];
        [selectionView addSubview:customButton];
        
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake(CGRectGetMidX(selectionView.frame) - 75, CGRectGetHeight(selectionView.frame) - 75, 150, 50);
        sendButton.layer.cornerRadius = 4.0;
        sendButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
        sendButton.titleLabel.font = [UIFont helveticaNeueWithSize:23];
        [sendButton setTitle:@"Envoi" forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
        [sendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
        [sendButton addTarget:self action:@selector(sendImage) forControlEvents:UIControlEventTouchUpInside];
        [selectionView addSubview:sendButton];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(CGRectGetMaxX(imageview.frame) - 100, CGRectGetHeight(selectionView.frame) - 75, 100, 50);
        shareButton.layer.cornerRadius = 4.0;
        shareButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
        shareButton.titleLabel.font = [UIFont helveticaNeueWithSize:23];
        [shareButton setTitle:@"Partage" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
        [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
        [shareButton addTarget:self action:@selector(facebookShare) forControlEvents:UIControlEventTouchUpInside];
        [selectionView addSubview:shareButton];
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake(CGRectGetMinX(imageview.frame), CGRectGetHeight(selectionView.frame) - 85, 60, 60);
        [editButton setBackgroundImage:[UIImage imageNamed:@"editButton.png"] forState:UIControlStateNormal];
        [selectionView addSubview:editButton];
        
        
        if ([theText.impersonal isEqualToString:@"false"]) {
            shareButton.hidden = YES;
        }
        
        
        // animate the view
        [UIView animateWithDuration:0.3 animations:^{
            selectionView.alpha = 1.0;
        }completion:^(BOOL finished) {
            
        }];
        
    }
}

-(void)sendImage {
    if ([collectionView selectedImage] != nil && [collectionView selectedText] != nil) {
        
        Text *theText = [collectionView selectedText];
        Image *theImage = [collectionView selectedImage];
        
        UIImage *imageToSend = [self createImageToSendWithImage:[UIImage imageWithData:theImage.imageData] andText:theText.content];
        
        [FBSDKMessengerSharer shareImage:imageToSend withOptions:nil];
        
    }
}

-(void)facebookShare {
    
    if ([collectionView selectedImage] != nil && [collectionView selectedText] != nil) {
        
        Text *theText = [collectionView selectedText];
        Image *theImage = [collectionView selectedImage];
        
        UIImage *imageToSend = [self createImageToSendWithImage:[UIImage imageWithData:theImage.imageData] andText:theText.content];
        
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = imageToSend;
        photo.userGenerated = YES;
        
        FBSDKSharePhotoContent *photoContent = [[FBSDKSharePhotoContent alloc] init];
        photoContent.photos = @[photo];
        
        [FBSDKShareDialog showFromViewController:self withContent:photoContent delegate:nil];
    }
    
}

-(UIImage*)createImageToSendWithImage:(UIImage*)theImage andText:(NSString*)theText {
    UIImage *selectedImage = theImage;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
    [imageView setImage:selectedImage];
    
    double fontSize = selectedImage.size.width / 20.0f;
    
    UIFont *font = [UIFont fontWithName:@"Noteworthy-Bold" size:fontSize];
    
    CGFloat heightForText = [theText heightForTextWithdWidth:selectedImage.size.width*0.8 andFont:font];
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(imageView.frame)*0.1, CGRectGetMaxY(imageView.frame) + 40, CGRectGetWidth(imageView.frame) * 0.8, heightForText + 4)];
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.numberOfLines = 0;
    newLabel.font = font;
    newLabel.text = theText;
    newLabel.textColor = [UIColor blackColor];
    
    UIView *snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectedImage.size.width, CGRectGetMaxY(newLabel.frame) + 60)];
    snapshotView.backgroundColor = [UIColor whiteColor];
    [snapshotView addSubview:imageView];
    [snapshotView addSubview:newLabel];
    
    UIImage *snapshotImage = [snapshotView imageByRenderingView];
    
    return snapshotImage;
}

#pragma mark Selection Actions

-(void)dismissSelectionView {
    [UIView animateWithDuration:0.3 animations:^{
        selectionView.alpha = 0.0;
    }completion:^(BOOL finished) {
        selectionView = nil;
        [collectionView resetSelection];
    }];
}

@end
