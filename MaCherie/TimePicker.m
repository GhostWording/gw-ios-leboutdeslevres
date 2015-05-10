//
//  TimePicker.m
//  MaCherie
//
//  Created by Mathieu Skulason on 05/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "TimePicker.h"
#import "UIColor+Extension.h"

@interface TimePicker () <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSMutableArray *hours;
    NSMutableArray *minutes;
}

@end

@implementation TimePicker

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.dataSource = self;
        self.showsSelectionIndicator = YES;
        
        hours = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 24; i++) {
            NSString *hourString;
            
            if (i < 10) {
                hourString = [NSString stringWithFormat:@"0%d", i];
            }
            else {
                hourString = [NSString stringWithFormat:@"%d", i];
            }
            
            [hours addObject:hourString];
        }
        
        minutes = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 60; i++) {
            NSString *minuteString;
            
            if (i < 10) {
                minuteString = [NSString stringWithFormat:@"0%d", i];
            }
            else {
                minuteString = [NSString stringWithFormat:@"%d", i];
            }
            
            [minutes addObject:minuteString];
        }
    }
    
    return self;
}


#pragma mark - 
#pragma mark Picker View Delegate

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if(component == 1)
    {
        return 20;
    }
    
    return CGRectGetWidth(self.frame)/2.0 - 10;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGFloat width = [[pickerView delegate] pickerView:pickerView widthForComponent:component];
    CGFloat height = [[pickerView delegate] pickerView:pickerView rowHeightForComponent:component];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    label.textColor = [UIColor appBlueColor];
    
    
    if (component == 0) {
        label.frame = CGRectMake(0, 0, width - 10, height);
        label.text = (NSString*)[hours objectAtIndex:row];
        label.textAlignment = NSTextAlignmentRight;
        return label;
    }
    else if (component == 1) {
        label.text = @":";
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }
    else if(component == 2)
    {
        label.frame = CGRectMake(30, 0, width, height);
        label.text = (NSString*)[minutes objectAtIndex:row];
        label.textAlignment = NSTextAlignmentLeft;
        return label;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Picker View Data Source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 24;
    }
    else if(component == 1) {
        return 1;
    }
    else if(component == 2) {
        return 60;
    }
    
    return 0;
}

-(NSInteger)numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 24;
    }
    else if(component == 1) {
        return 60;
    }
    
    return 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
