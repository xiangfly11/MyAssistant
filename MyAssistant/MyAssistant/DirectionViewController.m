//
//  DirectionViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/30/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "DirectionViewController.h"
#import <MapKit/MapKit.h>

@interface DirectionViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *myMapView;

@property (nonatomic) CLLocationManager *locationManager;
//@property (nonatomic) DirectionViewController *testViewController;
@end

@implementation DirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.myMapView setDelegate: self];
    
    self.myMapView.mapType = MKMapTypeHybrid;
    
    self.myMapView.showsUserLocation = YES;
    
    
    //MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(40.565849, -74.361953) addressDictionary:nil];
    //MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(40.543401, -74.533935) addressDictionary:nil];
    
    //self.startItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    //self.endItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    
    
    NSLog(@"slongitude:%.6f",self.startItem.placemark.coordinate.longitude);
    NSLog(@"slatidude:%.6f",self.startItem.placemark.coordinate.latitude);
    
    NSLog(@"dlongitude:%.6f",self.endItem.placemark.coordinate.longitude);
    NSLog(@"dlatidude:%.6f",self.endItem.placemark.coordinate.latitude);

//    
//    MKCoordinateRegion *region = MKCoordinateRegionMakeWithDistance(self.startCoordinate, 2000, 2000);
    
    self.myMapView.delegate = self;
    
    [self getDirection];
    
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) getDirection {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    
    request.source = self.startItem;
    
    request.destination = self.endItem;
    
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self showRoute:response];
        }else {
            NSLog(@"Directions Error:%@",error.localizedDescription);
        }
    }];
    
}

-(void) showRoute:(MKDirectionsResponse *) response{
    for (MKRoute *route in response.routes) {
        [self.myMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@",step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}




- (IBAction)cancelAction:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}







@end
