//
//  WeatherAPI.h
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherAPI : NSObject
-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

@end
