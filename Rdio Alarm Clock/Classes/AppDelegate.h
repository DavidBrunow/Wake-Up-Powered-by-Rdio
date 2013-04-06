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
#import "AlarmNavController.h"
#import "SimpleKeychain.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import "DHBAlarmClock.h"
#import "DHBMusicLibrary.h"
#import "DHBPlaylist.h"
#import "RdioUser.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    Reachability *internetReachable;
    Reachability *hostReachable;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Rdio *rdio;
@property (nonatomic) bool alarmIsSet;
@property (nonatomic) bool alarmIsPlaying;
@property (nonatomic) float appBrightness;
@property (nonatomic) float originalBrightness;
@property (nonatomic) float originalVolume;
@property (nonatomic) float appVolume;
@property (nonatomic) NSIndexPath *selectedPlaylistPath;
@property (nonatomic, retain) NSMutableArray *playlistsInfo;
@property (nonatomic, retain) NSMutableArray *tracksInfo;
@property (nonatomic, retain) DHBAlarmClock *alarmClock;
@property (nonatomic, retain) AlarmNavController *mainNav;
@property (nonatomic, retain) RdioUser *rdioUser;
@property (nonatomic, retain) DHBMusicLibrary *musicLibrary;
@property (nonatomic, retain) DHBPlaylist *selectedPlaylist;
@property (nonatomic, retain) UILocalNotification *backupAlarm;
@property (nonatomic, retain) UILocalNotification *mustBeInApp;

+ (Rdio *) rdioInstance;
- (void) checkNetworkStatus:(NSNotification *)notice;

@end
