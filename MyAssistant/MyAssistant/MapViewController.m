//
//  MapViewController.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/20/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "MapViewController.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RouteViewController.h"
#import "AnnotationButton.h"
#import "LocationDetailViewController.h"

@interface MapViewController ()<UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    NSString *searchBarInput;
    NSMutableArray *annotations;
    NSMutableArray *resultPlacemark;
    NSMutableArray *resultMapItem;
    NSMutableArray *annotationTitle;
    NSUInteger selectedRowIndex;
    
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *currentLocation;

@end

@implementation MapViewController

-(void)viewWillAppear:(BOOL)animated {
    
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
    
    annotations = [[NSMutableArray alloc] init];
    resultPlacemark = [[NSMutableArray alloc] init];
    resultMapItem = [[NSMutableArray alloc] init];
    annotationTitle = [[NSMutableArray alloc] init];
    self.searchBar.delegate = self;
    self.mapView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self configueCLLocationManager];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - CLLocationManager Configuation & CLLocationManager Delegate

-(void) configueCLLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 50;
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = [locations lastObject];
    
   
    //[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 5000, 5000)];
    
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 5000, 5000) animated:YES];
    
}


#pragma mark - SearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBarInput = self.searchBar.text;
    [self.searchBar resignFirstResponder];
    if (annotations.count > 0) {
        [self.mapView removeAnnotations: annotations];
        [annotations removeAllObjects];
        [resultPlacemark removeAllObjects];
        [resultMapItem removeAllObjects];
        [annotationTitle removeAllObjects];
    }
    [self performSearchWithInput:searchBarInput];
    
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    searchBarInput = @"";
    [annotations removeAllObjects];
    [resultMapItem removeAllObjects];
    [resultPlacemark removeAllObjects];
    [annotationTitle removeAllObjects];
}


#pragma mark - Perform Search

-(void) performSearchWithInput:(NSString *) inputContent {
    
    
    if (inputContent.length > 0) {
        NSLog(@"%.6f",self.currentLocation.coordinate.latitude);
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 5000, 5000);
        MKLocalSearchRequest *localRequest = [[MKLocalSearchRequest alloc] init];
        localRequest.naturalLanguageQuery = inputContent;
        localRequest.region = region;
        
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:localRequest];

        
        [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Search Request Error:%@",error.localizedDescription);
            }
            
            if (response.mapItems.count == 0) {
                //Do Something to implement this situation
                NSLog(@"No Response!");
            }
            
            for (MKMapItem *item in response.mapItems) {
                
                CLLocation *resultLocation = item.placemark.location;
                if ([self.currentLocation distanceFromLocation:resultLocation] <= 5000) {
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    MKPlacemark *placemark = item.placemark;
                    annotation.subtitle = [NSString stringWithFormat:@"%@ %@,%@,%@,%@",placemark.subThoroughfare,placemark.thoroughfare,placemark.locality,placemark.administrativeArea,placemark.postalCode];
                    annotation.title = placemark.name;
                    annotation.coordinate = placemark.coordinate;
                    
                    [annotations addObject:annotation];
                    [resultPlacemark addObject:placemark];
                    [resultMapItem addObject:item];
                    [annotationTitle addObject:annotation.title];
                    [self.mapView addAnnotation:annotation];
                }
                
                
            }
            
        }];
        
    }
    
}


#pragma mark - MapView Delegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return  nil;
    }
    
    static NSString *identifier = @"annotationView";
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        
        if (!pinAnnotationView) {
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pinAnnotationView.canShowCallout = YES;
            pinAnnotationView.animatesDrop = YES;
            
            UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightBtn setTitle:[NSString stringWithFormat:@"%@",annotation.title] forState:UIControlStateNormal];
            
            [rightBtn addTarget:nil action:@selector(showMoreInfoInActionSheet:) forControlEvents:UIControlEventTouchUpInside];
            
            pinAnnotationView.rightCalloutAccessoryView = rightBtn;
        
        }
        
        
        
    
    }
    
    [self.tableView reloadData];
    
    
    return pinAnnotationView;
    
}


-(void) showMoreInfoInActionSheet:(UIButton *) sender {
//    NSUInteger index = [annotationTitle indexOfObject:sender.currentTitle];
//    CLPlacemark *placemark = [resultPlacemark objectAtIndex:index];
//    UIAlertController *infoController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@",placemark.name] message:[NSString stringWithFormat:@"%@,%@",placemark.subThoroughfare,placemark.thoroughfare] preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];;
//    [infoController addAction:action];
//    
//    [self presentViewController:infoController animated:YES completion:nil];
    
    NSUInteger index = [annotationTitle indexOfObject:sender.currentTitle];
    MKMapItem *item = [resultMapItem objectAtIndex:index];
    
    LocationDetailViewController *locationDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationDetail"];
    
    locationDetail.mapItem = item;
    
    [self.navigationController showViewController:locationDetail sender:self];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    NSLog(@"HELLO++++++++++++++++++++");
    MKAnnotationView *currentAnnotation = [mapView viewForAnnotation:userLocation];
    currentAnnotation.canShowCallout = YES;

}

//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    [self.mapView setcen]
//}


#pragma mark - UITableViewDataSource Delegate & UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MKPlacemark *placemark = resultPlacemark[indexPath.row];
    cell.textLabel.text = placemark.name;
    
    return cell;
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return annotations.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedRowIndex = indexPath.row;
    [self performSegueWithIdentifier:@"goToRoute" sender:tableView];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    RouteViewController *routeViewController = (RouteViewController *)[segue destinationViewController];
    
    MKPlacemark *currentPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.currentLocation.coordinate addressDictionary:nil];
    routeViewController.startMapItem = [[MKMapItem alloc] initWithPlacemark:currentPlacemark];
    
    routeViewController.endMapItem = resultMapItem[selectedRowIndex];
    
}


@end
