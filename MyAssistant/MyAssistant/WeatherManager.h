//
//  WeatherManager.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeatherCondition.h"
#import "WeatherManagerDelegate.h"
@import Foundation;
@import CoreLocation;

@interface WeatherManager : NSObject<CLLocationManagerDelegate>

+ (instancetype)sharedManager;


@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WeatherCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;
@property (nonatomic,weak) id<WeatherManagerDelegate> delegate;

- (void)findCurrentLocation;

@end
