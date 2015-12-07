//
//  MoodModeViewController.h
//  MaCherie
//
//  Created by Mathieu Skulason on 19/11/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoodModeViewController : UIView

-(void)reloadData;

-(void)themeChosenWithCompletion:(void (^)(NSString *themePath))block;

@end
