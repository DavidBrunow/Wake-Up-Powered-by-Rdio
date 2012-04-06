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

#import <MediaPlayer/MPMusicPlayerController.h>

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
    UIView *sleepView;
    UIView *wakeView;
    UIView *setAlarmView;
    UITextField *timeTextField;
    UISwitch *remindMe;
    UILocalNotification *nightlyReminder;
    ListsViewController *listsViewController;
    UILabel *_alarmLabel;
    UIView *_loadingView;
    UITableView *_chooseMusic;
    NSMutableArray *_canBeStreamed;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) UIButton *playButton;

- (void) setAlarmClicked;
- (void) alarmSounding;
- (void) fadeScreenIn;
- (void) fadeScreenOut;
- (void) textFieldValueChange:(UITextField *) textField;

@end
