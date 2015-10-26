//
//  RouteViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/20/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "RouteViewController.h"


@interface RouteViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;



@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.startMapItem.placemark.coordinate, 5000, 5000);
    self.mapView.showsUserLocation = YES;
    [self.mapView setRegion:region];
    
    self.mapView.delegate = self;
    
    [self createAnnotation];
    
    [self getDirection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) getDirection {
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = self.startMapItem;
    directionRequest.destination = self.endMapItem;
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:directionRequest];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Directino Error:%@",error.localizedDescription);
        }else {
            [self showRoute:response];
        }
        
        
    }];
    
}

-(void) createAnnotation {
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.endMapItem.placemark.coordinate;
    annotation.title = self.endMapItem.placemark.name;
    
    [self.mapView addAnnotation:annotation];
}

-(void) showRoute:(MKDirectionsResponse *) response {
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@",step.instructions);
        }
    }
    
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return  nil;
    }
    
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *identifier = @"annotationView";
        annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
    }
    
    return annotationView;
    
    
}
- (IBAction)navigationWasPressed:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Navigation Optios" message:@"You can select navigation apps from below list." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:@"Apple Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.endMapItem openInMapsWithLaunchOptions:nil];
    }];
    
    
    UIAlertAction *actionTwo = [UIAlertAction actionWithTitle:@"Google Map" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *urlStr = [[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f",self.endMapItem.placemark.coordinate.latitude,self.endMapItem.placemark.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSURL *url = [NSURL URLWithString:urlStr];
        
        if (![[UIApplication sharedApplication] canOpenURL:url]) {
            UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Navigation Error" message:@"Your selection cannot be use,please press OK." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            
            [errorController addAction: alertAction];
            
            [self presentViewController:errorController animated:YES completion:nil];
        }else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    [alertController addAction:actionOne];
    [alertController addAction:actionTwo];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
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
