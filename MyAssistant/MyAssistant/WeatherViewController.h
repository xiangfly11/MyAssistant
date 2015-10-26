//
//  WeatherViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/22/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface WeatherViewController : UIViewController <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>


@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
