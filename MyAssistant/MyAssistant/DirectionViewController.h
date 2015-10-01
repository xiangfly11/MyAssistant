//
//  DirectionViewController.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 9/30/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DirectionViewController : UIViewController

@property (nonatomic,strong) MKMapItem *startItem;

@property (nonatomic,strong) MKMapItem *endItem;

@property (nonatomic) CLLocationCoordinate2D startCoordinate;

@end
