//
//  LocationEntity.h
//  MyAssistant
//
//  Created by Jiaxiang Li on 10/24/15.
//  Copyright © 2015 Jiaxiang Li. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LocationEntity : NSManagedObject
@property (nonatomic,retain) NSString *cityName;
@property (nonatomic,retain) NSString *countryCode;


@end
