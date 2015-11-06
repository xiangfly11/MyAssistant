//
//  MainViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/21.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "NewsConnection.h"
#import "NewsEntry.h"
#import "MainViewCell.h"
#import "NewsDetailViewController.h"

#import "MainViewCellWithoutImage.h"

@interface MainViewController()

@property (nonatomic,strong) NSMutableArray *myNewsEntries;
@property (nonatomic) NSInteger selectedRowIndex;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    
    self.newsManage = [[NewsManage alloc]init];
    
    self.newsManage.newsConnection = [[NewsConnection alloc] init];
    
    self.newsManage.delegate = self;

    self.newsManage.newsConnection.delegate = self.newsManage;
    
    
    self.tableView.estimatedRowHeight = 368;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
//    self.loading = [[MBProgressHUD alloc] init];
//    
//    self.loading.labelText = @"LOADING";
//    
//    [self.view addSubview:self.loading];
    
    
    [self.newsManage connectEntries];
    
//    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        //[self.tableView.header beginRefreshing];
//        [self.newsManage connectEntries];
//        if (self.myNewsEntries.count != 0) {
//            [self.tableView.header endRefreshing];
//        }
//        
//    }];
    
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    //[self applicationDocumentsDirectory];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NewsDetailViewController *newsDetail = [segue destinationViewController];
    
    NewsEntry *selectedEntry = self.myNewsEntries[self.selectedRowIndex];
    
    newsDetail.urlString = selectedEntry.newsURL;
    
    //NSLog(@"title ======%@",selectedEntry.newsTitle);
    
    //NSLog(@"index =====%ld",self.selectedRowIndex);
    
    
    
}

#pragma mark - TableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.myNewsEntries count];
    
    
}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier1 = @"MainViewCell";
    static NSString *identifier2 = @"CellNoImage";
    
    NewsEntry *currentEntry = [[NewsEntry alloc] init];
    
    currentEntry = self.myNewsEntries[indexPath.row];
    
    if (currentEntry.newsSmallImage) {
        MainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        
        if (!cell) {
            cell = (MainViewCell *) [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        cell.titleLabel.text = currentEntry.newsTitle;
        cell.newsImage.image = currentEntry.newsSmallImage;
        cell.abstractLabel.text = currentEntry.newsAbstraction;
        
        return cell;
    }else {
        MainViewCellWithoutImage *cell = [tableView dequeueReusableCellWithIdentifier:identifier2 forIndexPath:indexPath];
        
        if (!cell) {
            cell = (MainViewCellWithoutImage *) [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        }
        cell.titleLabel.text = currentEntry.newsTitle;
        cell.abstractLabel.text = currentEntry.newsAbstraction;
        
        return cell;
        
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedRowIndex = indexPath.row;
    [self performSegueWithIdentifier:@"goToNewsDetail" sender:self];
    
    
}




#pragma mark - NewsManageDelegate

-(void) connectionFailedWithError:(NSError *)error {
    
    NSLog(@"The error is %@ %@",error,[error localizedDescription]);
}


-(void) didReceiveNewsEntries:(NSArray *)newsEntries {
    //[self.tableView.header endRefreshing];
    //[self.loading show:YES];
    
    self.myNewsEntries = [[NSMutableArray alloc] initWithArray:newsEntries];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        //[self.loading hide:YES];
    });
    
    
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "MyPractice.CoreData" in the application's documents directory.
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSLog(@"%@",url.absoluteString);
    
    return url;
    
    
}




@end
