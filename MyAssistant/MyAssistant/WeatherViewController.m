//
//  WeatherViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/4/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "WeatherViewController.h"
#import "SWRevealViewController.h"
#import "WeatherManager.h"
#import "WeatherClient.h"
@interface WeatherViewController ()<WeatherClientDelegate>{
    UILabel *temperatureLabel;
    UILabel *hiloLabel;
    UILabel *cityLabel;
    UILabel *conditionsLabel;
    UIImageView *iconView;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (strong,nonatomic) WeatherManager *weatherManager;
@property (strong,nonatomic) WeatherClient *weatherClient;
@property (strong,nonatomic) NSMutableArray *dailyArray;
@property (strong,nonatomic) NSMutableArray *hourlyArray;
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation WeatherViewController



-(void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    
    
    [self configureViews];
    
    //[[WeatherManager sharedManager] findCurrentLocation];
    self.weatherManager = [WeatherManager sharedManager];
    self.weatherClient = [[WeatherClient alloc] init];
    self.weatherManager.delegate = self.weatherClient;
    self.weatherClient.delegate = self;
    [self.weatherManager findCurrentLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) configureViews {
    UIImage *backgroundImage = [UIImage imageNamed:@"bg"];
    
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:backgroundImage blurRadius:10 completionBlock:nil];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    CGFloat inset = 40;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 70;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(20,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 2
    // bottom left
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0º";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:100];
    temperatureLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:temperatureLabel];
    
    // bottom left
    hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0º / 0º";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    hiloLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:hiloLabel];
    
    // top
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:conditionsLabel];
    
    // 3
    // bottom left
    iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];

}


#pragma UITableViewDataSource 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.hourlyArray.count+1;
        //return 3;
    }
    
    return self.dailyArray.count+1;
    //return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    //cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    NSLog(@"%ld",(long)indexPath.row);
    //WeatherCondition *hourlyCondition = self.hourlyArray[indexPath.row-1];
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forcast"];
        }else {
            WeatherCondition *hourlyCondition = self.hourlyArray[indexPath.row-1];
            [self configureHourlyCell:cell weatherCondition:hourlyCondition];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forcast"];
        }else {
            WeatherCondition *dailyCondition = self.dailyArray[indexPath.row-1];
            [self configureDailyCell:cell weatherCondition:dailyCondition];
        }
    }
    
    
    
    return  cell;
}


#pragma UITableVeiwDelegate 
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.view.bounds.size.height / (CGFloat)cellCount;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) passWeatherConditonToViewController:(WeatherCondition *)condition {
    cityLabel.text = condition.locationName;
    temperatureLabel.text = [NSString stringWithFormat:@"%.0fº",[condition.temperature floatValue]];
    iconView.image = [UIImage imageNamed:condition.icon];
    //hiloLabel.text = [NSString stringWithFormat:@"%.0fº/%.0fº",[condition.tempLow floatValue],[condition.tempHigh floatValue]];
    hiloLabel.text = [NSString stringWithFormat:@"%.0f %%",[condition.humidity floatValue]];
    conditionsLabel.text = condition.condition;
}

-(void) passDailyForcastToViewController:(NSMutableArray *)arrayDaily {
    self.dailyArray = [[NSMutableArray alloc] initWithArray:arrayDaily];
    
    NSLog(@"%lu",(unsigned long)self.dailyArray.count);
    [self.tableView reloadData];
    
}


-(void) passHourlyForcastToViewController:(NSMutableArray *)arrayHourly {
    self.hourlyArray = [[NSMutableArray alloc] initWithArray:arrayHourly];
    [self.tableView reloadData];
}


-(void) configureHeaderCell:(UITableViewCell *) cell title:(NSString *) titleStr {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = titleStr;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

-(void) configureHourlyCell:(UITableViewCell *) cell weatherCondition:(WeatherCondition *) hourlyCondition {
    self.hourlyFormatter = [[NSDateFormatter alloc] init];
    self.hourlyFormatter.dateFormat = @"h a";
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:hourlyCondition.date];
   
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",hourlyCondition.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:hourlyCondition.icon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void) configureDailyCell:(UITableViewCell *) cell weatherCondition:(WeatherCondition *) dailyCondition {
    NSString *dateComponents = @"yyMMdd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    self.dailyFormatter = [[NSDateFormatter alloc] init];
    [self.dailyFormatter setDateFormat:dateFormat];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:dailyCondition.date];
    NSLog(@"Date:%@",[self.dailyFormatter stringFromDate:dailyCondition.date]);
    NSLog(@"Temp====%.0f",[dailyCondition.tempHigh floatValue]);
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 [dailyCondition.tempLow floatValue],
                                 [dailyCondition.tempHigh floatValue]];
    
    NSLog(@"Tem:%@",cell.detailTextLabel.text);
    cell.imageView.image = [UIImage imageNamed:dailyCondition.icon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

@end
