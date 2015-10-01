//
//  NewsCoreDataStack.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/28.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "NotesCoreDataStack.h"

@implementation NotesCoreDataStack


#pragma mark - Core Data Stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+(instancetype) defaultStack {
    static NotesCoreDataStack *coreDataStack;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        coreDataStack = [[self alloc] init];
    });
    
    return coreDataStack;
}



- (NSURL *)applicationDocumentsDirectory  {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    //NSLog(@"%@",url);
    
    return url;
}


-(NSManagedObjectModel *) managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return  _managedObjectModel;
    }
    
    
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    return _managedObjectModel;
}




-(NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CurrentMyAssistant.sqlite"];
    
    NSError *error = nil;
    
    NSString *failedReason = @"There is a error";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary    dictionary];
        
        
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        
        dict[NSLocalizedFailureReasonErrorKey] = failedReason;
        
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    return _persistentStoreCoordinator;
    
    
}


-(NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
    
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
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
