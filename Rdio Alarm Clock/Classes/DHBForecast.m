//
//  DHBForecast.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/24/13.
//
//

#import "DHBForecast.h"
#import "Credentials.h"
#import "DHBGeoLocation.h"

@implementation DHBForecast


-(id) init
{
    self.currentLocation = [[DHBGeoLocation alloc] init];
    
    self.weatherData = [[NSMutableData alloc] init];
    [self.currentLocation addObserver:self forKeyPath:@"isCurrent" options:NSKeyValueObservingOptionNew context:nil];
    [self setIsUpdated:NO];

    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([self.currentLocation isCurrent]) {
        [self updateWeather];
    }
}

-(void) updateWeather
{
    [self.updateTimer invalidate];

    NSString *latLon = [NSString stringWithFormat:@"%f,%f", self.currentLocation.latitude, self.currentLocation.longitude];

    NSString *weatherURLString = [NSString stringWithFormat:@"http://api.worldweatheronline.com/free/v1/weather.ashx?key=%@&q=%@&num_of_days=1&format=json&extra=localobstime", WEATHER_API_KEY, latLon];
    //NSLog(@"Weather URL String:%@", weatherURLString);
    NSURLRequest *weatherURLRequest  = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:weatherURLString]];
    //[self.webView loadRequest:storeDataURLRequest];
    NSURLConnection *weatherDataURLConnection = [[NSURLConnection alloc] initWithRequest:weatherURLRequest delegate:self];
    [self setIsUpdated:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.weatherData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *weatherDataString = [[NSString alloc] initWithData:self.weatherData encoding:NSUTF8StringEncoding];
    NSLog(@"Data String: '%@'", weatherDataString);
    
    
    NSMutableDictionary *weatherDictionary = [NSJSONSerialization JSONObjectWithData:self.weatherData options:0 error:nil];
    //NSMutableDictionary *weatherDictionary = [weatherDataString objectFromJSONString];
    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithDictionary:[weatherDictionary objectForKey:@"data"]];
    
    NSDictionary *currentConditionDictionary = [tempDictionary objectForKey:@"current_condition"];
    
    [self setCurrentTempC:[[[currentConditionDictionary valueForKey:@"temp_C"] objectAtIndex:0] floatValue]];
    [self setCurrentTempF:[[[currentConditionDictionary valueForKey:@"temp_F"] objectAtIndex:0] floatValue] ];
    
    NSDictionary *todaysWeatherDictionary = [tempDictionary objectForKey:@"weather"];
    
    NSDictionary *todaysConditions = [todaysWeatherDictionary valueForKey:@"weatherDesc"];
    
    [self setHighTempC:[[[todaysWeatherDictionary valueForKey:@"tempMaxC"] objectAtIndex:0] floatValue]];
    [self setHighTempF:[[[todaysWeatherDictionary valueForKey:@"tempMaxF"] objectAtIndex:0] floatValue]];
    [self setLowTempC:[[[todaysWeatherDictionary valueForKey:@"tempMinC"] objectAtIndex:0] floatValue]];
    [self setLowTempF:[[[todaysWeatherDictionary valueForKey:@"tempMinF"] objectAtIndex:0] floatValue]];
    [self setWindSpeed:[[[todaysWeatherDictionary valueForKey:@"windspeedMiles"] objectAtIndex:0] floatValue]];
    [self setConditions:[[[todaysConditions valueForKey:@"value"] objectAtIndex:0] objectAtIndex:0]];
    
    if(self.conditions != nil) {
        NSLog(@"Conditions: %@, current temperature: %f", self.conditions, self.currentTempF);
        NSLog(@"Fetched the current weather");
        [self setIsUpdated:YES];
    } else if([weatherDataString rangeOfString:@"data"].location == NSNotFound) {
        [self.updateTimer invalidate];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateWeather) userInfo:nil repeats:NO];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
