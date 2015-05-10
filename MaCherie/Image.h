//
//  Image.h
//  MaCherie
//
//  Created by Mathieu Skulason on 10/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageId;
@property (nonatomic, retain) NSString * theme;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSString * application;

@end
