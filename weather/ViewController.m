//
//  ViewController.m
//  weather
//
//  Created by Maslov Sergey on 10.08.15.
//  Copyright (c) 2015 ROKOLabs. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>{
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
}
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *place;

@end

@implementation ViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	[self CurrentLocationIdentifier];
}

- (void)CurrentLocationIdentifier {
	// ---- For getting current gps location
	locationManager = [CLLocationManager new];
	locationManager.delegate = self;
	locationManager.distanceFilter = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	// ------
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
	[locationManager stopUpdatingLocation];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
	{
	    if (!(error)) {
	        CLPlacemark *placemark = [placemarks objectAtIndex:0];
	        
	        NSString *Area = [[NSString alloc] initWithString:placemark.locality];
	        NSString *Country = [[NSString alloc] initWithString:placemark.country];
	        NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area, Country];
	        _place.text = CountryArea;
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

@end
