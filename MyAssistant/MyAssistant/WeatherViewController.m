//
//  WeatherViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/22/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "WeatherViewController.h"
#import "SWRevealViewController.h"

#import "CoreDataStack.h"
#import "LocationEntity.h"


@interface WeatherViewController ()@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSString *urlStr;
@property (strong,nonatomic) NSURL *url;


@property (strong,nonatomic) CLLocation *currentLocation;

@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuButton setTarget:self.revealViewController];
        
        [self.slideMenuButton setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.urlStr = [[NSString alloc] init];
    self.url = [[NSURL alloc] init];
    
    self.tableView.delegate = self;
    
    [self.tableView setDataSource:self];
    
    [self configureLocationManager];
    
    [self.fetchedResultsController performFetch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configureLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    self.locationManager.distanceFilter = 10000;
    
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    self.currentLocation = [locations  lastObject];
    
    CLGeocoder *gecoder = [[CLGeocoder alloc] init];
    [gecoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Gecoder Error:%@",error.localizedDescription);
        }
        
        if (placemarks.count > 0) {
            CLPlacemark *currentPlacemark = [placemarks lastObject];
            
            NSString *currentCityName = [currentPlacemark.locality lowercaseString];
            
            NSString *currentCountry = [currentPlacemark.country lowercaseString];
            
            [self getWeatherInfoWithCity:currentCityName andCountry:currentCountry boolCurrentLocation:YES];
        }
    }];
    
    [self.locationManager stopUpdatingLocation];
}


-(void) getWeatherInfoWithCity:(NSString *) cityName andCountry:(NSString *) country boolCurrentLocation:(BOOL) isCurrentLocation {
    
    //NSString *urlStr = [[NSString alloc] init];
    if(isCurrentLocation == YES){
        self.urlStr= [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=e40fd6f9191b29b575b0f77a9ce44bf6",cityName];
    }else {
        self.urlStr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=e40fd6f9191b29b575b0f77a9ce44bf6",cityName];
        //self.urlStr = @"http://api.openweathermap.org/data/2.5/weather?q=london&appid=e40fd6f9191b29b575b0f77a9ce44bf6";
    }
    
    
    //NSURL *url = [[NSURL alloc] init];
    self.url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:self.url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        
        if (!error && urlResponse.statusCode == 200) {
            NSError *jsonError;
            
            NSDictionary *weatherInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (!error) {
                NSDictionary *mainDict = [weatherInfo objectForKey:@"main"];
                
                NSNumber *tempInKelvin = [mainDict objectForKey:@"temp"];
                
                NSInteger tempInCelsius = [tempInKelvin integerValue] - 273.15;
                
                NSArray *weatherArray = [weatherInfo objectForKey:@"weather"];
                
                NSString *weatherDescription;
                for (NSDictionary *contents in weatherArray) {
                    weatherDescription = [contents objectForKey:@"description"];
                }
                
                NSDictionary *sysDict = [weatherInfo objectForKey:@"sys"];
                
                NSString *countryCode = [sysDict objectForKey:@"country"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tempLabel.text = [NSString stringWithFormat:@"%.1ld℃",(long)tempInCelsius];
                    
                    self.addressLabel.text = [NSString stringWithFormat:@"%@,%@",cityName,countryCode];
                    
                    self.descriptionLabel.text = weatherDescription;
                    
                    self.addressLabel.font = [UIFont boldSystemFontOfSize:16];
                    
                    self.tempLabel.font = [UIFont boldSystemFontOfSize:86];
                    
                    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:16];
                    
                });
                
            }
        }
    } ];
    
    
    [dataTask resume];
    
    
//    if (isCurrentLocation == YES) {
//        <#statements#>
//    }
    
}

-(NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:@"cityName" cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(NSFetchRequest *) entryListFetchRequest {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"LocationEntity"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cityName" ascending:NO]];
    
    return fetchRequest;
}




-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections] [section];
    
    return [sectionInfo name];
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocationEntity *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    [[coreDataStack managedObjectContext] deleteObject:entry];
    
    [coreDataStack saveContext];
}


-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}





-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
    
}


-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
    
}


-(void) controllerDidChangeContent: (NSFetchedResultsController *) controller {
    
    //NSLog(@"controllerDidChangeContent===============");
    [self.tableView endUpdates];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    NSLog(@"numberOfSectionsInTableView:%ld",self.fetchedResultsController.sections.count);
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections] [section];
    
    
    NSLog(@"tableView,numberOfRowInSection:%ld",[sectionInfo numberOfObjects]);

    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"tableView,cellForRowAtIndexPath");
    static NSString *identifier = @"cityNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    
    
    
    // Configure the cell...
    
    LocationEntity *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    
    
    //cell.textLabel.text = entry.body;
    
    //[cell configureCellForEntry: entry];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@,%@",entry.cityName,entry.countryCode];
    
    
    NSLog(@"cell:%@,%@",entry.cityName,entry.countryCode);
    
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationEntity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *cityName = [entity.cityName lowercaseString];
    NSString *countryCode = [entity.countryCode lowercaseString];
    
    [self getWeatherInfoWithCity:cityName andCountry:countryCode boolCurrentLocation:NO];
    
    
    
}



//- (IBAction)addWasPressed:(id)sender {
//    
//    [self performSegueWithIdentifier:@"addLocation" sender:self];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
