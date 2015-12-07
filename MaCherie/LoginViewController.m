//
//  LoginViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 22/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "LoginViewController.h"
#import "DefaultButton.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"
#import "LBDLocalization.h"
#import "RootViewModel.h"
#import "UserDefaults.h"
#import "GWLocalizedBundle.h"
#import "ConstantsManager.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate> {
    DefaultButton *frenchButton;
    DefaultButton *englishButton;
    DefaultButton *spanishButton;
    UIButton *noFacebookLoginButton;
    RootViewModel *_viewModel;
    
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewModel = [[RootViewModel alloc] init];
    
    UIImageView *appLogo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 0.28, CGRectGetHeight(self.view.frame) * 0.1, CGRectGetWidth(self.view.frame) * 0.44, CGRectGetWidth(self.view.frame) * 0.44)];
    [appLogo setImage:[UIImage imageNamed:@"appDisplayIcon.png"]];
    appLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:appLogo];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2.0 - 120, CGRectGetHeight(self.view.frame) - 60 - 60, 240, 60)];
    loginButton.readPermissions = @[@"email", @"public_profile", @"user_friends"];
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    
    noFacebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noFacebookLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [noFacebookLoginButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [noFacebookLoginButton setTitle:LBDLocalizedString(@"<LBDLuseWithoutFacebookConnection>", nil) forState:UIControlStateNormal];
    [noFacebookLoginButton addTarget:self action:@selector(loginWithoutFacebook) forControlEvents:UIControlEventTouchUpInside];
    noFacebookLoginButton.titleLabel.font = [UIFont helveticaNeueBoldWithSize:15.0];
    noFacebookLoginButton.frame = CGRectMake(CGRectGetMinX(loginButton.frame) - 15, CGRectGetMaxY(loginButton.frame), CGRectGetWidth(loginButton.frame) + 30, 40);
    [self.view addSubview:noFacebookLoginButton];
    
    frenchButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)*0.35 - 45, CGRectGetMidY(self.view.frame)  + 40, 90, 36)];
    frenchButton.buttonBackgroundColor = [UIColor appBlueColor];
    frenchButton.buttonSelectedBackgroundColor = [UIColor whiteColor];
    frenchButton.buttonBorderColor = [UIColor whiteColor];
    frenchButton.layer.borderWidth = 1.0;
    [frenchButton setTitle:@"Francais" forState:UIControlStateNormal];
    [frenchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [frenchButton setTitleColor:[UIColor appBlueColor] forState:UIControlStateSelected];
    [frenchButton addTarget:self action:@selector(languageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:frenchButton];
    
    englishButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 45, CGRectGetMinY(frenchButton.frame), 90, 36)];
    englishButton.buttonBackgroundColor = [UIColor appBlueColor];
    englishButton.buttonSelectedBackgroundColor = [UIColor whiteColor];
    englishButton.buttonBorderColor = [UIColor whiteColor];
    englishButton.layer.borderWidth = 1.0;
    [englishButton setTitle:@"English" forState:UIControlStateNormal];
    [englishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [englishButton setTitleColor:[UIColor appBlueColor] forState:UIControlStateSelected];
    [englishButton addTarget:self action:@selector(languageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:englishButton];
    
    spanishButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) * 1.65 - 45, CGRectGetMinY(englishButton.frame), 90, 36)];
    spanishButton.buttonBackgroundColor = [UIColor appBlueColor];
    spanishButton.buttonSelectedBackgroundColor = [UIColor whiteColor];
    spanishButton.buttonBorderColor = [UIColor whiteColor];
    spanishButton.layer.borderWidth = 1.0;
    [spanishButton setTitle:@"Español" forState:UIControlStateNormal];
    [spanishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [spanishButton setTitleColor:[UIColor appBlueColor] forState:UIControlStateSelected];
    [spanishButton addTarget:self action:@selector(languageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:spanishButton];
    
    
    if ([[UserDefaults currentCulture] isEqualToString: frenchCultureString]) {
        [frenchButton setSelected:YES];
        [GWLocalizedBundle setLanguage:frenchCultureString];
    }
    else if([[UserDefaults currentCulture] isEqualToString: spanishCultureString]) {
        [spanishButton setSelected:YES];
        [GWLocalizedBundle setLanguage:englishCultureString];
    }
    else if([[UserDefaults currentCulture] isEqualToString: englishCultureString]) {
        [englishButton setSelected:YES];
        [GWLocalizedBundle setLanguage:englishCultureString];
    }
    
    
    self.view.backgroundColor = [UIColor appBlueColor];
    
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 0.15, CGRectGetMaxY(appLogo.frame) + 30, CGRectGetWidth(self.view.frame) * 0.7, 50)];
    appTitle.text = @"Le bout des lèvres";
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.textColor = [UIColor whiteColor];
    appTitle.font = [UIFont noteworthyBoldWithSize:27];
    [self.view addSubview:appTitle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
        [UserDefaults setFacebookUserId:[FBSDKAccessToken currentAccessToken].userID];
    }
    
}

-(void)updateViewData {
    [noFacebookLoginButton setTitle:LBDLocalizedString(@"<LBDLuseWithoutFacebookConnection>", nil) forState:UIControlStateNormal];
}

-(void)languageButtonPressed:(DefaultButton*)button {
    
    [frenchButton setSelected:NO];
    [englishButton setSelected:NO];
    [spanishButton setSelected:NO];
    
    [button setSelected:YES];
    
    RootViewModel *viewModel = [[RootViewModel alloc] init];
    
    if (button == englishButton) {
        [UserDefaults setCulture:englishCultureString];
        [GWLocalizedBundle setLanguage:englishCultureString];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_LANGUAGE withAction:GA_ACTION_BUTTON_PRESSED withLabel:englishCultureString wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:GA_CATEGORY_LANGUAGE targetParameter:englishCultureString];
        
        
    }
    else if(button == frenchButton) {
        [UserDefaults setCulture:frenchCultureString];
        [GWLocalizedBundle setLanguage:frenchCultureString];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_LANGUAGE withAction:GA_ACTION_BUTTON_PRESSED withLabel:frenchCultureString wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:GA_CATEGORY_LANGUAGE targetParameter:frenchCultureString];
        
    }
    else if(button == spanishButton) {
        [UserDefaults setCulture:spanishCultureString];
        [GWLocalizedBundle setLanguage:englishCultureString];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_LANGUAGE withAction:GA_ACTION_BUTTON_PRESSED withLabel:spanishCultureString wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:GA_CATEGORY_LANGUAGE targetParameter:spanishCultureString];
        
    }
    
    [self updateViewData];
    
    [viewModel downloadTextsForArea:[ConstantsManager sharedInstance].area withCompletion:^(NSArray *theTexts, NSError *error) {
        
    }];
    
}

#pragma mark - Use app without login

-(void)loginWithoutFacebook {
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_LOGIN withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"LoginWithoutFacebook" wtihValue:nil];
    [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_LOGIN targetType:@"Command" targetId:@"Login" targetParameter:@"LoginWithoutFacebook"];
    
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

#pragma mark - Login Delegate

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (!result.isCancelled && !error) {
        
        if ([FBSDKAccessToken currentAccessToken]) {
            [UserDefaults setFacebookUserId:[FBSDKAccessToken currentAccessToken].userID];
            NSLog(@"facebook user id is: %@", [UserDefaults facebookUserId]);
        }
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_LOGIN withAction:GA_ACTION_BUTTON_PRESSED withLabel:@"LoginWithFacebook" wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_LOGIN targetType:@"Command" targetId:@"Login" targetParameter:@"LoginWithFacebook"];
        
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
