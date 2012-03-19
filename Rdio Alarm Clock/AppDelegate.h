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
#import "MainViewController.h"
#import "MMPDeepSleepPreventer.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    Rdio *rdio;
    Reachability *internetReachable;
    Reachability *hostReachable;
    MainViewController *mainView;
    UIWindow *window;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainView;
@property (strong, nonatomic) MMPDeepSleepPreventer *awake;
@property (readonly, retain) Rdio *rdio;

+(Rdio *)rdioInstance;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end
