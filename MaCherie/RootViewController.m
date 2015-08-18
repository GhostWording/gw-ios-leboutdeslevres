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
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImage+RenderViewToImage.h"
#import "UIView+RenderViewToImage.h"
#import "NSString+TextHeight.h"
#import "TimeOutManager.h"
#import "NavigationSlideAnimator.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "ServerComm.h"
#import "SpecialOccasionView.h"
#import "TextFilter.h"
#import "BoxedActivityIndicatorView.h"
#import "GWIntention.h"

const float bottomHeight = 60.0f;
const int numberOfImagesToLoad = 10;
const int numberOfTextsToLoad = 10;

@interface RootViewController () <UIAlertViewDelegate, TextScrollViewDelegate, TextScrollViewDataSource, ImageScrollViewDataSource, ImageScrollViewDelegate, UIViewControllerTransitioningDelegate>
{
    TextScrollView *theTextPagedView;
    ImageScrollView *theImagePagedView;
    SpecialOccasionView *theSpecialOccasionView;
    BoxedActivityIndicatorView *loadingIndicatorView;
    UIView *specialOccasionContainerView;
    UILabel *firstLabel;
    UIView *firstLaunView;
    UIView *newView;
    UIView *editTextView;
    UIView *tmpView;
    
    UIButton *dismissEditViewButton;
    UIButton *dismissKeyboardButton;
    UITextView *textView;
    
    UILabel *specialIntentionLabel;
    UIButton *normalSendButton;
    UIButton *editButton;
    UIButton *editedTextSendButton;
    UIButton *shareButton;
    UIButton *specialOccasionButton;
    FBSDKSharePhotoContent *photoContent;
    
    UIAlertView *alert;
    
    RootViewModel *model;
    ServerComm *serverComm;
    BOOL isShowingRatingView;
    BOOL isShowingPulse;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    editTextView = nil;
    theSpecialOccasionView = nil;
    isShowingPulse = NO;
    
    DataManager *dataMan = [[DataManager alloc] init];
    serverComm = [[ServerComm alloc] init];
    model = [[RootViewModel alloc] init];
    
    NSArray *randomText = [model randomtTextWithNum:numberOfTextsToLoad];
    
    theImagePagedView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20) andImages:nil];
    theImagePagedView.imageScrollViewDataSource = self;
    theImagePagedView.imageScrollViewDelegate = self;
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
    
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 40, CGRectGetMaxY(theImagePagedView.frame) + 3, 30, 30);
    //editButton.frame = CGRectMake(10, CGRectGetMaxY(theTextPagedView.frame) + 4, 38, 38);
    [editButton setImage:[UIImage imageNamed:@"editButton.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"editButtonSelected.png"] forState:UIControlStateHighlighted];
    [editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    
    normalSendButton = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
    normalSendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 60, CGRectGetMaxY(theTextPagedView.frame) + 3, 120, 40);
    //normalSendButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    //normalSendButton.layer.cornerRadius = 4.0;
    normalSendButton.titleLabel.font = [UIFont helveticaNeueWithSize:17];
    [normalSendButton setTitle:@"Envoi" forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [normalSendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalSendButton];
    
    UIImageView *messengerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messengerIconAlpha.png"]];
    messengerIcon.frame = CGRectMake(8, 11, 20, 20);
    //[normalSendButton addSubview:messengerIcon];
    
    UIImageView *messengerIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messengerIconAlpha.png"]];
    messengerIcon2.frame = CGRectMake(CGRectGetWidth(normalSendButton.frame)  - 28, 11, 20, 20);
    //[normalSendButton addSubview:messengerIcon2];
    
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
    
    
    specialOccasionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    specialOccasionButton.frame = CGRectMake(10, CGRectGetMinY(normalSendButton.frame) + 3, 60, 40);
    [specialOccasionButton setImage:[UIImage imageNamed:@"fire.png"] forState:UIControlStateNormal];
    [specialOccasionButton setImage:[UIImage imageNamed:@"arrowBackButtonRed.png"] forState:UIControlStateSelected];
    [specialOccasionButton addTarget:self action:@selector(createSpecialOccasionView) forControlEvents:UIControlEventTouchUpInside];
    specialOccasionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:specialOccasionButton];
    
    specialIntentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, CGRectGetMaxY(theTextPagedView.pageControl.frame) + CGRectGetMaxY(theImagePagedView.frame), CGRectGetWidth(self.view.frame) * 0.8, 10)];
    specialIntentionLabel.font = [UIFont helveticaNeueWithSize:12];
    specialIntentionLabel.textAlignment = NSTextAlignmentCenter;
    specialIntentionLabel.textColor = [UIColor lightGrayColor];
    specialIntentionLabel.alpha = 0.0f;
    [self.view addSubview:specialIntentionLabel];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    
    UserDefaults *defaults = [[UserDefaults alloc] init];
    
    NSLog(@"is first launch: %@", [UserDefaults firstLaunchOfApp]);
    NSLog(@"number of texts are: %ld", (long)[dataMan numTexts]);
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        
        if (![self setGenderBasedOnFacebookData]) {
            
            [self createFirstLaunView];
            
        }
        else {
            [self dismissFirstLaunchView];
        }
    }
    
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && ([[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults timeSpentInApp] intValue] < 90)) {
        [specialOccasionButton setHidden:YES];
        
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewDataWhenAppBecomesActive)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [self performSelector:@selector(showPulseIfTimePassed) withObject:nil afterDelay:1.0];
}

-(void)showPulseIfTimePassed {
    if ([[UserDefaults timeSpentInApp] intValue] >= 90) {
        NSLog(@"showPulse");
        specialOccasionButton.hidden = NO;
        [self showPulseIfAppropriate];
    }
    else if ([[UserDefaults timeSpentInApp] intValue] < 90) {
        NSLog(@"pulse not ready to be shown");
        [self performSelector:@selector(showPulseIfTimePassed) withObject:nil afterDelay:1.0];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    if (model.isShowingRatingView) {
        if(buttonIndex != [alertView cancelButtonIndex]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=992242564&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
        
        [UserDefaults hasRatedApp:[NSNumber numberWithBool:YES]];
    }
    
    model.isShowingRatingView = NO;
    
    NSLog(@"cancel");
}

-(void)updateViewData {
    
    NSLog(@"update view Data");
    
    [theTextPagedView reloadDataAnimated:YES];
    [theImagePagedView reloadDataAnimated:YES];
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        // make the text scroll view shake after a certain time if the user hasn't interacted with it
        // handled automatically by the text scroll view
        [theTextPagedView shakeAnimateScrollViewAftertime:10.0];
        [theImagePagedView shakeAnimateScrollViewAfterTime:24.0];
        [UserDefaults setDateInstalled:[NSDate date]];
        [UserDefaults setFirstLaunchOfApp:NO];
    }
    
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
    
    [self showViewDataWhenAppBecomesActive];
    [self showRatingViewIfAppropriate];
    
}

-(void)showViewDataWhenAppBecomesActive {
    [UIView animateWithDuration:0.3 animations:^{
        editButton.alpha = 1.0f;
    }];
    
    [[GoogleAnalyticsCommunication sharedInstance] setScreenName:GA_SCREEN_MAIN];
    [[CustomAnalytics sharedInstance] postActionWithType:@"init" actionLocation:GA_SCREEN_MAIN targetType:@"init" targetId:@"init" targetParameter:@""];
    
    [[TimeOutManager shareTimeOutManager] startTime];
    [self updateViewData];
    
    [self showPulseIfAppropriate];
}

-(void)showPulseIfAppropriate {
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && !([[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults timeSpentInApp] intValue] < 90) && !isShowingPulse) {
        
        NSLog(@"show pulse if appropriate");
        
        CAShapeLayer *shape = [CAShapeLayer layer];
        //shape.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(specialOccasionButton.frame), CGRectGetMidY(specialOccasionButton.frame)) radius:50 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        shape.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(25, 25) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
        shape.backgroundColor = [UIColor clearColor].CGColor;
        shape.fillColor = [UIColor clearColor].CGColor;
        shape.strokeColor = [UIColor appBlueColor].CGColor;
        shape.lineWidth = 3.0f;
        shape.anchorPoint = CGPointMake(.5, .5);
        
        
        CABasicAnimation *basicAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        basicAnim.duration = 1.0;
        basicAnim.repeatCount = 100000;
        basicAnim.autoreverses = YES;
        //basicAnim.removedOnCompletion = YES;
        basicAnim.toValue = @1.2;
        basicAnim.fromValue = @1.0;
        basicAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [tmpView removeFromSuperview];
        tmpView = nil;
        
        tmpView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(specialOccasionButton.frame) - 25, CGRectGetMidY(specialOccasionButton.frame) - 25, 50, 50)];
        tmpView.backgroundColor = [UIColor clearColor];
        tmpView.tag = 100;
        tmpView.userInteractionEnabled = NO;
        [tmpView.layer addSublayer:shape];
        [tmpView.layer addAnimation:basicAnim forKey:@"pulse"];
        [self.view addSubview:tmpView];
        
    }
}

#pragma mark - Rating View

-(void)showRatingViewIfAppropriate {
    
    NSLog(@"showing rating view if appropriate");
    
    NSLog(@"number sent messages and share: %d", [[UserDefaults numberOfFacebookShares] intValue] + [[UserDefaults numberOfMessagesSent] intValue] );
    NSLog(@"time interval: %f", [[UserDefaults dateInstalled] timeIntervalSinceNow]);
    NSLog(@"date installed: %@", [UserDefaults dateInstalled]);
    if (model.isShowingRatingView == NO && ([[UserDefaults numberOfFacebookShares] intValue] + [[UserDefaults numberOfMessagesSent] intValue]) >= 2 && [[UserDefaults hasRatedApp] boolValue] == NO && [[UserDefaults dateInstalled] timeIntervalSinceNow] *(-1) >= 72 * 60 * 60 ) {
        
        NSLog(@"performing selector to show rating window");
        [self performSelector:@selector(showRatingWindowAfterDelay) withObject:nil afterDelay:1.5];
    }
        
}

-(void)showRatingWindowAfterDelay {
    
    NSLog(@"showing rating window after delay");
    model.isShowingRatingView = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Merci ?" message:@"Pourriez-vous svp trouver quelques instants pour noter l'application ?" delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Oui", nil];
    [alertView show];
    
    /*
    if ([UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Rate our app" message:@"We would really appreciate if you would rate our app on the app store!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            model.isShowingRatingView = NO;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=992242564&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            model.isShowingRatingView = NO;
        }]];
        
        [self presentViewController:alertController animated:YES completion:^{
            [UserDefaults hasRatedApp:[NSNumber numberWithBool:YES]];
        }];
    }
    else {
        
    }
    */
}

-(BOOL)setGenderBasedOnFacebookData {
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 if ([result valueForKey:@"gender"] != nil) {
                     NSString *theGender = (NSString*)[result valueForKey:@"gender"];
                     if ([theGender isEqualToString:@"male"]) {
                         NSLog(@"gender is male");
                         [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderMale]];
                         
                         [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_MALE wtihValue:nil];
                         [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"H"];
                         
                     }
                     else if([theGender isEqualToString:@"female"]) {
                         NSLog(@"gender is female");
                         [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderFemale]];
                         
                         [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_FEMALE wtihValue:nil];
                         [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"F"];
                         
                     }
                     else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self createFirstLaunView];
                             firstLaunView.alpha = 0.0f;
                             
                             [UIView animateWithDuration:0.3 animations:^{
                                 firstLaunView.alpha = 1.0f;
                             }];
                             
                         });
                     }
                 }
             }
         }];
        
        return YES;
    }
    
    return NO;
}

-(void)createFirstLaunView {
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
    
    // have to add a button to skip the registration as apple says
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 80, CGRectGetMaxY(femaleLabel.frame) + 40, 160, 40);
    [skipButton setTitle:@"Ignorer" forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor appBlueColor] forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [skipButton addTarget:self action:@selector(ignoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:skipButton];
}

-(void)login:(id)sender
{
    [[TimeOutManager shareTimeOutManager] restartTime];
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
    NSLog(@"login segue");
}

#pragma mark - Edit Text View

-(void)editButtonPressed {
    [self createEditTextView:[theTextPagedView selectedText]];
}

-(void)createEditTextView:(NSString*)editText {
    NSLog(@"created edit text view");
    
    [[TimeOutManager shareTimeOutManager] pauseTime];
    
    if (!editTextView && [theImagePagedView selectedImage] != nil) {
        editTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        editTextView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 40, 25, 20, 20);
        [cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
        //[cancelButton addTarget:self action:@selector(dismissEditTextView) forControlEvents:UIControlEventTouchUpInside];
        [editTextView addSubview:cancelButton];
        
        UIView *cancelButtonTapArea = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(cancelButton.frame) - 20, CGRectGetMinY(cancelButton.frame) - 20, CGRectGetWidth(cancelButton.frame) + 40, CGRectGetHeight(cancelButton.frame) + 40)];
        cancelButtonTapArea.backgroundColor = [UIColor clearColor];
        [editTextView addSubview:cancelButtonTapArea];
        
        UITapGestureRecognizer *cancelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissEditTextView)];
        [cancelButtonTapArea addGestureRecognizer:cancelTapGesture];
        
         
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.05, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(self.view.frame) * 0.9, CGRectGetHeight(self.view.frame) * 0.7)];
        textView.font = [UIFont noteworthyBoldWithSize:17.0f];
        textView.text = editText;
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
        //[editedTextSendButton addSubview:editMessengerIcon];
        
        UIImageView *editMessengerIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messengerIconAlpha.png"]];
        editMessengerIcon2.frame = CGRectMake(CGRectGetWidth(editedTextSendButton.frame)  - 28, 11, 20, 20);
        //[editedTextSendButton addSubview:editMessengerIcon2];
        
        [editTextView addSubview:textView];
        editTextView.alpha = 0.0f;
        [self.view addSubview:editTextView];
        
        [UIView animateWithDuration:0.3 animations:^{
            editTextView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [textView becomeFirstResponder];
        }];
        
    }
}

-(void)dismissEditTextView {
    NSLog(@"dismiss text");
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

#pragma mark - Special Occasion Views

-(void)createSpecialOccasionView {
    
    if ([self.view viewWithTag:100] != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view viewWithTag:100].alpha = 0.0f;
        }];
    }
    
    if (!specialOccasionButton.isSelected) {
        
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_SPECIAL_INTENTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"ShowSpecialIntention" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"showSpecialIntention" targetParameter:@""];
        
        
        specialOccasionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        specialOccasionContainerView.backgroundColor = [UIColor appLightOverlayColor];
        [self.view addSubview:specialOccasionContainerView];
        
        //UITapGestureRecognizer *specialOccasionDismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSpecialOccasionView)];
        //[specialOccasionContainerView addGestureRecognizer:specialOccasionDismissTapGesture];
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = CGRectMake(CGRectGetWidth(specialOccasionContainerView.frame) - 120, 0, 100, 60);
        dismissButton.contentMode = UIViewContentModeRight;
        [dismissButton setTitle:@"Annuler" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [dismissButton setTitleColor:[UIColor clearColor] forState:UIControlStateSelected];
        [dismissButton addTarget:self action:@selector(dismissSpecialOccasionView) forControlEvents:UIControlEventTouchUpInside];
        [specialOccasionContainerView addSubview:dismissButton];
        
        theSpecialOccasionView = [[SpecialOccasionView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 0.1, CGRectGetHeight(self.view.frame) * 0.15, CGRectGetWidth(self.view.frame) * 0.8, CGRectGetHeight(self.view.frame) * 0.7)];
        [specialOccasionContainerView addSubview:theSpecialOccasionView];
        
        
        [theSpecialOccasionView selectedIntentionAndRecipient:^(GWIntention *intentionObject, RecipientObject *recipientObject) {
            
            specialIntentionLabel.text = intentionObject.label;
            [UIView animateWithDuration:0.3 animations:^{
                specialIntentionLabel.alpha = 1.0f;
            }];
            
            __weak typeof(self) wSelf = self;
            [wSelf dismissSpecialOccasionView];
            [wSelf showLoadingIndicator];
            
            // images loading
            if (intentionObject && recipientObject) {
                model.isSpecialOccasionIntentionChosen = YES;
                NSLog(@"fetchedImages");
                [model fetchImagesForIntention:intentionObject.imagePath withCompletion:^(NSArray *theImages, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"the images for the special intentions are: %d", (int)theImages.count);
                        [model setRandomImageForCurrentIntention:theImages withNum:(int)theImages.count];
                        [theImagePagedView reloadDataAnimated:YES];
                        
                        [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
                            
                        }];
                        
                    });
                }];
            }
            
            
            /////////////////////////////////////////////
            ///////////// TEXT HANDLING /////////////////
            /*
            if (intentionObject && !recipientObject) {
                model.isSpecialOccasionIntentionChosen = YES;
                [specialOccasionButton setSelected:YES];
                
                
                [model fetchTextsForIntention:intentionObject.intentionSlug withCompletion:^(NSArray *theTexts, NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [model setRandomTextForIntention:intentionObject.intentionSlug withNum:numberOfTextsToLoad];
                        [theTextPagedView reloadDataAnimated:YES];
                    });
                        
                }];
                
                
            }
            else */
            if(intentionObject && recipientObject) {
                
                model.isSpecialOccasionIntentionChosen = YES;
                [specialOccasionButton setSelected:YES];
                
                [model fetchTextsForIntention:intentionObject.slugPrototypeLink withCompletion:^(NSArray *theTexts, NSError *error) {
                    
                    if (!error) {
                        
                        [model setRandomTextForSpecialOccasionTexts:theTexts];
                        [theTextPagedView reloadDataAnimated:YES];
                    }
                    else {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [alertView show];
                        
                        model.isSpecialOccasionIntentionChosen = NO;
                        [specialOccasionButton setSelected:NO];
                        [theTextPagedView reloadDataAnimated:YES];
                        NSLog(@"Error");
                    }
                    
                }];
            }
        }];
    }
    else {
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_SPECIAL_INTENTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"HideSpecialIntention" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"hideSpecialOccasionButton" targetParameter:@""];
        
        [UIView animateWithDuration:0.3 animations:^{
            specialIntentionLabel.alpha = 0.0f;
        }];
        
        [self fadeOutLoadingIndicator];
        
        [specialOccasionButton setSelected: NO];
        model.isSpecialOccasionIntentionChosen = NO;
        [theTextPagedView reloadDataAnimated:YES];
        [theImagePagedView reloadDataAnimated:YES];
    }
    
    [UserDefaults setHasPressedIntentionButton:YES];
}

-(void)showLoadingIndicator {
    NSLog(@"show loading indicator");
    [loadingIndicatorView removeFromSuperview];
    loadingIndicatorView = nil;
    
    loadingIndicatorView = [[BoxedActivityIndicatorView alloc] init];
    [loadingIndicatorView setFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.2, CGRectGetHeight(self.view.frame)/2.0 - CGRectGetWidth(self.view.frame)*0.3, CGRectGetWidth(self.view.frame)*0.6, CGRectGetWidth(self.view.frame)*0.6)];
    loadingIndicatorView.activityLabel.text = @"Télechargement en cours...";
    loadingIndicatorView.activityLabel.textColor = [UIColor whiteColor];
    loadingIndicatorView.activityLabel.textAlignment = NSTextAlignmentCenter;
    loadingIndicatorView.alpha = 0.0f;
    loadingIndicatorView.activityLabel.numberOfLines = 0;
    [self.view addSubview:loadingIndicatorView];
    
    [loadingIndicatorView fadeInWithCompletion:^(BOOL completed) {
        
    }];
}

-(void)fadeOutLoadingIndicator {
    
    [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
        
    }];
    
}

-(void)dismissSpecialOccasionView {
    //[specialOccasionContainerView removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        specialOccasionContainerView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [specialOccasionContainerView removeFromSuperview];
        
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

-(void)ignoreButtonPressed:(UIButton*)button {
    [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderNone]];
    [self performSelector:@selector(dismissFirstLaunchView) withObject:nil afterDelay:0.3];
}

#pragma mark - First Time Launch View

-(void)dismissFirstLaunchView {
    
    
    if ([model minimumImagesAndTextsToDownloadWithNumTexts:100 withNumImages:5]) {
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
            NSLog(@"completion run");
            [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
        }];
    }
}

-(void)isSufficientResourcesDownloaded {

    if ([model minimumImagesAndTextsToDownloadWithNumTexts:100 withNumImages:5]) {
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
    [UserDefaults incrementNumberOfMessagesSent];
    [self showRatingViewIfAppropriate];
    
    [[TimeOutManager shareTimeOutManager] restartTime];
    
    if ([theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        NSLog(@"is last page: %d", [theTextPagedView isLastPage]);
        if (([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) && ![theTextPagedView isLastPage]) {
            
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
                
                [[CustomAnalytics sharedInstance] postActionWithType:@"Send" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:selectedTextId targetParameter:@""];
                [[CustomAnalytics sharedInstance] postActionWithType:@"Send" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:selectedImageId targetParameter:@""];
                
            }
            else if([sender isEqual:editedTextSendButton]) {
                selectedText = textView.text;
                
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
                
                [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSend" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:selectedTextId targetParameter:@""];
                [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSend" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:selectedImageId targetParameter:@""];
            }
            
            UIImage *snapshotImage = [self createImageWithText:selectedText];
            
            
            [FBSDKMessengerSharer shareImage:snapshotImage withOptions:nil];
        }
        else {
            // Messenger isn't installed. Redirect the person to the App Store.
            NSString *appStoreLink = @"https://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
    }
    else if([theTextPagedView isLastPage]) {
        
        if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
            
            if ([sender isEqual:editedTextSendButton]) {
                NSString *selectedText = textView.text;
                
                if (textView != nil) {
                    selectedText = textView.text;
                }
                
                UIImage *snapshotImage = [self createImageWithText:selectedText];
                
                [FBSDKMessengerSharer shareImage:snapshotImage withOptions:nil];
                
            }
            else {
                [self sendOnlyImage];
            }
            
        }
        else {
            // Messenger isn't installed. Redirect the person to the App Store.
            NSString *appStoreLink = @"https://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        }
    }
}


#pragma mark - Share Button

-(void)shareButton:(UIButton *)sender {
    
    NSLog(@"share button pressed");
    
    [UserDefaults incrementNumberOfFacebookShares];
    [self showRatingViewIfAppropriate];
    
    NSString *selectedText = [theTextPagedView selectedText];
    
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = [self createImageWithText:selectedText];
    photo.userGenerated = YES;
    
    photoContent.photos = @[photo];
    
    NSString *selectedTextId = [theTextPagedView selectedTextId];
    NSString *selectedImageId = [theImagePagedView selectedImageId];
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SHARE withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SHARE withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
    
    [[CustomAnalytics sharedInstance] postActionWithType:@"FacebookShare" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:selectedTextId targetParameter:@""];
    [[CustomAnalytics sharedInstance] postActionWithType:@"FacebookShare" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:selectedImageId targetParameter:@""];
    
    [FBSDKShareDialog showFromViewController:self withContent:photoContent delegate:nil];
    
}

#pragma mark - Text Scroll View Delegate

-(void)textFacebookShareCompatible:(BOOL)shareCompatibility {
    
    NSLog(@"share compatibility is: %d", shareCompatibility);
    
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

-(void)scrolledToIndex:(int)index {
    
    
    if ([theTextPagedView isLastPage]) {
        [UIView animateWithDuration:0.3 animations:^{
            NSLog(@"edit button is zero");
            editButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            editButton.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)sendOnlyImage {
    
    UIImage *selectedImage = [theImagePagedView selectedImage];
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        if (selectedImage != nil) {
            NSString *imageId = [theImagePagedView selectedImageId];
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_ONLY_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:imageId wtihValue:nil];
            [[CustomAnalytics sharedInstance] postActionWithType:@"SendImageOnly" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:imageId targetParameter:@""];
            
            [FBSDKMessengerSharer shareImage:selectedImage withOptions:nil];
        }
    }
    else {
        NSString *appStoreLink = @"https://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
    }
    
    
}

-(void)writeText {
    
    NSString *imageId = [theImagePagedView selectedImageId];

    if (imageId != nil) {
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_CREATED withAction:GA_ACTION_BUTTON_PRESSED withLabel:imageId wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_CATEGORY_TEXT_CREATED actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:imageId targetParameter:@""];
        
        [self createEditTextView:@""];

    }
}

-(void)refreshButtonPressed {
    [UserDefaults increaseNumberOfTextRefreshes];
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
    
    [UIView animateWithDuration:0.3 animations:^{
        NSLog(@"edit button alpha");
        editButton.alpha = 1.0;
    }];
    
    [UserDefaults increaseNumberOfTextRefreshes];
    
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && ([[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults timeSpentInApp] intValue] < 90)) {
        [specialOccasionButton setHidden:YES];
    }
    else {
        [specialOccasionButton setHidden:NO];
        [self showPulseIfAppropriate];
    }
    
    if (model.isSpecialOccasionIntentionChosen) {
        
        if ([model specialOccasionTexts].count == 0) {
            UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Zéro texte disponible pour ce destinataire et cette intention" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [tmpAlert show];
            
            model.isSpecialOccasionIntentionChosen = NO;
            return [model randomtTextWithNum:numberOfTextsToLoad];
        }
        
        return [model specialOccasionTexts];
    }
    
    return [model randomtTextWithNum:numberOfTextsToLoad];
}

#pragma mark - Image Paged View Data Source

-(NSArray*)updateImageScrollViewImages {
    //return [model randomImagesWithNum:numberOfImagesToLoad];
    if (model.isSpecialOccasionIntentionChosen) {
        return [model specialOccasionImages];
    }
    
    
    return [model randomImagesWithImagesBasedOnTexts:[theTextPagedView theTexts] WithNum:numberOfImagesToLoad];
}

#pragma mark - Image Paged View Delegate

-(void)refreshImagesPressedWithImageScrollView:(ImageScrollView *)theScrollView {
    
    [UserDefaults increaseNumberOfImageRefreshesByUser];
    
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && ([[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults timeSpentInApp] intValue] < 90)) {
        [specialOccasionButton setHidden:YES];
    }
    else {
        [specialOccasionButton setHidden:NO];
        [self showPulseIfAppropriate];
    }
    
    if (model.isSpecialOccasionIntentionChosen) {
        GWIntention *selectedOCcasionIntention = [theSpecialOccasionView selectedIntention];
        [self showLoadingIndicator];

        if (!model.isLoadingImages) {
            model.isLoadingImages = YES;
            
            NSLog(@"selected intention path: %@", selectedOCcasionIntention.imagePath);
            [model fetchImagesForIntention:selectedOCcasionIntention.imagePath withCompletion:^(NSArray *theImages, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.isLoadingImages = NO;
                    NSLog(@"the number of images are: %d", (int)theImages.count);
                    [model setRandomImageForCurrentIntention:theImages withNum:(int)theImages.count];
                    [theScrollView reloadDataAnimated:YES];
                    [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
                        
                    }];
                });
            }];
        }
        
    }
    else {
        [theScrollView reloadDataAnimated:YES];
    }
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
