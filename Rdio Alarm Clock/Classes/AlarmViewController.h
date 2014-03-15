//
//  AlarmViewController.h
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
#import "stdlib.h"
#import "AlarmNavController.h"
#import "ListsViewController.h"
#import <MediaPlayer/MPVolumeView.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "DHBTextField.h"

@interface AlarmViewController : UIViewController <RDPlayerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    UIButton *setAlarmButton;
    bool paused;
    bool playing;
    NSDate  *alarmTime;
    NSTimer *t;
    NSTimer *fader;
    NSTimer *delay;
    UIView *sleepView;
    UIView *wakeView;
    UIView *setAlarmView;
    UIView *autoStartAlarmView;
    int _lastLength;
    UISwitch *remindMe;
    UILocalNotification *nightlyReminder;
    UILabel *_alarmLabel;
    UILabel *_chargingLabel;
    UILabel *_lblAMPM;
    UIView *_loadingView;
    NSMutableArray *_canBeStreamed;
    NSString *_timeSeparator;
    NSString *_language;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) MPMusicPlayerController *music;
@property (nonatomic, retain) MPVolumeView *hideVolume;
@property (nonatomic, retain) UILabel *lblWakeUpTo;
@property (nonatomic, retain) UILabel *lblPlaylist;
@property (nonatomic, retain) UILabel *lblAutoSetPlaylistName;
@property (nonatomic) ListsViewController *listsViewController;
@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) bool settingsOpen;
@property (nonatomic) UITextField *timeTextField;
@property (nonatomic) UIColor *lightTextColor;
@property (nonatomic) UIColor *darkTextColor;
@property (nonatomic) UIView *alarmTimeView;
@property (nonatomic) UIView *currentTimeView;
@property (nonatomic) UIView *currentWeatherView;
@property (nonatomic, retain) NSMutableArray *songsToPlay;
@property (nonatomic) bool isSnoozing;
@property (nonatomic, retain) NSTimer *clockTimer;

- (void) setAlarmClicked;
- (void) alarmSounding;
- (void) fadeScreenIn;
- (void) fadeScreenOut;
- (void) textFieldValueChange:(UITextField *) textField;
- (void) loadPlaylistName;


@end
