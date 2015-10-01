//
//  NewsManageDelegate.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/9/1.
//  Copyright © 2015年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewsManageDelegate <NSObject>

-(void) didReceiveNewsEntries:(NSArray *) newsEntries;
-(void) connectionFailedWithError:(NSError *) error;

@end