//
//  WeatherAPI.m
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import "WeatherAPI.h"
NSString *const kAPIGetWeather = @"http://api.openweathermap.org/data/2.5/weather?q=";

@implementation WeatherAPI
-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAPIGetWeather, name]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                              
                               if (connectionError == nil) {
                                   if (callback){
                                       json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                                       callback(connectionError, json);
                                   }
                               } else {
                                   if (callback){
                                       callback(connectionError, nil);
                                   }
                               }
                           }];
}
@end
