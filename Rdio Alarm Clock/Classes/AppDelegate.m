//
//  AppDelegate.m
//  Rdio Alarm Clock
//
//  Created by David Brunow on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AlarmNavController.h"
#import "Credentials.h"

@implementation AppDelegate

+(Rdio *)rdioInstance
{
    return [(id)[[UIApplication sharedApplication] delegate] rdio];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"397a28383f7de900ab3c235f67199d7d_Nzk2MTU4MjAxMi0xMi0xOSAyMjo1OTowOS42MDk1MzM"];
    
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
    self.alarmIsSet = NO;
    self.alarmIsPlaying = NO;
    self.originalBrightness = [UIScreen mainScreen].brightness;
    self.appBrightness = self.originalBrightness;
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];

    self.originalVolume = music.volume;
    self.appVolume = self.originalVolume;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    [self.window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
    
    self.rdio = [[Rdio alloc] initWithConsumerKey:CONSUMER_KEY andSecret:CONSUMER_SECRET delegate:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    //internetReachable = [Reachability reachabilityForInternetConnection];
    //[internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostname: @"www.rdio.com"];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
            
    self.mainNav = [[AlarmNavController alloc] init];

    [self.mainNav setNavigationBarHidden:YES];
    [self.window setRootViewController:self.mainNav];
    
    self.rdioUser = [[RdioUser alloc] init];
    self.selectedPlaylist = [[DHBPlaylist alloc] init];

    self.musicLibrary = [[DHBMusicLibrary alloc] init];
        
    self.alarmClock = [[DHBAlarmClock alloc] init];
    
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

    float currentVolume = music.volume;
    if (currentVolume < self.originalVolume) {
        [music setVolume:self.originalVolume];
    }
    
    if (self.alarmIsSet) {
        
        self.mustBeInApp = [[UILocalNotification alloc] init];
        
        self.mustBeInApp.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        NSLog(@"alarm will go off: %@", self.mustBeInApp.fireDate);
        self.mustBeInApp.timeZone = [NSTimeZone systemTimeZone];
        
        self.mustBeInApp.alertBody = [NSString stringWithFormat:NSLocalizedString(@"APP MUST BE OPEN REMINDER", nil)];
        self.mustBeInApp.alertAction = [NSString stringWithFormat:NSLocalizedString(@"TURN ALARM BACK ON", nil)];
        self.mustBeInApp.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:self.mustBeInApp];
        
        self.backupAlarm = [[UILocalNotification alloc] init];
        
        self.backupAlarm.fireDate = [self.alarmClock alarmTime];
        NSLog(@"alarm will go off: %@", self.backupAlarm.fireDate);
        self.backupAlarm.timeZone = [NSTimeZone systemTimeZone];
        
        self.backupAlarm.alertBody = @"Good morning, time to wake up.";
        self.backupAlarm.alertAction = @"Show me";
        self.backupAlarm.soundName = UILocalNotificationDefaultSoundName;
        
        //[[UIApplication sharedApplication] scheduleLocalNotification:backupAlarm];
        
    } else if (!self.alarmIsPlaying) {
        //[self.window setRootViewController:nil];
    }
    [application setIdleTimerDisabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    //[[UIScreen mainScreen] setBrightness:originalBrightness];
    [application setIdleTimerDisabled:NO];
    if (!self.alarmIsSet && !self.alarmIsPlaying) {
        [self.window setRootViewController:nil];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //originalBrightness = [UIScreen mainScreen].brightness;
    //[UIScreen mainScreen].brightness = appBrightness;
    
    
    if (self.alarmIsSet) {
        MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
        [music setVolume:0.0];
        [[UIScreen mainScreen] setBrightness:0.0];
        [[UIApplication sharedApplication] cancelLocalNotification:self.mustBeInApp];
        [[UIApplication sharedApplication] cancelLocalNotification:self.backupAlarm];
        [application setIdleTimerDisabled:YES];
    } else if (!self.alarmIsPlaying) {
        [self.window setRootViewController:self.mainNav];
        
        if(self.rdioUser == nil) {
            self.rdioUser = [[RdioUser alloc] init];
        }
        
        if(self.selectedPlaylist == nil) {
            self.selectedPlaylist = [[DHBPlaylist alloc] init];
        }
        
        if(self.musicLibrary == nil) {
            self.musicLibrary = [[DHBMusicLibrary alloc] init];
        }
        
        if(self.alarmClock == nil) {
            self.alarmClock = [[DHBAlarmClock alloc] init];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.alarmIsSet || self.alarmIsPlaying) {
        [application setIdleTimerDisabled:YES];
    }
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
            //UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Internet is needed for this app. Enable internet, or try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
            //[alert show];
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
            UIAlertView * alert  = [[UIAlertView alloc] initWithTitle:@"Website Unreachable" message:[NSString stringWithFormat:NSLocalizedString(@"CANNOT CONNECT TO RDIO", nil)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
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
    if (self.alarmIsSet || self.alarmIsPlaying) {
        [application setIdleTimerDisabled:YES];
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)notification {
	//[mainView playClicked];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        //[mainView playClicked];
        // Application was in the background when notification
        // was delivered.
    }
    if (self.alarmIsSet || self.alarmIsPlaying) {
        [application setIdleTimerDisabled:YES];
    }
}


@end
