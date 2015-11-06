//
//  WeatherClient.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 11/5/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherManagerDelegate.h"
#import "WeatherClientDelegate.h"
@import Foundation;
@import CoreLocation;
@interface WeatherClient : NSObject <WeatherManagerDelegate>

@property (nonatomic,weak) id<WeatherClientDelegate> delegate;

@end
