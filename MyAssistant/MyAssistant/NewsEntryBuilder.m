//
//  EntryBuilder.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/28.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "NewsEntryBuilder.h"
#import "NewsEntry.h"

@implementation NewsEntryBuilder

+(NSArray *) newsFromJson:(NSData *)objectData error:(NSError **)error {
    
    NSMutableArray *finalNewsArray = [[NSMutableArray alloc] init];
    
    NSError *localError = nil;
    
    NSDictionary *newsDictionary = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&localError];
    
    //NSLog(@"%@",newsDictionary);
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    
    NSArray *results = [newsDictionary objectForKey:@"results"];
    
    for (NSDictionary *dict in results) {
        NewsEntry *news = [[NewsEntry alloc] init];
        
        news.newsSection = [dict objectForKey:@"section"];
        
        news.newsTitle = [dict objectForKey:@"title"];
        
        news.newsAbstraction = [dict objectForKey:@"abstract"];
        
        NSString *imageStr = [dict objectForKey:@"thumbnail_standard"];
        
        NSURL *imageURL = [NSURL URLWithString:imageStr];
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        UIImage *imageIcon = [UIImage imageWithData:imageData];
        
        news.newsSmallImage = imageIcon;
        
        news.newsURL = [dict objectForKey:@"url"];
//        
//        news.newsDate = [dict objectForKey:@"updated_date"];
//        
//        NSArray *mutimedia = [dict objectForKey:@"multimedia"];
//        
//        
//        NSDictionary *tempDict = mutimedia[1];
//        
//        NSString *imageStr2 = [tempDict objectForKey:@"url"];
//        
//        NSURL *urlImage2 = [NSURL URLWithString:imageStr2];
//        
//        NSData *dataImage2 = [NSData dataWithContentsOfURL:urlImage2];
//        
//        UIImage *largeImage = [UIImage imageWithData:dataImage2];
//        
//        news.newsLargeImage = largeImage;
        
        
        [finalNewsArray addObject:news];
        //NSLog(@"fff================:%@",finalNewsArray);
    }
    
    //NSLog(@"finalArray:%@",finalNewsArray);
    
    return finalNewsArray;
    
    
}




@end
