//
//  LoginViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 22/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *appLogo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 0.28, CGRectGetHeight(self.view.frame) * 0.1, CGRectGetWidth(self.view.frame) * 0.44, CGRectGetWidth(self.view.frame) * 0.44)];
    [appLogo setImage:[UIImage imageNamed:@"appDisplayIcon.png"]];
    appLogo.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:appLogo];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2.0 - 120, CGRectGetHeight(self.view.frame) - 60 - 60, 240, 60)];
    loginButton.readPermissions = @[@"email", @"public_profile", @"user_friends"];
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    
    UIButton *noFacebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noFacebookLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [noFacebookLoginButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [noFacebookLoginButton setTitle:@"Utiliser sans connexion Facebook" forState:UIControlStateNormal];
    [noFacebookLoginButton addTarget:self action:@selector(loginWithoutFacebook) forControlEvents:UIControlEventTouchUpInside];
    noFacebookLoginButton.titleLabel.font = [UIFont helveticaNeueBoldWithSize:13.0];
    noFacebookLoginButton.frame = CGRectMake(CGRectGetMinX(loginButton.frame), CGRectGetMaxY(loginButton.frame), CGRectGetWidth(loginButton.frame), 40);
    [self.view addSubview:noFacebookLoginButton];
    
    
    self.view.backgroundColor = [UIColor appBlueColor];
    
    UILabel *appTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 0.15, CGRectGetMaxY(appLogo.frame) + 30, CGRectGetWidth(self.view.frame) * 0.7, 50)];
    appTitle.text = @"Le bout des lèvres";
    appTitle.textAlignment = NSTextAlignmentCenter;
    appTitle.textColor = [UIColor whiteColor];
    appTitle.font = [UIFont noteworthyBoldWithSize:27];
    [self.view addSubview:appTitle];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
