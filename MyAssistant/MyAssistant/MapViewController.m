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
@import AddressBook;
@interface MapViewController ()<CLLocationManagerDelegate,UITextFieldDelegate> {
    NSString *sStreetAddress;
    NSString *sCityName;
    NSString *sStateName;
    NSString *sZip;
    
    NSString *dStreetAddress;
    NSString *dCityName;
    NSString *dStateName;
    NSString *dZip;
    
    CLLocationCoordinate2D __block startCoordinate;
    
    CLLocationCoordinate2D __block endCoordinate;
    
    
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
    

    
    self.endCity.delegate = self;
    self.endState.delegate = self;
    self.endStreet.delegate = self;
    self.endZip.delegate = self;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];

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
    
    NSLog(@"==============%.6f",startMapItem.placemark.coordinate.latitude);
    
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
    
    //[self performSegueWithIdentifier:@"goToDirection" sender:self];
    
    
}


-(void) createMKMapItem {
    
    CLGeocoder *startGeocoder = [[CLGeocoder alloc] init];
    
    CLGeocoder *endGecoder = [[CLGeocoder alloc] init];
    
    NSString *startAddress = [NSString stringWithFormat:@"%@ %@ %@ %@",sStreetAddress,sCityName,sStateName,sZip];
    
    NSString *endAddress = [NSString stringWithFormat:@"%@ %@ %@ %@",dStreetAddress,dCityName,dStateName,dZip];
    DirectionViewController *testViewController = [[DirectionViewController alloc] init];
    //CLLocation __block *startLocation = [[CLLocation alloc] init];
    //CLLocation __block *endLocation = [[CLLocation alloc] init];;
    //CLPlacemark __block *startPlacemark = [[CLPlacemark alloc] init] ;
    //CLPlacemark __block *endPlacemark = [[CLPlacemark alloc] init];
    
    [startGeocoder geocodeAddressString:startAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                //startPlacemark = placemark;
                CLLocation *startLocation = placemark.location;
                
                
                startCoordinate = startLocation.coordinate;
                
                MKPlacemark *startPlacemark1 = [[MKPlacemark alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
                
                startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark1];
                
                testViewController.startItem = startMapItem;
                NSLog(@"lat:%.6f,lon:%.6f",startCoordinate.latitude,startCoordinate.longitude);
            }//end placemark
        }// end error
        else {
            NSLog(@"Eroor4444444:%@",error.localizedDescription);
        }
    }];
    
    
    [endGecoder geocodeAddressString:endAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (!error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                //endPlacemark = placemark;
                CLLocation *endLocation = placemark.location;
                
                
                endCoordinate = endLocation.coordinate;
                
                 MKPlacemark *endPlacemark1 = [[MKPlacemark alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
                
                endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark1];
                NSLog(@"lat:%.6f,lon:%.6f",endCoordinate.latitude,endCoordinate.longitude);
                
                //[self performSegueWithIdentifier:@"goToDirection" sender:self];
                
                
                testViewController.endItem = endMapItem;
                
                [self.navigationController pushViewController:testViewController animated:YES];
                
            }//end placemark
        }// end error
        else {
            NSLog(@"Error:%@",error.localizedDescription);
        }
    }];

    
    
//    NSDictionary *startAddressDict = @{
//                                       (NSString *)kABPersonAddressStreetKey:[NSString stringWithFormat:@"%@ %@",startPlacemark.subThoroughfare,startPlacemark.thoroughfare],
//                                       (NSString *)kABPersonAddressCityKey:startPlacemark.locality,
//                                       (NSString *)kABPersonAddressStateKey:startPlacemark.administrativeArea,
//                                       (NSString *)kABPersonAddressZIPKey:startPlacemark.postalCode
//                                       };
//    
//    
//    
//    
//    NSDictionary *endAddressDict = @{
//                                     (NSString *)kABPersonAddressStreetKey:[NSString stringWithFormat:@"%@ %@",endPlacemark.subThoroughfare,endPlacemark.thoroughfare],
//                                     (NSString *)kABPersonAddressCityKey:endPlacemark.locality,
//                                     (NSString *)kABPersonAddressStateKey:endPlacemark.administrativeArea,
//                                     (NSString *)kABPersonAddressZIPKey:endPlacemark.postalCode
//                                     };
    
    
    
//    MKPlacemark *startPlacemark1 = [[MKPlacemark alloc] initWithCoordinate:startCoordinate addressDictionary:nil];
//    
//    NSLog(@"***********************%.6f",startCoordinate.latitude);
//    
//    MKPlacemark *endPlacemark1 = [[MKPlacemark alloc] initWithCoordinate:endCoordinate addressDictionary:nil];
//    
//    
//    startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark1];
//    
//    endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark1];
//    
//    //[self performSegueWithIdentifier:@"goToDirection" sender:self];
//    
//    DirectionViewController *testViewController = [[DirectionViewController alloc] init];
//    testViewController.startItem = startMapItem;
//    testViewController.endItem = endMapItem;
//    
//    NSLog(@"????%.6f",testViewController.startItem.placemark.coordinate.latitude);
    
    
//    [self.navigationController pushViewController:testViewController animated:YES];
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
                self.startStreet.text = [NSString stringWithFormat:@"%@ %@",myPlacemark.subThoroughfare,myPlacemark.thoroughfare];
                
                self.startCity.text = myPlacemark.locality;
            
                self.startState.text =myPlacemark.administrativeArea;
                
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

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"resizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect rect = CGRectMake(0.0f, -100, width, height);
    self.view.frame = rect;
    [UIView commitAnimations];
    return YES;
    
}

-(void) hidenKeyboard {
    [self resumeView];
}


-(void) resumeView {
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"resizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    CGRect rect = CGRectMake(0.0f,60, width, height);
    self.view.frame = rect;
    [UIView commitAnimations];
}

@end
