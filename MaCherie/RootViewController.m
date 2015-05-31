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
#import "RootViewModel.h"
#import "UserDefaults.h"
#import "DefaultButton.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "UIViewController+Extension.h"
#import "AppDelegate.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UIImage+RenderViewToImage.h"
#import "UIView+RenderViewToImage.h"
#import "NSString+TextHeight.h"
#import "TimeOutManager.h"
#import "NavigationSlideAnimator.h"
#import "GoogleAnalyticsCommunication.h"

const float bottomHeight = 60.0f;
const int numberOfImagesToLoad = 10;
const int numberOfTextsToLoad = 10;

@interface RootViewController () <UIAlertViewDelegate, TextScrollViewDelegate, TextScrollViewDataSource, ImageScrollViewDataSource, UIViewControllerTransitioningDelegate>
{
    TextScrollView *theTextPagedView;
    ImageScrollView *theImagePagedView;
    UILabel *firstLabel;
    UIView *firstLaunView;
    UIView *newView;
    UIView *editTextView;
    
    UIButton *dismissEditViewButton;
    UIButton *dismissKeyboardButton;
    UITextView *textView;
    
    UIButton *normalSendButton;
    UIButton *editedTextSendButton;
    UIButton *shareButton;
    FBSDKSharePhotoContent *photoContent;
    
    UIAlertView *alert;
    
    RootViewModel *model;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    editTextView = nil;
    
    DataManager *dataMan = [[DataManager alloc] init];
    model = [[RootViewModel alloc] init];
    
    NSArray *randomText = [model randomtTextWithNum:numberOfTextsToLoad];
    
    // TODO: should not call the data manager instead the model should handle
    // all data calls
    theImagePagedView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20) andImages:nil];
    theImagePagedView.imageScrollViewDataSource = self;
    [self.view addSubview:theImagePagedView];
    
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
    
    theTextPagedView = [[TextScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(theImagePagedView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 - bottomHeight - 20) andTexts:randomText];
    theTextPagedView.shareDelegate = self;
    theTextPagedView.textScrollViewDataSource = self;
    [self.view addSubview:theTextPagedView];
    
    NSLog(@"after scroll view");
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 40, CGRectGetMaxY(theImagePagedView.frame) + 3, 30, 30);
    //editButton.frame = CGRectMake(10, CGRectGetMaxY(theTextPagedView.frame) + 4, 38, 38);
    [editButton setImage:[UIImage imageNamed:@"editButton.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"editButtonSelected.png"] forState:UIControlStateHighlighted];
    [editButton addTarget:self action:@selector(createEditTextView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    
    normalSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    normalSendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 60, CGRectGetMaxY(theTextPagedView.frame) + 3, 120, 40);
    normalSendButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    normalSendButton.layer.cornerRadius = 4.0;
    normalSendButton.titleLabel.font = [UIFont helveticaNeueWithSize:17];
    [normalSendButton setTitle:@"Envoi" forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [normalSendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalSendButton];
    
    UIImageView *messengerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messengerIconAlpha.png"]];
    messengerIcon.frame = CGRectMake(8, 11, 20, 20);
    [normalSendButton addSubview:messengerIcon];
    
    photoContent = [[FBSDKSharePhotoContent alloc] init];

    if ([theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = [self createImageWithText:[theTextPagedView selectedText]];
        photo.userGenerated = YES;
        
        photoContent.photos = @[photo];
    }
    
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    shareButton.layer.cornerRadius = 4.0;
    shareButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 80 - 10, CGRectGetMinY(normalSendButton.frame), 80, 40);
    
    if (![theTextPagedView wantsFacebookShareForCurrentText]) {
        shareButton.alpha = 0.0f;
    }
    
    shareButton.titleLabel.font = [UIFont helveticaNeueWithSize:17];
    [shareButton setTitle:@"Partage" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    
    UserDefaults *defaults = [[UserDefaults alloc] init];
    
    NSLog(@"is first launch: %@", [UserDefaults firstLaunchOfApp]);
    NSLog(@"number of texts are: %ld", (long)[dataMan numTexts]);
    
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
        
        // the timeout manager if the user hasn't interacted with the view for a long time
        
        [[TimeOutManager shareTimeOutManager] timeElapsedWithCompletion:^(BOOL finished) {
            if (!alert) {
                alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Faites glisser les textes et les photos vers la gauche. \n Envoyez la combinaison qui vous plaît !" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                [[TimeOutManager shareTimeOutManager] deactivate];
            }
        }];
        
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[TimeOutManager shareTimeOutManager] restartTime];
    alert = nil;
    NSLog(@"cancel");
}

-(void)updateViewData {
    
    NSLog(@"update view Data");
        
    [theImagePagedView reloadDataAnimated:YES];
    [theTextPagedView reloadDataAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    [[TimeOutManager shareTimeOutManager] pauseTime];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    // update the texts in case we have chosen a different gender and the texts need
    // to be re-filtered
    
    NSLog(@"View will appear");
    
    [[TimeOutManager shareTimeOutManager] startTime];
    [self updateViewData];
}

-(void)login:(id)sender
{
    [[TimeOutManager shareTimeOutManager] restartTime];    
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
    NSLog(@"login segue");
}

#pragma mark - Edit Text View

-(void)createEditTextView {
    NSLog(@"created edit text view");
    
    [[TimeOutManager shareTimeOutManager] pauseTime];
    
    if (!editTextView && [theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        editTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        editTextView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 40, 25, 20, 20);
        [cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(dismissEditTextView) forControlEvents:UIControlEventTouchUpInside];
        [editTextView addSubview:cancelButton];
         
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.05, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(self.view.frame) * 0.9, CGRectGetHeight(self.view.frame) * 0.7)];
        textView.font = [UIFont noteworthyBoldWithSize:17.0f];
        textView.text = [theTextPagedView selectedText];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.layer.borderColor = [UIColor appBlueColor].CGColor;
        textView.layer.borderWidth = 1.5f;
        textView.layer.cornerRadius = 6.0f;
        UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
        accessoryView.backgroundColor = [UIColor appBlueColor];
        
        dismissKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissKeyboardButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 90, 0, 90, CGRectGetHeight(accessoryView.frame));
        [dismissKeyboardButton setTitle:@"Accepter" forState:UIControlStateNormal];
        [dismissKeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissKeyboardButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
        [dismissKeyboardButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
        [dismissKeyboardButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:dismissKeyboardButton];
        
        [textView setInputAccessoryView:accessoryView];
        
        editedTextSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editedTextSendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 60, CGRectGetMaxY(textView.frame) + 56, 120, 40);
        editedTextSendButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
        editedTextSendButton.layer.cornerRadius = 4.0f;
        [editedTextSendButton setTitle:@"Envoi" forState:UIControlStateNormal];
        [editedTextSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editedTextSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
        [editedTextSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
        [editedTextSendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [editTextView addSubview:editedTextSendButton];
        
        UIImageView *editMessengerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messengerIconAlpha.png"]];
        editMessengerIcon.frame = CGRectMake(8, 11, 20, 20);
        [editedTextSendButton addSubview:editMessengerIcon];
        
        [editTextView addSubview:textView];
        editTextView.alpha = 0.0f;
        [self.view addSubview:editTextView];
        
        [UIView animateWithDuration:0.3 animations:^{
            editTextView.alpha = 1.0f;
        }];
        
    }
}

-(void)dismissEditTextView {
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    if (editTextView) {
        [UIView animateWithDuration:0.3 animations:^{
            editTextView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [editTextView removeFromSuperview];
                editTextView = nil;
            }
        }];
    }
}

-(void)keyboardOnScreen:(NSNotification*)notification {
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [UIView animateWithDuration:0.2 animations:^{
        float height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(keyboardFrame) - CGRectGetMinY(textView.frame);
        textView.frame = CGRectMake(CGRectGetMinX(textView.frame), CGRectGetMinY(textView.frame), CGRectGetWidth(textView.frame), height);
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)dismissKeyboard {
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    [textView resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        textView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.05, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(self.view.frame) * 0.9, CGRectGetHeight(self.view.frame) * 0.7);
    } completion:^(BOOL finished) {
        
    }];
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

#pragma mark - First Time Launch View

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


-(void)sendButtonPressed:(UIButton*)sender
{
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    if ([theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        
        if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
            
            NSString *selectedText;
            
            // send the events to google analytics
            NSString *selectedTextId  = [theTextPagedView selectedTextId];
            NSString *selectedImageId = [theImagePagedView selectedImageId];
            
            // text depends on wether we are sending a message directly
            // or if we have edited in the edit text view
            if ([sender isEqual:normalSendButton]) {
                selectedText = [theTextPagedView selectedText];
                
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
                
            }
            else if([sender isEqual:editedTextSendButton]) {
                selectedText = textView.text;
                
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
            }
            
            UIImage *snapshotImage = [self createImageWithText:selectedText];
            
            
            [FBSDKMessengerSharer shareImage:snapshotImage withOptions:nil];
        } else {
            // Messenger isn't installed. Redirect the person to the App Store.
            NSString *appStoreLink = @"https://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
    }
}


#pragma mark - Share Button And Share Delegate

-(void)shareButton:(UIButton *)sender {
    
    NSLog(@"share button pressed");
    
    NSString *selectedText = [theTextPagedView selectedText];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [self createImageWithText:selectedText];
    photo.userGenerated = YES;
    
    photoContent.photos = @[photo];
    
    NSString *selectedTextId = [theTextPagedView selectedTextId];
    NSString *selectedImageId = [theImagePagedView selectedImageId];
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SHARE withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SHARE withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
    
    [FBSDKShareDialog showFromViewController:self withContent:photoContent delegate:nil];
    
}

-(void)textFacebookShareCompatible:(BOOL)shareCompatibility {
    
    NSLog(@"share delegate called");
    
    if (shareCompatibility) {
        [UIView animateWithDuration:0.3 animations:^{
            shareButton.alpha = 1.0f;
        }];
    }
    else {
        
        [UIView animateWithDuration:0.3 animations:^{
            shareButton.alpha = 0.0f;
        }];
    }
}

#pragma mark - Create Image 

-(UIImage*)createImageWithText:(NSString*)theText {
    
    UIImage *selectedImage = [theImagePagedView selectedImage];
    
    
    //
    NSString *selectedTextId = [theTextPagedView selectedTextId];
    NSString *selectedImageId = [theImagePagedView selectedImageId];
    
    [FBAppEvents logEvent:selectedTextId];
    //[FBAppEvents logEvent:selectedImageId];
    
    
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


#pragma mark - Text Paged View Data Source

-(NSArray*)updateTextsScrollViewTexts {
    return [model randomtTextWithNum:numberOfTextsToLoad];
}

#pragma mark - Image Paged View Data Source

-(NSArray*)updateImageScrollViewImages {
    return [model randomImagesWithNum:numberOfImagesToLoad];
}

#pragma mark Prepare for Segue and Controller Animations

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    NavigationSlideAnimator *slideAnimator = [[NavigationSlideAnimator alloc] initWithTransitionDuration:0.3];
    
    NSLog(@"presented controller");
    
    return slideAnimator;
    
}

-(id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NavigationSlideAnimator *slideAnimator = [[NavigationSlideAnimator alloc] initWithTransitionDuration:0.3];
    
    NSLog(@"dismiss controller");
    
    [self updateViewData];
    
    return slideAnimator;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginSegue"]) {
        UIViewController *destinationVC = (UIViewController*)[segue destinationViewController];
        
        destinationVC.transitioningDelegate = self;
        destinationVC.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
