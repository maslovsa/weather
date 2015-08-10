//
//  ViewController.m
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WeatherAPI.h"

@interface ViewController () <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	NSArray *_pickerData;
}
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *tempNight;
@property (weak, nonatomic) IBOutlet UILabel *tempEve;
@property (weak, nonatomic) IBOutlet UILabel *tempMorn;

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
- (IBAction)getLocation:(id)sender {
    [self currentLocationInit];
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	[[WeatherAPI new] currentWeatherByCityName:_pickerData[row]
	 withCallback:^( NSError *error, NSDictionary *result ) {
	    if (!error && result) {
	        CGFloat kelvin = [result[@"main"][@"temp"] floatValue];
	        NSString *cityId = result[@"id"];
	        dispatch_async(dispatch_get_main_queue(), ^{
				_temp.text = [NSString stringWithFormat:@"%.1f℃", [self tempToCelcius:kelvin]];
			});
	        [self updateForecast:cityId];
		}
	}];
	
	
}

- (void)updateForecast:(NSString *)cityId {

	[[WeatherAPI new] forecast:cityId andLang:@"en" withCallback:^( NSError *error, NSDictionary *result ) {
        if (!error && result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = result[@"list"][0];
                NSLog(@"%@", dic);
                _tempNight.text = [NSString stringWithFormat:@"%.1f℃", [self tempToCelcius:[dic[@"temp"][@"night"] floatValue]]];
                _tempEve.text = [NSString stringWithFormat:@"%.1f℃", [self tempToCelcius:[dic[@"temp"][@"eve"] floatValue]]];
                _tempMorn.text = [NSString stringWithFormat:@"%.1f℃", [self tempToCelcius:[dic[@"temp"][@"morn"] floatValue]]];
            });
        }
	
	}];
	
}

#pragma mark - Utilites

- (CGFloat)tempToCelcius:(CGFloat)tempKelvin {
	return tempKelvin - 273.15;
}

@end
