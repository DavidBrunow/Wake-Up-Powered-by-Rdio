//
//  DHBGeoLocation.h
//  Rdio Alarm
//
//  Created by David Brunow on 4/27/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DHBGeoLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) bool isCurrent;
@property (nonatomic) NSDate *timeStamp;

-(void) updateCurrentLocation;

@end
