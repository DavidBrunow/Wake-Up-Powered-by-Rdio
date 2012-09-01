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

@implementation AppDelegate

@synthesize window, rdio, loggedIn, mainNav, appBrightness, originalBrightness, alarmIsSet, alarmTime, originalVolume, appVolume, selectedPlaylist, selectedPlaylistPath, numberOfPlaylistsOwned, numberOfPlaylistsCollab, numberOfPlaylistsSubscr, playlistsInfo, typesInfo, tracksInfo;

+(Rdio *)rdioInstance
{
    return [(id)[[UIApplication sharedApplication] delegate] rdio];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [application setIdleTimerDisabled:YES];
    application.statusBarHidden = YES;
    alarmIsSet = NO;
    originalBrightness = [UIScreen mainScreen].brightness;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0];
    
    rdio = [[Rdio alloc] initWithConsumerKey:@"qdka6u625c2u8c72r3v9x9r4" andSecret:@"GprgYzn5Vp" delegate:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"www.rdio.com"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
    UIViewController *authController = [[AuthViewController alloc] init];
    
    NSString *accessToken = [SFHFKeychainUtils getPasswordForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    
    NSLog(@"access token: %@", accessToken);
    
    if(accessToken != nil) {
        mainNav = [[AlarmNavController alloc] init];
        [[AppDelegate rdioInstance] authorizeUsingAccessToken:accessToken fromController:authController];
        [mainNav.navigationBar setTintColor:[UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0]];
        self.loggedIn = YES;
        [self.window setRootViewController:mainNav];
        [self.window addSubview:mainNav.view];
    } else {
        [self.window setRootViewController:authController];
        [self.window addSubview:authController.view];
    }
    //mainNav = [[AlarmNavController alloc] init];
    
    
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    //[UIScreen mainScreen].brightness = originalBrightness;
    
    
    if (alarmIsSet) {
        NSLog(@"current brightness: %f", [UIScreen mainScreen].brightness);
        NSLog(@"original brightness: %f", originalBrightness);
        [[UIScreen mainScreen] setBrightness:originalBrightness];
        NSLog(@"current brightness: %f", [UIScreen mainScreen].brightness);
        mustBeInApp = [[UILocalNotification alloc] init];
        
        mustBeInApp.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        NSLog(@"alarm will go off: %@", mustBeInApp.fireDate);
        mustBeInApp.timeZone = [NSTimeZone systemTimeZone];
        
        mustBeInApp.alertBody = @"You will not wake up to music if you close out of the Wake Up app.";
        mustBeInApp.alertAction = @"turn alarm back on";
        mustBeInApp.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:mustBeInApp];
        
        backupAlarm = [[UILocalNotification alloc] init];
        
        backupAlarm.fireDate = alarmTime;
        NSLog(@"alarm will go off: %@", backupAlarm.fireDate);
        backupAlarm.timeZone = [NSTimeZone systemTimeZone];
        
        backupAlarm.alertBody = @"Good morning, time to wake up.";
        backupAlarm.alertAction = @"Show me";
        backupAlarm.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:backupAlarm];
        [music setVolume:originalVolume];
        NSLog(@"current brightness: %f", [UIScreen mainScreen].brightness);
        NSLog(@"original brightness: %f", originalBrightness);
        [[UIScreen mainScreen] setBrightness:originalBrightness];
        NSLog(@"current brightness: %f", [UIScreen mainScreen].brightness);
    }
    [application setIdleTimerDisabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[UIScreen mainScreen] setBrightness:originalBrightness];
    [application setIdleTimerDisabled:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //originalBrightness = [UIScreen mainScreen].brightness;
    //[UIScreen mainScreen].brightness = appBrightness;
    
    [application setIdleTimerDisabled:YES];
    if (alarmIsSet) {
        MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
        [music setVolume:0.0];
        [[UIScreen mainScreen] setBrightness:0.0];
        [[UIApplication sharedApplication] cancelLocalNotification:mustBeInApp];
        [[UIApplication sharedApplication] cancelLocalNotification:backupAlarm];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [application setIdleTimerDisabled:YES];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //originalBrightness = [UIScreen mainScreen].brightness;
    //[UIScreen mainScreen].brightness = appBrightness;
    /*[[UIApplication sharedApplication] cancelLocalNotification:mustBeInApp];
    [[UIApplication sharedApplication] cancelLocalNotification:backupAlarm];
    [application setIdleTimerDisabled:YES];
    if (alarmIsSet) {
        MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
        [music setVolume:0.0];
        [[UIScreen mainScreen] setBrightness:0.0];
    }*/
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
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Internet is needed for this app. Enable internet, or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
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
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:@"Website Unreachable" message:@"Cannot connect to the website. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            [alert show];
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
