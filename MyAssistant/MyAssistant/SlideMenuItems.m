//
//  SlideMenuItems.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/23.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "SlideMenuItems.h"

@implementation SlideMenuItems

-(instancetype) init{
    self = [super init];
    if (self) {
        _items = [NSArray arrayWithObjects:@"Title",@"News",@"Weather",@"Map",@"Notes", nil];
    }
    
    
    return  self;
}



@end
