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
#import "LocationDetailViewController.h"



@interface MapViewController ()<UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate> {
    
    NSString *searchBarInput;
    NSMutableArray *annotations;
    NSMutableArray *resultPlacemark;
    NSMutableArray *resultMapItem;
    NSMutableArray *annotationTitle;
    NSUInteger selectedRowIndex;
    BOOL isListShow;
    
}


@property (weak, nonatomic) IBOutlet UIBarButtonItem *slideMenuButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showListButton;

@end

@implementation MapViewController



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.origin.y = self.view.bounds.size.height+self.tableView.bounds.size.height;
    self.tableView.frame = tableViewFrame;
    

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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height-200, self.view.frame.size.width, 200.0f) style:UITableViewStylePlain];
    [self.tableView setAlpha:0.7f];
    [self.view addSubview:self.tableView];
    annotations = [[NSMutableArray alloc] init];
    resultPlacemark = [[NSMutableArray alloc] init];
    resultMapItem = [[NSMutableArray alloc] init];
    annotationTitle = [[NSMutableArray alloc] init];
    self.searchBar.delegate = self;
    self.mapView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    isListShow = NO;
    
    [self configueCLLocationManager];
    
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
    
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    searchBarInput = @"";
    [self.mapView removeAnnotations:annotations];

    CGRect tableViewFram = self.tableView.frame;
    tableViewFram.origin.y= self.view.bounds.size.height+self.tableView.bounds.size.height;

    if (isListShow == YES) {
        
        [UITableView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tableView.frame = tableViewFram;
            //self.tableView.hidden = YES;
        } completion:^(BOOL finished) {
            //self.tableView.hidden = YES;
            [annotations removeAllObjects];
            [resultMapItem removeAllObjects];
            [resultPlacemark removeAllObjects];
            [annotationTitle removeAllObjects];
            isListShow = NO;
            self.showListButton.title = @"Show List";
        }];

    }
    
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
                    NSLog(@"Annotation:=== %@",annotation.title);
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
        NSLog(@"!!!!");
        
        return  nil;
    }
    
    static NSString *identifier = @"annotationView";
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        
        if (!pinAnnotationView) {
            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
        
        }
        
        pinAnnotationView.canShowCallout = YES;
        pinAnnotationView.animatesDrop = YES;
        
        UIButton *rightBtn=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightBtn setTitle:[NSString stringWithFormat:@"%@",annotation.title] forState:UIControlStateNormal];
        NSLog(@"Button\\\\\%@",rightBtn.currentTitle);
        
        [rightBtn addTarget:nil action:@selector(showMoreInfoInActionSheet:) forControlEvents:UIControlEventTouchUpInside];
        
        pinAnnotationView.rightCalloutAccessoryView = rightBtn;
        
    
    }

    
    return pinAnnotationView;
    
}


-(void) showMoreInfoInActionSheet:(UIButton *) sender {

    
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




#pragma mark - UITableViewDataSource Delegate & UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MKPlacemark *placemark = resultPlacemark[indexPath.row];
    cell.textLabel.text = placemark.name;
    cell.contentView.alpha = 0.85;
    
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
- (IBAction)showListWasPressed:(id)sender {
    
    
    
    
    if (isListShow == NO) {
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.origin.y = self.view.bounds.size.height-self.toolBar.frame.size.height-self.tableView.frame.size.height;
        [UITableView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.tableView.frame = tableViewFrame;
            
        } completion:^(BOOL finished) {
            //self.tableView.hidden = NO;
            [self.tableView reloadData];
            isListShow = YES;
            self.showListButton.title = @"Hide list";
        }];
    }else {
        CGRect tableViewFram = self.tableView.frame;
        tableViewFram.origin.y= self.view.bounds.size.height+self.tableView.bounds.size.height;
        [UITableView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.tableView.frame = tableViewFram;
            //self.tableView.hidden = YES;
        } completion:^(BOOL finished) {
            //self.tableView.hidden = YES;
            isListShow = NO;
            self.showListButton.title = @"Show List";
        }];
    }
    
    
    
}


@end
