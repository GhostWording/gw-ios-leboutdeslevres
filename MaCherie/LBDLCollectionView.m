//
//  LBDLCollectionView.m
//  MaCherieiPad
//
//  Created by Mathieu Skulason on 02/06/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "LBDLCollectionView.h"
#import "LBDLCollectionViewModel.h"
#import "ImageCollectionViewCell.h"
#import "TextCollectionViewCell.h"
#import "Text.h"
#import "Image.h"
#import "UIColor+Extension.h"

@interface LBDLCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    LBDLCollectionViewModel *model;
    
}

@property (nonatomic, strong) NSIndexPath *selectedImageIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedTextIndexPath;
@property (nonatomic, strong) ImageCollectionViewCell *selectedImageCell;
@property (nonatomic, strong) TextCollectionViewCell *selectedTextCell;


@end

@implementation LBDLCollectionView

static NSString *imageCellIdentifier = @"imageCellIdentifier";
static NSString *textCellIdentifier = @"textCellIdentifier";

#pragma mark - Initializers

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:imageCellIdentifier];
        [self registerClass:[TextCollectionViewCell class] forCellWithReuseIdentifier:textCellIdentifier];
        model = [[LBDLCollectionViewModel alloc] init];
        
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout andTexts:(NSArray *)theTexts andImages:(NSArray *)theImages {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:imageCellIdentifier];
        [self registerClass:[TextCollectionViewCell class] forCellWithReuseIdentifier:textCellIdentifier];
        model = [[LBDLCollectionViewModel alloc] initCollectionViewModelWithTexts:theTexts andImages:theImages];
    }
    
    return self;
}

#pragma mark - Collection View Flow Layout Delegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) / 4.0;
    
    
    return CGSizeMake(width, width);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - Collection View Data Source

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [model randomImagesAndTexts].count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"collection view cell");
    
    NSArray *cellContent = [model randomImagesAndTexts];
    id imageOrText = [cellContent objectAtIndex:indexPath.row];
    
    
    if ([imageOrText isKindOfClass:[Text class]]) {

        TextCollectionViewCell *textCell = (TextCollectionViewCell*)[self dequeueReusableCellWithReuseIdentifier:textCellIdentifier forIndexPath:indexPath];
        
        if (self.selectedTextIndexPath != indexPath) {
            
            [textCell resetCell];
        }
        else {
            
            [textCell animateIntoBorder];
            // reset the selected cell if it happens to be deleted
            self.selectedTextCell = textCell;
        }
        
        Text *theText = [cellContent objectAtIndex:indexPath.row];
        textCell.textLabel.text = theText.content;
        
        return textCell;
        
    }
    else if([imageOrText isKindOfClass:[Image class]]) {
        NSLog(@"image cell");
        ImageCollectionViewCell *imageCell = (ImageCollectionViewCell*)[self dequeueReusableCellWithReuseIdentifier:imageCellIdentifier forIndexPath:indexPath];
        
        if (self.selectedImageIndexPath != indexPath) {
            [imageCell resetCell];
        }
        else {
            [imageCell animateIntoBorder];
            self.selectedImageCell = imageCell;
        }
        
        Image *theImage = [cellContent objectAtIndex:indexPath.row];
        imageCell.imageView.image = [UIImage imageWithData:theImage.imageData];
        
        return imageCell;
    }
    
    return nil;
}

#pragma mark - Cell Selection

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected item at index path");
    
    //NSArray *cellContent = [model randomImagesAndTexts];
    //id imageOrText = [cellContent objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[TextCollectionViewCell class]]) {
        
        TextCollectionViewCell *textCell = (TextCollectionViewCell*)cell;
        
        if (self.selectedTextIndexPath != indexPath) {

            [self.selectedTextCell animateOutBorder];
            self.selectedTextCell = textCell;
            self.selectedTextIndexPath = indexPath;
            [textCell animateIntoBorder];
            
        }
    }
    else if ([cell isKindOfClass:[ImageCollectionViewCell class]]) {
        
        ImageCollectionViewCell *imageCell = (ImageCollectionViewCell*)cell;
        
        if (self.selectedImageIndexPath != indexPath) {
            [self.selectedImageCell animateOutBorder];
            self.selectedImageCell = imageCell;
            self.selectedImageIndexPath = indexPath;
            [imageCell animateIntoBorder];
        }
        
        
    }
    
    // if we have selected both a text and an image send a delegate call
    if (self.selectedTextCell != nil && self.selectedImageCell != nil) {
        NSIndexPath *textPath = [self indexPathForCell:self.selectedTextCell];
        NSIndexPath *imagePath = [self indexPathForCell:self.selectedImageCell];
        
        Text *theText = (Text*)[[model randomImagesAndTexts] objectAtIndex:textPath.row];
        Image *theImage = (Image*)[[model randomImagesAndTexts] objectAtIndex:imagePath.row];
        
        
        [_selectionDelegate selectedImage:theImage andSelectedText:theText];
    }
    
}

-(void)resetSelection {
    [self.selectedImageCell animateOutBorder];
    [self.selectedTextCell animateOutBorder];
    
    self.selectedImageIndexPath = nil;
    self.selectedTextIndexPath = nil;
    self.selectedImageCell = nil;
    self.selectedTextCell = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
