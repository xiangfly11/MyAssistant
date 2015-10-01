//
//  Entry.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/28.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NewsEntry : NSObject

@property (nonatomic,strong) NSString *newsTitle;
@property (nonatomic,strong) UIImage *newsSmallImage;
@property (nonatomic,strong) UIImage *newsLargeImage;
@property (nonatomic,strong) NSString *newsDate;
@property (nonatomic,strong) NSString *newsSection;
@property (nonatomic,strong) NSString *newsLocation;
@property (nonatomic,strong) NSString *newsAbstraction;
@property (nonatomic,strong) NSString *newsURL;



@end
