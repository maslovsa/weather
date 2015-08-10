//
//  WeatherAPI.m
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import "WeatherAPI.h"
NSString *const kAPIGetWeather = @"http://api.openweathermap.org/data/2.5/weather?q=";
NSString *const kAPIForecast = @"http://api.openweathermap.org/data/2.5/forecast/daily?id=%@&lang=%@";


@implementation WeatherAPI
-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kAPIGetWeather, name]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                              
                               if (connectionError == nil) {
                                   if (callback){
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
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

-(void) forecast:(NSString *) name andLang:(NSString *)lang
    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kAPIForecast, name, lang]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError == nil) {
                                   if (callback){
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
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
