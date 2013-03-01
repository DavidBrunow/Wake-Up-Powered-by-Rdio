//
//  MainViewController.m
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "AlarmNavController.h"
#import "AppDelegate.h"
#import "SimpleKeychain.h"
#import <Rdio/Rdio.h>
#import <QuartzCore/QuartzCore.h>

@implementation MainViewController

@synthesize player, playButton, snoozeTime, sleepTime, autoStartAlarm;

-(RDPlayer*)getPlayer
{
    if (player == nil) {
        player = [AppDelegate rdioInstance].player;
    }
    return player;
}

- (void) setAlarmClicked {
    NSRange colonRange = NSRangeFromString(@"2,1");
    
    if (timeTextField.text.length == 4 && [[timeTextField.text substringWithRange:colonRange] isEqualToString:_timeSeparator]) {
        timeTextField.text = [timeTextField.text stringByReplacingOccurrencesOfString:_timeSeparator withString:@""];
        timeTextField.text = [NSString stringWithFormat:@"%@%@%@", [timeTextField.text substringToIndex:1], _timeSeparator, [timeTextField.text substringFromIndex:1]];
        NSLog(@"newtime: %@", timeTextField.text);
    }
    
    NSString *tempTimeString = timeTextField.text;
    tempTimeString = [NSString stringWithFormat:@"%@ AM", tempTimeString];
    
    [self setAlarm];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        
    } else {
        [self setAlarm];
    }
}

- (void) getAlarmTime {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *tempTimeString = @"";
    
    if (timeTextField.text.length == 4) {
        tempTimeString = [NSString stringWithFormat:@"0%@", timeTextField.text];
    } else {
        tempTimeString = timeTextField.text;
    }
    tempTimeString = [tempTimeString stringByReplacingOccurrencesOfString:_timeSeparator withString:@":"];
        
    NSString *tempDateString = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    
    tempDateString = [NSString stringWithFormat:@"%@T%@", tempDateString, tempTimeString];
    [appDelegate.alarmClock setAlarmTime:[formatter dateFromString:tempDateString]];
    if(!_is24h) {
        if ([[appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[appDelegate.alarmClock alarmTime]) {
            [appDelegate.alarmClock setAlarmTime:[appDelegate.alarmTime dateByAddingTimeInterval:43200]];
            if ([[appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[appDelegate.alarmClock alarmTime]) {
                [appDelegate.alarmClock setAlarmTime:[appDelegate.alarmTime dateByAddingTimeInterval:43200]];
            }
        }
    } else if (_is24h) {
        if ([[appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[appDelegate.alarmClock alarmTime]) {
            [appDelegate.alarmClock setAlarmTime:[appDelegate.alarmTime dateByAddingTimeInterval:86400]];
            if ([[appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[appDelegate.alarmClock alarmTime]) {
                [appDelegate.alarmClock setAlarmTime:[appDelegate.alarmTime dateByAddingTimeInterval:86400]];
            }
        }
    }

}

- (void) setAlarm {
    [timeTextField resignFirstResponder];
    
    [self getAlarmTime];
    
    if (remindMe.on) {
        nightlyReminder = [[UILocalNotification alloc] init];
        
        nightlyReminder.fireDate = [NSDate dateWithTimeIntervalSinceNow:86400];
        NSLog(@"alarm will go off: %@", nightlyReminder.fireDate);
        nightlyReminder.timeZone = [NSTimeZone systemTimeZone];
        
        nightlyReminder.alertBody = @"Are you ready to set your nightly alarm?";
        nightlyReminder.alertAction = @"Set Alarm";
        nightlyReminder.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:nightlyReminder];
    }

    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [self displaySleepScreen];

}

- (void) displaySleepScreen {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = YES;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect sleepLabelRect = CGRectMake(20.0, 170.0, 280.0, 200.0);
    CGRect alarmLabelRect = CGRectMake(20.0, 20.0, 280.0, 200.0);
    CGRect chargingLabelRect = CGRectMake(20.0, 320.0, 280.0, 200.0);
    
    
    NSString *alarmTimeText;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (!_is24h) {
        [formatter setDateFormat:@"h:mm a"];
    } else if (_is24h) {
        [formatter setDateFormat:@"H:mm"];
        NSLog(@"this is 24 hour clock");
    }
    alarmTimeText = [formatter stringFromDate:[appDelegate.alarmClock alarmTime]];
    alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@":" withString:_timeSeparator];
    sleepView = [[UIView alloc] initWithFrame:screenRect];
    
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [sleepView setBackgroundColor:[UIColor blackColor]];
    UILabel *sleepLabel = [[UILabel alloc] initWithFrame:sleepLabelRect];
    //[sleepLabel setText:NSLocalizedString(@"PLEASE REST PEACEFULLY", nil)];
    [sleepLabel setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    //[sleepLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0]];
    [sleepLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [sleepLabel setBackgroundColor:[UIColor blackColor]];
    [sleepLabel setNumberOfLines:10];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    
    [sleepLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"PLEASE REST PEACEFULLY", nil) lowercaseString] attributes:ats]];
    
    //[sleepLabel setAdjustsFontSizeToFitWidth:YES];
    [sleepView addSubview:sleepLabel];
    
    _alarmLabel = [[UILabel alloc] initWithFrame:alarmLabelRect];
    //[_alarmLabel setText:[NSString stringWithFormat:NSLocalizedString(@"YOUR ALARM IS SET", nil), alarmTimeText]];
    [_alarmLabel setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    //[_alarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
    [_alarmLabel setBackgroundColor:[UIColor blackColor]];
    [_alarmLabel setNumberOfLines:10];
    [_alarmLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"YOUR ALARM IS SET", nil), alarmTimeText] lowercaseString] attributes:ats]];

    //[_alarmLabel setAdjustsFontSizeToFitWidth:YES];
    [sleepView addSubview:_alarmLabel];
    
    _chargingLabel = [[UILabel alloc] initWithFrame:chargingLabelRect];
    //[_chargingLabel setText:NSLocalizedString(@"PLUG ME IN", nil)];
    [_chargingLabel setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [_chargingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
    [_chargingLabel setBackgroundColor:[UIColor blackColor]];
    [_chargingLabel setNumberOfLines:10];
    //[_chargingLabel setAdjustsFontSizeToFitWidth:YES];
    [_chargingLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"PLUG ME IN", nil) lowercaseString] attributes:ats]];

    if ([UIDevice currentDevice].batteryState != UIDeviceBatteryStateCharging && [UIDevice currentDevice].batteryState != UIDeviceBatteryStateFull) {
        [sleepView addSubview:_chargingLabel];
    }
    
    CGRect cancelFrame = CGRectMake((self.view.frame.size.width - 49) / 2, self.view.frame.size.height - 19 - 49, 49, 49);
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:cancelFrame];
    
    UIImage *cancelButtonImage = [UIImage imageNamed:@"x"];
    
    [cancelButton setBackgroundColor:[UIColor blackColor]];
    [cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor blackColor]];
    [cancelButton setAccessibilityLabel:NSLocalizedString(@"Cancel Alarm", nil)];
    [cancelButton addGestureRecognizer:slideViewGesture];
    [cancelButton addTarget:self action:@selector(bounceView) forControlEvents:UIControlEventTouchUpInside];
    
    [sleepView addSubview:cancelButton]; 
    
    [self.view addSubview:sleepView]; 
    
    [fader invalidate];
    
    if (sleepTime != 0) {
        if ([[AppDelegate rdioInstance] player].state == RDPlayerStatePaused) {
            [[[AppDelegate rdioInstance] player] togglePause];
        } else {
            songsToPlay = [self shuffle:songsToPlay];
            songsToPlay = [self getEnough:songsToPlay];
            [[[AppDelegate rdioInstance] player] playSources:songsToPlay];
        }
        fader = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES];
    } else {
        fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES]; 
    }
    
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    appDelegate.originalVolume = music.volume;
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:sender.view.superview];
    
    CGRect newFrame = [[UIScreen mainScreen] bounds];

    newFrame.origin.y += (translate.y);
    sender.view.superview.frame = newFrame;
        
         
    //}
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (translate.y < -100.0) {
            [UIView animateWithDuration:0.3 animations:^{[sender.view.superview setFrame:CGRectMake(0.0, -[[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];} completion:^(BOOL finished){[sender.view.superview removeFromSuperview];[self cancelAlarm];}];
        } else {
            [self bounceView];
        }
    }
}

- (void) cancelAlarm {
    [fader invalidate];
    fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenIn) userInfo:nil repeats:YES];
    [t invalidate];
    [self stopAlarm];
}

- (void) fadeScreenOut {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    NSInteger sleepTimeSeconds = sleepTime * 60;
    if (sleepTimeSeconds == 0) {
        sleepTimeSeconds = 100;
    }
    
    if ([UIScreen mainScreen].brightness <= 0.0) {
        [fader invalidate];
        if (sleepTime != 0) {
            [[[AppDelegate rdioInstance] player] togglePause];
        }
        appDelegate.appBrightness = 0.0;
        [_alarmLabel removeFromSuperview];
        [_chargingLabel removeFromSuperview];
        [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    } else {
        float increment = (appDelegate.originalBrightness - 0.0)/(sleepTimeSeconds);
        float newBrightness = [UIScreen mainScreen].brightness - increment;
        [[UIScreen mainScreen] setBrightness:newBrightness];
        
        float incrementVolume = (appDelegate.originalVolume - 0.0)/(sleepTimeSeconds);
        float newVolume = music.volume - incrementVolume;
        if (appDelegate.appVolume > 0) {
            if (sleepTime != 0) {
                [music setVolume:newVolume];
                appDelegate.appVolume = newVolume;
            } else {
                [music setVolume:0];
                appDelegate.appVolume = 0;
            }
        }
    }
}

- (void) fadeScreenIn {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    
    if (appDelegate.originalVolume <= 0.1) {
        appDelegate.originalVolume = 0.5;
    }
    
    if ([UIScreen mainScreen].brightness >= appDelegate.originalBrightness && music.volume >= appDelegate.originalVolume) {
        [fader invalidate];
    } else {
        if ([UIScreen mainScreen].brightness < appDelegate.originalBrightness) {
            float incrementScreen = (appDelegate.originalBrightness - 0.0)/100.0;
            float newBrightness = [UIScreen mainScreen].brightness + incrementScreen;
            [[UIScreen mainScreen] setBrightness:newBrightness];
            appDelegate.appBrightness = newBrightness;
        }
        
        if (music.volume < appDelegate.originalVolume) {
            float incrementVolume = (appDelegate.originalVolume - 0.0)/100.0;
            float newVolume = music.volume + incrementVolume;
            if (appDelegate.appVolume < appDelegate.originalVolume) {
                [music setVolume:newVolume];
                appDelegate.appVolume = newVolume;
            }
        }
    }
}

- (void) alarmSounding {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = NO;
    appDelegate.alarmIsPlaying = YES;
    [fader invalidate];
    fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenIn) userInfo:nil repeats:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [sleepView removeFromSuperview];
    
    if ([[AppDelegate rdioInstance] player].state == RDPlayerStatePaused) {
        [[[AppDelegate rdioInstance] player] togglePause];
    } else {
        songsToPlay = [self shuffle:songsToPlay];
        [[[AppDelegate rdioInstance] player] playSources:songsToPlay];
    }
    
    wakeView = [[UIView alloc] initWithFrame:screenRect];
    [wakeView setBackgroundColor:[UIColor colorWithRed:241.0/255 green:147.0/255 blue:20.0/255 alpha:1.0]];
    
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    //[wakeView addGestureRecognizer:slideViewGesture];
    
    CGRect snoozeFrame = CGRectMake(40, 170, 240, 80);
    UIButton *snoozeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [snoozeButton setFrame:snoozeFrame];
    
    [snoozeButton setTitle:NSLocalizedString(@"SNOOZE", nil) forState: UIControlStateNormal];
    [snoozeButton setTintColor:[UIColor colorWithRed:241.0/255 green:147.0/255 blue:20.0/255 alpha:1.0]];
    [snoozeButton setBackgroundColor:[UIColor clearColor]];
    [snoozeButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:58.0]];
    [snoozeButton.titleLabel setTextColor:[UIColor blackColor]];
    
    [snoozeButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [snoozeButton addTarget:self action:@selector(startSnooze) forControlEvents:UIControlEventTouchUpInside];
    [wakeView addSubview:snoozeButton];
    
    CGRect offFrame = CGRectMake((self.view.frame.size.width - 49) / 2, self.view.frame.size.height - 19 - 49, 49, 49);
    UIImage *offButtonImage = [UIImage imageNamed:@"orangex"];
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [offButton setImage:offButtonImage forState:UIControlStateNormal];
    [offButton setAccessibilityLabel:NSLocalizedString(@"TURN OFF ALARM", nil)];
    [offButton setFrame:offFrame];
    [offButton setBackgroundColor:[UIColor clearColor]];
    [offButton addTarget:self action:@selector(bounceView) forControlEvents:UIControlEventTouchUpInside];
    [offButton addGestureRecognizer:slideViewGesture];
    //[offButton addTarget:self action:@selector(slideViewUp) forControlEvents:UIControlEventTouchDragInside];
    [wakeView addSubview:offButton]; 
    [self.view addSubview:wakeView];
}

- (void) bounceView
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    CGRect bounceUpFrameFirst = [[UIScreen mainScreen] bounds];
    bounceUpFrameFirst.origin.y = bounceUpFrameFirst.origin.y - 30.0;
    CGRect bounceUpFrameSecond = [[UIScreen mainScreen] bounds];
    bounceUpFrameSecond.origin.y = bounceUpFrameFirst.origin.y - 15.0;
    CGRect bounceUpFrameThird = [[UIScreen mainScreen] bounds];
    bounceUpFrameThird.origin.y = bounceUpFrameFirst.origin.y - 10.0;
    CGRect bounceDownFrame = [[UIScreen mainScreen] bounds];
    
    [UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameFirst]; [sleepView setFrame:bounceUpFrameFirst];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameSecond]; [sleepView setFrame:bounceUpFrameSecond];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameThird]; [sleepView setFrame:bounceUpFrameThird];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];}];}];}];}];}];}];
    
    if (UIAccessibilityIsVoiceOverRunning())
    {
        if (appDelegate.alarmIsSet) {
            [sleepView removeFromSuperview];
            [self cancelAlarm];
            [self setAccessibilityLabel:NSLocalizedString(@"ALARM CANCELED", nil)];
                    } else {
            [wakeView removeFromSuperview];
            [self stopAlarm];
            [self setAccessibilityLabel:NSLocalizedString(@"ALARM STOPPED", nil)]; 
        }
    }
}

- (NSMutableArray *) shuffle: (NSMutableArray *) list
{
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:[list count]];
    NSString *testObject = @"";
    int x = 0;
    int oldListCount = list.count;
    
    while (oldListCount != newList.count) {
        NSLog(@"oldlistcount: %d, newlistcount: %d", list.count, newList.count);
         
        int listIndex = (arc4random() % list.count);
        testObject = [list objectAtIndex:listIndex];

        NSLog(@"_canBeStreamed: %@",[_canBeStreamed objectAtIndex:listIndex]); 
        if ([[_canBeStreamed objectAtIndex:listIndex] isEqualToString:@"YES"]) {
            [newList  addObject:testObject];
            [list removeObjectAtIndex:listIndex];
            [_canBeStreamed removeObjectAtIndex:listIndex];
            
            NSLog(@"list item #%d: %@", x, [newList objectAtIndex:x]);
            x++;
        } else {
            NSLog(@"list item not added: %@", [list objectAtIndex:listIndex]);
            [list removeObjectAtIndex:listIndex];
            [_canBeStreamed removeObjectAtIndex:listIndex];
            oldListCount--;
        }
    }
    
    return newList;
}

- (NSMutableArray *) getEnough: (NSMutableArray *) list
{
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:[list count]];
    
    while (newList.count < 120) {
        [newList addObjectsFromArray:list];
        NSLog(@"number of items in songstoplay now: %d", newList.count);
    }
    
    return newList;
}

- (void) startSnooze {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //double currentPosition = [[AppDelegate rdioInstance] player].position; 
    [[[AppDelegate rdioInstance] player] togglePause];
    
    int snoozeTimeSeconds = snoozeTime * 60;
    //#TODO: Find some way to not save the value this time, since we are only snoozing
    [appDelegate.alarmClock setAlarmTime:[NSDate dateWithTimeIntervalSinceNow:snoozeTimeSeconds]];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [wakeView removeFromSuperview];
    [self displaySleepScreen];
}

- (void) stopAlarm {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    appDelegate.alarmIsSet = NO;
    appDelegate.alarmIsPlaying = NO;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    [music setVolume:appDelegate.originalVolume];
    [[UIScreen mainScreen] setBrightness:appDelegate.originalBrightness];
    self.navigationController.navigationBarHidden = YES;
    [[[AppDelegate rdioInstance] player] stop];
    [self determineStreamableSongs];
    //[wakeView removeFromSuperview];
    //[self.view addSubview:setAlarmView];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{

}
*/

- (void) loginClicked {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logOutNotification" object:nil];
}

- (void) updateSnoozeLabel {
    if ((int)_sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:@"%d min", (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 91) / 2, 105.0, 126, 43)];
        //[_lblSnooze setText:[NSString stringWithFormat:NSLocalizedString(@"SNOOZE SLIDER LABEL", nil), (int)_sliderSnooze.value]];
    } else {
        if(_sliderSnooze.value < 10) {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 105.0, 126, 43)];
        } else {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 105.0, 126, 43)];

        }
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:@"%d mins", (int)_sliderSnooze.value]];
        //[_lblSnooze setText:[NSString stringWithFormat:NSLocalizedString(@"SNOOZE SLIDER LABEL PLURAL", nil), (int)_sliderSnooze.value]];
    }
    NSString *sliderSnoozeString = [NSString stringWithFormat:@"%d", (int)_sliderSnooze.value];
    [_settings setValue:sliderSnoozeString forKey:@"Snooze Time"];
    self.snoozeTime = (int)_sliderSnooze.value;
    [self writeSettings];
}

- (void) updateSleepLabel {
    float sleepTimeValue;
    double svalue = _sliderSleep.value / 10.0;
    double dvalue = svalue - floor(svalue);
    //Check if the decimal value is closer to a 5 or not
    if(dvalue >= 0.25 && dvalue < 0.75)
        dvalue = floorf(svalue) + 0.5f;
    else
        dvalue = roundf(svalue);
    sleepTimeValue = dvalue * 10;
    NSLog(@"%f", sleepTimeValue);
    //if ((int)_sliderSleep.value == 1) {
    //    [_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL", nil), (int)sleepTimeValue]];
    //
    /*} else */
    if (sleepTimeValue < 5) {
        //[_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL DISABLED", nil)]];
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"DISABLED"]];
        [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 124) / 2, 232.0, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [_sliderSleep setValue:0.0];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];

        if(sleepTimeValue < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 235.0, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 235.0, 126, 43)];
            
        }
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%d mins", (int)sleepTimeValue]];

        //[_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL PLURAL", nil), (int)sleepTimeValue]];
    }
    NSString *sliderSleepString = [NSString stringWithFormat:@"%d", (int)sleepTimeValue];
    [_settings setValue:sliderSleepString forKey:@"Sleep Time"];
    self.sleepTime = (int)sleepTimeValue;
    [self writeSettings];
}




- (void) updateAutoStart {
    NSString *autoStartString = [NSString stringWithFormat:@"%d", (bool)_switchAutoStart.on];
    [_settings setValue:autoStartString forKey:@"Auto Start Alarm"];
    self.autoStartAlarm = (bool)_switchAutoStart.on;
    [self writeSettings];
}

-(void)writeSettings
{
    //NSString* docFolder = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString * path = [docFolder stringByAppendingPathComponent:@"Settings.plist"];
    
    if([_settings writeToFile:_settingsPath atomically: YES]){
    } else {

    }
    
}



- (void) changeBatteryLabel
{
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 50.0f;
        paragraphStyle.maximumLineHeight = 50.0;
        paragraphStyle.minimumLineHeight = 50.0f;
        
        NSDictionary *ats = @{
                              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                              NSParagraphStyleAttributeName : paragraphStyle
                              };

        [_chargingLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"CHARGING LABEL", nil) lowercaseString] attributes:ats]];
        //[_chargingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"CHARGING LABEL", nil)]];
        //[_chargingLabel setAdjustsFontSizeToFitWidth:YES];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBatteryLabel) name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    
    _language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    _timeSeparator = @":";
    
    if([_language isEqualToString:@"en"]) {
        _timeSeparator = @":";
    } else if([_language isEqualToString:@"fr"] || [_language isEqualToString:@"pt-PT"]) {
        _timeSeparator = @"h";
    } else if([_language isEqualToString:@"de"] || [_language isEqualToString:@"da"] || [_language isEqualToString:@"fi"]) {
        _timeSeparator = @".";
    }
    //NSLog(@"%@", _language);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    _is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    //NSLog(@"%@\n",(_is24h ? @"YES" : @"NO"));

    
    
        
    self.sleepTime = [appDelegate.alarmClock sleepTime];
    self.snoozeTime = [appDelegate.alarmClock snoozeTime];
    self.autoStartAlarm = [appDelegate.alarmClock autoStartAlarm];
    
    _lastLength = 0;
    [self.navigationItem setHidesBackButton:true];
    [self.view setBounds:[[UIScreen mainScreen] bounds]];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    
    //CGRect fullScreen = [[UIScreen mainScreen] bounds];
    CGRect fullScreen = [self.navigationController view].frame;
    
    UIView *settingsView = [[UIView alloc] initWithFrame:fullScreen];
    //UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"550L_cloth.jpg"]];
    [settingsView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"settings-darkbg"]]];
    
    CGRect frameBtnSignOut = CGRectMake((self.view.frame.size.width - 89) / 2, self.view.frame.size.height - 125, 89, 29);
    UIButton *btnSignOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignOut setFrame:frameBtnSignOut];
    [btnSignOut setTitle:[NSString stringWithFormat:NSLocalizedString(@"SIGN OUT", nil)] forState:UIControlStateNormal];
    [btnSignOut.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [btnSignOut.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btnSignOut setTitleColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout"] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout-pressed"] forState:UIControlStateHighlighted];

    [btnSignOut addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _sliderSnooze = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2, 150, 250, 50)];
    [_sliderSnooze setMinimumValue:1.0];
    [_sliderSnooze setMaximumValue:30.0];
    [_sliderSnooze setValue:snoozeTime animated:NO];
    [_sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [_sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];

    [_sliderSnooze setMinimumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];
    [_sliderSnooze setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];

    [_sliderSnooze addTarget:self action:@selector(updateSnoozeLabel) forControlEvents:UIControlEventAllEvents];
    
    [settingsView addSubview:_sliderSnooze];
    
    _lblSnooze = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 60, 280, 50)];
    if ((int)_sliderSnooze.value == 1) {
        [_lblSnooze setText:[NSString stringWithFormat:NSLocalizedString(@"SNOOZE SLIDER LABEL", nil), (int)_sliderSnooze.value]];
    } else {
        [_lblSnooze setText:[NSString stringWithFormat:NSLocalizedString(@"SNOOZE SLIDER LABEL PLURAL", nil), (int)_sliderSnooze.value]];
    }
    //[_lblSnooze setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    [_lblSnooze setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];

    [_lblSnooze setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [_lblSnooze setBackgroundColor:[UIColor clearColor]];
    [_lblSnooze setNumberOfLines:10];
    
    [_lblSnooze setAdjustsFontSizeToFitWidth:YES];
    
    [_lblSnooze setTextAlignment:NSTextAlignmentCenter];
    [settingsView addSubview:_lblSnooze];
    
    UIImageView *snoozeBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [snoozeBubble setFrame:CGRectMake((self.view.frame.size.width - 136) / 2, 100.0, 136, 48)];
    [settingsView addSubview:snoozeBubble];
    
    self.lblSnoozeAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 105.0, 126, 43)];
    
    if ((int)_sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:@"%d min", (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 91) / 2, 105.0, 126, 43)];
    } else if(_sliderSnooze.value < 10) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:@"%d mins", (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 105.0, 126, 43)];
    } else {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:@"%d mins", (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 105.0, 126, 43)];
    }
    
    [self.lblSnoozeAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSnoozeAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSnoozeAmount setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    
    [settingsView addSubview:self.lblSnoozeAmount];
    
    _sliderSleep = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2, 280, 250, 50)];
    [_sliderSleep setMinimumValue:0.0];
    [_sliderSleep setMaximumValue:60.0];
    [_sliderSleep setValue:sleepTime animated:NO];
    [_sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [_sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];
    
    [_sliderSleep setMinimumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];
    [_sliderSleep setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];

    [_sliderSleep addTarget:self action:@selector(updateSleepLabel) forControlEvents:UIControlEventAllEvents];
    
    _lblSleep = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 190, 280, 50)];
    if ((int)_sliderSleep.value == 1) {
        [_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL", nil), (int)_sliderSleep.value]];
        
    } else if ((int)_sliderSleep.value == 0) {
        [_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL DISABLED", nil)]];
    } else {
        [_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL PLURAL", nil), (int)_sliderSleep.value]];
    }
    //[_lblSleep setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    [_lblSleep setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [_lblSleep setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [_lblSleep setBackgroundColor:[UIColor clearColor]];
    [_lblSleep setNumberOfLines:10];
    [_lblSleep setAdjustsFontSizeToFitWidth:YES];
    
    [_lblSleep setTextAlignment:NSTextAlignmentCenter];
    
    UIImageView *sleepBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [sleepBubble setFrame:CGRectMake((self.view.frame.size.width - 136) / 2, 230.0, 136, 48)];
    [settingsView addSubview:sleepBubble];
    
    self.lblSleepAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 105.0, 126, 43)];
    
    float sleepTimeValue;
    double svalue = _sliderSleep.value / 10.0;
    double dvalue = svalue - floor(svalue);
    //Check if the decimal value is closer to a 5 or not
    if(dvalue >= 0.25 && dvalue < 0.75)
        dvalue = floorf(svalue) + 0.5f;
    else
        dvalue = roundf(svalue);
    sleepTimeValue = dvalue * 10;
    
    if (sleepTimeValue < 5) {
        //[_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL DISABLED", nil)]];
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"DISABLED"]];
        [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 124) / 2, 232.0, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [_sliderSleep setValue:0.0];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];
        
        if(sleepTimeValue < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 235.0, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 235.0, 126, 43)];
            
        }
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%d mins", (int)sleepTimeValue]];
        
        //[_lblSleep setText:[NSString stringWithFormat:NSLocalizedString(@"SLEEP SLIDER LABEL PLURAL", nil), (int)sleepTimeValue]];
    }
    
    [self.lblSleepAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSleepAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSleepAmount setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    
    [settingsView addSubview:self.lblSleepAmount];
    
    _switchAutoStart = [[UISwitch alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 80) / 2, 325, 50, 50)];
    [_switchAutoStart setOn:autoStartAlarm animated:NO];
    [_switchAutoStart setTintColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    //[_switchAutoStart setThumbTintColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];];
    [_switchAutoStart addTarget:self action:@selector(updateAutoStart) forControlEvents:UIControlEventAllEvents];
    
    //[settingsView addSubview:_switchAutoStart];
    
    _lblAutoStart = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, 260, 200, 60)];
    [_lblAutoStart setText:[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM", nil)]];
    [_lblAutoStart setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    //[_lblAutoStart setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];

    [_lblAutoStart setTextAlignment:NSTextAlignmentCenter];
    [_lblAutoStart setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [_lblAutoStart setBackgroundColor:[UIColor clearColor]];
    [_lblAutoStart setLineBreakMode:NSLineBreakByWordWrapping];
    [_lblAutoStart setNumberOfLines:10];
    [_lblAutoStart setAdjustsFontSizeToFitWidth:YES];
    
    //[settingsView addSubview:_lblAutoStart];

    if (appDelegate.loggedIn) {
        [settingsView addSubview:btnSignOut];
        [settingsView addSubview:_lblSleep];
        [settingsView addSubview:_sliderSleep];
    }
    
    UIImageView *ivTexas = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ThickTexasVector"]];
    [ivTexas setFrame:CGRectMake((self.view.frame.size.width - 32) / 2, self.view.frame.size.height - 90, 31, 30)];
    
    [settingsView addSubview:ivTexas];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300) / 2, self.view.frame.size.height - 60, 300, 50)];
    [lblName setText:[NSString stringWithFormat:@"David Brunow\n@davidbrunow\nhelloDavid@brunow.org"]];
    [lblName setText:[NSString stringWithFormat:@"Designed and Developed in Texas by\nJenni Leder @thoughtbrain jenni.leder@gmail.com\nDavid Brunow @davidbrunow helloDavid@brunow.org"]];
    [lblName setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [lblName setTextColor:[UIColor blackColor]];

    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0]];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setNumberOfLines:10];
    
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [settingsView addSubview:lblName];
    
    [self.view addSubview:settingsView];
    
    setAlarmView = [[UIView alloc] initWithFrame:fullScreen];
    //[setAlarmView setBackgroundColor:[UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0]];
    [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
    
    CGRect setAlarmFrame = CGRectMake((self.view.frame.size.width - 240) / 2, self.view.frame.size.height - 150, 240, 50);
    setAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setAlarmButton setFrame:setAlarmFrame];
    
    [setAlarmButton setBackgroundImage:[UIImage imageNamed:@"btn-setalarm"] forState:UIControlStateNormal];
    [setAlarmButton setTitle:NSLocalizedString(@"SET ALARM", nil) forState: UIControlStateNormal];
    [setAlarmButton setBackgroundColor:[UIColor grayColor]];
    [setAlarmButton.titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    [setAlarmButton addTarget:self action:@selector(setAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
    [setAlarmButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
    [setAlarmButton setTitleColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0] forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [setAlarmButton setEnabled:NO];
    [setAlarmView addSubview:setAlarmButton];
    
    /*
     CGRect remindMeFrame = CGRectMake(40.0, 180.0, 120, 30);
     remindMe = [[UISwitch alloc] initWithFrame:remindMeFrame];
     [remindMe setOn:YES animated:YES];
     [setAlarmView addSubview:remindMe]; */
    
    CGRect timeTextFrame = CGRectMake(10, 5, self.view.frame.size.width, 92);
    UIImage *timeTextBackground = [UIImage imageNamed:@"timeSetRoundedRect"];
    UIImageView *timeTextBackgroundView = [[UIImageView alloc] initWithImage:timeTextBackground];
    [timeTextBackgroundView setFrame:timeTextFrame];
    //[setAlarmView addSubview:timeTextBackgroundView];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    
    timeTextField = [[UITextField alloc] initWithFrame:timeTextFrame];
    [timeTextField setDelegate:self];
    [timeTextField setBackgroundColor:[UIColor clearColor]];
    [timeTextField setTextAlignment:NSTextAlignmentLeft];
    [timeTextField setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [timeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [timeTextField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:92]];
    //[timeTextField setBounds:CGRectMake(5.0, 60, 300, 150)];
    //[timeTextField setContentMode:UIViewContentModeScaleToFill];
    [timeTextField setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"CHOOSE ALARM TIME", nil)]];
    [timeTextField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    //[timeTextField setAdjustsFontSizeToFitWidth:YES];
    timeTextField.inputAccessoryView = numberToolbar;
    NSString *timeTextString = [NSString stringWithFormat:@"%@",[appDelegate.alarmClock getAlarmTimeString] ];
    if (timeTextString == nil) {
        timeTextString = [NSString stringWithFormat:@""];
    } else {
        timeTextString = [timeTextString stringByReplacingOccurrencesOfString:@"h" withString:_timeSeparator];
    }
    [timeTextField setText:timeTextString];
    
    //TODO: Make sure that the default time of 06:00 will work with 24 hour clocks
    
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] init];
    [dismissTap addTarget:self action:@selector(doneWithNumberPad)];
    
    [self.view addGestureRecognizer:dismissTap];
    
    [timeTextField setPlaceholder:_timeSeparator];
    [setAlarmView addSubview:timeTextField];
    
    CGRect chooseMusicFrame = CGRectMake(30.0, 300, 260.0, 100.0);
    _chooseMusic = [[UITableView alloc] initWithFrame:chooseMusicFrame style:UITableViewStyleGrouped];
    [_chooseMusic setScrollEnabled:NO];
    [_chooseMusic setBackgroundColor:[UIColor clearColor]];
    [_chooseMusic setBackgroundView:nil];
    [_chooseMusic setDelegate:self];
    [_chooseMusic setDataSource:self];
    
    self.lblWakeUpTo = [[UILabel alloc] initWithFrame:CGRectMake(10, 131.0, 300.0, 40.0)];
    [self.lblWakeUpTo setText:[NSString stringWithFormat:NSLocalizedString(@"WAKE UP TO", nil)]];
    [self.lblWakeUpTo setBackgroundColor:[UIColor clearColor]];
    [self.lblWakeUpTo setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [self.lblWakeUpTo setNumberOfLines:1];
    [self.lblWakeUpTo setContentMode:UIControlContentVerticalAlignmentTop];
    [self.lblWakeUpTo setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0]];
    [self.lblWakeUpTo sizeToFit];
    
    [setAlarmView addSubview:self.lblWakeUpTo];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    self.lblPlaylist = [[UILabel alloc] initWithFrame:CGRectMake(10, 154.0, self.view.frame.size.width, 200.0)];
    if (appDelegate.loggedIn) {
        [self.lblPlaylist setText:[NSString stringWithFormat:NSLocalizedString(@"CHOOSE PLAYLIST", nil)]];
        [tap addTarget:self action:@selector(showPlaylists)];
    } else {
        [self.lblPlaylist setText:[NSString stringWithFormat:NSLocalizedString(@"NOT SIGNED IN LABEL", nil)]];
        [tap addTarget:self action:@selector(RdioSignUp)];
    }
    [self.lblPlaylist setBackgroundColor:[UIColor clearColor]];
    [self.lblPlaylist setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    [self.lblPlaylist sizeToFit];
    if (self.view.frame.size.height > 480) {
        [self.lblPlaylist setNumberOfLines:4];
    } else {
        [self.lblPlaylist setNumberOfLines:3];
    }
    [self.lblPlaylist setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0]];
    [self.lblPlaylist setUserInteractionEnabled:YES];
    [self.lblPlaylist addGestureRecognizer:tap];
    
    

    [setAlarmView addSubview:self.lblPlaylist];
    
    if (appDelegate.loggedIn) {
        //[setAlarmView addSubview:_chooseMusic];
    } else {
        
        CGRect notLoggedInLabelFrame = CGRectMake(40.0, -5.0, 240.0, 100.0);
        UIButton *notLoggedInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [notLoggedInButton setFrame:notLoggedInLabelFrame];
        [notLoggedInButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"NOT SIGNED IN LABEL", nil)] forState:UIControlStateNormal];
        [notLoggedInButton setBackgroundColor:[UIColor clearColor]];
        [notLoggedInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notLoggedInButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [notLoggedInButton.titleLabel setNumberOfLines:0];
        
        [notLoggedInButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [notLoggedInButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [notLoggedInButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [notLoggedInButton addTarget:self action:@selector(RdioSignUp) forControlEvents:UIControlEventTouchUpInside];

        //[setAlarmView addSubview:notLoggedInButton];
        
    }
    
    /* This is supposed to hide the volume controls, but has a problem where the controls are initially shown when this view is added. */
    /*
    MPVolumeView *hideVolume = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    [hideVolume setHidden:YES];
    [hideVolume setAlpha:0.0];
    [hideVolume setShowsVolumeSlider:NO];
    [hideVolume setShowsRouteButton:NO];
    
    [self.view addSubview:hideVolume];
*/
    [setAlarmView.layer setShadowColor:[UIColor blackColor].CGColor];
    [setAlarmView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [setAlarmView.layer setShadowRadius:6.0];
    [setAlarmView.layer setShadowOpacity:1.0];
    
    CGRect settingsButtonFrame = CGRectMake((self.view.frame.size.width - 161) / 2, self.view.frame.size.height - 45, 161, 34);
    UIImage *settingsButtonImage = [UIImage imageNamed:@"icon-settings"];
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSettings setImage:settingsButtonImage forState:UIControlStateNormal];
    [btnSettings setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"CHANGE SETTINGS", nil)]];
    [btnSettings setFrame:settingsButtonFrame];
    //TODO: Make settings button respond to swipes
    //[btnSettings setBackgroundColor:[UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0]];
    [btnSettings setTintColor:[UIColor clearColor]];
    
    [btnSettings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    
    [setAlarmView addSubview:btnSettings];
    
    [self.view addSubview:setAlarmView];
    
    [self setAMPMLabel];
    
    if (_switchAutoStart.on && ![timeTextString isEqualToString:@""]) {
        [self getAlarmTime];
        NSString *alarmTimeText;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if(!_is24h) {
            [formatter setDateFormat:@"h:mm a"];
        } else {
            [formatter setDateFormat:[NSString stringWithFormat:@"H:mm"]];
        }
        alarmTimeText = [formatter stringFromDate:[appDelegate.alarmClock alarmTime]];
        alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@":" withString:_timeSeparator];
        self.navigationController.navigationBarHidden = YES;
        autoStartAlarmView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [autoStartAlarmView setBackgroundColor:[UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0]];
        UILabel *autoStartAlarmViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 240, 400)];
        [autoStartAlarmViewLabel setBackgroundColor:[UIColor clearColor]];
        [autoStartAlarmViewLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [autoStartAlarmViewLabel setText:[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM BEING SET", nil), [appDelegate.alarmClock playlistName], alarmTimeText]];
        [autoStartAlarmViewLabel setNumberOfLines:20];
        [autoStartAlarmViewLabel setAdjustsFontSizeToFitWidth:YES];
        [autoStartAlarmViewLabel setTextColor:[UIColor whiteColor]];
        [autoStartAlarmViewLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
        [autoStartAlarmView addSubview:autoStartAlarmViewLabel];
        
        [self.view addSubview:autoStartAlarmView];
        [delay invalidate];
        delay = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(delayAutoStart) userInfo:nil repeats:NO];

    }
}

-(void) doneWithNumberPad
{
    [timeTextField resignFirstResponder];
}

-(void) showPlaylists
{
    self.listsViewController = [[ListsViewController alloc] init];
    
    [self.navigationController pushViewController:self.listsViewController animated:YES];
}

-(void) setAMPMLabel
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [_lblAMPM removeFromSuperview];
    [self getAlarmTime];
    NSString *sAMPM;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a"];
    sAMPM = [formatter stringFromDate:[appDelegate.alarmClock alarmTime]];
    
    _lblAMPM = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 62, 12, 75, 50)];
    if ([sAMPM isEqualToString:@"PM"]) {
        [_lblAMPM setFrame:CGRectMake(self.view.frame.size.width - 62, 47, 75, 50)];
    }
    [_lblAMPM setBackgroundColor:[UIColor clearColor]];
    [_lblAMPM setLineBreakMode:NSLineBreakByWordWrapping];
    [_lblAMPM setText:[NSString stringWithFormat:@"%@", [sAMPM lowercaseString]]];
    [_lblAMPM setTextColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [_lblAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
    if (sAMPM.length > 0 && !_is24h) {
        [setAlarmView addSubview:_lblAMPM];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (delay.isValid) {
        [self cancelAutoStart];
    }
}

- (void) showSettings
{
    CGRect settingsOpenFrame = [[UIScreen mainScreen] bounds];
    settingsOpenFrame.origin.y = -[[UIScreen mainScreen] bounds].size.height + 60;
    CGRect settingsClosedFrame = [[UIScreen mainScreen] bounds];

    CGFloat y = setAlarmView.frame.origin.y;
    
    if (y == 0 ) {
        [UIView animateWithDuration:0.3 animations:^{[setAlarmView setFrame:settingsOpenFrame];}];
        setAlarmButton.enabled = false;
        [self setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SETTINGS OPENED", nil)]];
    } else {
        [UIView animateWithDuration:0.3 animations:^{[setAlarmView setFrame:settingsClosedFrame];}];
        //setAlarmButton.enabled = true;
        [self testToEnableAlarmButton];
        [self setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SETTINGS CLOSED", nil)]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [super viewDidAppear:animated];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *ats = @{
    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
    NSParagraphStyleAttributeName : paragraphStyle
    };
    
    if([appDelegate.alarmClock playlistName]) {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[[appDelegate.alarmClock playlistName] lowercaseString] attributes:ats]];
    } else {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:@"choose playlist..." attributes:ats]];
    }
    //[self.lblPlaylist setText:[appDelegate.selectedPlaylist lowercaseString]];
    [self.lblPlaylist setFrame:CGRectMake(10, 154.0, 300.0, 200.0)];
    [self.lblPlaylist sizeToFit];
    
    if([appDelegate.alarmClock playlistPath] == nil) {
        //appDelegate.selectedPlaylistPath = ipPlaylistPath;
        //appDelegate.selectedPlaylist = [_settings valueForKey:@"Playlist Name"];
        [self loadSongs];
    } else if ([appDelegate.alarmClock playlistPath] != nil) {
        //[_settings setValue:[NSNumber numberWithInteger:appDelegate.selectedPlaylistPath.section] forKey:@"Playlist Section"];
        //[_settings setValue:[NSNumber numberWithInteger:appDelegate.selectedPlaylistPath.row] forKey:@"Playlist Number"];
        //[_settings setValue:appDelegate.selectedPlaylist forKey:@"Playlist Name"];
        NSLog(@"Selected Playlist Name: %@", appDelegate.selectedPlaylist);
        NSLog(@"Selected Playlist Section: %@", appDelegate.selectedPlaylistPath);
        //[self writeSettings];
    }
    
    if (appDelegate.loggedIn) {
        [_chooseMusic reloadData];
    }
    
    if ([appDelegate.alarmClock playlistPath] != nil && playlists != nil) {
        [self loadSongs];
    }
    
    if(playlists == nil) {
        if(appDelegate.loggedIn) {
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"trackKeys", @"extras", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:trackInfo delegate:self];
            _loadingView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds] ];
            [_loadingView setBackgroundColor:[UIColor blackColor]];
            [_loadingView setAlpha:0.9];
            UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [aiView setCenter:CGPointMake(160, 200)];
            [aiView startAnimating];
            UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 200.0, 120.0, 100.0)];
            [loadingLabel setText:[NSString stringWithFormat:NSLocalizedString(@"LOADING", nil)]];
            [loadingLabel setBackgroundColor:[UIColor clearColor]];
            [loadingLabel setTextColor:[UIColor whiteColor]];
            [loadingLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:24.0]];
            [loadingLabel setTextAlignment:NSTextAlignmentCenter];
            
            [loadingLabel setAdjustsFontSizeToFitWidth:YES];
            [_loadingView addSubview:loadingLabel];
            [_loadingView addSubview:aiView];
            if (!_switchAutoStart.on) {
                //[self.view addSubview:_loadingView];
            }
        } else {
            //choose songs from top songs chart
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Track", @"type", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getTopCharts" withParameters:trackInfo delegate:self];
        }
    }
    
    [self testToEnableAlarmButton];
    
    //[self determineStreamableSongs];
    
    

    //songsToPlay = [self shuffle:songsToPlay];
}

- (void) testToEnableAlarmButton
{
    //TODO: Make this work with the new leading 0 format
    NSString *firstChar = @"";
    NSString *secondChar = @"";
    NSString *thirdChar = @"";
    NSString *fourthChar = @"";
    
    if (timeTextField.text.length > 0) {
        firstChar = [timeTextField.text substringToIndex:1];
    }
    
    NSRange secondCharRange = NSRangeFromString(@"1,1");
    if (timeTextField.text.length > 1) {
        secondChar = [timeTextField.text substringWithRange:secondCharRange];
    }
    
    NSRange thirdCharRange = NSRangeFromString(@"2,1");
    if (timeTextField.text.length > 2) {
        thirdChar = [timeTextField.text substringWithRange:thirdCharRange];
    }
    
    NSRange fourthCharRange = NSRangeFromString(@"3,1");
    if (timeTextField.text.length > 3) {
        fourthChar = [timeTextField.text substringWithRange:fourthCharRange];
    }
    
    if (!_is24h) {
        if (songsToPlay != nil && timeTextField.text.length == 6 && [secondChar isEqualToString:@"1"] && ([thirdChar isEqualToString:@"0"] || [thirdChar isEqualToString:@"1"] || [thirdChar isEqualToString:@"2"])) {
            [setAlarmButton setEnabled:YES];
        } else if (songsToPlay != nil && timeTextField.text.length == 5 ) {
            [setAlarmButton setEnabled:YES];
        } else {
            [setAlarmButton setEnabled:NO];
        }
    } else if(_is24h) {
        if (songsToPlay != nil && timeTextField.text.length == 5 && ([firstChar isEqualToString:@"1"] || ([firstChar isEqualToString:@"2"] && ([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"] || [secondChar isEqualToString:@"3"])))) {
            [setAlarmButton setEnabled:YES];
        } else if (songsToPlay != nil && timeTextField.text.length == 4 ) {
            [setAlarmButton setEnabled:YES];
        } else {
            [setAlarmButton setEnabled:NO];
        }
    }
}

- (void) determineStreamableSongs
{
    songsToPlay = [self removeDuplicatesInPlaylist:songsToPlay];
    _canBeStreamed = [[NSMutableArray alloc] initWithCapacity:songsToPlay.count];
    NSString *songsToPlayString = [songsToPlay objectAtIndex:0];
    for (int x = 1; x < songsToPlay.count; x++) {
        songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [songsToPlay objectAtIndex:x]];
    }
    NSLog(@"Songs to play: %@", songsToPlayString);
    NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:songsToPlayString, @"keys", @"canStream", @"extras", nil];
    [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:trackInfo delegate:self];
}

- (NSMutableArray *) removeDuplicatesInPlaylist: (NSMutableArray *) playlist
{    
    for (int x = 0; x < playlist.count; x++) {
        for (int y = x+1; y < playlist.count; y++) {
            if ([[playlist objectAtIndex:x] isEqual:[playlist objectAtIndex:y]]) {
                [playlist removeObjectAtIndex:y];
            }
        }
    }
    
    return playlist;
}

- (void) RdioSignUp 
{
    UIViewController *signUpViewController = [[UIViewController alloc] init];

    CGRect webViewRect = [[UIScreen mainScreen] bounds];
    UIWebView *signUpView = [[UIWebView alloc] initWithFrame:webViewRect];
    //[signUpView setDelegate:signUpViewController];
    NSURL *RdioAffiliateURL = [NSURL URLWithString:@"http://click.linksynergy.com/fs-bin/click?id=TWsTggfYv7c&offerid=221756.10000002&type=3&subid=0"];
    NSURLRequest *RdioAffiliateRequest = [NSURLRequest requestWithURL:RdioAffiliateURL];
    [signUpView loadRequest:RdioAffiliateRequest];
    //[signUpViewController setTitle:@"Learn More"];
    [signUpViewController.view addSubview:signUpView];
    
    //[self.view addSubview:signUpView];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"musicCell"];
    
    if ([appDelegate.alarmClock playlistPath] != nil) {
        [cell setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SELECTED PLAYLIST IS", nil), [appDelegate.alarmClock playlistName]]];
        cell.textLabel.text = [appDelegate.alarmClock playlistName];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CHOOSE PLAYLIST", nil)];
        
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    self.listsViewController = [[ListsViewController alloc] init];
    
    [self.navigationController pushViewController:self.listsViewController animated:YES];
}

- (void) textFieldValueChange:(UITextField *) textField
{
    //TODO: Make this work with the new leading 0 format

    float currentLength = textField.text.length;
        
    if (_lastLength == 0) {
        _lastLength = currentLength;
    }

    NSString *firstChar = @"";
    NSString *secondChar = @"";
    NSString *thirdChar = @"";
    NSString *fourthChar = @"";
    NSString *fifthChar = @"";

    
    if (textField.text.length > 0) {
        firstChar = [textField.text substringToIndex:1];
    }
    
    NSRange secondCharRange = NSRangeFromString(@"1,1");
    //NSLog(@"%@", secondCharRange);
    if (textField.text.length > 1) {
        secondChar = [textField.text substringWithRange:secondCharRange];
    }
    
    NSRange thirdCharRange = NSRangeFromString(@"2,1");
    if (textField.text.length > 2) {
        thirdChar = [textField.text substringWithRange:thirdCharRange];
    }
    
    NSRange fourthCharRange = NSRangeFromString(@"3,1");
    if (textField.text.length > 3) {
        fourthChar = [textField.text substringWithRange:fourthCharRange];
    }
    
    NSRange fifthCharRange = NSRangeFromString(@"4,1");
    if (textField.text.length > 4) {
        fifthChar = [textField.text substringWithRange:fifthCharRange];
    }
    
    if(!_is24h) {
        if (([firstChar isEqualToString: @"0"]) && [secondChar isEqualToString: @"0"]) {
            textField.Text = [NSString stringWithFormat:@"0"];
        } else if (!([secondChar isEqualToString: @"1"]) || [thirdChar isEqualToString:_timeSeparator]) {
            
            if(currentLength == 6) {
                textField.text = [textField.text substringToIndex:4];
            } else if(currentLength == 2 && _lastLength <= currentLength) {
                textField.text = [NSString stringWithFormat:@"%@%@%@", firstChar, secondChar, _timeSeparator];
            } else if (currentLength == 2 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@""];
            } else if(currentLength == 3 && _lastLength <= currentLength) {
                if ([thirdChar isEqualToString: @"0"] || [thirdChar isEqualToString: @"1"] || [thirdChar isEqualToString: @"2"] || [thirdChar isEqualToString: @"3"] || [thirdChar isEqualToString: @"4"] || [thirdChar isEqualToString: @"5"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@%@", firstChar, _timeSeparator, secondChar ];
                } else if (![thirdChar isEqualToString:_timeSeparator]) {
                    textField.text = [NSString stringWithFormat:@"%@", firstChar];
                }
            } else if (currentLength == 3 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@"%@", firstChar];
            }
        } else {
            if(currentLength == 7) {
                textField.text = [textField.text substringToIndex:5];
            } else if(currentLength == 2 && _lastLength <= currentLength) {
                if ([thirdChar isEqualToString: @"3"] || [thirdChar isEqualToString: @"4"] || [thirdChar isEqualToString: @"5"]) {
                    textField.Text = [NSString stringWithFormat:@"%@%@%@", firstChar, _timeSeparator, secondChar ];
                } else if ([thirdChar isEqualToString: @"0"] || [thirdChar isEqualToString: @"1"] || [thirdChar isEqualToString: @"2"]) {
                    textField.Text = [NSString stringWithFormat:@"%@%@", textField.text, _timeSeparator ];
                } else {
                    textField.text = [NSString stringWithFormat:@"%@", firstChar];
                }
            } else if (currentLength == 2 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@"%@", firstChar];
            }
        }
    } else if (_is24h) {
        if (([firstChar isEqualToString: @"0"])) {
            textField.Text = [NSString stringWithFormat:@""];
        } else if (!([firstChar isEqualToString: @"1"] || [firstChar isEqualToString:@"2"]) || [secondChar isEqualToString:_timeSeparator]) {
            
            if(currentLength == 5) {
                textField.text = [textField.text substringToIndex:4];
            } else if(currentLength == 1 && _lastLength <= currentLength) {
                textField.text = [NSString stringWithFormat:@"%@%@", firstChar,_timeSeparator];
            } else if (currentLength == 1 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@""];
            } else if(currentLength == 2 && _lastLength <= currentLength) {
                if ([secondChar isEqualToString: @"0"] || [secondChar isEqualToString: @"1"] || [secondChar isEqualToString: @"2"] || [secondChar isEqualToString: @"3"] || [secondChar isEqualToString: @"4"] || [secondChar isEqualToString: @"5"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@%@", firstChar, _timeSeparator, secondChar ];
                } else if (![secondChar isEqualToString:_timeSeparator]) {
                    textField.text = [NSString stringWithFormat:@"%@", firstChar];
                } 
            } else if (currentLength == 2 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@"%@", firstChar];
            } else if(currentLength == 3 && _lastLength <= currentLength) {
                if ([thirdChar isEqualToString: @"6"] || [thirdChar isEqualToString: @"7"] || [thirdChar isEqualToString: @"8"] || [thirdChar isEqualToString: @"9"]) {
                    textField.Text = [NSString stringWithFormat:@"%@%@", firstChar, _timeSeparator];
                }
            }
        } else if ([firstChar isEqualToString: @"1"] || [firstChar isEqualToString:@"2"]) {
            if(currentLength == 6) {
                textField.text = [textField.text substringToIndex:5];
            } else if(currentLength == 2 && _lastLength <= currentLength) {
                if ([firstChar isEqualToString:@"2"] && ([secondChar isEqualToString: @"4"] || [secondChar isEqualToString: @"5"])) {
                    textField.Text = [NSString stringWithFormat:@"%@%@%@", firstChar, _timeSeparator, secondChar ];
                } else if ([firstChar isEqualToString:@"1"] && ([secondChar isEqualToString: @"6"] || [secondChar isEqualToString: @"7"] || [secondChar isEqualToString: @"8"] || [secondChar isEqualToString: @"9"])) {
                    textField.Text = [NSString stringWithFormat:@"%@%@", textField.text, _timeSeparator ];
                } else if ([firstChar isEqualToString:@"2"] && ([secondChar isEqualToString: @"0"] || [secondChar isEqualToString: @"1"] || [secondChar isEqualToString: @"2"] || [secondChar isEqualToString: @"3"])) {
                    textField.Text = [NSString stringWithFormat:@"%@%@", textField.text, _timeSeparator ];
                } else if ([firstChar isEqualToString:@"1"] && ([secondChar isEqualToString: @"0"] || [secondChar isEqualToString: @"1"] || [secondChar isEqualToString: @"2"] || [secondChar isEqualToString: @"3"] || [secondChar isEqualToString: @"4"] || [secondChar isEqualToString: @"5"])) {
                    textField.Text = [NSString stringWithFormat:@"%@%@", textField.text, _timeSeparator ];
                } else {
                    textField.text = [NSString stringWithFormat:@"%@", firstChar];
                }
            } else if (currentLength == 2 && _lastLength > currentLength) {
                textField.text = [NSString stringWithFormat:@"%@", firstChar];
            } else if (currentLength == 5 && _lastLength <= currentLength && (([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"] || [secondChar isEqualToString:@"3"] || [secondChar isEqualToString:@"4"] || [secondChar isEqualToString:@"5"]) && ([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]))) {
                textField.text = [NSString stringWithFormat:@"%@%@%@%@", firstChar, secondChar, _timeSeparator, fourthChar];
            } else if (currentLength == 4 && _lastLength <= currentLength && (([secondChar isEqualToString:@"6"] || [secondChar isEqualToString:@"7"] || [secondChar isEqualToString:@"8"] || [secondChar isEqualToString:@"9"]) && ([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]))) {
                textField.text = [NSString stringWithFormat:@"%@%@%@", firstChar, secondChar, _timeSeparator];
            }
        }

    }
    
    [self testToEnableAlarmButton];
    [self setAMPMLabel];
    _lastLength = textField.text.length;
}

- (void) tick
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"current time: %@ & alarm time: %@", [NSDate date], [appDelegate.alarmClock alarmTime]);
    
    NSDate *now = [NSDate date];
    
    if([[appDelegate.alarmClock alarmTime] isEqualToDate:([[appDelegate.alarmClock alarmTime] earlierDate:now])] && !playing)
    {
        [self alarmSounding];
        [t invalidate];
    }

}

- (void) delayAutoStart
{
    [self cancelAutoStart];
    [self setAlarm];
}

- (void) cancelAutoStart
{
    self.navigationController.navigationBarHidden = YES;
    [autoStartAlarmView removeFromSuperview];
    [delay invalidate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark RDPlayerDelegate

- (BOOL) rdioIsPlayingElsewhere {
    // let the Rdio framework tell the user.
    return NO;
}

- (void) rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state {
    playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
    paused = (state == RDPlayerStatePaused);
    if (paused || !playing) {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark RDAPIRequestDelegate
/**
 * Our API call has returned successfully.
 * the data parameter can be an NSDictionary, NSArray, or NSData 
 * depending on the call we made.
 *
 * Here we will inspect the parameters property of the returned RDAPIRequest
 * to see what method has returned.
 */
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    NSString *method = [request.parameters objectForKey:@"method"];
    
    NSLog(@"request: %@", [request.parameters objectForKey:@"method"]);
    //NSLog(@"data: %@", [data objectAtIndex:0]);
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if([method isEqualToString:@"getTopCharts"]) {
        if(playlists != nil) {
            playlists = nil;
        }
        playlists = [[NSMutableArray alloc] initWithArray:data];
        playlists = data;
        songsToPlay = [[NSMutableArray alloc] initWithCapacity:playlists.count];
        //listsViewController.tableInfo = [[NSMutableArray alloc] initWithCapacity:playlists.count];
        for (int x = 0; x < playlists.count; x++) {
            NSLog(@"top chart song: %@", [[playlists objectAtIndex:x] objectForKey:@"key"]);
            [songsToPlay addObject:[[playlists objectAtIndex:x] objectForKey:@"key"]];
            
            //[listsViewController.tableInfo addObject:songsToPlay];
        }
        [self determineStreamableSongs];
        //[self getTrackKeysForAlbums];
    } else if([method isEqualToString:@"getPlaylists"]) {
        // we are returned a dictionary but it will be easier to work with an array
        // for our needs

        playlists = [[NSMutableArray alloc] initWithCapacity:[data count]];
        appDelegate.typesInfo = [[NSMutableArray alloc] init];
        appDelegate.playlistsInfo = [[NSMutableArray alloc] init];
        appDelegate.tracksInfo = [[NSMutableArray alloc] init];
        
        int x = 0;
        for(NSString *key in [data allKeys]) {
            [playlists addObject:[data objectForKey:key]];
            //NSLog(@"playlist added: %@", [data objectForKey:key]);
            for (int xy = 0; xy < [[playlists objectAtIndex:x] count]; xy++) {
                [appDelegate.playlistsInfo addObject:[[[playlists objectAtIndex:x] objectAtIndex:xy] objectForKey:@"name"]];
                if (x == 0) {
                    appDelegate.numberOfPlaylistsCollab = [[playlists objectAtIndex:x] count];
                } else if (x == 1) {
                    appDelegate.numberOfPlaylistsOwned = [[playlists objectAtIndex:x] count];
                } else {
                    appDelegate.numberOfPlaylistsSubscr = [[playlists objectAtIndex:x] count];
                }
            }
            for (int y = 0; y < [[playlists objectAtIndex:x] count]; y++) {
                //[listsViewController.playlistsInfo addObject:[[[playlists objectAtIndex:x] objectAtIndex:y] objectForKey:@"name"]];
                for (int z = 0; z < [[[[playlists objectAtIndex:x] objectAtIndex:y] objectForKey:@"trackKeys"] count]; z++) {
                    [appDelegate.tracksInfo addObject:[[[playlists objectAtIndex:x] objectAtIndex:y] objectForKey:@"trackKeys"]];
                }
            }
            x++;
        }
        [appDelegate.alarmClock setPlaylistPath:nil];
        for (int i = 0; i < [playlists count]; i++) {
            for(int j = 0; j < [[playlists objectAtIndex:i] count]; j++) {
                if ([[[[playlists objectAtIndex:i] objectAtIndex:j] objectForKey:@"name"] isEqualToString:[appDelegate.alarmClock playlistName]]) {
                    NSLog(@"I found the right playlist! %d, %d", i, j);
                    NSLog(@"For reference: %@", [appDelegate.alarmClock playlistName]);
                    [appDelegate.alarmClock setPlaylistPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    [appDelegate.alarmClock setPlaylistName:[[[playlists objectAtIndex:i] objectAtIndex:j] objectForKey:@"name"]];
                    NSLog(@"Then after setting it: %@", [appDelegate.alarmClock playlistName]);
                }
            }
        }
        
        if(([appDelegate.alarmClock playlistPath] == nil && [appDelegate.alarmClock playlistName] != nil) || [appDelegate.alarmClock alarmTime] == nil) {
            //alert the user that the playlist could not be found
            [self cancelAutoStart];
            [appDelegate.alarmClock setPlaylistName:nil];
            
        }
        
        if([appDelegate.alarmClock playlistPath] != nil) {
            [self loadSongs];
            [self testToEnableAlarmButton];
        }
        [_loadingView removeFromSuperview];
        //[self loadSongs];
        //[self determineStreamableSongs];
        //[self loadAlbumChoices];
    } else if ([method isEqualToString:@"get"]) {
        NSLog(@"total number of keys: %d", [data allKeys].count);
        for(NSString *key in [data allKeys]) {
            NSLog(@"canstream: %@", [[data objectForKey:key] objectForKey:@"canStream"]);
            //[_canBeStreamed addObject:[[data objectForKey:key] objectForKey:@"canStream"]];
            if ([[[data objectForKey:key] objectForKey:@"canStream"] isEqual:[NSNumber numberWithBool:YES]]) {
                [_canBeStreamed addObject:@"YES"];
            } else {
                [_canBeStreamed addObject:@"NO"];
            }
        }
        
    }
}

- (void) loadSongs 
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.alarmClock playlistPath] != nil && playlists != nil) {
        songsToPlay = [[NSMutableArray alloc] initWithArray:[[[playlists objectAtIndex:[appDelegate.alarmClock playlistPath].section] objectAtIndex:[appDelegate.alarmClock playlistPath].row] objectForKey:@"trackKeys"]];
        NSLog(@"section selected: %d, row selected: %d", [appDelegate.alarmClock playlistPath].section, [appDelegate.alarmClock playlistPath].row);
        songsToPlay = [[[playlists objectAtIndex:[appDelegate.alarmClock playlistPath].section] objectAtIndex:[appDelegate.alarmClock playlistPath].row] objectForKey:@"trackKeys"];
    } /* else {
        songsToPlay = [[NSMutableArray alloc] initWithArray:[[[playlists objectAtIndex:1] objectAtIndex:1] objectForKey:@"trackKeys"]];
        songsToPlay = [[[playlists objectAtIndex:1] objectAtIndex:1] objectForKey:@"trackKeys"];
    } */
    [self determineStreamableSongs];
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    
}

@end
