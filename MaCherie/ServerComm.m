//
//  ServerComm.m
//  MaCherie
//
//  Created by Mathieu Skulason on 07/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#import "ServerComm.h"
#import "AppDelegate.h"
#import "Text.h"
#import "TagId.h"
#import "Image.h"

#define APP_PREFIX @"http://api.cvd.io"
#define AREA @"SweetheartDaily"

#define IMAGE_PREFIX @"http://gw-static.azurewebsites.net"


@interface ServerComm () {
    NSManagedObjectContext *context;
    NSPersistentStoreCoordinator *persistentStore;
    NSArray *intentionNames;
    NSDateFormatter *dateFormatter;
}

@end

@implementation ServerComm

-(id)init {
    if (self = [super init]) {
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        context = delegate.managedObjectContext;
        persistentStore = delegate.persistentStoreCoordinator;
        dateFormatter = [[NSDateFormatter alloc] init];
        intentionNames = @[@"I-want-you", @"there-is-something-missing", @"thank-you", @"I-miss-you", @"I-love-you", @"I-think-of-you", @"positive-thoughts", @"a-few-words-for-you", @"facebook-status", @"jokes", @"surprise-me"];
    }
    
    return self;
}


#pragma mark - 
#pragma mark Image Downloading

-(void)downloadImagesWithCompletion:(void (^)(BOOL, NSError *))block {
    [block copy];
    
    
    
}

-(void)downloadNumImages:(int)numImages withCompletion:(void (^)(BOOL finished, NSError *))block {
    [block copy];
    
    NSLog(@"downloading images");
        
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/container/cvd/sweetheart?size=small", IMAGE_PREFIX]];
    NSURL *url = [NSURL URLWithString:@"http://gw-static.azurewebsites.net/container/cvd/sweetheart/istockpairs?size=small"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"fr-FR" forHTTPHeaderField:@"Accept-Language"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            
            __weak __block ServerComm *weakSelf = self;
            
            NSMutableArray *containerArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            [weakSelf downloadImagesForContainers:containerArray withCompletion:^(NSMutableArray *imagePathsToDownload, NSManagedObjectContext *managedContext, NSError *error) {
                
                for (int i = 0; i < numImages; i++) {
                    [weakSelf downloadImagesWithURLArray:imagePathsToDownload andManagedContext:managedContext];
                }
                
            }];
        }
    }];
    
}

-(void)downloadImagesForContainers:(NSArray*)containers withCompletion:(void (^)(NSMutableArray *imagePathsToDownload, NSManagedObjectContext *managedContext, NSError *error))block {
    
    [block copy];
    
    NSDictionary *dict = [containers objectAtIndex:0];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/container/files%@", IMAGE_PREFIX, dict[@"id"]]];
    NSLog(@"url is: %@", [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX, dict[@"id"]]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"fr-FR" forHTTPHeaderField:@"Accept-Language"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSMutableArray *imagePaths = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
            [newContext setPersistentStoreCoordinator:persistentStore];
            
            // fetch the images we stored
            NSArray *imageArray = [newContext executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Image"] error:nil];
            NSLog(@"number of images: %d", imageArray.count);

            [self removeImagesInArray:imagePaths imageArray:imageArray];
            
            block(imagePaths, newContext, nil);
        }
    }];
}

// remove all the images that we already have
-(void)removeImagesInArray:(NSMutableArray*)downloadArray imageArray:(NSArray*)imageArray {
    
    for (int i = 0; i < imageArray.count; i++) {
        Image *img = [imageArray objectAtIndex:i];
        [self removeImageWithUrl:img.imageId inArray:downloadArray];
    }
}

-(void)removeImageWithUrl:(NSString*)theUrl inArray:(NSMutableArray*)theArray {
    
    for (int i = 0; i < theArray.count; i++) {
        NSString *string = [theArray objectAtIndex:i];
        
        if ([string isEqual:[NSNull null]]) {
            
            [theArray removeObjectAtIndex:i];
        } else {
            if ([string isEqualToString:theUrl]) {
                [theArray removeObjectAtIndex:i];
            }
        }
    }
}


-(void)downloadImagesWithURLArray:(NSMutableArray*)array andManagedContext:(NSManagedObjectContext*)managedContext {
    
    
    if (array && array.count != 0) {
        int randomPos = rand() % array.count;
        NSString *imagePostfix = [array objectAtIndex:randomPos];
        
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGE_PREFIX, imagePostfix]];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        
        Image *imageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedContext];
        imageObject.imageData = imageData;
        imageObject.imageId = imagePostfix;
        
        [self saveContextChanges:managedContext];
        
        // use a block to send the data back if the save succeeded and the image has been loaded
        [array removeObjectAtIndex:randomPos];
    }
    
}

#pragma mark - 
#pragma mark Text downloading

-(void)downloadTexts {
    [self downloadTextsArray:intentionNames atIndex:0];
}

-(void)downloadTextsArray:(NSArray*)array atIndex:(int)index
{
    if (index < array.count) {
        NSString *intentions = [array objectAtIndex:index];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/texts?relationtype=9E2D23&filtervalue=relationtype", APP_PREFIX, AREA, intentions]];
        NSLog(@"the array is: %@", [NSString stringWithFormat:@"%@/%@/%@/texts?relationtype=9E2D23&filtervalue=relationtype", APP_PREFIX, AREA, intentions]);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"fr-FR" forHTTPHeaderField:@"Accept-Language"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *request, NSData *data, NSError *error){
            
            NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] init];
            [newContext setPersistentStoreCoordinator:persistentStore];
            
            if (!error) {
                NSMutableArray *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //NSLog(@"the dictionary: %@", jsonDict);
                
                NSEntityDescription *textEntity = [NSEntityDescription entityForName:@"Text" inManagedObjectContext:newContext];
                NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:textEntity.name];
                NSArray *textsArray = [newContext executeFetchRequest:fetch error:nil];
                
                __weak typeof (self) xSelf = self;
                
                for (NSDictionary *textDict in jsonDict) {
                    [xSelf textExists:textDict withArray:textsArray andContext:newContext update:YES];
                }
                
                [xSelf saveContextChanges:newContext];
                
                //NSLog(@"first object is: %@", [jsonDict objectAtIndex:0]);
                NSLog(@"intention is: %@ with number of texts: %d", intentions, jsonDict.count);
                
                
                [xSelf downloadTextsArray:array atIndex:index + 1];
                
            }
            else {
                NSLog(@"error downloading texts: %@", error.userInfo);
            }
        }];
    } else {
        NSLog(@"succeeded");
    }
}

-(BOOL)textExists:(NSDictionary*)textDict withArray:(NSArray*)array andContext:(NSManagedObjectContext*)tmpContext update:(BOOL)shouldUpdate {
    
    //NSLog(@"text dictionary: %@", textDict);
    //NSLog(@"updating");
    
    for (Text *text in array) {
        if ([[text textId] isEqualToString:[textDict valueForKey:@"TextId"]]) {
            
            if (shouldUpdate) {
                [self updateText:text andNewTextData:textDict andContext:tmpContext];
                return YES;
            }

        }
    }
    NSLog(@"Adding text");
    [self addText:textDict andContext:tmpContext];
    return NO;
}

-(void)addText:(NSDictionary*)textDict andContext:(NSManagedObjectContext*)bkgContext {
    
    Text *text = [NSEntityDescription insertNewObjectForEntityForName:@"Text" inManagedObjectContext:bkgContext];
    
    [self updateText:text andNewTextData:textDict andContext:bkgContext];
}

-(void)updateText:(Text*)theText andNewTextData:(NSDictionary*)textDict andContext:(NSManagedObjectContext*)bkgContext {
    
    if (textDict[@"Abstract"] != [NSNull null]) {
        [theText setAbstract:textDict[@"Abstract"]];
    }
    
    [theText setAuthor:textDict[@"Author"]];
    [theText setContent:textDict[@"Content"]];
    [theText setCulture:textDict[@"Culture"]];
    [theText setImpersonal:textDict[@"Impersonal"]];
    [theText setIntentionId:textDict[@"IntentionId"]];
    
    if (textDict[@"IntentionLabel"] != [NSNull null]) {
        [theText setIntentionLabel:textDict[@"IntentionLabel"]];
    }
    
    [theText setIsQuote:textDict[@"IsQuote"]];
    [theText setPoliteForm:textDict[@"PoliteForm"]];
    [theText setPrototypeId:textDict[@"PrototypeId"]];
    [theText setProximity:textDict[@"Proximity"]];
    [theText setSender:textDict[@"Sender"]];
    [theText setSortBy:textDict[@"SortBy"]];
    [theText setStatus:textDict[@"Status"]];
    [theText setTarget:textDict[@"Target"]];
    [theText setTextId:textDict[@"TextId"]];
    
    // check the format of the update date
    [dateFormatter setDateFormat:@"yyyy'-'mm'-'dd'T'HH:mm:ss.SSS"];
    NSString *dateString = textDict[@"Updated"];
    
    if (![dateFormatter dateFromString:dateString]) {
        
        [dateFormatter setDateFormat:@"yyyy'-'mm'-'dd'T'HH:mm:ss"];
        
        if (![dateFormatter dateFromString:dateString]) {
            [theText setUpdateDate:[NSDate date]];
        }
        else {
            [theText setUpdateDate:[dateFormatter dateFromString:dateString]];
        }
    }
    else {
        [theText setUpdateDate:[dateFormatter dateFromString:dateString]];
    }
    
    NSArray *tags = textDict[@"TagIds"];
    NSMutableOrderedSet *mutableSet = [[NSMutableOrderedSet alloc] init];
    
    for (id tagId in tags) {
        TagId *tag = [NSEntityDescription insertNewObjectForEntityForName:@"TagId" inManagedObjectContext:bkgContext];
        tag.tagId = tagId;
        tag.text = theText;
        [mutableSet addObject:tag];
    }
    
    theText.tagIds = mutableSet;
}

-(void)saveContextChanges:(NSManagedObjectContext*)managedObjectContext {
    NSLog(@"saving context");
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
