//
//  NewsManage.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/9/1.
//  Copyright © 2015年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsConnectionDelegate.h"
#import "NewsManageDelegate.h"
#import "NewsConnection.h"

@interface NewsManage : NSObject <NewsConnectionDelegate>

-(void) connectEntries;

@property (nonatomic,weak) id<NewsManageDelegate> delegate;
@property (nonatomic,strong) NewsConnection *newsConnection;


@end
