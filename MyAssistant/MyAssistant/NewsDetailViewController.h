//
//  NewsDetailViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/6/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailViewController : UIViewController

@property (nonatomic,strong) NSString *urlString;

@property (nonatomic,strong) IBOutlet UIWebView *webView;

@end
