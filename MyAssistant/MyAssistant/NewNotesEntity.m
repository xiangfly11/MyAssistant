//
//  NewNotesEntity.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/9/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import "NewNotesEntity.h"


@implementation NewNotesEntity

@dynamic body;
@dynamic title;
@dynamic location;
@dynamic date;


-(NSString *) sectionName {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.date];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"MM dd yyyy"];
    
    
    return [dateFormatter stringFromDate:date];
    
}


@end
