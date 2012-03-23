//
//  AppDelegate.m
//  Rdio Alarm Clock
//
//  Created by David Brunow on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AlarmViewController.h"
#import "AlarmNavController.h"
#import "MMPDeepSleepPreventer.h"

@implementation AppDelegate

@synthesize window, rdio, awake, loggedIn, mainNav, appBrightness, originalBrightness, alarmIsSet, alarmTime;

+(Rdio *)rdioInstance
{
    return [(id)[[UIApplication sharedApplication] delegate] rdio];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = YES;
    alarmIsSet = NO;
    originalBrightness = [UIScreen mainScreen].brightness;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"www.apple.com"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
    
        
    mainNav = [[AlarmNavController alloc] init];
    rdio = [[Rdio alloc] initWithConsumerKey:@"qdka6u625c2u8c72r3v9x9r4" andSecret:@"GprgYzn5Vp" delegate:nil];

    [self.window setRootViewController:mainNav];
    [self.window addSubview:mainNav.view];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [UIScreen mainScreen].brightness = originalBrightness;
    if (alarmIsSet) {
    UILocalNotification *alarmTime = [[UILocalNotification alloc] init];
    
    alarmTime.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    NSLog(@"alarm will go off: %@", alarmTime.fireDate);
    alarmTime.timeZone = [NSTimeZone systemTimeZone];
    
    alarmTime.alertBody = @"You will not wake up to music if you close out of the Wake Up app.";
    alarmTime.alertAction = @"Show me";
    alarmTime.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:alarmTime];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [UIScreen mainScreen].brightness = originalBrightness;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    originalBrightness = [UIScreen mainScreen].brightness;
    [UIScreen mainScreen].brightness = appBrightness;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    
    {
        case NotReachable:
        {
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:@"Network Failed" message:@"Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            [alert show];
            NSLog(@"The internet is down.");
            
            break;
            
        }
        case ReachableViaWiFi:
        {               
            NSLog(@"The internet is working via WIFI.");
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            
            break;
            
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            
            break;
            
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            
            break;
            
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            
            break;
            
        }
    }
}

- (void)application:(UIApplication *)application 
didReceiveLocalNotification:(UILocalNotification *)notification {
	//[mainView playClicked];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        //[mainView playClicked];
        // Application was in the background when notification
        // was delivered.
    }
}



@end
