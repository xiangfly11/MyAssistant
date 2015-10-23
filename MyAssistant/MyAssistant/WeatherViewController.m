//
//  WeatherViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/22/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "WeatherViewController.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>

@interface WeatherViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong,nonatomic) CLLocationManager *locationManager;

@property (strong,nonatomic) CLLocation *currentLocation;

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
    
    
    [self configureLocationManager];

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
    
    NSString *urlStr;
    if(isCurrentLocation == YES){
        urlStr= [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&appid=e40fd6f9191b29b575b0f77a9ce44bf6",cityName];
    }else {
        urlStr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@&appid=e40fd6f9191b29b575b0f77a9ce44bf6",cityName,country];
    }
    
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
