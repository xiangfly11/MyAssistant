//
//  WeatherViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/4/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
@interface WeatherViewController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) IBOutlet UIImageView *blurredImageView;

@property (strong,nonatomic) UITableView *tableView;

@end
