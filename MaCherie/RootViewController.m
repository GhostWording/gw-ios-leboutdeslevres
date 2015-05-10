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
#import "DataManager.h"
#import "UIColor+Extension.h"
#import "UIFont+ArialAndHelveticaNeue.h"
#import "UIViewController+Extension.h"
#import "AppDelegate.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "UIImage+RenderViewToImage.h"
#import "UIView+RenderViewToImage.h"
#import "NSString+TextHeight.h"

const float bottomHeight = 50.0f;

@interface RootViewController ()
{
    UIScrollView *imageScrollView;
    UIScrollView *textScrollView;
    TextScrollView *theScrollView;
    ImageScrollView *theImageScrollView;
    UILabel *firstLabel;
}

@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    /*
    imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20)];
    imageScrollView.pagingEnabled = YES;
    imageScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*3.0f, CGRectGetHeight(imageScrollView.frame));
    imageScrollView.showsHorizontalScrollIndicator = NO;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.png"]];
    imageView1.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(imageScrollView.frame));
    imageView1.contentMode = UIViewContentModeScaleAspectFill;
    [imageScrollView addSubview:imageView1];
    */
    
     DataManager *dataMan = [[DataManager alloc] init];
    
    theImageScrollView = [[ImageScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 + 20) andImages:[dataMan randomImagesForNumberOfImages:8]];
    [self.view addSubview:theImageScrollView];
    
    [self.view addSubview:imageScrollView];
    
    UIView *settingsView = [[UIView alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    settingsView.backgroundColor = [UIColor appLightGrayColor];
    settingsView.layer.cornerRadius = 4.0f;
    [self.view addSubview:settingsView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(6, 6, 18, 18);
    button.tintColor = [UIColor appBlueColor];
    [button setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [settingsView addSubview:button];
    
    
    UIPageControl *topPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageScrollView.frame) - 20, CGRectGetWidth(self.view.frame), 20)];
    topPageControl.numberOfPages = 8;
    topPageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
    topPageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
    [self.view addSubview:topPageControl];
    
    /*
    textScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageScrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 - bottomHeight - 20)];
    textScrollView.pagingEnabled = YES;
    textScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*3.0f, CGRectGetHeight(textScrollView.frame));
    textScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:textScrollView];
    
    UIPageControl *bottomPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(textScrollView.frame), CGRectGetWidth(self.view.frame), 20)];
    bottomPageControl.numberOfPages = 8;
    bottomPageControl.pageIndicatorTintColor = [UIColor appLightGrayColor];
    bottomPageControl.currentPageIndicatorTintColor = [UIColor appBlueColor];
    [self.view addSubview:bottomPageControl];
     */
    
    
    theScrollView = [[TextScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(theImageScrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)*0.5 - bottomHeight - 20) andTexts:[dataMan randomTextsForGender:nil numTexts:8]];
    [self.view addSubview:theScrollView];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 80, CGRectGetMaxY(theScrollView.frame), 160, 40);
    bottomButton.layer.backgroundColor = [UIColor appBlueColor].CGColor;
    bottomButton.layer.cornerRadius = 4.0;
    [bottomButton setTitle:@"Send" forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateSelected];
    [bottomButton setTitleColor:[UIColor appLightGrayColor] forState:UIControlStateHighlighted];
    [bottomButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomButton];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedContext = delegate.managedObjectContext;
    
    NSArray *texts = [managedContext executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Text"] error:nil];
    
    NSLog(@"texts is: %d", texts.count);
    
    firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.1, 35, CGRectGetWidth(self.view.frame)*0.8, CGRectGetHeight(textScrollView.frame))];
    firstLabel.textAlignment = NSTextAlignmentCenter;
    firstLabel.numberOfLines = 0;
    firstLabel.text = @"It's been a while since we talked. How are you?";
    firstLabel.font = [UIFont helveticaNeueBoldWithSize:17.0f];
    firstLabel.frame = CGRectMake(CGRectGetMinX(firstLabel.frame), CGRectGetMinY(firstLabel.frame), CGRectGetWidth(firstLabel.frame), [UIViewController heightForText:firstLabel.text andWidth:CGRectGetWidth(firstLabel.frame) andFont:firstLabel.font]);
    [textScrollView addSubview:firstLabel];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login:(id)sender
{
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
}

-(void)sendButtonPressed
{
    //UIImage *image = [UIImage imageByRenderingView:self.view];
    
    UIImage *image = [UIImage imageNamed:@"1.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [imageView setImage:image];
    
    double fontSize = image.size.width / 20.0f;
    //UIFont *font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:fontSize];
    UIFont *font = [UIFont fontWithName:@"Noteworthy-Bold" size:fontSize];
    
    CGFloat heightForText = [firstLabel.text heightForTextWithdWidth:image.size.width*0.9 andFont:font];
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(imageView.frame)*0.05, CGRectGetMaxY(imageView.frame) + 20, CGRectGetWidth(imageView.frame) * 0.9, heightForText + 4)];
    newLabel.textAlignment = NSTextAlignmentCenter;
    newLabel.numberOfLines = 0;
    newLabel.font = font;
    newLabel.text = firstLabel.text;
    newLabel.textColor = [UIColor blackColor];
    
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, CGRectGetMaxY(newLabel.frame) + 40)];
    newView.backgroundColor = [UIColor whiteColor];
    [newView addSubview:imageView];
    [newView addSubview:newLabel];
    
    UIImage *snapshotView = [newView imageByRenderingView];
    
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        [FBSDKMessengerSharer shareImage:snapshotView withOptions:nil];
    }
    
    /*
    UIImage *image = [self.view imageByRenderingView];
    NSLog(@"image is: %@", image);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    [self.view addSubview:imageView];
    
    NSLog(@"added image view");
    */
    
    /*
    if ([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage) {
        UIImage *image = [UIImage imageNamed:@"1.png"];
        
        [FBSDKMessengerSharer shareImage:image withOptions:nil];
    }
     */
}

@end
