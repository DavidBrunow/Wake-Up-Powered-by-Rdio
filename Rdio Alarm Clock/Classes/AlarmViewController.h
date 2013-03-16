//
//  MainViewController.h
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
<<<<<<< HEAD:Rdio Alarm Clock/Classes/AlarmViewController.h
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
=======
#import "AppDelegate.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import "DHBTextField.h"
>>>>>>> refs/heads/UI-Redesign:Rdio Alarm Clock/Classes/AlarmViewController.h

@interface MainViewController : UIViewController <RDPlayerDelegate, RDAPIRequestDelegate, UITextFieldDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    RDPlayer* player;
    UIButton *setAlarmButton;
    bool paused;
    bool playing;
    NSMutableArray *playlists;
    NSMutableArray *songsToPlay;
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
    UILabel *_lblSnooze;
    UILabel *_lblSleep;
    UILabel *_lblAutoStart;
    UILabel *_lblAMPM;
    UISlider *_sliderSleep;
    UISlider *_sliderSnooze;
    UIView *_loadingView;
    NSMutableArray *_canBeStreamed;
    int snoozeTime;
    int sleepTime;
    bool autoStartAlarm;
    bool _is24h;    
    NSDictionary *_settings;
    NSString *_settingsPath;
    NSString *_timeSeparator;
    NSString *_language;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) UIButton *playButton;
@property (nonatomic) int snoozeTime;
@property (nonatomic) int sleepTime;
@property (nonatomic) bool autoStartAlarm;
<<<<<<< HEAD:Rdio Alarm Clock/Classes/AlarmViewController.h
@property (nonatomic) bool shuffle;
@property (nonatomic, retain) UISwitch *switchShuffle;
@property (nonatomic, retain) UILabel *lblShuffle;
@property (nonatomic, retain) MPMusicPlayerController *music;
@property (nonatomic, retain) MPVolumeView *hideVolume;
=======
@property (nonatomic, retain) UILabel *lblWakeUpTo;
@property (nonatomic, retain) UILabel *lblPlaylist;
@property (nonatomic) ListsViewController *listsViewController;
@property (nonatomic) UITableView *chooseMusic;
@property (nonatomic) UILabel *lblSleepAmount;
@property (nonatomic) UILabel *lblSnoozeAmount;
@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) UISlider *sliderAutoStart;
@property (nonatomic) UILabel *lblAutoStartYES;
@property (nonatomic) UILabel *lblAutoStartNO;
@property (nonatomic) UISlider *sliderShuffle;
@property (nonatomic) UILabel *lblShuffle;
@property (nonatomic) UILabel *lblShuffleYES;
@property (nonatomic) UILabel *lblShuffleNO;
@property (nonatomic) bool settingsOpen;
@property (nonatomic) DHBTextField *timeTextField;
@property (nonatomic) UIColor *lightTextColor;
@property (nonatomic) UIColor *darkTextColor;

>>>>>>> refs/heads/UI-Redesign:Rdio Alarm Clock/Classes/AlarmViewController.h

- (void) setAlarmClicked;
- (void) alarmSounding;
- (void) fadeScreenIn;
- (void) fadeScreenOut;
- (void) textFieldValueChange:(UITextField *) textField;

@end
