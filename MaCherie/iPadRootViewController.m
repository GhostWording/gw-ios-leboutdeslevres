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
#import "DataManager.h"
#import "RootiPadViewModel.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "NSString+TextHeight.h"
#import "UIView+RenderViewToImage.h"

@interface iPadRootViewController () <LBDLCollectionViewDelegate> {
    RootiPadViewModel *model;
    
    UIView *headerView;
    UIView *selectionView;
    LBDLCollectionView *collectionView;
}

@end

@implementation iPadRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    model = [[RootiPadViewModel alloc] init];
    
    // add the header view
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
    headerView.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
    
    selectionView = nil;
    
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 100, 22, 200, 36)];
    headerTitle.textColor = [UIColor appBlueColor];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = @"Le Bout des lèvres";
    headerTitle.font = [UIFont noteworthyBoldWithSize:19.0];
    [headerView addSubview:headerTitle];
    
    // bottom line
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - 2, CGRectGetWidth(self.view.frame), 10)];
    separator.backgroundColor = [UIColor appBlueColor];
    [headerView addSubview:separator];
    
    [self.view addSubview:headerView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *collectionViewLAyout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLAyout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    collectionView = [[LBDLCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(headerView.frame)) collectionViewLayout:collectionViewLAyout andTexts:[model randomtTextWithNum:60] andImages:[model randomImagesWithNum:60]];
    collectionView.selectionDelegate = self;
    [self.view addSubview:collectionView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
