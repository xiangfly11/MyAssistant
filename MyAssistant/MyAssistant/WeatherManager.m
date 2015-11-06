//
//  WeatherManager.m
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import "WeatherManager.h"
#import "WeatherClient.h"
#import <TSMessages/TSMessage.h>

@interface WeatherManager ()

@property (nonatomic, strong, readwrite) WeatherCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WeatherClient *client;

@end

@implementation WeatherManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];

    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 1
//    if (self.isFirstUpdate) {
//        self.isFirstUpdate = NO;
//        return;
//    }
//    
//    CLLocation *location = [locations lastObject];
//    
//    // 2
//    if (location.horizontalAccuracy > 0) {
//        // 3
//        self.currentLocation = location;
//        [self.locationManager stopUpdatingLocation];
//    }
    
    
    self.currentLocation = [locations lastObject];
    //CLLocation *sb = [[CLLocation alloc]initWithLatitude:40.0f longitude:40.0f];
//    CLLocationCoordinate2D sb = CLLocationCoordinate2DMake(40.0f, 40.0f);
    
    [self.delegate passLocationToClient:self.currentLocation];
    [self.locationManager stopUpdatingLocation];
}



@end
