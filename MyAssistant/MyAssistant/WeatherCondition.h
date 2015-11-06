//
//  WeatherCondition.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherCondition : NSObject

@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSNumber *humidity;
@property (nonatomic,strong) NSNumber *temperature;
@property (nonatomic,strong) NSNumber *tempHigh;
@property (nonatomic,strong) NSNumber *tempLow;
@property (nonatomic,strong) NSString *locationName;
@property (nonatomic,strong) NSDate *sunrise;
@property (nonatomic,strong) NSDate *sunset;
@property (nonatomic,strong) NSString *conditionDescription;
@property (nonatomic,strong) NSString *condition;
@property (nonatomic,strong) NSNumber *windBearing;
@property (nonatomic,strong) NSNumber *windSpeed;
@property (nonatomic,strong) NSString *icon;

-(NSString *) imageName:(NSString *) key;



@end
