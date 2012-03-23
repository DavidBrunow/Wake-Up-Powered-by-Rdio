//
//  AppDelegate.h
//  Rdio Alarm Clock
//
//  Created by David Brunow on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
#import "Reachability.h"
#import "AlarmViewController.h"
#import "AlarmNavController.h"
#import "MMPDeepSleepPreventer.h"
#import "SimpleKeychain.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    Rdio *rdio;
    Reachability *internetReachable;
    Reachability *hostReachable;
    UIWindow *window;
    bool loggedIn;
    bool alarmIsSet;
    float originalBrightness;
    float appBrightness;
    UINavigationController *mainNav;
    NSDate  *alarmTime;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MMPDeepSleepPreventer *awake;
@property (readonly, retain) Rdio *rdio;
@property (nonatomic) bool loggedIn;
@property (nonatomic) bool alarmIsSet;
@property (nonatomic) float appBrightness;
@property (nonatomic) float originalBrightness;
@property (strong, nonatomic) UINavigationController *mainNav;
@property (strong, nonatomic) NSDate *alarmTime;


+(Rdio *)rdioInstance;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end
