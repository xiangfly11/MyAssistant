//
//  RouteViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/20/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RouteViewController : UIViewController

@property (strong,nonatomic) MKMapItem *startMapItem;
@property (strong,nonatomic) MKMapItem *endMapItem;

@end
