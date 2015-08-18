//
//  ConstantsManager.h
//  MaCherie
//
//  Created by Mathieu Skulason on 09/08/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConstantsManager : NSObject

@property (nonatomic, readonly) NSString *area;
@property (nonatomic, readonly) NSString *specialOccasionArea;

+(instancetype)sharedInstance;

@end
