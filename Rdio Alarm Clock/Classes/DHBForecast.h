//
//  DHBForecast.h
//  Rdio Alarm
//
//  Created by David Brunow on 4/24/13.
//
//

#import <Foundation/Foundation.h>
#import "DHBGeoLocation.h"

@interface DHBForecast : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic) float currentTempC;
@property (nonatomic) float currentTempF;
@property (nonatomic) float highTempC;
@property (nonatomic) float highTempF;
@property (nonatomic) float lowTempC;
@property (nonatomic) float lowTempF;
@property (nonatomic) float chanceOfPrecip;
@property (nonatomic) float windSpeed;
@property (nonatomic) NSString *conditions;
@property (nonatomic, retain) NSMutableData *weatherData;
@property (nonatomic, strong) DHBGeoLocation *currentLocation;
@property (nonatomic) bool isUpdated;
@property (nonatomic, strong) NSTimer *updateTimer;

-(void) updateWeather;

@end
