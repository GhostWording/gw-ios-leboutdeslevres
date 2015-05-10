//
//  TagId.h
//  MaCherie
//
//  Created by Mathieu Skulason on 08/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Text;

@interface TagId : NSManagedObject

@property (nonatomic, retain) NSString * tagId;
@property (nonatomic, retain) Text *text;

@end
