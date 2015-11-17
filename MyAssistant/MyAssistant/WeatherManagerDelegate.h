//
//  WeatherManagerDelegate.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;

@protocol WeatherManagerDelegate <NSObject>

-(void) passLocationToClient:(CLLocation *) location;
-(void) passCityNameToClient:(NSString *) cityName;
@end