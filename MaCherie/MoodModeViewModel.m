//
//  MoodModeViewModel.m
//  MaCherie
//
//  Created by Mathieu Skulason on 19/11/15.
//  Copyright © 2015 Mathieu Skulason. All rights reserved.
//

#import "MoodModeViewModel.h"
#import "GWDataManager.h"
#import "GWImage.h"
#import "GWLocalizedBundle.h"
#import "NSArray+Extension.h"
#import "ConstantsManager.h"
#import "UserDefaults.h"
#import "GWIntention.h"


@interface MoodDataObject : NSObject

@property (nonatomic, strong) GWImage *moodImage;
// has three different keys fr-FR, en-EN and es-ES for the labels
@property (nonatomic, strong) NSDictionary *moodImageNamesDict;

@property (nonatomic, strong) NSString *moodName;
@property (nonatomic, strong) UIImage *moodNormalImage;



@end

@implementation MoodDataObject



@end

@interface MoodModeViewModel () {
    GWDataManager *_dataMan;
    NSMutableArray *_themeData;
    NSMutableArray *_themeImages;
    
    NSArray *_themeComposedData;
    NSMutableArray *_themeRandomComposedData;
    
    NSMutableArray *_randomThemeData;
    NSMutableArray *_randomThemeImages;
    
    BOOL _isRandomTheme;
}

@end

@implementation MoodModeViewModel

-(id)init {
    if (self = [super init]) {
        _dataMan = [[GWDataManager alloc] init];
        _themeImages = [[NSMutableArray alloc] init];
        _themeRandomComposedData = [NSMutableArray array];
        _isRandomTheme = YES;
    }
    
    return self;
}

-(void)reset {
    [self randomizeComposedData];
}

-(void)downloadThemesWithCompletion:(void (^)(NSArray *, NSError *))block {
    [block copy];
    
    [_dataMan downloadImageThemesWithCompletion:^(NSDictionary *theImageThemes, NSError *error) {
        
        _themeData = [theImageThemes valueForKey:@"Themes"];
        _randomThemeData = _themeData;
        
        NSMutableArray *imageUrls = [NSMutableArray array];
        
        for (NSDictionary *currentTheme in _themeData) {
            NSString *partialImagePath = [currentTheme objectForKey:@"DefaultImage"];
            NSString *composedURL = [NSString stringWithFormat:@"/%@", partialImagePath];
            [imageUrls addObject:composedURL];
        }
        
        __weak typeof (self) wSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            _themeImages = [NSMutableArray arrayWithArray:[_dataMan fetchImagesWithImagePaths:imageUrls]];
            _randomThemeImages = _themeImages;
            
            if (_themeImages != nil && _themeImages.count == _themeData.count) {
                _themeData = [wSelf themeDataWithImages:_themeImages themeData:_themeData];
                [wSelf randomizeThemeImages:_themeImages themeData:_themeData];
                
                _themeComposedData = [wSelf composedThemeDataWithImages:_themeImages withData:_themeData];
                [wSelf randomizeComposedData];
                //_randomThemeData = _themeData;
                block(_themeImages, nil);
            }
            else {
                
                if (_themeImages.count != 0) {
                    for (GWImage *image in _themeImages) {
                        for (int i = 0; i < imageUrls.count; i++) {
                            NSString *currentImage = [imageUrls objectAtIndex:i];
                            if ([currentImage isEqualToString:image.imageId]) {
                                [imageUrls removeObject:currentImage];
                            }
                        }
                    }
                }
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    [_dataMan downloadImagesWithUrls:imageUrls isRelativeURL:YES  withCompletion:^(NSArray *theImageIds, NSError *theError) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_themeImages addObjectsFromArray:[_dataMan fetchImagesWithImagePaths:theImageIds]];
                            _themeData = [wSelf themeDataWithImages:_themeImages themeData:_themeData];
                            
                            _themeComposedData = [wSelf composedThemeDataWithImages:_themeImages withData:_themeData];
                            [wSelf randomizeComposedData];
                            
                            [wSelf randomizeThemeImages:_themeImages themeData:_themeData];
                            
                            block(_themeImages, theError);
                        });
                        
                    }];
                    
                });
                
                
            }
            
        });
        
        
    }];
    
}

-(NSArray *)composedThemeDataWithImages:(NSMutableArray *)theImages withData:(NSMutableArray *)theData {
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSDictionary *dict in theData) {
        
        NSString *themeImageId = [NSString stringWithFormat:@"/%@", [dict objectForKey:@"DefaultImage"]];
        
        for (GWImage *image in theImages) {
            NSString *imageId = image.imageId;
            
            if ([themeImageId isEqualToString:imageId]) {
                
                MoodDataObject *dataObj = [[MoodDataObject alloc] init];
                dataObj.moodImageNamesDict = dict;
                dataObj.moodImage = image;
                
                [mutableArray addObject:dataObj];
                
                break ;
            }
            
        }
        
    }
    
    return mutableArray;
}

#pragma mark - Normal Theme Image/Data access

-(NSMutableArray*)themeDataWithImages:(NSArray*)theImages themeData:(NSArray *)theThemeData {
    
    NSMutableArray *themesWithImages = [NSMutableArray array];
    
    for (NSDictionary *themes in theThemeData) {
        NSString *imageId = [NSString stringWithFormat:@"/%@", [themes objectForKey:@"DefaultImage"]];
        
        for (GWImage *image in theImages) {
            if ([imageId isEqualToString:image.imageId]) {
                [themesWithImages addObject:themes];
                break;
            }
        }
    }
    
    return themesWithImages;
}

-(NSInteger)numThemeImages {
    return _themeImages.count;
}

-(UIImage *)imageThemeAtIndex:(NSInteger)theIndex {
    if (theIndex >= _themeImages.count) {
        NSLog(@"ERROR: ");
        return nil;
    }
    
    GWImage *themeImage = [_themeImages objectAtIndex:theIndex];
    
    return [UIImage imageWithData:themeImage.imageData];
}

-(NSString*)themeNameAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _themeData.count) {
        return nil;
    }
    
    
    NSDictionary *dict = [_themeData objectAtIndex:theIndex];
    NSArray *themeLanguageTranslations = [dict objectForKey:@"Labels"];
    
    for (NSDictionary *languageDict in themeLanguageTranslations) {
        if ([(NSString*)[languageDict objectForKey:@"Language"] isEqualToString:[GWLocalizedBundle currentLocaleAPIString]]) {
            return [languageDict objectForKey:@"Label"];
        }
    }
    
    return @"";
}


#pragma mark - Random Theme Image/Data access

-(void)randomizeComposedData {
    
    _themeRandomComposedData = [NSMutableArray arrayWithArray:[NSArray randomIndexesFromArray:_themeComposedData withNumRandomIndexes:4]];
    
    // add the normal button to go back
    if (_isRandomTheme == NO) {
        MoodDataObject *dataObj = [[MoodDataObject alloc] init];
        dataObj.moodName = @"Normal";
        dataObj.moodNormalImage = [UIImage imageNamed:@"randomImage.png"];
        [_themeRandomComposedData insertObject:dataObj atIndex:0];
        
    }
}

-(void)randomizeThemeImages:(NSMutableArray *)theThemeImages themeData:(NSMutableArray *)theThemeData  {
    _randomThemeImages = [NSMutableArray arrayWithArray:[NSArray randomIndexesFromArray:theThemeImages withNumRandomIndexes:4]];
    _randomThemeData = [self themeDataWithImages:_randomThemeImages themeData:theThemeData];
    [self orderThemeImages:_randomThemeImages withThemeData:_randomThemeData];
    
    if (_isRandomTheme == NO) {
        UIImage *normalTheme = [UIImage imageNamed:@"randomImage.png"];
        NSDictionary *normalThemeData = @{ @"Labels" : @[ @{ @"Language" : @"fr-FR", @"Label" : @"Normal"} , @{ @"Language" : @"en-EN", @"Label" : @"Normal" }, @{ @"Language" : @"es-ES", @"Label" : @"Normal" } ] };
                
        [_randomThemeImages insertObject:normalTheme atIndex:0];
        [_randomThemeData insertObject:normalThemeData atIndex:0];
    }
    
}

-(void)orderThemeImages:(NSMutableArray *)theThemeImages withThemeData:(NSMutableArray *)theThemeData {
    for (int i = 0; i < theThemeImages.count; i++) {
        GWImage *currentImage = [theThemeImages objectAtIndex:i];
        
        for (int k = 0; k < theThemeData.count; k++) {
            NSDictionary *currentThemeData = [theThemeData objectAtIndex:k];
            NSString *themeImagePath = [NSString stringWithFormat:@"%@%@", @"/", [currentThemeData objectForKey:@"DefaultImage"]];
            
            if ([themeImagePath isEqualToString:currentImage.imageId] == YES) {
                [theThemeData exchangeObjectAtIndex:k withObjectAtIndex:i];
            }
            
        }
        
        
    }
}

-(NSInteger)numRandomThemeImages {
    return _randomThemeImages.count;
}

-(UIImage*)randomImageThemeAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _themeRandomComposedData.count) {
        return nil;
    }
    
    MoodDataObject *dataObj = [_themeRandomComposedData objectAtIndex:theIndex];
    
    if (dataObj.moodImage != nil) {
        return [UIImage imageWithData:dataObj.moodImage.imageData];
    }
    else {
        return dataObj.moodNormalImage;
    }
    
}

-(NSString*)randomThemeNameAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _themeRandomComposedData.count) {
        return nil;
    }
    
    MoodDataObject *dataObj = [_themeRandomComposedData objectAtIndex:theIndex];
    
    NSDictionary *dict = dataObj.moodImageNamesDict;
    NSArray *themeLanguageTranslations = [dict objectForKey:@"Labels"];
    
    for (id languageDict in themeLanguageTranslations) {
        if ([languageDict isKindOfClass:[NSDictionary class]]) {
            if ([(NSString*)[(NSDictionary *)languageDict objectForKey:@"Language"] isEqualToString:[GWLocalizedBundle currentLocaleAPIString]]) {
                return [languageDict objectForKey:@"Label"];
            }
        }
    }
    
    return dataObj.moodName;
    
}

-(NSString*)randomThemePathAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _themeRandomComposedData.count) {
        return nil;
    }
    
    MoodDataObject *dataObject = [_themeRandomComposedData objectAtIndex:theIndex];
    
    if (dataObject.moodImageNamesDict != nil) {
        return [NSString stringWithFormat:@"/%@", (NSString*)[dataObject.moodImageNamesDict objectForKey:@"Path"]];
    }
    else  {
        return @"Random";
    }
    
}

-(void)setIsRandomTheme:(BOOL)isRandomTheme {
    _isRandomTheme = isRandomTheme;
}

-(BOOL)isRandomThemeAtIndex:(NSInteger)theIndex {
    
    if (theIndex >= _themeRandomComposedData.count) {
        return NO;
    }
    
    MoodDataObject *dataObj = [_themeRandomComposedData objectAtIndex:theIndex];
    
    if (dataObj.moodNormalImage != nil) {
        return YES;
    }
    
    
    return NO;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
