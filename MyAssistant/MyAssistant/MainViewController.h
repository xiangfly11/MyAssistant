//
//  MainViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/21.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsManageDelegate.h"
#import "NewsManage.h"
@interface MainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NewsManageDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NewsManage *newsManage;

@end
