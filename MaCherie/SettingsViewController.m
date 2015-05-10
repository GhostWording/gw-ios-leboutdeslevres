//
//  SettingsViewController.m
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "DefaultButton.h"
#import "TimePicker.h"

const float heightOffset = 20.0;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 32, heightOffset + 12, 18, 18);
    [closeButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetMinX(closeButton.frame), heightOffset + 10, CGRectGetWidth(self.view.frame) - 2*(CGRectGetWidth(self.view.frame) - CGRectGetMinX(closeButton.frame)), 22)];
    title.text = @"Mon profil";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont helveticaNeueMediumWitihSize:17.0f];
    title.textColor = [UIColor appBlueColor];
    [self.view addSubview:title];
    
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 40 + heightOffset, CGRectGetWidth(self.view.frame), 1)];
    topSeparator.backgroundColor = [UIColor appBlueColor];
    [self.view addSubview:topSeparator];
    
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topSeparator.frame) + 15, CGRectGetWidth(self.view.frame), 20)];
    genderLabel.text = @"Je suis";
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.textColor = [UIColor appBlueColor];
    [self.view addSubview:genderLabel];
    
    DefaultButton *button = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 90, CGRectGetMaxY(genderLabel.frame) + 15, 60, 60)];
    [button setImage:[UIImage imageNamed:@"maleGender.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"maleGenderSelected.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    
    DefaultButton *buttonTwo = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 30, CGRectGetMaxY(genderLabel.frame) + 15, 60, 60)];
    [buttonTwo setImage:[UIImage imageNamed:@"femaleGender.png"] forState:UIControlStateNormal];
    [buttonTwo setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateHighlighted];
    [buttonTwo setImage:[UIImage imageNamed:@"femaleGenderSelected.png"] forState:UIControlStateSelected];
    [self.view addSubview:buttonTwo];
    
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(buttonTwo.frame) + 20, CGRectGetWidth(self.view.frame), 20)];
    ageLabel.text = @"Age";
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.textColor = [UIColor appBlueColor];
    [self.view addSubview:ageLabel];
    
    DefaultButton *firstAgeButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 80 - 60 - 10, CGRectGetMaxY(ageLabel.frame) + 15, 54, 36)];
    [firstAgeButton setTitle:@"17-" forState:UIControlStateNormal];
    [self.view addSubview:firstAgeButton];
    
    DefaultButton *secondAgeButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 84, CGRectGetMaxY(ageLabel.frame) + 15, 76, 36)];
    [secondAgeButton setTitle:@"18-39" forState:UIControlStateNormal];
    [self.view addSubview:secondAgeButton];
    
    DefaultButton *thirdAgeButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 8, CGRectGetMaxY(ageLabel.frame) + 15, 76, 36)];
    [thirdAgeButton setTitle:@"40-64" forState:UIControlStateNormal];
    [self.view addSubview:thirdAgeButton];
    
    DefaultButton *fourthAgeButton = [[DefaultButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) + 96, CGRectGetMaxY(ageLabel.frame) + 15, 54, 36)];
    [fourthAgeButton setTitle:@"65+" forState:UIControlStateNormal];
    [self.view addSubview:fourthAgeButton];
    
    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(fourthAgeButton.frame) + 25, CGRectGetWidth(self.view.frame), 20)];
    notificationLabel.text = @"Notifications";
    notificationLabel.textAlignment = NSTextAlignmentCenter;
    notificationLabel.textColor = [UIColor appBlueColor];
    [self.view addSubview:notificationLabel];
    
    UISwitch *notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    notificationSwitch.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(notificationLabel.frame) + CGRectGetHeight(notificationSwitch.frame)*0.5 + 15);
    notificationSwitch.onTintColor = [UIColor appBlueColor];
    [self.view addSubview:notificationSwitch];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(notificationSwitch.frame) + 25, CGRectGetWidth(self.view.frame), 20)];
    dateLabel.text = @"Notification time";
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [UIColor appBlueColor];
    [self.view addSubview:dateLabel];
    
    
    TimePicker *timePicker = [[TimePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateLabel.frame), CGRectGetWidth(self.view.frame), 80)];
    [self.view addSubview:timePicker];
     
    
    /*
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateLabel.frame) + 10, CGRectGetWidth(self.view.frame), 200)];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    [datePicker setDatePickerMode:UIDatePickerModeTime];
    
    [self.view addSubview:datePicker];
     */
     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
