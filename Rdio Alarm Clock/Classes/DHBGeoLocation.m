//
//  DHBGeoLocation.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/27/13.
//
//

#import "DHBGeoLocation.h"

@implementation DHBGeoLocation

- (id) init
{
    self.timeStamp = [[NSDate alloc] init];
    [self setIsCurrent:NO];

    if([CLLocationManager locationServicesEnabled]) {
        [self updateCurrentLocation];
    } else {
    }
    
    return self;
}

-(void) updateCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    [self.locationManager setDistanceFilter:10000];
    [self.locationManager setDelegate:self];
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    self.timeStamp = currentLocation.timestamp;

    NSTimeInterval howRecent = [self.timeStamp timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        self.longitude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
        //[self setValue:@"YES" forKey:@"isCurrent"];
        [self setIsCurrent:YES];
    }
}

@end
