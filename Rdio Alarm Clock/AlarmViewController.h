//
//  MainViewController.h
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
#import "AlarmNavController.h"
#import "AppDelegate.h"
#import <MediaPlayer/MPMusicPlayerController.h>

@interface MainViewController : UIViewController <RDPlayerDelegate, RDAPIRequestDelegate, UITextFieldDelegate>
{
    RDPlayer* player;
    UIButton *playButton;
    bool paused;
    bool playing;
    NSMutableArray *playlists;
    NSDate  *alarmTime;
    NSTimer *t;
    NSTimer *fader;
    UIView *sleepView;
    UIView *wakeView;
    UIView *setAlarmView;
    UITextField *timeTextField;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) UIButton *playButton;

- (void) setAlarmClicked;
- (void) alarmSounding;
- (void) fadeScreenIn;
- (void) fadeScreenOut;

@end
