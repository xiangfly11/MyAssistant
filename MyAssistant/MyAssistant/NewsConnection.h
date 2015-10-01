//
//  NewsConnection.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/9/1.
//  Copyright © 2015年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsConnectionDelegate.h"

@interface NewsConnection : NSObject


-(void) connectData;

@property (weak,nonatomic) id<NewsConnectionDelegate> delegate;



@end
