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
#import "RootViewModel.h"
#import "UserDefaults.h"
#import "DefaultButton.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "UIViewController+Extension.h"
#import "AppDelegate.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImage+RenderViewToImage.h"
#import "UIView+RenderViewToImage.h"
#import "NSString+TextHeight.h"
#import "NavigationSlideAnimator.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "SpecialOccasionView.h"
#import "TextFilter.h"
#import "BoxedActivityIndicatorView.h"
#import "GWIntention.h"
#import "ConstantsManager.h"
#import "LBDLocalization.h"
#import "Chameleon.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "BlocksAlertView.h"
#import "NewFeatureView.h"
#import "MoodModeViewController.h"
#import "IntentionModeViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>


const float bottomHeight = 60.0f;
const int numberOfImagesToLoad = 10;
const int numberOfTextsToLoad = 10;

@interface RootViewController () <UIAlertViewDelegate, TextScrollViewDelegate, TextScrollViewDataSource, ImageScrollViewDataSource, ImageScrollViewDelegate, UIViewControllerTransitioningDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FBSDKSharingDelegate>
{
    UIImagePickerController *imagePicker;
    
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
    UIView *settingsPulse;
    UIView *chooseSendMethodView;
    UIView *chooseEditMethodView;
    
    UIButton *dismissEditViewButton;
    UIButton *dismissKeyboardButton;
    UITextView *textView;
    
    UILabel *specialIntentionLabel;
    UIButton *normalSendButton;
    UIButton *editButton;
    UIButton *editedTextSendButton;
    UIButton *shareButton;
    UIButton *specialOccasionButton;
    UIButton *buttonUsedToSend;
    UIButton *addPhotoCameraButton, *addPhotoRollButton;
    UIButton *_settingsButton;
    FBSDKSharePhotoContent *photoContent;
    
    UIAlertView *alert;
    UIAlertView *languageChangeAlert;
    
    RootViewModel *model;
    BOOL isShowingRatingView;
    
    float timeSinceLastAlert;
    int _numRefreshesPressed;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    editTextView = nil;
    theSpecialOccasionView = nil;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    imagePicker = [[UIImagePickerController alloc] init];
    model = [[RootViewModel alloc] init];
    
    imagePicker.delegate = self;
    
    theImagePagedView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20) andImages:nil];
    theImagePagedView.imageScrollViewDataSource = self;
    theImagePagedView.imageScrollViewDelegate = self;
    [self.view addSubview:theImagePagedView];
    
    
    theTextPagedView = [[TextScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(theImagePagedView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 - bottomHeight - 20) andTexts:nil];
    theTextPagedView.shareDelegate = self;
    theTextPagedView.textScrollViewDataSource = self;
    [self.view addSubview:theTextPagedView];
    
    
    _settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 50, 50)];
    _settingsButton.layer.backgroundColor = [UIColor clearColor].CGColor;
    _settingsButton.layer.cornerRadius = 4.0;
    _settingsButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [_settingsButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [_settingsButton addTarget:self action:@selector(settingsSegue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settingsButton];
    
    addPhotoCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoCameraButton.frame = CGRectMake(CGRectGetWidth(theImagePagedView.frame) - 55, 20, 50, 50);
    addPhotoCameraButton.layer.backgroundColor = [UIColor clearColor].CGColor;
    addPhotoCameraButton.layer.cornerRadius = 4.0;
    addPhotoCameraButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [addPhotoCameraButton setImage:[UIImage imageNamed:@"cameraIcon.png"] forState:UIControlStateNormal];
    [addPhotoCameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addPhotoCameraButton];
    
    addPhotoRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoRollButton.frame = CGRectMake(CGRectGetWidth(theImagePagedView.frame) - 55, CGRectGetMaxY(addPhotoCameraButton.frame) + 10, 50, 50);
    addPhotoRollButton.layer.backgroundColor = [UIColor clearColor].CGColor;
    addPhotoRollButton.layer.cornerRadius = 4.0;
    addPhotoRollButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [addPhotoRollButton setImage:[UIImage imageNamed:@"photoIcon.png"] forState:UIControlStateNormal];
    [addPhotoRollButton addTarget:self action:@selector(cameraRollButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [theImagePagedView addSubview:addPhotoRollButton];
    
        
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 55, CGRectGetMaxY(theImagePagedView.frame) - 5, 40, 40);
    editButton.layer.backgroundColor = [UIColor flatOrangeColor].CGColor;
    editButton.layer.cornerRadius = editButton.frame.size.width / 2.0;
    [editButton setImage:[UIImage imageNamed:@"createNewTextIcon.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(buttonAlphaPressed:) forControlEvents:UIControlEventTouchDown];
    [editButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpOutside];
    [editButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    editButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    editButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:editButton];
    
    
    normalSendButton = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
    normalSendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 60, CGRectGetMaxY(theTextPagedView.frame) + 3, 120, 40);
    normalSendButton.titleLabel.font = [UIFont helveticaNeueWithSize:17];
    [normalSendButton setTitle:LBDLocalizedString(@"<LBDLSendMessage>", nil) forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [normalSendButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [normalSendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalSendButton];
    
    
    photoContent = [[FBSDKSharePhotoContent alloc] init];

    if ([theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = [self createImageWithText:[theTextPagedView selectedText]];
        photo.userGenerated = YES;
        
        photoContent.photos = @[photo];
    }
    
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 72, CGRectGetMidY(normalSendButton.frame) - 28, 80, 50);
    [shareButton setImage:[UIImage imageNamed:@"shareIcon.png"] forState:UIControlStateNormal];
    
    shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    shareButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [shareButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(shareExtensionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    
    specialOccasionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    specialOccasionButton.frame = CGRectMake(5, CGRectGetMidY(normalSendButton.frame) - 25, 60, 50);
    [specialOccasionButton setImage:[UIImage imageNamed:@"listIcon4.png"] forState:UIControlStateNormal];
    [specialOccasionButton setImage:[UIImage imageNamed:@"arrowBackButtonRed.png"] forState:UIControlStateSelected];
    [specialOccasionButton addTarget:self action:@selector(createSpecialOccasionView) forControlEvents:UIControlEventTouchUpInside];
    specialOccasionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:specialOccasionButton];
    
    specialIntentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, CGRectGetMaxY(theTextPagedView.pageControl.frame) + CGRectGetMaxY(theImagePagedView.frame) + 1, CGRectGetWidth(self.view.frame) * 0.8, 16)];
    specialIntentionLabel.font = [UIFont helveticaNeueWithSize:14];
    specialIntentionLabel.textAlignment = NSTextAlignmentCenter;
    specialIntentionLabel.textColor = [UIColor lightGrayColor];
    specialIntentionLabel.alpha = 0.0f;
    [self.view addSubview:specialIntentionLabel];
    
    
    timeSinceLastAlert = [[UserDefaults lastTimeAskedForNotificationPermission] timeIntervalSinceNow];
    NSLog(@"timeSinceLastAlert: %f", timeSinceLastAlert);
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    
    __weak typeof (self) wSelf = self;
    
    [theTextPagedView intentionChosenWithCompletion:^(GWIntention *theIntention) {
        
        // nil is returned when going into normal mode
        if (theIntention == nil) {
            model.isSpecialOccasionIntentionChosen = NO;
            [specialOccasionButton setSelected:YES];
            [wSelf createSpecialOccasionView];
            return ;
        }
       
        [wSelf showLoadingIndicator];
        model.selectedSpecialOccasionIntention = theIntention;
        specialIntentionLabel.text = theIntention.label;
        
        [UIView animateWithDuration:0.3 animations:^{
            specialIntentionLabel.alpha = 1.0;
        }];
        
        model.isViewingTheme = NO;
        [wSelf downloadSpecialOccasionImagesWithIntention:theIntention];
        [wSelf downloadSpecialOccasionTextsWithIntention:theIntention];
        
        
    }];
    
    
    UserDefaults *defaults = [[UserDefaults alloc] init];
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        
        if (![self setGenderBasedOnFacebookData]) {
            
            [self createFirstLaunView];
         
        }
        else {
            [self dismissFirstLaunchView];
        }
        
        __weak typeof (self) wSelf = self;
        __block BOOL hasDownloadedTextOrImages = NO;
        [model downloadWelcomeTextsWithCompletion:^(NSArray *theTexts, NSError *theError) {
            if (hasDownloadedTextOrImages == YES) {
                [wSelf isSufficientResourcesDownloaded];
            }
            hasDownloadedTextOrImages = YES;
        }];
        
        [model downloadWelcomeImagesWithCompletion:^(NSArray *theImages, NSError *theError) {
            if (hasDownloadedTextOrImages == YES) {
                [wSelf isSufficientResourcesDownloaded];
            }
            hasDownloadedTextOrImages = YES;
        }];
        
        
        [theTextPagedView shakeAnimateScrollViewAftertime:7.0];
        [theImagePagedView shakeAnimateScrollViewAfterTime:7.0];
        
    }
    else {
        [self setGenderBasedOnFacebookData];
    }
    
    
    
    // MARK: Pop up windows
    if ([[UserDefaults timeSpentInApp] intValue] >= 90) {
        [self performSelector:@selector(showPulseIfAppropriate) withObject:nil afterDelay:0.2];
    }
    else {
        [self performSelector:@selector(showPulseIfAppropriate) withObject:nil afterDelay:90 - [[UserDefaults timeSpentInApp] intValue]];
    }
    
    if ([[UserDefaults timeSpentInApp] intValue] <= 60 * 5) {
        [self performSelector:@selector(showPulseForSettingsIfAppropriate) withObject:nil afterDelay:60 * 5 - [[UserDefaults timeSpentInApp] intValue]];
    }
    else {
        [self performSelector:@selector(showPulseForSettingsIfAppropriate) withObject:nil afterDelay:0.1];
    }
    
    if ([[UserDefaults firstLaunchOfApp] boolValue] == NO) {
        [self updateViewData];
    }
    
}

-(void)showNotificationAlert {
    
    
    if ([[UserDefaults acceptedNotifications] boolValue] == NO && [[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)] && timeSinceLastAlert < (-1) * 24 * 60 * 60) {
        
        BlocksAlertView *blockAlert = [[BlocksAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLAccessNotificationsTitle>", nil) message:LBDLocalizedString(@"<LBDLAccessNotificationsMessage>", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:LBDLocalizedString(@"<LBDLAccessNotificationsAccept>", nil), LBDLocalizedString(@"<LBDLAccessNotificationsCancel>", nil), nil];
        
        [blockAlert buttonPressedWithCompletion:^(int buttonIndex, UIAlertView *alert) {
            
            [UserDefaults setLastTimeAskedForNotificationPermission:[NSDate date]];
            
            
            if (buttonIndex == 0) {
                
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"UserNotificationDialogYes" wtihValue:nil];
                [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"UserNotificationDialogYes" targetParameter:@""];
                
                [UserDefaults setAcceptedNotifications:YES];
                [self notificationSystemPermission];
            }
            else {
                
                [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_APP_EVENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"UserNotificationDialogNo" wtihValue:nil];
                [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"UserNotificationDialogNo" targetParameter:@""];
                
            }
            
            
        }];
        
        [blockAlert show];
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (model.isShowingRatingView) {
        if(buttonIndex != [alertView cancelButtonIndex]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=992242564&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
        
        [UserDefaults hasRatedApp:[NSNumber numberWithBool:YES]];
    }
    
    model.isShowingRatingView = NO;
    
    if (alertView == languageChangeAlert) {
        
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            [self showLoadingIndicator];
            [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:0.5];
            
            [model downloadTextsForArea:[ConstantsManager sharedInstance].area withCompletion:^(NSArray *theTexts, NSError *error) {
                
            }];
        }
        
    }
}

-(void)updateViewLanguage {
    [normalSendButton setTitle:LBDLocalizedString(@"<LBDLSendMessage>", nil) forState:UIControlStateNormal];
    [shareButton setTitle:LBDLocalizedString(@"<LBDLFacebookShare>", nil) forState:UIControlStateNormal];
}

-(void)updateViewData {
    
    [theTextPagedView reloadDataAnimated:YES];
    [theImagePagedView reloadDataAnimated:YES];
    
    [self performSelector:@selector(setFirstLaunchParam) withObject:nil afterDelay:0.6];
}

-(void)setFirstLaunchParam {
    if ([[UserDefaults firstLaunchOfApp] boolValue] == YES) {
        
        [UserDefaults setDateInstalled:[NSDate date]];
        [UserDefaults setFirstLaunchOfApp:NO];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    // update the texts in case we have chosen a different gender and the texts need
    // to be re-filtered
    
    [UIView animateWithDuration:0.3 animations:^{
        editButton.alpha = 1.0f;
    }];
    
    [[GoogleAnalyticsCommunication sharedInstance] setScreenName:GA_SCREEN_MAIN];
    [[CustomAnalytics sharedInstance] postActionWithType:@"init" actionLocation:GA_SCREEN_MAIN targetType:@"init" targetId:@"init" targetParameter:@""];
}

-(void)showViewDataWhenAppBecomesActive {

    float idleTime = [[UserDefaults lastActiveDate] timeIntervalSinceNow];
    if (idleTime <= (-1) * 5 * 60) {
        if (model.isUserPhotosSelected == NO && [[UserDefaults firstLaunchOfApp] boolValue] == NO) {
            [self updateViewData];
        }
        
        [self showPulseIfAppropriate];
    }
    
    
}

-(void)showPulseForSettingsIfAppropriate {
    
    if ([[UserDefaults hasViewedSettings] boolValue] == NO) {
        
        CAShapeLayer *shape = [CAShapeLayer layer];
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
        
        [settingsPulse removeFromSuperview];
        settingsPulse = nil;
        
        settingsPulse = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(_settingsButton.frame) - 25, CGRectGetMidY(_settingsButton.frame) - 25, 50, 50)];
        settingsPulse.backgroundColor = [UIColor clearColor];
        settingsPulse.tag = 200;
        settingsPulse.userInteractionEnabled = NO;
        [settingsPulse.layer addSublayer:shape];
        [settingsPulse.layer addAnimation:basicAnim forKey:@"pulse"];
        [self.view addSubview:settingsPulse];
    }
}

-(void)showPulseIfAppropriate {
    
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && !([[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfImageRefreshesByUser] intValue] < 1) && specialOccasionButton.hidden == NO) {
        
        CAShapeLayer *shape = [CAShapeLayer layer];
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
    

    if (model.isShowingRatingView == NO && ([[UserDefaults numberOfFacebookShares] intValue] + [[UserDefaults numberOfMessagesSent] intValue]) >= 2 && [[UserDefaults hasRatedApp] boolValue] == NO ) {
        
        [self performSelector:@selector(showRatingWindowAfterDelay) withObject:nil afterDelay:1.5];
    }
        
}

-(void)showRatingWindowAfterDelay {
    
    model.isShowingRatingView = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLAlertThankYouTitle>", nil) message:LBDLocalizedString(@"<LBDLRatingMessage>", nil) delegate:self cancelButtonTitle:LBDLocalizedString(@"<LBDLNo>", nil) otherButtonTitles:LBDLocalizedString(@"<LBDLYes>", nil), nil];
    [alertView show];
    
}

-(BOOL)setGenderBasedOnFacebookData {
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields" : @"id, name, gender, age_range"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 
                 if ([result valueForKey:@"gender"] != nil) {
                     
                     NSString *theGender = (NSString*)[result valueForKey:@"gender"];
                     
                     if ([theGender isEqualToString:@"male"]) {
                         
                         [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderMale]];
                         
                         [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_MALE wtihValue:nil];
                         [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"H"];
                         
                     }
                     else if([theGender isEqualToString:@"female"]) {

                         [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderFemale]];
                         
                         [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_FEMALE wtihValue:nil];
                         [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"F"];
                         
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
    firstLaunView.backgroundColor = [UIColor appLightOverlayColor];
    [self.view addSubview:firstLaunView];
    
    UILabel *genderTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(firstLaunView.frame) * 0.3, CGRectGetWidth(firstLaunView.frame), 40)];
    genderTitleLabel.font = [UIFont noteworthyBoldWithSize:26.0f];
    genderTitleLabel.textColor = [UIColor appBlueColor];
    genderTitleLabel.text = LBDLocalizedString(@"<LBDLIAmGender>", nil);
    genderTitleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:genderTitleLabel];
    
    DefaultButton *maleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) - 90, CGRectGetMidY(firstLaunView.frame) - 30, 60, 60)];
    [maleButton setImage:[UIImage imageNamed:@"maleGender.png"] forState:UIControlStateNormal];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateSelected];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateHighlighted];
    [maleButton addTarget:self action:@selector(maleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:maleButton];
    
    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(maleButton.frame) - 40, CGRectGetMaxY(maleButton.frame) + 10, 80, 20)];
    maleLabel.font = [UIFont noteworthyBoldWithSize:17.0];
    maleLabel.text = LBDLocalizedString(@"<LBDLMale>", nil);
    maleLabel.textColor = [UIColor appBlueColor];
    maleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:maleLabel];
    
    DefaultButton *femaleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(firstLaunView.frame) + 30, CGRectGetMidY(firstLaunView.frame) - 30, 60, 60)];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGender.png"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateHighlighted];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateSelected];
    [femaleButton addTarget:self action:@selector(femaleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:femaleButton];
    
    UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(femaleButton.frame) - 40, CGRectGetMaxY(femaleButton.frame) + 10, 80, 20)];
    femaleLabel.font = [UIFont noteworthyBoldWithSize:17.0f];
    femaleLabel.text = LBDLocalizedString(@"<LBDLFemale>", nil);
    femaleLabel.textColor = [UIColor appBlueColor];
    femaleLabel.textAlignment = NSTextAlignmentCenter;
    [firstLaunView addSubview:femaleLabel];
    
    // have to add a button to skip the registration as apple says
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 80, CGRectGetMaxY(femaleLabel.frame) + 40, 160, 40);
    [skipButton setTitle:LBDLocalizedString(@"<LBDLIgnore>", nil) forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor appBlueColor] forState:UIControlStateNormal];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [skipButton addTarget:self action:@selector(ignoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [firstLaunView addSubview:skipButton];
}

-(void)settingsSegue:(id)sender
{
    [UserDefaults setHasViewedSettings:[NSNumber numberWithBool:YES]];
    [settingsPulse removeFromSuperview];
    [self performSegueWithIdentifier:@"settingsSegue" sender:self];
}

#pragma mark - Edit Text View

-(void)editButtonPressed {
    
    chooseEditMethodView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    chooseEditMethodView.backgroundColor = [UIColor appLightOverlayColor];
    chooseEditMethodView.alpha = 0.0f;
    [self.view addSubview:chooseEditMethodView];
    
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseEditMethodBackgroundPress:)];
    [chooseEditMethodView addGestureRecognizer:backgroundTap];
    
    [UIView animateWithDuration:0.3 animations:^{
        chooseEditMethodView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    
    UIButton *cancelChooseMethodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelChooseMethodButton.frame = CGRectMake(CGRectGetWidth(chooseEditMethodView.frame) / 4.0 * 3.0 - 80, CGRectGetHeight(chooseEditMethodView.frame) * 0.07, 160, 25);
    cancelChooseMethodButton.titleLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    [cancelChooseMethodButton setTitle:LBDLocalizedString(@"<LBDLCancel>", nil) forState:UIControlStateNormal];
    [cancelChooseMethodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelChooseMethodButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [cancelChooseMethodButton addTarget:self action:@selector(chooseEditMethodBackgroundPress:) forControlEvents:UIControlEventTouchUpInside];
    [chooseEditMethodView addSubview:cancelChooseMethodButton];
    
    UIButton *newTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newTextButton.frame = CGRectMake(CGRectGetWidth(chooseEditMethodView.frame) * 0.25 - 40, CGRectGetMidY(chooseEditMethodView.frame) - 40, 80, 80);
    [newTextButton setImage:[UIImage imageNamed:@"createNewTextIcon.png"] forState:UIControlStateNormal];
    newTextButton.adjustsImageWhenHighlighted = NO;
    newTextButton.layer.backgroundColor = [UIColor flatOrangeColor].CGColor;
    newTextButton.layer.cornerRadius = newTextButton.frame.size.width / 2.0;
    [newTextButton addTarget:self action:@selector(buttonAlphaPressed:) forControlEvents:UIControlEventTouchDown];
    [newTextButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpOutside];
    [newTextButton addTarget:self action:@selector(newTextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [chooseEditMethodView addSubview:newTextButton];
    
    UILabel *newTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(newTextButton.frame) - 80, CGRectGetMaxY(newTextButton.frame) + 5, 160, 25)];
    newTextLabel.textAlignment = NSTextAlignmentCenter;
    newTextLabel.textColor = [UIColor whiteColor];
    newTextLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    newTextLabel.text = LBDLocalizedString(@"<LBDLNewText>", nil);
    [chooseEditMethodView addSubview:newTextLabel];
    
    UIButton *editTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editTextButton.frame = CGRectMake(CGRectGetWidth(chooseEditMethodView.frame) * 0.75 - 40, CGRectGetMidY(chooseEditMethodView.frame) - 40, 80, 80);
    [editTextButton setImage:[UIImage imageNamed:@"editTextIcon.png"] forState:UIControlStateNormal];
    editTextButton.adjustsImageWhenHighlighted = NO;
    editTextButton.layer.backgroundColor = [UIColor flatRedColor].CGColor;
    editTextButton.layer.cornerRadius = editTextButton.frame.size.width / 2.0;
    [editTextButton addTarget:self action:@selector(buttonAlphaPressed:) forControlEvents:UIControlEventTouchDown];
    [editTextButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpOutside];
    [editTextButton addTarget:self action:@selector(editTextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [chooseEditMethodView addSubview:editTextButton];
    
    UILabel *newEditTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(editTextButton.frame) - 80, CGRectGetMaxY(editTextButton.frame) + 5, 160, 25)];
    newEditTextLabel.textAlignment = NSTextAlignmentCenter;
    newEditTextLabel.textColor = [UIColor whiteColor];
    newEditTextLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    newEditTextLabel.text = LBDLocalizedString(@"<LBDLEditText>", nil);
    [chooseEditMethodView addSubview:newEditTextLabel];
    
}

-(void)chooseEditMethodBackgroundPress:(UIGestureRecognizer *)theGesture {
    
    [UIView animateWithDuration:0.3 animations:^{
        chooseEditMethodView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [chooseEditMethodView removeFromSuperview];
        chooseEditMethodView = nil;
    }];
}


-(void)newTextButtonPressed:(UIButton *)theButton {
    
    [UIView animateWithDuration:0.1 animations:^{
        theButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    [self createEditTextView:@""];
    
    [self chooseEditMethodBackgroundPress:nil];
}

-(void)editTextButtonPressed:(UIButton *)theButton {
    
    [UIView animateWithDuration:0.1 animations:^{
        theButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    [self createEditTextView:[theTextPagedView selectedText]];
    
    [self chooseEditMethodBackgroundPress:nil];
}

-(void)createEditTextView:(NSString*)editText {
    
    if (!editTextView && [theImagePagedView selectedImage] != nil) {
        editTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        editTextView.backgroundColor = [UIColor appLightOverlayColor];
        
        
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
        [dismissKeyboardButton setTitle:LBDLocalizedString(@"<LBDLAccept>", nil) forState:UIControlStateNormal];
        [dismissKeyboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dismissKeyboardButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
        [dismissKeyboardButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
        [dismissKeyboardButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:dismissKeyboardButton];
        
        [textView setInputAccessoryView:accessoryView];
        
        editedTextSendButton = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
        editedTextSendButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 60, CGRectGetMaxY(theTextPagedView.frame) + 3, 120, 40);
        //editedTextSendButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
        //editedTextSendButton.layer.cornerRadius = 4.0f;
        [editedTextSendButton setTitle:LBDLocalizedString(@"<LBDLSendMessage>", nil) forState:UIControlStateNormal];
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
        
        model.isUserPhotosSelected = NO;
        model.userSelectedImages = nil;
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_SPECIAL_INTENTION withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"ShowSpecialIntention" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_MAIN targetType:@"Command" targetId:@"showSpecialIntention" targetParameter:@""];
        
        
        IntentionModeViewController *intentionVC = [[IntentionModeViewController alloc] init];
        
        [intentionVC selectedIntentionChosenWithCompletion:^(GWIntention *intention) {
            
            model.selectedSpecialOccasionIntention = intention;
            
            [UserDefaults setWelcomeTextsShow:YES];
            [UserDefaults setWelcomeImagesShown:YES];
            
            specialIntentionLabel.text = intention.label;
            [UIView animateWithDuration:0.3 animations:^{
                specialIntentionLabel.alpha = 1.0f;
            }];
            
            __weak typeof(self) wSelf = self;
            [wSelf dismissSpecialOccasionView];
            [wSelf showLoadingIndicator];
            
            
            // images loading
            if (intention != nil) {
                [wSelf downloadSpecialOccasionImagesWithIntention:intention];
                [wSelf downloadSpecialOccasionTextsWithIntention:intention];
            }

            
        }];
        
        [self presentViewController:intentionVC animated:YES completion:nil];
        
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

-(void)downloadSpecialOccasionImagesWithIntention:(GWIntention*)theIntention {
    
    model.isSpecialOccasionIntentionChosen = YES;
    NSLog(@"fetchedImages");
    [model fetchImagesForIntention:theIntention.imagePath withCompletion:^(NSArray *theImages, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (theImages != nil) {

                [model setRandomImageForCurrentIntention:theImages withNum:(int)theImages.count];
                [theImagePagedView reloadDataAnimated:YES];
                
                [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
                    
                }];
            }
            
        });
    }];
    
}

-(void)downloadSpecialOccasionTextsWithIntention:(GWIntention*)theIntention {
    model.isSpecialOccasionIntentionChosen = YES;
    [specialOccasionButton setSelected:YES];
    
    [model fetchTextsForIntentionId:theIntention.intentionId withCompletion:^(NSArray *theTexts, NSError *error) {
        
        if (!error) {
            
            [model setRandomTextForSpecialOccasionTexts:theTexts withFilter:[[TextFilter alloc] init]];
            [theTextPagedView reloadDataAnimated:YES];
        }
        else {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLOops>", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:LBDLocalizedString(@"<LBDLOk>", nil) otherButtonTitles: nil];
            [alertView show];
            
            model.isSpecialOccasionIntentionChosen = NO;
            [specialOccasionButton setSelected:NO];
            [theTextPagedView reloadDataAnimated:YES];

        }
        
    }];
}

-(void)showLoadingIndicator {

    [loadingIndicatorView removeFromSuperview];
    loadingIndicatorView = nil;
    
    loadingIndicatorView = [[BoxedActivityIndicatorView alloc] init];
    [loadingIndicatorView setFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.2, CGRectGetHeight(self.view.frame)/2.0 - CGRectGetWidth(self.view.frame)*0.3, CGRectGetWidth(self.view.frame)*0.6, CGRectGetWidth(self.view.frame)*0.6)];
    loadingIndicatorView.activityLabel.text = LBDLocalizedString(@"<LBDLCurrentlyDownloading>", nil);
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
    
    
    if ([model minimumImagesAndTextsToDownloadWithNumTexts:100 withNumImages:5] && (model.firstLaunchTexts.count != 0 || model.firstLaunchError == nil) && (model.firstLaunchImages.count != 0 || model.firstLaunchImageError == nil)) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            firstLaunView.alpha = 0.0f;
        
        } completion:^(BOOL finished) {
            [firstLaunView removeFromSuperview];
            firstLaunView = nil;
        }];
        
    } else {
        // show another view
        newView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        newView.backgroundColor = [UIColor appLightOverlayColor];
        [self.view addSubview:newView];
        
        UIActivityIndicatorView *activityIndiciator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndiciator.frame = CGRectMake(CGRectGetWidth(newView.frame)/2.0 - 37/2.0, CGRectGetHeight(newView.frame)*0.35, 37, 37);
        [newView addSubview:activityIndiciator];
        [activityIndiciator startAnimating];
        
        UILabel *downloadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(newView.frame)*0.1, CGRectGetHeight(newView.frame)*0.5, CGRectGetWidth(newView.frame)*0.8, 55)];
        downloadingLabel.font = [UIFont noteworthyBoldWithSize:25.0f];
        downloadingLabel.text = LBDLocalizedString(@"<LBDLCurrentlyDownloading>", nil);
        downloadingLabel.textColor = [UIColor appBlueColor];
        downloadingLabel.textAlignment = NSTextAlignmentCenter;
        downloadingLabel.numberOfLines = 2;
        [newView addSubview:downloadingLabel];
        
        [UIView animateWithDuration:0.3 animations:^ {
            firstLaunView.frame = CGRectMake(-CGRectGetWidth(firstLaunView.frame), CGRectGetMinY(firstLaunView.frame), CGRectGetWidth(firstLaunView.frame), CGRectGetHeight(firstLaunView.frame));
            newView.frame = CGRectMake(0, 0, CGRectGetWidth(newView.frame), CGRectGetHeight(newView.frame));
        } completion:^(BOOL completion) {
            firstLaunView = nil;
        }];
    }
}

-(void)isSufficientResourcesDownloaded {

     [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(isSufficientResourcesDownloaded) object:nil];
    if ([model minimumImagesAndTextsToDownloadWithNumTexts:100 withNumImages:5] && (model.firstLaunchTexts.count != 0 || model.firstLaunchError == nil) && (model.firstLaunchImages.count != 0 || model.firstLaunchImageError == nil)) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(updateViewData) withObject:nil afterDelay:1.0];
        });
        
        if (loadingIndicatorView) {
            [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
                
            }];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            newView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            newView = nil;
        }];
        
    } else {
        [self performSelector:@selector(isSufficientResourcesDownloaded) withObject:nil afterDelay:1.0];
    }
}

#pragma mark -
#pragma mark Send Button And Accompanying Views


-(void)sendButtonPressed:(UIButton*)sender
{
    [UserDefaults incrementNumberOfMessagesSent];
    [self showRatingViewIfAppropriate];
    
    buttonUsedToSend = sender;
    
    chooseSendMethodView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    chooseSendMethodView.backgroundColor = [UIColor appLightOverlayColor];
    chooseSendMethodView.alpha = 0.0f;
    [self.view addSubview:chooseSendMethodView];
    
    UITapGestureRecognizer *chooseMethodBackgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSendMethodBackgroundPressed:)];
    [chooseSendMethodView addGestureRecognizer:chooseMethodBackgroundTap];
    
    [UIView animateWithDuration:0.3 animations:^{
        chooseSendMethodView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    UIButton *cancelChooseMethodButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelChooseMethodButton.frame = CGRectMake(CGRectGetWidth(chooseSendMethodView.frame) / 4.0 * 3.0 - 80, CGRectGetHeight(chooseSendMethodView.frame) * 0.07, 160, 25);
    cancelChooseMethodButton.titleLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    [cancelChooseMethodButton setTitle:LBDLocalizedString(@"<LBDLCancel>", nil) forState:UIControlStateNormal];
    [cancelChooseMethodButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelChooseMethodButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [cancelChooseMethodButton addTarget:self action:@selector(chooseSendMethodBackgroundPressed:) forControlEvents:UIControlEventTouchUpInside];
    [chooseSendMethodView addSubview:cancelChooseMethodButton];
    
    UIButton *messengerButton = [FBSDKMessengerShareButton circularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue width:100];
    messengerButton.frame = CGRectMake(CGRectGetMidX(chooseSendMethodView.frame) - 50, CGRectGetHeight(chooseSendMethodView.frame) * 0.22, 100, 100);
    [messengerButton addTarget:self action:@selector(messengerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [chooseSendMethodView addSubview:messengerButton];
    
    UILabel *messengerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(chooseSendMethodView.frame) - 120, CGRectGetMaxY(messengerButton.frame) + 5, 240, 25)];
    messengerLabel.textAlignment = NSTextAlignmentCenter;
    messengerLabel.textColor = [UIColor whiteColor];
    messengerLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    messengerLabel.text = LBDLocalizedString(@"<LBDLMessenger>", nil);
    [chooseSendMethodView addSubview:messengerLabel];
    
    UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    smsButton.frame = CGRectMake(CGRectGetWidth(chooseSendMethodView.frame) / 4.0 * 3.0 - 40, CGRectGetHeight(chooseSendMethodView.frame) * 0.56, 80, 80);
    smsButton.layer.backgroundColor = [UIColor flatOrangeColor].CGColor;
    smsButton.layer.cornerRadius = smsButton.frame.size.width / 2.0;
    [smsButton setImage:[UIImage imageNamed:@"smsIcon.png"] forState:UIControlStateNormal];
    smsButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    smsButton.adjustsImageWhenHighlighted = NO;
    [smsButton addTarget:self action:@selector(buttonAlphaPressed:) forControlEvents:UIControlEventTouchDown];
    [smsButton addTarget:self action:@selector(smsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [smsButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpOutside];
    [chooseSendMethodView addSubview:smsButton];
    
    UILabel *smsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(smsButton.frame) - 60, CGRectGetMaxY(smsButton.frame) + 5, 120, 25)];
    smsLabel.textAlignment = NSTextAlignmentCenter;
    smsLabel.textColor = [UIColor whiteColor];
    smsLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    smsLabel.text = LBDLocalizedString(@"<LBDLSms>", nil);
    [chooseSendMethodView addSubview:smsLabel];
    
    UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mailButton.frame = CGRectMake(CGRectGetWidth(chooseSendMethodView.frame) / 4.0 - 40, CGRectGetHeight(chooseSendMethodView.frame) * 0.56, 80, 80);
    mailButton.layer.backgroundColor = [UIColor flatRedColor].CGColor;
    mailButton.layer.cornerRadius = mailButton.frame.size.width / 2.0;
    [mailButton setImage:[UIImage imageNamed:@"mailButton.png"] forState:UIControlStateNormal];
    mailButton.adjustsImageWhenHighlighted = NO;
    [mailButton addTarget:self action:@selector(buttonAlphaPressed:) forControlEvents:UIControlEventTouchDown];
    [mailButton addTarget:self action:@selector(mailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [mailButton addTarget:self action:@selector(buttonAlphaOutsidePressed:) forControlEvents:UIControlEventTouchUpOutside];
    [chooseSendMethodView addSubview:mailButton];
    
    UILabel *mailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(mailButton.frame) - 60, CGRectGetMaxY(mailButton.frame) + 5, 120, 25)];
    mailLabel.textAlignment = NSTextAlignmentCenter;
    mailLabel.textColor = [UIColor whiteColor];
    mailLabel.font = [UIFont helveticaNeueBoldWithSize:19.0];
    mailLabel.text = LBDLocalizedString(@"<LBDLEmail>", nil);
    [chooseSendMethodView addSubview:mailLabel];
    
}

-(void)chooseSendMethodBackgroundPressed:(UIButton *)theButton {
    
    [UIView animateWithDuration:0.3 animations:^{
        chooseSendMethodView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [chooseSendMethodView removeFromSuperview];
        chooseSendMethodView = nil;
    }];
    
}

-(void)buttonAlphaPressed:(UIButton *)theButton {
    
    [UIView animateWithDuration:0.1 animations:^{
        theButton.alpha = 0.4;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)buttonAlphaOutsidePressed:(UIButton *)theButton {
    
    [UIView animateWithDuration:0.1 animations:^{
        theButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - Image Picker Methods

-(void)cameraButtonPressed {
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)cameraRollButtonPressed {
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Image Picker Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (image) {
        
        CGFloat widthRatio = image.size.width / 800.0f;
        image = [image c_resizeImageWithSize:CGSizeMake(image.size.width / widthRatio, image.size.height / widthRatio)];
        
        model.isUserPhotosSelected = YES;
        model.userSelectedImages = @[image];
        
        [theImagePagedView reloadDataAnimated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Messenger, SMS and Mail Sending

-(void)dismissEditedTextView {
    [UIView animateWithDuration:0.1 animations:^{
        if (editTextView != nil) {
            editTextView.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
        if (editTextView != nil) {
            [editTextView removeFromSuperview];
            editTextView = nil;
        }
    }];
}

-(void)messengerButtonPressed:(UIButton *)sender {
    
    model.isUserPhotosSelected = NO;
    model.userSelectedImages = nil;
    
    [self dismissEditedTextView];
    
    if ([theTextPagedView selectedText] != nil && [theImagePagedView selectedImage] != nil) {
        NSLog(@"is last page: %d", [theTextPagedView isLastPage]);
        NSString *selectedText;
        
        // send the events to google analytics
        NSString *selectedTextId  = [theTextPagedView selectedTextId];
        NSString *selectedImageId = [theImagePagedView selectedImageId];
        
        // text depends on wether we are sending a message directly
        // or if we have edited in the edit text view
        if ([buttonUsedToSend isEqual:normalSendButton]) {
            selectedText = [theTextPagedView selectedText];
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"Send" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:selectedTextId targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"Send" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:selectedImageId targetParameter:@""];
            
        }
        else if([buttonUsedToSend isEqual:editedTextSendButton]) {
            selectedText = textView.text;
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedTextId wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_EDIT withAction:GA_ACTION_BUTTON_PRESSED withLabel:selectedImageId wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSend" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:selectedTextId targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSend" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:selectedImageId targetParameter:@""];
        }
        
        UIImage *snapshotImage = [self createImageWithText:selectedText];
        
        
        [FBSDKMessengerSharer shareImage:snapshotImage withOptions:nil];
    }
    else if([theTextPagedView isLastPage]) {
        
        if ([buttonUsedToSend isEqual:editedTextSendButton]) {
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

    [self chooseSendMethodBackgroundPressed:nil];
    
}

-(void)smsButtonPressed:(UIButton *)theButton {
    
    model.isUserPhotosSelected = NO;
    model.userSelectedImages = nil;
    
    [self dismissEditedTextView];
    
    if ([MFMessageComposeViewController canSendText] && [MFMessageComposeViewController canSendAttachments]) {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.messageComposeDelegate = self;
        
        if ([buttonUsedToSend isEqual:normalSendButton]) {
            messageVC.body = [model addImagePathToSMS:[theTextPagedView selectedText] relativePath:[theImagePagedView selectedImagePath]];
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SENT_SMS withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theTextPagedView selectedTextId] wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SENT_SMS withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theImagePagedView selectedImageId] wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"SendSMS" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:[theTextPagedView selectedTextId] targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"SendSMS" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:[theImagePagedView selectedImageId] targetParameter:@""];
            
        }
        else if([buttonUsedToSend isEqual:editedTextSendButton]) {
            messageVC.body = textView.text;
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_EDIT_SMS withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theTextPagedView selectedTextId] wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SENT_SMS withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theImagePagedView selectedImageId] wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSendSMS" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:[theTextPagedView selectedTextId] targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSendSMS" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:[theImagePagedView selectedImageId] targetParameter:@""];
        }
        
        
        [self presentViewController:messageVC animated:YES completion:^{
            model.isUserPhotosSelected = NO;
            model.userSelectedImages = nil;
        }];
        
        [self chooseSendMethodBackgroundPressed:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLOops>", nil) message:LBDLocalizedString(@"<LBDLMessageSendingNotPossible>", nil) delegate:nil cancelButtonTitle:LBDLocalizedString(@"<LBDLOk>", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    model.isUserPhotosSelected = NO;
    model.userSelectedImages = nil;
    
    switch (result) {
            
        case MessageComposeResultSent:
            
            break;
            
        case MessageComposeResultCancelled:
            
            break;
            
        case MessageComposeResultFailed:
            
            break;
            
        default:
            break;
    }
    
}

-(void)mailButtonPressed:(UIButton *)theButton {
    
    [self dismissEditedTextView];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        
        if ([buttonUsedToSend isEqual:normalSendButton]) {
            [mailVC setMessageBody:[theTextPagedView selectedText] isHTML:NO];
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_SENT_MAIL withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theTextPagedView selectedTextId] wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_SENT_MAIL withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theImagePagedView selectedImageId] wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"SendMail" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:[theTextPagedView selectedTextId] targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"SendMail" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:[theImagePagedView selectedImageId] targetParameter:@""];
            
        }
        else if([buttonUsedToSend isEqual:editedTextSendButton]) {
            [mailVC setMessageBody:textView.text isHTML:NO];
            
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_TEXT_EDIT_MAIL withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theTextPagedView selectedTextId] wtihValue:nil];
            [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_EDIT_MAIL withAction:GA_ACTION_BUTTON_PRESSED withLabel:[theImagePagedView selectedImageId] wtihValue:nil];
            
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSendMail" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:[theTextPagedView selectedTextId] targetParameter:@""];
            [[CustomAnalytics sharedInstance] postActionWithType:@"EditedSendMail" actionLocation:GA_SCREEN_MAIN targetType:@"Image" targetId:[theImagePagedView selectedImageId] targetParameter:@""];
            
        }
        
        [mailVC addAttachmentData:UIImageJPEGRepresentation([theImagePagedView selectedImage], 0.7) mimeType:@"image/jpeg" fileName:@"image.jpg"];
        [self presentViewController:mailVC animated:YES completion:^{
            
        }];
        
        [self chooseSendMethodBackgroundPressed:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLOops>", nil) message:LBDLocalizedString(@"<LBDLMailSendingNotPossible>", nil) delegate:nil cancelButtonTitle:LBDLocalizedString(@"<LBDLOk>", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    model.isUserPhotosSelected = NO;
    model.userSelectedImages = nil;
    
    switch (result) {
            
        case MFMailComposeResultSent:
            
            break;
            
        case MFMailComposeResultCancelled:
            
            break;
            
        case MFMailComposeResultFailed:
            
            break;
            
        case MFMailComposeResultSaved:
            
            break;
            
        default:
            break;
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
    
    [FBSDKShareDialog showFromViewController:self withContent:photoContent delegate:self];
    
}

-(void)shareExtensionPressed:(UIButton *)theButton {
    
    NSString *selectedText = [theTextPagedView selectedText];
    UIImage *selectedImage = [theImagePagedView selectedImage];
    
    if (selectedText != nil && selectedImage != nil) {
        UIImage *image = [self createImageWithText:selectedText];
        
        NSString *selectedTextId = [theTextPagedView selectedTextId];
        NSString *selectedImageId = [theImagePagedView selectedImageId];
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        
        NSArray *excludeActivities = @[UIActivityTypeAirDrop];
        
        activityVC.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    
}

#pragma mark - System Notification Permission Dialog

-(void)notificationSystemPermission {
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
}

#pragma mark - Text Scroll View Delegate

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
    
    if (selectedImage != nil) {
        NSString *imageId = [theImagePagedView selectedImageId];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_IMAGE_ONLY_SENT withAction:GA_ACTION_BUTTON_PRESSED withLabel:imageId wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:@"SendImageOnly" actionLocation:GA_SCREEN_MAIN targetType:@"Text" targetId:imageId targetParameter:@""];
        
        [FBSDKMessengerSharer shareImage:selectedImage withOptions:nil];
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
    _numRefreshesPressed++;
    
    if (_numRefreshesPressed >= 2) {
        [self showNotificationAlert];
    }
    
    [self showRatingViewIfAppropriate];
    [UserDefaults increaseNumberOfTextRefreshesByUser];
    [UserDefaults setWelcomeTextsShow:YES];
}

#pragma mark - Create Image 

-(UIImage*)createImageWithText:(NSString*)theText {
    
    UIImage *selectedImage = [theImagePagedView selectedImage];
    
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

        editButton.alpha = 1.0;
    }];
    
    [UserDefaults numberOfTextRefreshes];
    
    //if (![[UserDefaults hasPressedIntentionButton] boolValue] && ([[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfTextRefreshesByUser] intValue] < 1 && [[UserDefaults timeSpentInApp] intValue] < 90)) {
    if ([[UserDefaults hasPressedIntentionButton] boolValue] == NO && ([[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfTextRefreshesByUser] intValue] < 1)) {
    }
    else {
        
        [self showPulseIfAppropriate];
    }
    
    if ([[UserDefaults welcomeTextsShown] boolValue] == NO && model.firstLaunchError == nil && model.firstLaunchTexts != nil && model.firstLaunchTexts.count != 0) {
        return model.firstLaunchTexts;
    }
    
    if (model.isSpecialOccasionIntentionChosen) {
        
        if ([model specialOccasionTexts].count == 0) {
            UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLError>", nil) message:LBDLocalizedString(@"<LBDLNoTextsForSpecialIntention>", nil) delegate:nil cancelButtonTitle:LBDLocalizedString(@"<LBDLOk>", nil) otherButtonTitles: nil];
            [tmpAlert show];
            
            model.isSpecialOccasionIntentionChosen = NO;
            return [model randomtTextWithNum:numberOfTextsToLoad ignoringTexts:nil];
        }
        
        return [model specialOccasionTexts];
    }
    
    NSArray *randomTexts = [model randomtTextWithNum:numberOfTextsToLoad ignoringTexts:theTextPagedView.viewModel.theTexts];
    
    if (randomTexts.count == 0 && firstLaunView == nil && newView == nil) {
        languageChangeAlert = [[UIAlertView alloc] initWithTitle:LBDLocalizedString(@"<LBDLOops>", nil) message:LBDLocalizedString(@"<LBDLNoTextsAvailableForGivenLanguage>", nil) delegate:self cancelButtonTitle:LBDLocalizedString(@"<LBDLNo>", nil) otherButtonTitles:LBDLocalizedString(@"<LBDLYes>", nil), nil];
        [languageChangeAlert show];
    }
    
    return randomTexts;
}

#pragma mark - Image Paged View Data Source

-(NSArray*)updateImageScrollViewImages {
    
    if (model.isUserPhotosSelected && model.userSelectedImages != nil) {
        return [model userSelectedImages];
    }
    else if(model.userSelectedImages == nil) {
        model.isUserPhotosSelected = NO;
    }
    
    if ([UserDefaults welcomeImagesShown] == NO && model.firstLaunchImages != nil && model.firstLaunchImages.count != 0 && model.firstLaunchImageError == nil) {
        return model.firstLaunchImages;
    }
    
    if (model.isViewingTheme == YES) {
        return [model themeImages];
    }
    
    if (model.isSpecialOccasionIntentionChosen) {
        return [model specialOccasionImages];
    }
    
    return [model randomImagesWithNum:numberOfImagesToLoad ignoringImages:theImagePagedView.viewModel.theImages numberOfImagesInDB:30];
    //return [model randomImagesWithImagesBasedOnTexts:[theTextPagedView theTexts] WithNum:numberOfImagesToLoad];
}

#pragma mark - Image Paged View Delegate

-(void)refreshImagesPressedWithImageScrollView:(ImageScrollView *)theScrollView {
    
    _numRefreshesPressed++;
    
    if (_numRefreshesPressed >= 2) {
        [self showNotificationAlert];
    }
    
    [self showRatingViewIfAppropriate];
    
    [UserDefaults increaseNumberOfImageRefreshesByUser];
    
    if (model.isUserPhotosSelected) {
        model.userSelectedImages = nil;
        model.isUserPhotosSelected = NO;
    }
    
    [UserDefaults setWelcomeImagesShown:YES];
    
    if (![[UserDefaults hasPressedIntentionButton] boolValue] && ([[UserDefaults numberOfImageRefreshesByUser] intValue] < 1 && [[UserDefaults numberOfTextRefreshesByUser] intValue] < 1)) {

    }
    else {
        [self showPulseIfAppropriate];
    }
    
    if (model.isViewingTheme == YES) {
        [theScrollView fadeInLoaderWithCompletion:^(BOOL finished) {
            
        }];
        [model fetchImagesForCurrentThemePathWithCompletion:^(NSArray *theImages, NSError *theError) {
            [theScrollView reloadDataAnimated:YES];
        }];
        
        return ;
    }
    
    if (model.isSpecialOccasionIntentionChosen) {
        GWIntention *selectedOCcasionIntention = [model selectedSpecialOccasionIntention];
        [self showLoadingIndicator];

        if (!model.isLoadingImages) {
            model.isLoadingImages = YES;
            
            NSLog(@"selected intention path: %@", selectedOCcasionIntention.imagePath);
            [model fetchImagesForIntention:selectedOCcasionIntention.imagePath withCompletion:^(NSArray *theImages, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (theImages != nil) {
                        model.isLoadingImages = NO;
                        NSLog(@"the number of images are: %d", (int)theImages.count);
                        [model setRandomImageForCurrentIntention:theImages withNum:(int)theImages.count];
                        [theScrollView reloadDataAnimated:YES];
                        [loadingIndicatorView fadeOutWithCompletion:^(BOOL completed) {
                            
                        }];
                    }
                });
            }];
        }
        
    }
    else {
        [theScrollView reloadDataAnimated:YES];
    }
}

-(void)refreshImageWithImageScrollView:(ImageScrollView *)theImageScrollView withThemePath:(NSString *)theThemePath {
    model.isUserPhotosSelected = NO;
    model.isSpecialOccasionIntentionChosen = NO;
    
    [UserDefaults setWelcomeImagesShown:YES];
    
    [model fetchImagesForThemePath:theThemePath withCompletion:^(NSArray *theImages, NSError *error) {
        if (theImages != nil) {
            model.isViewingTheme = YES;
            [theImageScrollView reloadDataAnimated:YES];
        }
        else {
            model.isViewingTheme = NO;
            [theImageScrollView reloadDataAnimated:YES];
        }
    }];
    
}

#pragma mark - Facebook Sharing Delegate

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    model.isUserPhotosSelected = NO;
    model.userSelectedImages = nil;
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
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
    
    [self updateViewLanguage];
    
    return slideAnimator;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"settingsSegue"]) {
        UIViewController *destinationVC = (UIViewController*)[segue destinationViewController];
        
        destinationVC.transitioningDelegate = self;
        destinationVC.modalPresentationStyle = UIModalPresentationCustom;
    }
}

@end
