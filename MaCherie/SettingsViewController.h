//
//  SettingsViewController.h
//  MaCherie
//
//  Created by Mathieu Skulason on 03/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

-(void)changedLanguageWithCompletion:(void (^)(void))block;

@end
