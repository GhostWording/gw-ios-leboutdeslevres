//
//  ServerComm.h
//  MaCherie
//
//  Created by Mathieu Skulason on 07/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ServerComm : NSObject

-(void)downloadTexts;
-(void)downloadTextsWithCompletion:(void (^)(BOOL finished, NSError *error))block;


-(void)downloadNumImages:(int)numImages withCompletion:(void (^)(BOOL finished, NSError *error))block;

@end
