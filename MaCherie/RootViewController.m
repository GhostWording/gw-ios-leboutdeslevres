//
//  RootViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "RootViewController.h"
#import "TextScrollView.h"
#import "ImageScrollView.h"
#import "DataManager.h"
#import "UserDefaults.h"
#import "DefaultButton.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "UIViewController+Extension.h"
#import "AppDelegate.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "UIImage+RenderViewToImage.h"
#import "UIView+RenderViewToImage.h"
#import "NSString+TextHeight.h"

const float bottomHeight = 50.0f;
const int numberOfImagesToLoad = 10;
const int numberOfTextsToLoad = 12;

@interface RootViewController ()
{
    TextScrollView *theScrollView;
    ImageScrollView *theImageScrollView;
    UILabel *firstLabel;
    UIView *firstLaunView;
    UIView *newView;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    DataManager *dataMan = [[DataManager alloc] init];
    
    theImageScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20) andImages:[dataMan randomImagesForNumberOfImages:numberOfImagesToLoad]];
    [self.view addSubview:theImageScrollView];
    
    
    UIView *settingsView = [[UIView alloc] initWithFrame:CGRectMake(10, 25, CGRectGetWidth(self.view.frame)*0.13, CGRectGetWidth(self.view.frame)*0.13)];
    settingsView.backgroundColor = [UIColor appLightGrayColor];
    settingsView.alpha = 0.8;
    settingsView.layer.cornerRadius = 4.0f;
    [self.view addSubview:settingsView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.01, CGRectGetWidth(self.view.frame)*0.01, CGRectGetWidth(self.view.frame)*0.11, CGRectGetWidth(self.view.frame)*0.11);
    button.tintColor = [UIColor appBlueColor];
    [button setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [settingsView addSubview:button];
    
    
    theScrollView = [[TextScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(theImageScrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 - bottomHeight - 20) andTexts:[dataMan randomTextsForGender:nil numTexts:numberOfTextsToLoad]];
    [self.view addSubview:theScrollView];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 80, CGRectGetMaxY(theScrollView.frame), 160, 40);
    bottomButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    bottomButton.layer.cornerRadius = 4.0;
    [bottomButton setTitle:@"Send" forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [bottomButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [bottomButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomButton];
    
    
    UserDefaults *defaults = [[UserDefaults alloc] init];
    
    NSLog(@"is first launch: %@", [UserDefaults firstLaunchOfApp]);
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        
        firstLaunView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        firstLaunView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        [self.view addSubview:firstLaunView];
        
        UILabel *genderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(firstLaunView.frame) * 0.3, CGRectGetWidth(firstLaunView.frame), 40)];
        genderTitleLabel.font = [UIFont noteworthyBoldWithSize:26.0f];
        genderTitleLabel.textColor = [UIColor appBlueColor];
        genderTitleLabel.text = @"Je suis";
        genderTitleLabel.textAlignment = NSTextAlignmentCenter;
        [firstLaunView addSubview:genderTitleLabel];
        
        DefaultButton *maleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) - 90, CGRectGetMidY(firstLaunView.frame) - 30, 60, 60)];
        [maleButton setImage:[UIImage imageNamed:@"maleGender.png"] forState:UIControlStateNormal];
        [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateSelected];
        [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateHighlighted];
        [maleButton addTarget:self action:@selector(maleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [firstLaunView addSubview:maleButton];
        
        UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(maleButton.frame), CGRectGetMaxY(maleButton.frame) + 10, CGRectGetWidth(maleButton.frame), 20)];
        maleLabel.font = [UIFont noteworthyBoldWithSize:17.0];
        maleLabel.text = @"Homme";
        maleLabel.textColor = [UIColor appBlueColor];
        maleLabel.textAlignment = NSTextAlignmentCenter;
        [firstLaunView addSubview:maleLabel];
        
        DefaultButton *femaleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) + 30, CGRectGetMidY(firstLaunView.frame) - 30, 60, 60)];
        [femaleButton setImage:[UIImage imageNamed:@"femaleGender.png"] forState:UIControlStateNormal];
        [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateHighlighted];
        [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateSelected];
        [femaleButton addTarget:self action:@selector(femaleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [firstLaunView addSubview:femaleButton];
        
        UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(femaleButton.frame), CGRectGetMaxY(femaleButton.frame) + 10, CGRectGetWidth(femaleButton.frame), 20)];
        femaleLabel.font = [UIFont noteworthyBoldWithSize:17.0f];
        femaleLabel.text = @"Femme";
        femaleLabel.textColor = [UIColor appBlueColor];
        femaleLabel.textAlignment = NSTextAlignmentCenter;
        [firstLaunView addSubview:femaleLabel];
        
    }
    
    
}

-(void)updateViewData {
    
    DataManager *dataMan = [[DataManager alloc] init];
    
    [theImageScrollView updateImages:[dataMan randomImagesForNumberOfImages:numberOfImagesToLoad]];
    [theScrollView updateTexts:[dataMan randomTextsForGender:nil numTexts:numberOfTextsToLoad]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login:(id)sender
{
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

#pragma mark - 
#pragma mark Gender Selection

-(void)maleButtonPressed:(DefaultButton*)button {
    [button setSelected:YES];
    [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderMale]];
    
    [self performSelector:@selector(dismissFirstLaunchView) withObject:nil afterDelay:0.3];
}

-(void)femaleButtonPressed:(DefaultButton*)button {
    [button setSelected:YES];
    [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderFemale]];
    
    [self performSelector:@selector(dismissFirstLaunchView) withObject:nil afterDelay:0.3];
}

-(void)dismissFirstLaunchView {
    
    DataManager *dataMan = [[DataManager alloc] init];
    
    [UserDefaults setFirstLaunchOfApp:NO];
    
    if ([dataMan numTexts] >= numberOfTextsToLoad && [dataMan numImages] >= numberOfImagesToLoad) {
        [UIView animateWithDuration:0.3 animations:^{
            firstLaunView.alpha = 0.0f;
            
            [self performSelectorOnMainThread:@selector(updateViewData) withObject:nil waitUntilDone:YES];
        
        }];
        
    } else {
        // show another view
        newView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        newView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        [self.view addSubview:newView];
        
        UIActivityIndicatorView *activityIndiciator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndiciator.frame = CGRectMake(CGRectGetWidth(newView.frame)/2.0 - 37/2.0, CGRectGetHeight(newView.frame)*0.35, 37, 37);
        [newView addSubview:activityIndiciator];
        [activityIndiciator startAnimating];
        
        UILabel *downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(newView.frame)*0.1, CGRectGetHeight(newView.frame)*0.5, CGRectGetWidth(newView.frame)*0.8, 55)];
        downloadingLabel.font = [UIFont noteworthyBoldWithSize:25.0f];
        downloadingLabel.text = @"Téléchargement en cours...";
        downloadingLabel.textColor = [UIColor appBlueColor];
        downloadingLabel.textAlignment = NSTextAlignmentCenter;
        downloadingLabel.numberOfLines = 2;
        [newView addSubview:downloadingLabel];
        
        [UIView animateWithDuration:0.3 animations:^ {
            firstLaunView.frame = CGRectMake(-CGRectGetWidth(firstLaunView.frame), CGRectGetMinY(firstLaunView.frame), CGRectGetWidth(firstLaunView.frame), CGRectGetHeight(firstLaunView.frame));
            newView.frame = CGRectMake(0, 0, CGRectGetWidth(newView.frame), CGRectGetHeight(newView.frame));
        } completion:^(BOOL completion) {

            [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
        }];
    }
}

-(void)isSufficientResourcesDownloaded {
    DataManager *dataMan = [[DataManager alloc] init];
    if ([dataMan numTexts] >= numberOfTextsToLoad && [dataMan numImages] >= numberOfImagesToLoad) {
        [self performSelectorOnMainThread:@selector(updateViewData) withObject:nil waitUntilDone:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            newView.alpha = 0.0f;
        }];
        
    } else {
        [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
    }
}

#pragma mark -
#pragma mark Send Button


-(void)sendButtonPressed
{
    NSString *selectedText = [theScrollView selectedText];
    UIImage *selectedImage = [theImageScrollView selectedImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
    [imageView setImage:selectedImage];
    
    double fontSize = selectedImage.size.width / 20.0f;
    
    UIFont *font = [UIFont fontWithName:@"Noteworthy-Bold" size:fontSize];
    
    CGFloat heightForText = [selectedText heightForTextWithdWidth:selectedImage.size.width*0.8 andFont:font];
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(imageView.frame)*0.1, CGRectGetMaxY(imageView.frame) + 40, CGRectGetWidth(imageView.frame) * 0.8, heightForText + 4)];
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.numberOfLines = 0;
    newLabel.font = font;
    newLabel.text = selectedText;
    newLabel.textColor = [UIColor blackColor];
    
    UIView *snapshotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectedImage.size.width, CGRectGetMaxY(newLabel.frame) + 60)];
    snapshotView.backgroundColor = [UIColor whiteColor];
    [snapshotView addSubview:imageView];
    [snapshotView addSubview:newLabel];
    
    UIImage *snapshotImage = [snapshotView imageByRenderingView];
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        
        [FBSDKMessengerSharer shareImage:snapshotImage withOptions:nil];
    }
}

@end
