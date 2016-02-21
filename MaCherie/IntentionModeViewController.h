//
//  IntentionModeViewController.h
//  LeRoiDuStatutFacebook
//
//  Created by Mathieu Skulason on 19/01/16.
//  Copyright © 2016 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GWIntention;

@interface IntentionModeViewController : UIViewController

-(void)selectedIntentionChosenWithCompletion:(void (^)(GWIntention *theImages))block;

@end
