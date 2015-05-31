//
//  TimePicker.h
//  MaCherie
//
//  Created by Mathieu Skulason on 05/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimePicker : UIPickerView

-(void)setHour:(int)hour andMinute:(int)minute;
-(NSString*)currentStringInComponent:(NSInteger)component;

// a value to indicate if the value of the picker has been changed
// during the duration of its lifetime, if it hasn't been interacted
// with it has not been changed
-(BOOL)hasChanged;

@end
