//
//  NewsManage.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/9/1.
//  Copyright © 2015年 Jiaxiang Li. All rights reserved.
//

#import "NewsManage.h"
#import "NewsEntryBuilder.h"

@implementation NewsManage

-(void) connectEntries {
    [self.newsConnection connectData];
    
}



-(void) receiveNewsJSON:(NSData *)newsData {
    
    NSError *error = nil;
    
    NSArray *newsEnties = [NewsEntryBuilder newsFromJson:newsData error:&error];
    
    if (error) {
        [self.delegate connectionFailedWithError:error];
    }else{
        
        //NSLog(@"%@",newsEnties);
        
        [self.delegate didReceiveNewsEntries:newsEnties];
    }
    
}


-(void) connectionFailedWithError:(NSError *)error {
    [self.delegate connectionFailedWithError:error];

}





@end
