//
//  MainViewCell.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/2/15.
//  Copyright (c) 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *abstractLabel;
@end
