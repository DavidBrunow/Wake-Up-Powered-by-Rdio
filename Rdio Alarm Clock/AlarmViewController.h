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
#import "MMPDeepSleepPreventer.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController <RDPlayerDelegate, RDAPIRequestDelegate, UITextFieldDelegate>
{
    RDPlayer* player;
    UIButton *playButton;
    bool paused;
    bool playing;
    float originalBrightness;
    float appBrightness;
    float originalVolume;
    NSMutableArray *playlists;
    NSDate  *alarmTime;
    NSTimer *t;
    UIView *sleepView;
    UIView *wakeView;
    UIView *setAlarmView;
    UITextField *timeTextField;
    MMPDeepSleepPreventer *awake;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) UIButton *playButton;

- (void) setAlarmClicked;
- (void) alarmSounding;

@end
