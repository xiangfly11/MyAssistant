//
//  SlideMenuViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/31.
//  Copyright © 2015年 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlideMenuItems;
@interface SlideMenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>


@property (nonatomic) SlideMenuItems* menuItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
