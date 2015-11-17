//
//  WeatherViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/4/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherManager.h"
#import "WeatherClient.h"
#import "WeatherPageViewController.h"
#import "SWRevealViewController.h"
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
//@property (nonatomic,strong) WeatherPageViewController *pageViewController;

@end

@implementation WeatherViewController



-(void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureViews];
    
    //[[WeatherManager sharedManager] findCurrentLocation];
    self.weatherManager = [WeatherManager sharedManager];
    self.weatherClient = [[WeatherClient alloc] init];
    self.weatherManager.delegate = self.weatherClient;
    self.weatherClient.delegate = self;
    if (self.cityName == nil) {
        [self.weatherManager findCurrentLocation];
    }else {
        [self.weatherManager findWeatherWithCity: self.cityName];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) configureViews {
    UIImage *backgroundImage = [UIImage imageNamed:@"weather_bg"];
    
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
//    CGFloat Y_AddButton = 200;
    CGFloat X_AddButton = 80;
    CGFloat Height_AddButton = 45;
    CGFloat Width_AddButton = 45;
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
    
    
    //CGRect addButtonFrame = CGRectMake(headerFrame.size.width - X_AddButton, headerFrame.size.height - Y_AddButton, Width_AddButton, Height_AddButton);
   
    CGRect addButtonFrame = hiloFrame;
    addButtonFrame.origin.x = headerFrame.size.width - X_AddButton;
    addButtonFrame.size.width = Width_AddButton;
    addButtonFrame.size.height = Height_AddButton;
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    
    temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0º";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:100];
    temperatureLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:temperatureLabel];
   
    hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0º%%";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    hiloLabel.textAlignment = NSTextAlignmentLeft;
    [header addSubview:hiloLabel];
    
    
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
    
   
    iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:addButtonFrame];
    UIImage *image = [UIImage imageNamed:@"add"];
    [button setImage:image forState:UIControlStateNormal];
    //button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(addButtonWasPressed) forControlEvents:UIControlEventTouchDown];
    [header addSubview:button];

}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // 3
    self.blurredImageView.alpha = percent;
}

#pragma UITableViewDataSource 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count;
    if (section == 0) {
        count = self.hourlyArray.count+1;
        //return 3;
    }else if (section == 1) {
        count = self.dailyArray.count+1;
    }
    
    return count;
    
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
    if (self.cityName != nil) {
        cityLabel.text = self.cityName;
    }else {
        cityLabel.text = condition.locationName;
    }
    temperatureLabel.text = [NSString stringWithFormat:@"%.0fº",[condition.temperature floatValue]];
    iconView.image = [UIImage imageNamed:condition.icon];
    //hiloLabel.text = [NSString stringWithFormat:@"%.0fº/%.0fº",[condition.tempLow floatValue],[condition.tempHigh floatValue]];
    hiloLabel.text = [NSString stringWithFormat:@"%.0f %%",[condition.humidity floatValue]];
    conditionsLabel.text = condition.condition;
}

-(void) passDailyForcastToViewController:(NSMutableArray *)arrayDaily {
    
    NSLog(@"arrayDaily Count:%lu",(unsigned long)arrayDaily.count);
    self.dailyArray = [[NSMutableArray alloc] initWithArray:arrayDaily];
    
    NSLog(@"??????????%lu",(unsigned long)self.dailyArray.count);
    [self.tableView reloadData];
    
}


-(void) passHourlyForcastToViewController:(NSMutableArray *)arrayHourly {
    NSLog(@"arrayHourly Count:%lu",(unsigned long)arrayHourly.count);
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

-(void) addButtonWasPressed {
    [self performSegueWithIdentifier:@"addLocation" sender:self];
}



@end
