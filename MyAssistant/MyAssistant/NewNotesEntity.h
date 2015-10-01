//
//  NewNotesEntity.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/9/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface NewNotesEntity : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * location;
@property (nonatomic) NSTimeInterval date;

@property (nonatomic,readonly) NSString *sectionName;
@end
