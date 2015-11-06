//
//  WeatherClientDelegate.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WeatherCondition;
@protocol WeatherClientDelegate <NSObject>

-(void) passWeatherConditonToViewController:(WeatherCondition *) condition;
//-(void) passForcastWithOneDay:(NSMutableArray *) arrayCondition andDailyForcast:(NSMutableArray *) arrayDaily;
-(void) passDailyForcastToViewController:(NSMutableArray *) arrayDaily;

-(void) passHourlyForcastToViewController:(NSMutableArray *) arrayHourly;
@end