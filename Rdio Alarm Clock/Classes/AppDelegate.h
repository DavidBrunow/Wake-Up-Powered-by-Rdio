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
    Rdio *rdio;
    Reachability *internetReachable;
    Reachability *hostReachable;
    UIWindow *window;
    bool loggedIn;
    bool alarmIsSet;
    bool alarmIsPlaying;
    float originalBrightness;
    float originalVolume;
    float appVolume;
    float appBrightness;
    NSDate  *alarmTime;
    UILocalNotification *backupAlarm;
    UILocalNotification *mustBeInApp;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly, retain) Rdio *rdio;
@property (nonatomic) bool loggedIn;
@property (nonatomic) bool alarmIsSet;
@property (nonatomic) bool alarmIsPlaying;
@property (nonatomic) float appBrightness;
@property (nonatomic) float originalBrightness;
@property (nonatomic) float originalVolume;
@property (nonatomic) float appVolume;
@property (strong, nonatomic) NSDate *alarmTime;
@property (nonatomic) NSIndexPath *selectedPlaylistPath;
@property (nonatomic) int numberOfPlaylistsOwned;
@property (nonatomic) int numberOfPlaylistsCollab;
@property (nonatomic) int numberOfPlaylistsSubscr;
@property (nonatomic, retain) NSMutableArray *playlistsInfo;
@property (nonatomic, retain) NSMutableArray *tracksInfo;
@property (nonatomic, retain) DHBAlarmClock *alarmClock;
@property (nonatomic, retain) AlarmNavController *mainNav;
@property (nonatomic, retain) RdioUser *rdioUser;
@property (nonatomic, retain) DHBMusicLibrary *musicLibrary;
@property (nonatomic, retain) DHBPlaylist *selectedPlaylist;


+(Rdio *)rdioInstance;

- (void) checkNetworkStatus:(NSNotification *)notice;

@end
