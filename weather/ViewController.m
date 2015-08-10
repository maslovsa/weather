//
//  ViewController.m
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
NSString *const kAPIGetWeather = @"api.openweathermap.org/data/2.5/weather?q=";

@interface ViewController () <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
    NSArray *_pickerData;
}
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
    _pickerData = @[@"Current", @"London", @"Paris", @"Tokio", @"New York"];
    _picker.dataSource = self;
    _picker.delegate = self;
	[self currentLocationInit];
}

- (void)currentLocationInit {
	locationManager = [CLLocationManager new];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError: %@", error);
	UIAlertView *errorAlert = [[UIAlertView alloc]
	                           initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

	currentLocation = [locations objectAtIndex:0];
    if (currentLocation != nil) {
        _longitude.text = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.longitude];
        _latitude.text = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.latitude];
    }
    
	[locationManager stopUpdatingLocation];
	
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
	{
	    if (!(error)) {
	        CLPlacemark *placemark = [placemarks objectAtIndex:0];
	        NSString *locality = [[NSString alloc] initWithString:placemark.locality];
            NSMutableArray *mutable = [[NSMutableArray alloc] initWithArray:_pickerData];
            mutable[0] = locality;
            _pickerData = [mutable copy];
            dispatch_async(dispatch_get_main_queue(), ^{
               _place.text = locality;
                [_picker reloadAllComponents];
            });
            
		} else {
	        NSLog(@"Geocode failed with error %@", error);
	        NSLog(@"\nCurrent Location Not Detected\n");
		}
	}];
	
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	switch (status) {
	case kCLAuthorizationStatusNotDetermined: {
		NSLog(@"User still thinking..");
	} break;
	case kCLAuthorizationStatusDenied: {
		NSLog(@"User hates you");
	} break;
	case kCLAuthorizationStatusAuthorizedWhenInUse:
	case kCLAuthorizationStatusAuthorizedAlways: {
		[locationManager startUpdatingLocation];
	} break;
	default:
		break;
	}
}

#pragma mark - PickerDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    NSURL *url =[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", kAPIGetWeather, _pickerData[row]]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSLog(@"Async JSON: %@", json);
                           }];
}
@end
