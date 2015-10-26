//
//  NewsCoreDataStack.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/28.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject


@property (readonly,strong,nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly,strong,nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly,strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(instancetype) defaultStack;

-(void) saveContext;
-(NSURL *) applicationDocumentsDirectory ;

@end
