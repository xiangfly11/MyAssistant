//
//  MapViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 15/8/23.
//  Copyright (c) 2015年 Jiaxiang Li. All rights reserved.
//

#import "MapViewController.h"
#import "SWRevealViewController.h"
#import "DirectionViewController.h"

@interface MapViewController ()<CLLocationManagerDelegate,UITextFieldDelegate> {
    NSString *sStreetAddress;
    NSString *sCityName;
    NSString *sStateName;
    NSString *sZip;
    
    NSString *dStreetAddress;
    NSString *dCityName;
    NSString *dStateName;
    NSString *dZip;
    
    CLLocationCoordinate2D startCoordinate;
    
    CLLocationCoordinate2D endCoordinate;
    
    
    MKMapItem *startMapItem;
    
    MKMapItem *endMapItem;
}

@property (nonatomic,strong) CLLocationManager *locationManager;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        [self.slideMenuBar setTarget:self.revealViewController];
        
        [self.slideMenuBar setAction:@selector(revealToggle:)];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    


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
    
    UINavigationController *navigationController = [segue destinationViewController];
    
    
    DirectionViewController *dirViewController = (DirectionViewController *) [[navigationController viewControllers] firstObject];
    
    
    dirViewController.startItem = startMapItem;
    
    dirViewController.endItem = endMapItem;
    
    dirViewController.startCoordinate = startCoordinate;
    
}


#pragma mark - Action


- (IBAction)getCurrentLocationAction:(id)sender {
    
    [self getMyLocation];
    
}

- (IBAction)getDirectionAction:(id)sender {
    
    dStreetAddress = self.endStreet.text;
    
    dCityName = self.endCity.text;
    
    dStateName = self.endState.text;
    
    dZip = self.endZip.text;
    
    
    sStreetAddress = self.startStreet.text;
    
    sCityName = self.startCity.text;
    
    sStateName = self.startState.text;
    
    sZip = self.startZip.text;
    
    [self createMKMapItem];
    
    [self performSegueWithIdentifier:@"goToDirection" sender:self];
    
    
}


-(void) createMKMapItem {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    NSString *startAddress = [NSString stringWithFormat:@"%@ %@ %@ %@",sStreetAddress,sCityName,sStateName,sZip];
    
    NSString *endAddress = [NSString stringWithFormat:@"%@ %@ %@ %@",dStreetAddress,dCityName,dStateName,dZip];
    
    
    [geocoder geocodeAddressString:startAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                
                CLLocation *location = placemark.location;
                
                
                startCoordinate = location.coordinate;
            }//end placemark
        }// end error
    }];
    
    
    [geocoder geocodeAddressString:endAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                
                CLLocation *location = placemark.location;
                
                
                endCoordinate = location.coordinate;
            }//end placemark
        }// end error
    }];

    
    
    NSDictionary *startAddressDict = @{
                                       @"streetAddress":sStreetAddress,
                                       @"cityName":sCityName,
                                       @"stateName":sStateName,
                                       @"zip":sZip
                    
                                       };
    
    
    
    
    NSDictionary *endAddressDict = @{
                                     @"streetAddress":dStreetAddress,
                                     @"cityName":dCityName,
                                     @"stateName":dStateName,
                                     @"zip":dZip
                                     };
    
    
    
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:startCoordinate addressDictionary:startAddressDict];
    
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:endCoordinate addressDictionary:endAddressDict];
    
    
    startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    
    endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
}




-(void) getMyLocation {
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager requestAlwaysAuthorization];
    
    
    [self.locationManager startUpdatingLocation];
    
    
    
}




-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations firstObject];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark *myPlacemark = [placemarks firstObject];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            dispatch_once_t myQueue;
            
            
//        dispatch_once(&myQueue, ^{
                self.startStreet.text = myPlacemark.thoroughfare;
                
                self.startCity.text = myPlacemark.locality;
                
                self.startStreet.text =myPlacemark.administrativeArea;
                
                self.startZip.text = myPlacemark.postalCode;
//            });
            
        });
    }];
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.startCity resignFirstResponder];
    [self.startStreet resignFirstResponder];
    [self.startState resignFirstResponder];
    [self.startZip resignFirstResponder];
    [self.endCity resignFirstResponder];
    [self.endStreet resignFirstResponder];
    [self.endState resignFirstResponder];
    [self.endZip resignFirstResponder];
    
}

@end
