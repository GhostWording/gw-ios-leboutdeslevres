//
//  SettingsViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserDefaults.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "DefaultButton.h"
#import "TimePicker.h"
#import "GoogleAnalyticsCommunication.h"
#import "CustomAnalytics.h"

const float heightOffset = 20.0;

@interface SettingsViewController () {
    
    // gender buttons
    DefaultButton *femaleButton;
    DefaultButton *maleButton;
    
    // age buttons
    DefaultButton *lessThan17Button;
    DefaultButton *between18And39Button;
    DefaultButton *between40And64Button;
    DefaultButton *over65Button;
    
    // Add UIScrollView for iPhone 4 devices
    UIScrollView *scrollView;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *activityIndicatorView;
    TimePicker *timePicker;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 32, heightOffset + 12, 18, 18);
    [closeButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    //[closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:closeButton];
    
    UIView *overlayCancelTouchView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.view.frame)*0.15, heightOffset - 2, CGRectGetWidth(self.view.frame)*0.15, 44)];
    overlayCancelTouchView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [overlayCancelTouchView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:overlayCancelTouchView];
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetMinX(closeButton.frame), heightOffset + 10, CGRectGetWidth(self.view.frame) - 2*(CGRectGetWidth(self.view.frame) - CGRectGetMinX(closeButton.frame)), 22)];
    title.text = @"Mon profil";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont helveticaNeueBoldWithSize:17.0f];
    title.textColor = [UIColor appBlueColor];
    [self.view addSubview:title];
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 40 + heightOffset, CGRectGetWidth(self.view.frame), 1)];
    topSeparator.backgroundColor = [UIColor appBlueColor];
    [self.view addSubview:topSeparator];
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topSeparator.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(topSeparator.frame))];
    [self.view addSubview:scrollView];
    
    
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 + 15, CGRectGetWidth(self.view.frame), 20)];
    genderLabel.text = @"Je suis";
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.font = [UIFont helveticaNeueBoldWithSize:16.0f];
    genderLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:genderLabel];
    
    maleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMaxY(genderLabel.frame) + 20, 60, 60)];
    [maleButton setImage:[UIImage imageNamed:@"maleGender.png"] forState:UIControlStateNormal];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateSelected];
    [maleButton setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateHighlighted];
    [maleButton addTarget:self action:@selector(maleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:maleButton];
    
    femaleButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 40, CGRectGetMaxY(genderLabel.frame) + 20, 60, 60)];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGender.png"] forState:UIControlStateNormal];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateHighlighted];
    [femaleButton setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateSelected];
    [femaleButton addTarget:self action:@selector(femaleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:femaleButton];
    
    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 114, CGRectGetMaxY(maleButton.frame) + 7, 100, 20)];
    maleLabel.text = @"un homme";
    maleLabel.textAlignment = NSTextAlignmentCenter;
    maleLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:maleLabel];
    
    UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 22, CGRectGetMaxY(femaleButton.frame) + 7, 100, 20)];
    femaleLabel.text = @"une femme";
    femaleLabel.textAlignment = NSTextAlignmentCenter;
    femaleLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:femaleLabel];
    
    // Set the state of the button
    if ([[UserDefaults userGender] intValue] == kGenderMale) {
        [maleButton setSelected:YES];
    } else if([[UserDefaults userGender] intValue] == kGenderFemale) {
        [femaleButton setSelected:YES];
    }
    
    
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(femaleLabel.frame) + 25, CGRectGetWidth(self.view.frame), 20)];
    ageLabel.text = @"Mon âge";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.font = [UIFont helveticaNeueBoldWithSize:16.0f];
    ageLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:ageLabel];
    
    lessThan17Button = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 80 - 60 - 10, CGRectGetMaxY(ageLabel.frame) + 15, 54, 36)];
    [lessThan17Button setTitle:@"17-" forState:UIControlStateNormal];
    [lessThan17Button addTarget:self action:@selector(ageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:lessThan17Button];
    
    between18And39Button = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 84, CGRectGetMaxY(ageLabel.frame) + 15, 76, 36)];
    [between18And39Button setTitle:@"18-39" forState:UIControlStateNormal];
    [between18And39Button addTarget:self action:@selector(ageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:between18And39Button];
    
    between40And64Button = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 8, CGRectGetMaxY(ageLabel.frame) + 15, 76, 36)];
    [between40And64Button setTitle:@"40-64" forState:UIControlStateNormal];
    [between40And64Button addTarget:self action:@selector(ageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:between40And64Button];
    
    over65Button = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 96, CGRectGetMaxY(ageLabel.frame) + 15, 54, 36)];
    [over65Button setTitle:@"65+" forState:UIControlStateNormal];
    [over65Button addTarget:self action:@selector(ageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:over65Button];
    
    
    // set the initial state of the age buttons
    if ([[UserDefaults userAgeSegment] intValue] == kAgeLessThan17) {
        [lessThan17Button setSelected:YES];
    } else if([[UserDefaults userAgeSegment] intValue] == kAgeBetween18And39) {
        [between18And39Button setSelected:YES];
    } else if([[UserDefaults userAgeSegment] intValue] == kAgeBetween40And64) {
        [between40And64Button setSelected:YES];
    } else if([[UserDefaults userAgeSegment] intValue] == kAgeOver65) {
        [over65Button setSelected:YES];
    }
    
    
    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(over65Button.frame) + 27, CGRectGetWidth(self.view.frame), 20)];
    notificationLabel.text = @"Recevoir les rappels";
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.font = [UIFont helveticaNeueBoldWithSize:16.0f];
    notificationLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:notificationLabel];
    
    UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    notificationSwitch.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(notificationLabel.frame) + CGRectGetHeight(notificationSwitch.frame)*0.5 + 23);
    notificationSwitch.onTintColor = [UIColor appBlueColor];
    [notificationSwitch addTarget:self action:@selector(wantsLocalNotification:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:notificationSwitch];
    
    
    // set the initial state of the notifications
    if ([[UserDefaults userWantsNotification] boolValue] == YES) {
        [notificationSwitch setOn:YES animated:YES];
    }
    
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(notificationSwitch.frame) + 25, CGRectGetWidth(self.view.frame), 20)];
    dateLabel.text = @"Heure des rappels";
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont helveticaNeueBoldWithSize:16.0f];
    dateLabel.textColor = [UIColor appBlueColor];
    [scrollView addSubview:dateLabel];
    
    
    timePicker = [[TimePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateLabel.frame) + 10, CGRectGetWidth(self.view.frame), 80)];
    [scrollView addSubview:timePicker];
    
    if ([UserDefaults firstLaunchOfApp] != nil) {
        int minutes = [UserDefaults notificationMinutes];
        int hours = [UserDefaults notificationHour];
        [timePicker setHour:hours andMinute:minutes];
    }
    
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(timePicker.frame) + 70)];
    
    
    // Do any additional setup after loading the view.
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(0, 0, 80, 80);
    //activityIndicator.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [activityIndicator startAnimating];
    
    activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    activityIndicatorView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.75];
    activityIndicatorView.layer.cornerRadius = 6.0f;
    activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame));
    [activityIndicatorView addSubview:activityIndicator];
    activityIndicatorView.hidden = YES;
    [self.view addSubview:activityIndicatorView];
     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[GoogleAnalyticsCommunication sharedInstance] setScreenName:GA_SCREEN_SETTINGS];
    [[CustomAnalytics sharedInstance] postActionWithType:@"init" actionLocation:GA_SCREEN_SETTINGS targetType:@"init" targetId:@"init" targetParameter:@""];
}

-(void)dismiss
{
    //activityIndicatorView.hidden = NO;
    
    if (timePicker.hasChanged) {
        NSString *hour = [timePicker currentStringInComponent:0];
        NSString *minute = [timePicker currentStringInComponent:2];
        NSString *time = [NSString stringWithFormat:@"%@:%@", hour, minute];
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_LABEL_USER_NOTIFICATION_TIME withLabel:time wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTiON_PICKER_SELECTION actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserNotification" targetParameter:time];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 
#pragma mark Notification Switch Value Changed

-(void)wantsLocalNotification:(UISwitch*)sender {
    
    [UserDefaults setUserWantsNotification:sender.isOn];
    
    [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_SWITCH_PRESSED withLabel:GA_LABEL_USER_WANTS_NOTIFICATION wtihValue:[NSNumber numberWithBool:sender.isOn]];
    [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserWantsNotification" targetParameter:[NSString stringWithFormat:@"%d", sender.isOn]];
}


#pragma mark - 
#pragma mark Age Buttons pressed

-(void)ageButtonPressed:(DefaultButton*)sender {
    
    [lessThan17Button setSelected:NO];
    [between18And39Button setSelected:NO];
    [between40And64Button setSelected:NO];
    [over65Button setSelected:NO];
    
    if (sender == lessThan17Button) {
        [lessThan17Button setSelected:YES];
        [UserDefaults setUserAgeSegment:[NSNumber numberWithInt:kAgeLessThan17]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_AGE_LESS_18 wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserAge" targetParameter:GA_LABEL_AGE_LESS_18];
        
    } else if(sender == between18And39Button) {
        [between18And39Button setSelected:YES];
        [UserDefaults setUserAgeSegment:[NSNumber numberWithInt:kAgeBetween18And39]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_AGE_BETWEEN_18_40 wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserAge" targetParameter:GA_LABEL_AGE_BETWEEN_18_40];
    } else if(sender == between40And64Button) {
        [between40And64Button setSelected:YES];
        [UserDefaults setUserAgeSegment:[NSNumber numberWithInt:kAgeBetween40And64]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_AGE_BETWEEN_40_64 wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserAge" targetParameter:GA_LABEL_AGE_BETWEEN_40_64];
    } else if(sender == over65Button) {
        [over65Button setSelected:YES];
        [UserDefaults setUserAgeSegment:[NSNumber numberWithInt:kAgeOver65]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_AGE_OVER_65 wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserAge" targetParameter:GA_LABEL_AGE_OVER_65];
    }
    
}

#pragma mark -
#pragma mark Gender Buttons pressed

-(void)maleButtonPressed:(DefaultButton*)sender {
    if (!sender.isSelected) {
        [sender setSelected:YES];
        [femaleButton setSelected:NO];
        [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderMale]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_MALE wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"H"];
        
    }
}

-(void)femaleButtonPressed:(DefaultButton*)sender {
    if (!sender.isSelected) {
        [sender setSelected:YES];
        [maleButton setSelected:NO];
        [UserDefaults setUserGender:[NSNumber numberWithInt:kGenderFemale]];
        
        [[GoogleAnalyticsCommunication sharedInstance] sendEventWithCategory:GA_CATEGORY_USER_INFORMATION withAction:GA_ACTION_BUTTON_PRESSED withLabel:GA_LABEL_GENDER_FEMALE wtihValue:nil];
        [[CustomAnalytics sharedInstance] postActionWithType:GA_ACTION_BUTTON_PRESSED actionLocation:GA_SCREEN_SETTINGS targetType:@"Command" targetId:@"UserGender" targetParameter:@"F"];
    }
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
