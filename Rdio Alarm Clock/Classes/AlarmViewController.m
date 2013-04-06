//
//  MainViewController.m
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "AlarmNavController.h"
#import "SimpleKeychain.h"
#import <Rdio/Rdio.h>
#import <QuartzCore/QuartzCore.h>

@implementation AlarmViewController

-(RDPlayer*)getPlayer
{
    if (self.player == nil) {
        self.player = [AppDelegate rdioInstance].self.player;
    }
    return self.player;
}

-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    
}

- (void) setAlarmClicked {
    NSRange colonRange = NSRangeFromString(@"2,1");

    if (self.timeTextField.text.length == 4 && [[self.timeTextField.text substringWithRange:colonRange] isEqualToString:_timeSeparator]) {
        self.timeTextField.text = [self.timeTextField.text stringByReplacingOccurrencesOfString:_timeSeparator withString:@""];
        self.timeTextField.text = [NSString stringWithFormat:@"%@%@%@", [self.timeTextField.text substringToIndex:1], _timeSeparator, [self.timeTextField.text substringFromIndex:1]];
        NSLog(@"newtime: %@", self.timeTextField.text);
    }
    
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *tempTimeString = self.timeTextField.text;    

    tempTimeString = [tempTimeString stringByReplacingOccurrencesOfString:_timeSeparator withString:@":"];
        
    NSString *tempDateString = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
    
    tempDateString = [NSString stringWithFormat:@"%@T%@", tempDateString, tempTimeString];
    [self.appDelegate.alarmClock setAlarmTime:[formatter dateFromString:tempDateString] save:YES];
    if(![self.appDelegate.alarmClock is24h]) {
        if ([[self.appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[self.appDelegate.alarmClock alarmTime]) {
            [self.appDelegate.alarmClock setAlarmTime:[[self.appDelegate.alarmClock alarmTime] dateByAddingTimeInterval:43200] save:NO];

            if ([[self.appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[self.appDelegate.alarmClock alarmTime]) {
                [self.appDelegate.alarmClock setAlarmTime:[[self.appDelegate.alarmClock alarmTime] dateByAddingTimeInterval:43200] save:NO];
            }
        }
    } else if ([self.appDelegate.alarmClock is24h]) {
        NSLog(@"Is 24 Hours");
        if ([[self.appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[self.appDelegate.alarmClock alarmTime]) {
            [self.appDelegate.alarmClock setAlarmTime:[[self.appDelegate.alarmClock alarmTime] dateByAddingTimeInterval:86400] save:NO];
            if ([[self.appDelegate.alarmClock alarmTime] earlierDate:[NSDate date]]==[self.appDelegate.alarmClock alarmTime]) {
                [self.appDelegate.alarmClock setAlarmTime:[[self.appDelegate.alarmClock alarmTime] dateByAddingTimeInterval:86400] save:NO];
            }
        }
    }

}

- (void) setAlarm {

    [self.timeTextField resignFirstResponder];
    
    [self getAlarmTime];
    
    if (remindMe.on) {
        nightlyReminder = [[UILocalNotification alloc] init];
        
        nightlyReminder.fireDate = [NSDate dateWithTimeIntervalSinceNow:86400];
        //NSLog(@"alarm will go off: %@", nightlyReminder.fireDate);
        nightlyReminder.timeZone = [NSTimeZone systemTimeZone];
        
        nightlyReminder.alertBody = @"Are you ready to set your nightly alarm?";
        nightlyReminder.alertAction = @"Set Alarm";
        nightlyReminder.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:nightlyReminder];
    }

    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    
    [self displaySleepScreen];

}

- (void) displaySleepScreen {
    self.appDelegate.alarmIsSet = YES;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect sleepLabelRect = CGRectMake(10.0, 90.0, 280.0, 200.0);
    CGRect alarmLabelRect = CGRectMake(10.0, 10.0, [[UIScreen mainScreen] bounds].size.width, 30.0);
    CGRect chargingLabelRect = CGRectMake(10.0, 260.0, 280.0, 200.0);
    
    NSString *alarmTimeText;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (![self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"h:mm a"];
    } else if ([self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"H:mm"];
        //NSLog(@"this is 24 hour clock");
    }
    alarmTimeText = [formatter stringFromDate:[self.appDelegate.alarmClock alarmTime]];
    alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@":" withString:_timeSeparator];
    sleepView = [[UIView alloc] initWithFrame:screenRect];
    
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [sleepView setBackgroundColor:[UIColor blackColor]];
    UILabel *sleepLabel = [[UILabel alloc] initWithFrame:sleepLabelRect];
    //[sleepLabel setText:NSLocalizedString(@"PLEASE REST PEACEFULLY", nil)];
    [sleepLabel setTextColor:self.darkTextColor];
    //[sleepLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0]];
    [sleepLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [sleepLabel setBackgroundColor:[UIColor clearColor]];
    [sleepLabel setNumberOfLines:0];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *atsBig = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:92.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    
    NSDictionary *atsSmall = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    
    [sleepLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"PLEASE REST PEACEFULLY", nil) lowercaseString] attributes:ats]];
    
    //[sleepLabel setAdjustsFontSizeToFitWidth:YES];
    [sleepView addSubview:sleepLabel];
    
    _alarmLabel = [[UILabel alloc] initWithFrame:alarmLabelRect];
    //[_alarmLabel setText:[NSString stringWithFormat:NSLocalizedString(@"YOUR ALARM IS SET", nil), alarmTimeText]];
    [_alarmLabel setTextColor:self.darkTextColor];
    //[_alarmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
    [_alarmLabel setBackgroundColor:[UIColor clearColor]];
    [_alarmLabel setNumberOfLines:1];
    [_alarmLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"YOUR ALARM IS SET", nil)] uppercaseString] attributes:atsSmall]];
    
    UILabel *alarmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, [[UIScreen mainScreen] bounds].size.width, 120.0)];
    [alarmTimeLabel setTextColor:self.darkTextColor];
    [alarmTimeLabel setBackgroundColor:[UIColor clearColor]];
    [alarmTimeLabel setNumberOfLines:0];
    self.alarmTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 150.0)];

    //[self getAlarmTime];
    
    if(![self.appDelegate.alarmClock is24h]) {
        NSString *alarmTimeAMPM = [[alarmTimeText componentsSeparatedByString:@" "] objectAtIndex:1];
        UILabel *sleepAMPM = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 62, 12, 75, 50)];
        if ([alarmTimeAMPM isEqualToString:@"PM"]) {
            [sleepAMPM setFrame:CGRectMake(self.view.frame.size.width - 62, 53, 75, 50)];
        }
        [sleepAMPM setBackgroundColor:[UIColor clearColor]];
        [sleepAMPM setLineBreakMode:NSLineBreakByWordWrapping];
        [sleepAMPM setText:[NSString stringWithFormat:@"%@", [alarmTimeAMPM lowercaseString]]];
        [sleepAMPM setTextColor:self.darkTextColor];
        [sleepAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
        [self.alarmTimeView addSubview:sleepAMPM];
        
        alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@" PM" withString:@""];
        alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@" AM" withString:@""];
    }
    
    if([alarmTimeText length] == 4) {
        alarmTimeText = [NSString stringWithFormat:@"0%@", alarmTimeText];
    }
    [alarmTimeLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", alarmTimeText] lowercaseString] attributes:atsBig]];

    //[_alarmLabel setAdjustsFontSizeToFitWidth:YES];
    [self.alarmTimeView addSubview:_alarmLabel];
    [self.alarmTimeView addSubview:alarmTimeLabel];
    [sleepView addSubview:self.alarmTimeView];
    
    ///////////////
    [self setupCurrentTimeView];
    [self.currentTimeView setHidden:YES];

    [sleepView addSubview:self.currentTimeView];
    
    
    ////////////////
    
    
    _chargingLabel = [[UILabel alloc] initWithFrame:chargingLabelRect];
    //[_chargingLabel setText:NSLocalizedString(@"PLUG ME IN", nil)];
    [_chargingLabel setTextColor:self.darkTextColor];
    [_chargingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0]];
    [_chargingLabel setBackgroundColor:[UIColor blackColor]];
    [_chargingLabel setNumberOfLines:10];
    //[_chargingLabel setAdjustsFontSizeToFitWidth:YES];
    [_chargingLabel setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"PLUG ME IN", nil) lowercaseString] attributes:ats]];

    if ([UIDevice currentDevice].batteryState != UIDeviceBatteryStateCharging && [UIDevice currentDevice].batteryState != UIDeviceBatteryStateFull) {
        [sleepView addSubview:_chargingLabel];
    }
    
    CGRect cancelFrame = CGRectMake((self.view.frame.size.width - 161) / 2, self.view.frame.size.height - 19 - 44, 161, 44);
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:cancelFrame];
    
    UIImage *cancelButtonImage = [UIImage imageNamed:@"sleepmode-grippy"];
    
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor blackColor]];
    [cancelButton setAccessibilityLabel:NSLocalizedString(@"Cancel Alarm", nil)];
    [cancelButton addGestureRecognizer:slideViewGesture];
    [cancelButton addTarget:self action:@selector(bounceView) forControlEvents:UIControlEventTouchUpInside];
    
    [sleepView addSubview:cancelButton];
    UITapGestureRecognizer *cycleSleepView = [[UITapGestureRecognizer alloc] init];
    [cycleSleepView addTarget:self action:@selector(cycleSleepView)];
    [sleepView addGestureRecognizer:cycleSleepView];
    [self.view addSubview:sleepView]; 
    
    [fader invalidate];
    
    if ([self.appDelegate.alarmClock sleepTime] != 0) {
        if ([[AppDelegate rdioInstance] player].state == RDPlayerStatePaused) {
            [[[AppDelegate rdioInstance] player] togglePause];
        } else {
            if([self.appDelegate.alarmClock isShuffle]) {
                self.appDelegate.selectedPlaylist.trackKeys = [self shuffle:self.appDelegate.selectedPlaylist.trackKeys];
            }
            self.appDelegate.selectedPlaylist.trackKeys = [self getEnough:self.appDelegate.selectedPlaylist.trackKeys];
            [[[AppDelegate rdioInstance] player] playSources:self.appDelegate.selectedPlaylist.trackKeys];
        }
        fader = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES];
    } else {
        fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES]; 
    }
    
    self.appDelegate.originalVolume = self.music.volume;
}

- (void) setupCurrentTimeView
{
    //#TODO: Fix bug where time doesn't update on first minute change
    if (self.currentTimeView == nil) {
        self.currentTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 150.0)];
    } else {
        NSLog(@"%d",[self.currentTimeView.subviews count]);
        for(int x = 0; x < [self.currentTimeView.subviews count]; x++) {
            [[self.currentTimeView.subviews objectAtIndex:x] removeFromSuperview];
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (![self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"h:mm a"];
    } else if ([self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"H:mm"];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *atsBig = @{
                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:92.0],
                             NSParagraphStyleAttributeName : paragraphStyle
                             };
    
    NSDictionary *atsSmall = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                               NSParagraphStyleAttributeName : paragraphStyle
                               };
    
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, [[UIScreen mainScreen] bounds].size.width, 30.0)];
    [currentLabel setTextColor:self.darkTextColor];
    [currentLabel setBackgroundColor:[UIColor clearColor]];
    [currentLabel setNumberOfLines:1];
    [currentLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"CURRENT TIME IS", nil)] uppercaseString] attributes:atsSmall]];
    
    UILabel *currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, [[UIScreen mainScreen] bounds].size.width, 120.0)];
    [currentTimeLabel setTextColor:self.darkTextColor];
    [currentTimeLabel setBackgroundColor:[UIColor clearColor]];
    [currentTimeLabel setNumberOfLines:0];
    
    NSString *currentTimeText = [formatter stringFromDate:[NSDate date]];

    currentTimeText = [currentTimeText stringByReplacingOccurrencesOfString:@":" withString:_timeSeparator];
    
    if(![self.appDelegate.alarmClock is24h]) {
        NSString *currentAMPM = [[currentTimeText componentsSeparatedByString:@" "] objectAtIndex:1];
        UILabel *lblCurrentAMPM = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 62, 12, 75, 50)];
        if ([currentAMPM isEqualToString:@"PM"]) {
            [lblCurrentAMPM setFrame:CGRectMake(self.view.frame.size.width - 62, 53, 75, 50)];
        }
        [lblCurrentAMPM setBackgroundColor:[UIColor clearColor]];
        [lblCurrentAMPM setLineBreakMode:NSLineBreakByWordWrapping];
        [lblCurrentAMPM setText:[NSString stringWithFormat:@"%@", [currentAMPM lowercaseString]]];
        [lblCurrentAMPM setTextColor:self.darkTextColor];
        [lblCurrentAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
        [self.currentTimeView addSubview:lblCurrentAMPM];
        
        currentTimeText = [currentTimeText stringByReplacingOccurrencesOfString:@" PM" withString:@""];
        currentTimeText = [currentTimeText stringByReplacingOccurrencesOfString:@" AM" withString:@""];
    }
    
    if([currentTimeText length] == 4) {
        currentTimeText = [NSString stringWithFormat:@"0%@", currentTimeText];
    }

    [currentTimeLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", currentTimeText] lowercaseString] attributes:atsBig]];
        
    [self.currentTimeView addSubview:currentLabel];
    [self.currentTimeView addSubview:currentTimeLabel];
}

- (void) cycleSleepView {
    
    if ([self.currentTimeView isHidden] && [self.alarmTimeView isHidden]) {
        [self.currentTimeView setHidden:NO];
        [self.alarmTimeView setHidden:YES];
    } else if([self.currentTimeView isHidden] && ![self.alarmTimeView isHidden]) {
        [self.alarmTimeView setHidden:YES];
    } else if(![self.currentTimeView isHidden] && [self.alarmTimeView isHidden]) {
        [self.alarmTimeView setHidden:NO];
        [self.currentTimeView setHidden:YES];
    } else {
        [self.currentTimeView setHidden:YES];
        [self.alarmTimeView setHidden:YES];
    }
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:sender.view.superview];
    
    CGRect newFrame = [[UIScreen mainScreen] bounds];

    newFrame.origin.y += (translate.y);
    sender.view.superview.frame = newFrame;
        
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
    NSInteger sleepTimeSeconds = [self.appDelegate.alarmClock sleepTime] * 60;
    if (sleepTimeSeconds == 0) {
        sleepTimeSeconds = 100;
    }
    
    if ([UIScreen mainScreen].brightness <= 0.0) {
        [fader invalidate];
        if ([self.appDelegate.alarmClock sleepTime] != 0) {
            [[[AppDelegate rdioInstance] player] togglePause];
        }
        self.appDelegate.appBrightness = 0.0;
        [self.alarmTimeView setHidden:YES];
        [_chargingLabel removeFromSuperview];
    } else {
        float increment = (self.appDelegate.originalBrightness - 0.0)/(sleepTimeSeconds);
        float newBrightness = [UIScreen mainScreen].brightness - increment;
        [[UIScreen mainScreen] setBrightness:newBrightness];
        
        float incrementVolume = (self.appDelegate.originalVolume - 0.0)/(sleepTimeSeconds);
        float newVolume = self.music.volume - incrementVolume;
        if (self.appDelegate.appVolume > 0 && !UIAccessibilityIsVoiceOverRunning()) {
            if ([self.appDelegate.alarmClock sleepTime] != 0) {
                [self.music setVolume:newVolume];
                self.appDelegate.appVolume = newVolume;
            } else {
                [self.music setVolume:0];
                self.appDelegate.appVolume = 0;
            }
        }
    }
}

- (void) fadeScreenIn {    
    if (self.appDelegate.originalVolume <= 0.1) {
        self.appDelegate.originalVolume = 0.5;
    }
    
    if ([UIScreen mainScreen].brightness >= self.appDelegate.originalBrightness && self.music.volume >= self.appDelegate.originalVolume) {
        [fader invalidate];
    } else {
        if ([UIScreen mainScreen].brightness < self.appDelegate.originalBrightness) {
            float incrementScreen = (self.appDelegate.originalBrightness - 0.0)/100.0;
            float newBrightness = [UIScreen mainScreen].brightness + incrementScreen;
            [[UIScreen mainScreen] setBrightness:newBrightness];
            self.appDelegate.appBrightness = newBrightness;
        }
        
        if (self.music.volume < self.appDelegate.originalVolume) {
            float incrementVolume = (self.appDelegate.originalVolume - 0.0)/100.0;
            float newVolume = self.music.volume + incrementVolume;
            if (self.appDelegate.appVolume < self.appDelegate.originalVolume) {
                [self.music setVolume:newVolume];
                self.appDelegate.appVolume = newVolume;
            }
        }
    }
}

- (void) alarmSounding {
    self.appDelegate.alarmIsSet = NO;
    self.appDelegate.alarmIsPlaying = YES;
    [fader invalidate];
    fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenIn) userInfo:nil repeats:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [sleepView removeFromSuperview];
    
    if ([[AppDelegate rdioInstance] player].state == RDPlayerStatePaused) {
        [[[AppDelegate rdioInstance] player] togglePause];
    } else {
        if ([self.appDelegate.alarmClock isShuffle]) {
            self.appDelegate.selectedPlaylist.trackKeys = [self shuffle:self.appDelegate.selectedPlaylist.trackKeys];
        }
        [[[AppDelegate rdioInstance] player] playSources:self.appDelegate.selectedPlaylist.trackKeys];
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
    
    CGRect offFrame = CGRectMake((self.view.frame.size.width - 161) / 2, self.view.frame.size.height - 19 - 44, 161, 44);
    UIImage *offButtonImage = [UIImage imageNamed:@"sleepmode-grippy"];
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
        if (self.appDelegate.alarmIsSet) {
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
    int x = 0;
    int oldListCount = list.count;
    
    while (oldListCount != newList.count) {         
        int listIndex = (arc4random() % list.count);
        NSString *testObject = [list objectAtIndex:listIndex];

        if ([[_canBeStreamed objectAtIndex:listIndex] isEqualToString:@"YES"]) {
            [newList  addObject:testObject];
            [list removeObjectAtIndex:listIndex];
            [_canBeStreamed removeObjectAtIndex:listIndex];
            
            x++;
        } else {
            //NSLog(@"list item not added: %@", [list objectAtIndex:listIndex]);
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
    }
    
    return newList;
}

- (void) startSnooze {
    //double currentPosition = [[AppDelegate rdioInstance] player].position; 
    [[[AppDelegate rdioInstance] player] togglePause];
    
    int snoozeTimeSeconds = [self.appDelegate.alarmClock snoozeTime] * 60;
    [self.appDelegate.alarmClock setAlarmTime:[NSDate dateWithTimeIntervalSinceNow:snoozeTimeSeconds] save:NO];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [wakeView removeFromSuperview];
    [self displaySleepScreen];
}

- (void) stopAlarm {
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    self.appDelegate.alarmIsSet = NO;
    self.appDelegate.alarmIsPlaying = NO;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    [music setVolume:self.appDelegate.originalVolume];
    [[UIScreen mainScreen] setBrightness:self.appDelegate.originalBrightness];
    self.navigationController.navigationBarHidden = YES;

    [[[AppDelegate rdioInstance] player] stop];
    //[self determineStreamableSongs];
    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
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

- (void) logoutClicked {
    [self.appDelegate.rdioUser logout];
}

- (void) updateSnoozeLabel {
    if ((int)_sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT", nil), (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 91) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];
    } else {
        if(_sliderSnooze.value < 10) {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];
        } else {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];

        }
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)_sliderSnooze.value]];
    }
    [_sliderSnooze setAccessibilityLabel:self.lblSnoozeAmount.text];

    [self.appDelegate.alarmClock setSnoozeTime:(int)_sliderSnooze.value];
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
    //NSLog(@"%f", sleepTimeValue);
    //if ((int)_sliderSleep.value == 1) {

    //
    /*} else */
    if (sleepTimeValue < 5) {
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"INNER TIME BUBBLE TEXT DISABLED", nil) uppercaseString]]];
        [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 124) / 2, 212, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [_sliderSleep setValue:0.0];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];
        
        if(sleepTimeValue < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 215, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 215, 126, 43)];
            
        }
        [_sliderSleep setValue:sleepTimeValue];
        [self.lblSleepAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)sleepTimeValue]];
    }
    [_sliderSleep setAccessibilityLabel:self.lblSnoozeAmount.text];

    [self.appDelegate.alarmClock setSleepTime:(int)_sliderSleep.value];
}

- (void) updateAutoStart {
    if ([self.appDelegate.alarmClock isAutoStart]) {
        [self.lblAutoStartNO setHidden:NO];
        [self.lblAutoStartYES setHidden:YES];
        [self.sliderAutoStart setValue:0.05 animated:YES];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
        [self.appDelegate.alarmClock setIsAutoStart:NO];
        [self.sliderAutoStart setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    } else {
        [self.lblAutoStartNO setHidden:YES];
        [self.lblAutoStartYES setHidden:NO];
        [self.sliderAutoStart bringSubviewToFront:self.inputView];
        [self.sliderAutoStart setValue:0.95 animated:YES];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];        
        [self.appDelegate.alarmClock setIsAutoStart:YES];
        [self.sliderAutoStart setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    }
}

- (void) updateShuffle {
    if ([self.appDelegate.alarmClock isShuffle]) {
        [self.lblShuffleNO setHidden:NO];
        [self.lblShuffleYES setHidden:YES];
        [self.sliderShuffle setValue:0.05 animated:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
        [self.appDelegate.alarmClock setIsShuffle:NO];
    } else {
        [self.lblShuffleNO setHidden:YES];
        [self.lblShuffleYES setHidden:NO];
        [self.sliderShuffle setValue:0.95 animated:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.appDelegate.alarmClock setIsShuffle:YES];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
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

    self.lightTextColor = [UIColor colorWithRed:(122.0/255.0) green:(94.0/255.0) blue:(148.0/255.0) alpha:(1.0)];
    self.darkTextColor = [UIColor colorWithRed:(23.0/255.0) green:(16.0/255.0) blue:(30.0/255.0) alpha:(1.0)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    NSDictionary *atsBig = @{
                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:92.0],
                             NSParagraphStyleAttributeName : paragraphStyle
                             };
    
    NSDictionary *atsSmall = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                               NSParagraphStyleAttributeName : paragraphStyle
                               };
    self.music = [[MPMusicPlayerController alloc] init];

    [self.navigationController setNavigationBarHidden:YES];
    self.appDelegate = [[UIApplication sharedApplication] delegate];

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBatteryLabel) name:@"UIDeviceBatteryStateDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideVolumeView) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    
    _language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    _timeSeparator = @":";
    
    if([_language isEqualToString:@"en"]) {
        _timeSeparator = @":";
    } else if([_language isEqualToString:@"fr"] || [_language isEqualToString:@"pt-PT"]) {
        _timeSeparator = @"h";
    } else if([_language isEqualToString:@"de"] || [_language isEqualToString:@"da"] || [_language isEqualToString:@"fi"]) {
        _timeSeparator = @".";
    }
    
    _lastLength = 0;
    [self.navigationItem setHidesBackButton:true];
    [self.view setBounds:[[UIScreen mainScreen] bounds]];
    
    CGRect fullScreen = [self.navigationController view].frame;
    
    UIView *settingsView = [[UIView alloc] initWithFrame:fullScreen];
    [settingsView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"settings-darkbg"]]];
    
    CGRect frameBtnSignOut = CGRectMake((self.view.frame.size.width - 78) / 4, self.view.frame.size.height - 125, 78, 28);
    if([[UIScreen mainScreen] bounds].size.height <= 480) {
        frameBtnSignOut = CGRectMake((self.view.frame.size.width - 78) / 4, self.view.frame.size.height - 40, 78, 28);
    }
    UIButton *btnSignOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignOut setFrame:frameBtnSignOut];
    [btnSignOut setTitle:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SIGN OUT", nil) uppercaseString]] forState:UIControlStateNormal];
    [btnSignOut.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [btnSignOut.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btnSignOut setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout"] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout-pressed"] forState:UIControlStateHighlighted];

    [btnSignOut addTarget:self action:@selector(logoutClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect frameBtnContactUs = CGRectMake(((self.view.frame.size.width - 78) * 3) / 4, self.view.frame.size.height - 125, 78, 28);
    if([[UIScreen mainScreen] bounds].size.height <= 480) {
        frameBtnContactUs = CGRectMake(((self.view.frame.size.width - 78) * 3) / 4, self.view.frame.size.height - 40, 78, 28);
    }
    UIButton *btnContactUs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnContactUs setFrame:frameBtnContactUs];
    [btnContactUs setTitle:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"CONTACT US", nil) uppercaseString]] forState:UIControlStateNormal];
    [btnContactUs.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [btnContactUs.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btnContactUs setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [btnContactUs setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout"] forState:UIControlStateNormal];
    [btnContactUs setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout-pressed"] forState:UIControlStateHighlighted];
    
    [btnContactUs addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
    
    if([MFMailComposeViewController canSendMail]) {
        [settingsView addSubview:btnContactUs];
    } else {
        frameBtnSignOut = CGRectMake((self.view.frame.size.width - 78) / 2, self.view.frame.size.height - 125, 78, 28);
        if([[UIScreen mainScreen] bounds].size.height <= 480) {
            frameBtnSignOut = CGRectMake((self.view.frame.size.width - 78) / 2, self.view.frame.size.height - 40, 78, 28);
        }
        [btnSignOut setFrame:frameBtnSignOut];
    }
    
    _sliderSnooze = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 270) / 2, 130, 270, 50)];
    [_sliderSnooze setMinimumValue:1.0];
    [_sliderSnooze setMaximumValue:30.0];
    [_sliderSnooze setValue:[self.appDelegate.alarmClock snoozeTime] animated:NO];
    [_sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [_sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];

    [_sliderSnooze setMinimumTrackImage:[[UIImage imageNamed:@"settings-sliderbase"] stretchableImageWithLeftCapWidth:9 topCapHeight:0] forState:UIControlStateNormal];
    [_sliderSnooze setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];

    [_sliderSnooze addTarget:self action:@selector(updateSnoozeLabel) forControlEvents:UIControlEventAllEvents];
    
    [settingsView addSubview:_sliderSnooze];
    
    _lblSnooze = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 50, 280, 50)];
    [_lblSnooze setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SNOOZE SLIDER LABEL", nil) uppercaseString]]];

    //[_lblSnooze setTextColor:self.lightTextColor];
    [_lblSnooze setTextColor:self.darkTextColor];

    [_lblSnooze setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [_lblSnooze setBackgroundColor:[UIColor clearColor]];
    [_lblSnooze setNumberOfLines:10];
    
    [_lblSnooze setAdjustsFontSizeToFitWidth:YES];
    
    [_lblSnooze setTextAlignment:NSTextAlignmentCenter];
    [settingsView addSubview:_lblSnooze];
    
    UIImageView *snoozeBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [snoozeBubble setFrame:CGRectMake((self.view.frame.size.width - 136) / 2, 85, 136, 48)];
    [settingsView addSubview:snoozeBubble];
    
    self.lblSnoozeAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 90, 126, 43)];
    
    if ((int)_sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT", nil), (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 91) / 2, 90, 126, 43)];
    } else if(_sliderSnooze.value < 10) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 90, 126, 43)];
    } else {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 90, 126, 43)];
    }
    [_sliderSnooze setAccessibilityLabel:self.lblSnoozeAmount.text];

    [self.lblSnoozeAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSnoozeAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSnoozeAmount setTextColor:self.lightTextColor];
    
    [settingsView addSubview:self.lblSnoozeAmount];
    
    UIImageView *imgFirstSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgFirstSettingsSeparator setFrame:CGRectMake(0.0, 185.0, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [settingsView addSubview:imgFirstSettingsSeparator];
    
    _sliderSleep = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 270) / 2, 255, 270, 50)];
    [_sliderSleep setMinimumValue:0.0];
    [_sliderSleep setMaximumValue:60.0];
    [_sliderSleep setValue:[self.appDelegate.alarmClock sleepTime] animated:NO];
    [_sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [_sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];
    
    [_sliderSleep setMinimumTrackImage:[[UIImage imageNamed:@"settings-sliderbase"] stretchableImageWithLeftCapWidth:9 topCapHeight:0] forState:UIControlStateNormal];
    [_sliderSleep setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];

    [_sliderSleep addTarget:self action:@selector(updateSleepLabel) forControlEvents:UIControlEventAllEvents];
    
    _lblSleep = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 175, 280, 50)];
    [_lblSleep setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SLEEP SLIDER LABEL", nil) uppercaseString]]];
    //[_lblSleep setTextColor:self.lightTextColor];
    [_lblSleep setTextColor:self.darkTextColor];
    [_lblSleep setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [_lblSleep setBackgroundColor:[UIColor clearColor]];
    [_lblSleep setNumberOfLines:10];
    [_lblSleep setAdjustsFontSizeToFitWidth:YES];
    
    [_lblSleep setTextAlignment:NSTextAlignmentCenter];
    
    UIImageView *sleepBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [sleepBubble setFrame:CGRectMake((self.view.frame.size.width - 136) / 2, 210, 136, 48)];
    [settingsView addSubview:sleepBubble];
    
    self.lblSleepAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 215, 126, 43)];
    NSLog(@"Sleep time: %d", [self.appDelegate.alarmClock sleepTime]);
    if ([self.appDelegate.alarmClock sleepTime] == 0) {
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"INNER TIME BUBBLE TEXT DISABLED", nil) uppercaseString]]];
        [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 124) / 2, 212, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [_sliderSleep setValue:[self.appDelegate.alarmClock sleepTime]];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];
        
        if([self.appDelegate.alarmClock sleepTime] < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 106) / 2, 215, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 215, 126, 43)];
            
        }
        [_sliderSleep setValue:[self.appDelegate.alarmClock sleepTime]];
        [self.lblSleepAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), [self.appDelegate.alarmClock sleepTime]]];
    }
    [_sliderSnooze setAccessibilityLabel:self.lblSleepAmount.text];

    [self.lblSleepAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSleepAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSleepAmount setTextColor:self.lightTextColor];
    
    [settingsView addSubview:self.lblSleepAmount];
    
    UIImageView *imgSecondSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgSecondSettingsSeparator setFrame:CGRectMake(0.0, 307, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [settingsView addSubview:imgSecondSettingsSeparator];
    
    self.sliderAutoStart = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 88), 322, 78, 28)];
    [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
    [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateHighlighted];
    
    [self.sliderAutoStart setMinimumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderAutoStart setMaximumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderAutoStart addTarget:self action:@selector(updateAutoStart) forControlEvents:UIControlEventTouchCancel | UIControlEventValueChanged];
    [self.sliderAutoStart setContinuous:NO];

    [settingsView addSubview:self.sliderAutoStart];
    
    self.lblAutoStartNO = [[UILabel alloc] initWithFrame:CGRectMake(38,0,30,28)];
    [self.lblAutoStartNO setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    [self.lblAutoStartNO setBackgroundColor:[UIColor clearColor]];
    [self.lblAutoStartNO setTextColor:self.darkTextColor];
    [self.lblAutoStartNO setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];

    self.lblAutoStartYES = [[UILabel alloc] initWithFrame:CGRectMake(18,0,30,28)];
    [self.lblAutoStartYES setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    [self.lblAutoStartYES setBackgroundColor:[UIColor clearColor]];
    [self.lblAutoStartYES setTextColor:self.lightTextColor];
    [self.lblAutoStartYES setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];

    [self.sliderAutoStart addSubview:self.lblAutoStartYES];
    [self.sliderAutoStart addSubview:self.lblAutoStartNO];
    
    if ([self.appDelegate.alarmClock isAutoStart]) {
        [self.lblAutoStartNO setHidden:YES];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateHighlighted];
        [self.sliderAutoStart setValue:0.95 animated:NO];
    } else {
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
        [self.lblAutoStartYES setHidden:YES];
        [self.sliderAutoStart setValue:0.05 animated:NO];
    }
    
    _lblAutoStart = [[UILabel alloc] initWithFrame:CGRectMake(15, 306, 200, 60)];
    [_lblAutoStart setText:[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM", nil)]];
    [_lblAutoStart setTextColor:self.lightTextColor];

    [_lblAutoStart setTextAlignment:NSTextAlignmentLeft];
    [_lblAutoStart setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [_lblAutoStart setBackgroundColor:[UIColor clearColor]];
    [_lblAutoStart setLineBreakMode:NSLineBreakByWordWrapping];
    [_lblAutoStart setNumberOfLines:2];
    [_lblAutoStart setAdjustsFontSizeToFitWidth:YES];
    
    [settingsView addSubview:_lblAutoStart];
    
    UIImageView *imgThirdSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgThirdSettingsSeparator setFrame:CGRectMake(0.0, 363, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [settingsView addSubview:imgThirdSettingsSeparator];

    self.sliderShuffle = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 88), 377, 78, 28)];
    [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
    [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateHighlighted];
    
    [self.sliderShuffle setMinimumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderShuffle setMaximumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderShuffle sendActionsForControlEvents:UIControlEventValueChanged];
    [self.sliderShuffle addTarget:self action:@selector(updateShuffle) forControlEvents:UIControlEventTouchCancel | UIControlEventValueChanged];
    [self.sliderShuffle setContinuous:NO];
    
    [settingsView addSubview:self.sliderShuffle];
    
    self.lblShuffleNO = [[UILabel alloc] initWithFrame:CGRectMake(38,0,30,28)];
    [self.lblShuffleNO setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    [self.lblShuffleNO setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffleNO setTextColor:self.darkTextColor];
    [self.lblShuffleNO setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    self.lblShuffleYES = [[UILabel alloc] initWithFrame:CGRectMake(18,0,30,28)];
    [self.lblShuffleYES setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    [self.lblShuffleYES setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffleYES setTextColor:self.lightTextColor];
    [self.lblShuffleYES setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [self.sliderShuffle addSubview:self.lblShuffleYES];
    [self.sliderShuffle addSubview:self.lblShuffleNO];
    
    if ([self.appDelegate.alarmClock isShuffle]) {
        [self.lblShuffleNO setHidden:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateHighlighted];
        [self.sliderShuffle setValue:0.95 animated:NO];
    } else {
        [self.lblShuffleYES setHidden:YES];
        [self.sliderShuffle setValue:0.05 animated:NO];
    }
    
    self.lblShuffle = [[UILabel alloc] initWithFrame:CGRectMake(15, 359, 200, 60)];
    [self.lblShuffle setText:[NSString stringWithFormat:NSLocalizedString(@"SHUFFLE", nil)]];
    [self.lblShuffle setTextColor:self.lightTextColor];
    //[_lblAutoStart setTextColor:self.darkTextColor];
    
    [self.lblShuffle setTextAlignment:NSTextAlignmentLeft];
    [self.lblShuffle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [self.lblShuffle setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffle setLineBreakMode:NSLineBreakByWordWrapping];
    [self.lblShuffle setNumberOfLines:2];
    [self.lblShuffle setAdjustsFontSizeToFitWidth:YES];
    
    [settingsView addSubview:self.lblShuffle];

    UIImageView *imgFourthSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgFourthSettingsSeparator setFrame:CGRectMake(0.0, 417, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [settingsView addSubview:imgFourthSettingsSeparator];

    if ([self.appDelegate.rdioUser isLoggedIn]) {
        [settingsView addSubview:btnSignOut];
        [settingsView addSubview:_lblSleep];
        [settingsView addSubview:_sliderSleep];
    }
    
    UIImageView *ivTexas = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ThickTexasVector"]];
    [ivTexas setFrame:CGRectMake((self.view.frame.size.width - 32) / 2, self.view.frame.size.height - 90, 31, 30)];
        
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, [[UIScreen mainScreen] bounds].size.width, 50)];
    [lblName setText:[NSString stringWithFormat:@"David Brunow\n@davidbrunow\nhelloDavid@brunow.org"]];
    [lblName setText:[NSString stringWithFormat:@"Designed and Developed in Texas by\nJenni Leder          @thoughtbrain      jenni.leder@gmail.com\nDavid Brunow        @davidbrunow      helloDavid@brunow.org"]];
    [lblName setTextColor:self.darkTextColor];
    [lblName setTextColor:[UIColor blackColor]];

    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0]];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setNumberOfLines:10];
    
    [lblName setTextAlignment:NSTextAlignmentCenter];
    
    if([[UIScreen mainScreen] bounds].size.height > 480) {
        [settingsView addSubview:ivTexas];
        [settingsView addSubview:lblName];
    }
    
    [self.view addSubview:settingsView];
    
    setAlarmView = [[UIView alloc] initWithFrame:fullScreen];
    
    if([[UIScreen mainScreen] bounds].size.height > 480) {
        [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
    } else {
        [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]]];
    }
    
    CGRect setAlarmFrame = CGRectMake((self.view.frame.size.width - 240) / 2, self.view.frame.size.height - 150, 240, 50);
    setAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [setAlarmButton setFrame:setAlarmFrame];
    
    [setAlarmButton setBackgroundImage:[UIImage imageNamed:@"btn-setalarm"] forState:UIControlStateNormal];
    [setAlarmButton setTitle:NSLocalizedString(@"SET ALARM", nil) forState: UIControlStateNormal];
    [setAlarmButton setBackgroundColor:[UIColor grayColor]];
    [setAlarmButton.titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    [setAlarmButton addTarget:self action:@selector(setAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
    [setAlarmButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
    [setAlarmButton setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [setAlarmButton setEnabled:NO];
    [setAlarmView addSubview:setAlarmButton];
    
    /*
     CGRect remindMeFrame = CGRectMake(40.0, 180.0, 120, 30);
     remindMe = [[UISwitch alloc] initWithFrame:remindMeFrame];
     [remindMe setOn:YES animated:YES];
     [setAlarmView addSubview:remindMe]; */
    
    UILabel *toolbarAutoAMPM = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 235, 30)];
    if(![self.appDelegate.alarmClock is24h]) {
        [toolbarAutoAMPM setText:[NSLocalizedString(@"AUTOSET AM PM", nil) lowercaseString]];
    }
    [toolbarAutoAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [toolbarAutoAMPM setTextColor:self.lightTextColor];
    [toolbarAutoAMPM setBackgroundColor:[UIColor clearColor]];

    
    CGRect timeTextFrame = CGRectMake(10, 5, self.view.frame.size.width, 92);
    UIImage *timeTextBackground = [UIImage imageNamed:@"timeSetRoundedRect"];
    UIImageView *timeTextBackgroundView = [[UIImageView alloc] initWithImage:timeTextBackground];
    [timeTextBackgroundView setFrame:timeTextFrame];
    //[setAlarmView addSubview:timeTextBackgroundView];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    [doneButton setTintColor:self.darkTextColor];
    
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithCustomView:toolbarAutoAMPM],
                           doneButton,
                           nil];
    [numberToolbar sizeToFit];
    
    
    self.timeTextField = [[DHBTextField alloc] initWithFrame:timeTextFrame];
    [self.timeTextField.cursor setBackgroundColor:self.lightTextColor];
    [self.timeTextField setDelegate:self];
    [self.timeTextField setBackgroundColor:[UIColor clearColor]];
    [self.timeTextField setTextAlignment:NSTextAlignmentLeft];
    [self.timeTextField setTextColor:self.darkTextColor];
    [self.timeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.timeTextField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:92]];
    //[timeTextField setBounds:CGRectMake(5.0, 60, 300, 150)];
    //[timeTextField setContentMode:UIViewContentModeScaleToFill];
    [self.timeTextField setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"CHOOSE ALARM TIME", nil)]];
    [self.timeTextField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    //[timeTextField setAdjustsFontSizeToFitWidth:YES];
    self.timeTextField.inputAccessoryView = numberToolbar;
    [self.timeTextField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    NSString *timeTextString = [NSString stringWithFormat:@"%@",[self.appDelegate.alarmClock getAlarmTimeString] ];
    NSLog(@"Time text string: %@", timeTextString);
    if (timeTextString == nil) {
        timeTextString = [NSString stringWithFormat:@""];
    } else {
        timeTextString = [timeTextString stringByReplacingOccurrencesOfString:@"h" withString:_timeSeparator];
    }
    [self.timeTextField setText:timeTextString];
        
    UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] init];
    [dismissTap addTarget:self action:@selector(doneWithNumberPad)];
    
    [self.view addGestureRecognizer:dismissTap];
    
    [self.timeTextField setPlaceholder:_timeSeparator];
    [setAlarmView addSubview:self.timeTextField];
    
    CGRect chooseMusicFrame = CGRectMake(30.0, 300, 260.0, 100.0);
    _chooseMusic = [[UITableView alloc] initWithFrame:chooseMusicFrame style:UITableViewStyleGrouped];
    [_chooseMusic setScrollEnabled:NO];
    [_chooseMusic setBackgroundColor:[UIColor clearColor]];
    [_chooseMusic setBackgroundView:nil];
    [_chooseMusic setDelegate:self];
    [_chooseMusic setDataSource:self];
    
    self.lblWakeUpTo = [[UILabel alloc] initWithFrame:CGRectMake(10, 131.0, 300.0, 40.0)];
    [self.lblWakeUpTo setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"WAKE UP TO", nil) uppercaseString]]];
    [self.lblWakeUpTo setBackgroundColor:[UIColor clearColor]];
    [self.lblWakeUpTo setTextColor:self.darkTextColor];
    [self.lblWakeUpTo setNumberOfLines:1];
    [self.lblWakeUpTo setContentMode:UIViewContentModeTop];
    [self.lblWakeUpTo setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0]];
    [self.lblWakeUpTo sizeToFit];
    
    [setAlarmView addSubview:self.lblWakeUpTo];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    self.lblPlaylist = [[UILabel alloc] initWithFrame:CGRectMake(10, 154.0, 300, 200.0)];
    if (self.view.frame.size.height > 480) {
        [self.lblPlaylist setNumberOfLines:4];
    } else {
        [self.lblPlaylist setNumberOfLines:3];
    }
    //if (self.appDelegate.loggedIn) {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [NSLocalizedString(@"CHOOSE PLAYLIST", nil) lowercaseString]] attributes:ats]];
        CGRect frame = CGRectMake(10, 154.0, 300.0, 200.0);
        [self.lblPlaylist setFrame:frame];
        [self.lblPlaylist sizeToFit];
        frame.size.height = self.lblPlaylist.frame.size.height;
        [self.lblPlaylist setFrame:frame];
        [tap addTarget:self action:@selector(showPlaylists)];
    //} else {
    //    [self.lblPlaylist setText:[NSString stringWithFormat:NSLocalizedString(@"NOT SIGNED IN LABEL", nil)]];
    //    [tap addTarget:self action:@selector(RdioSignUp)];
    //}
    [self.lblPlaylist setBackgroundColor:[UIColor clearColor]];
    [self.lblPlaylist setTextColor:self.lightTextColor];
    //[self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", [self.appDelegate.alarmClock playlistName]] lowercaseString] attributes:ats]];
    //[self.lblPlaylist sizeToFit];

    
    //[self.lblPlaylist setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0]];
    [self.lblPlaylist setUserInteractionEnabled:YES];
    [self.lblPlaylist addGestureRecognizer:tap];
    
    [setAlarmView addSubview:self.lblPlaylist];
    
    if (self.appDelegate.loggedIn) {
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
    self.hideVolume = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
    [self.hideVolume sizeToFit];
    [self.view addSubview:self.hideVolume];

    [setAlarmView.layer setShadowColor:[UIColor blackColor].CGColor];
    [setAlarmView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [setAlarmView.layer setShadowRadius:1.0];
    [setAlarmView.layer setShadowOpacity:7.0];
    
    
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSettingsPanGesture:)];
    
    UIImage *settingsButtonImage = [UIImage imageNamed:@"icon-settings"];
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSettings setImage:settingsButtonImage forState:UIControlStateNormal];
    [btnSettings setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"CHANGE SETTINGS", nil)]];
    [btnSettings setFrame:CGRectMake((self.view.frame.size.width - 161) / 2, self.view.frame.size.height - 45, 161, 34)];
    [btnSettings addGestureRecognizer:slideViewGesture];
    [btnSettings setTintColor:[UIColor clearColor]];
    
    [btnSettings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    
    [setAlarmView addSubview:btnSettings];
    
    [self.view addSubview:setAlarmView];
    
    [self setAMPMLabel];
    
    if ([self.appDelegate.alarmClock isAutoStart] && ![timeTextString isEqualToString:@""]) {
        //[self getAlarmTime];
        NSString *alarmTimeText;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if(![self.appDelegate.alarmClock is24h]) {
            [formatter setDateFormat:@"hh:mm a"];
        } else {
            [formatter setDateFormat:[NSString stringWithFormat:@"HH:mm"]];
        }
        alarmTimeText = [formatter stringFromDate:[self.appDelegate.alarmClock alarmTime]];
        alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@":" withString:_timeSeparator];
        self.navigationController.navigationBarHidden = YES;
        autoStartAlarmView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        if([[UIScreen mainScreen] bounds].size.height > 480) {
            [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
        } else {
            [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]]];
        }
        
        UILabel *autoStartAlarmViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -20, [[UIScreen mainScreen] bounds].size.width, 45)];
        [autoStartAlarmViewLabel setBackgroundColor:[UIColor clearColor]];
        [autoStartAlarmViewLabel setLineBreakMode:NSLineBreakByWordWrapping];

        [autoStartAlarmViewLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM BEING SET", nil)] uppercaseString] attributes:atsSmall]];
        [autoStartAlarmViewLabel setNumberOfLines:0];
        [autoStartAlarmViewLabel setTextColor:self.darkTextColor];
        [autoStartAlarmView addSubview:autoStartAlarmViewLabel];        
        
        UILabel *lblAutoSetPlaylist = [[UILabel alloc] initWithFrame:CGRectMake(10, 131,[[UIScreen mainScreen] bounds].size.width, 40)];
        [lblAutoSetPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSLocalizedString(@"AUTO ALARM PLAYLIST", nil) uppercaseString] attributes:atsSmall]];
        [lblAutoSetPlaylist setBackgroundColor:[UIColor clearColor]];
        [lblAutoSetPlaylist setTextColor:self.darkTextColor];
        
        [autoStartAlarmView addSubview:lblAutoSetPlaylist];

        UILabel *alarmTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, [[UIScreen mainScreen] bounds].size.width, 120.0)];
        [alarmTimeLabel setTextColor:self.darkTextColor];
        [alarmTimeLabel setBackgroundColor:[UIColor clearColor]];
        [alarmTimeLabel setNumberOfLines:0];
        
        if (![self.appDelegate.alarmClock is24h]) {
            NSString *alarmTimeAMPM = [[alarmTimeText componentsSeparatedByString:@" "] objectAtIndex:1];
            UILabel *sleepAMPM = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 62, 12, 75, 50)];
            if ([alarmTimeAMPM isEqualToString:@"PM"]) {
                [sleepAMPM setFrame:CGRectMake(self.view.frame.size.width - 62, 53, 75, 50)];
            }
            [sleepAMPM setBackgroundColor:[UIColor clearColor]];
            [sleepAMPM setLineBreakMode:NSLineBreakByWordWrapping];
            [sleepAMPM setText:[NSString stringWithFormat:@"%@", [alarmTimeAMPM lowercaseString]]];
            [sleepAMPM setTextColor:self.darkTextColor];
            [sleepAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
            [autoStartAlarmView addSubview:sleepAMPM];
            alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@" PM" withString:@""];
            alarmTimeText = [alarmTimeText stringByReplacingOccurrencesOfString:@" AM" withString:@""];
        }
        
        if([alarmTimeText length] == 4) {
            alarmTimeText = [NSString stringWithFormat:@"0%@", alarmTimeText];
        }
        [alarmTimeLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", alarmTimeText] lowercaseString] attributes:atsBig]];
        
        UILabel *lblAutoSetPlaylistName = [[UILabel alloc] initWithFrame:CGRectMake(10, 154.0, [[UIScreen mainScreen] bounds].size.width - 20, 200.0)];
        [lblAutoSetPlaylistName setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", [self.appDelegate.alarmClock playlistName]] lowercaseString] attributes:ats]];
        [lblAutoSetPlaylistName setTextColor:self.lightTextColor];
        [lblAutoSetPlaylistName setBackgroundColor:[UIColor clearColor]];
        if (self.view.frame.size.height > 480) {
            [lblAutoSetPlaylistName setNumberOfLines:4];
        } else {
            [lblAutoSetPlaylistName setNumberOfLines:3];
        }
        [lblAutoSetPlaylistName sizeToFit];
        [lblAutoSetPlaylistName setContentMode:UIViewContentModeTop];
        [autoStartAlarmView addSubview:lblAutoSetPlaylistName];
        [autoStartAlarmView addSubview:alarmTimeLabel];

        UILabel *lblTapToCancel = [[UILabel alloc] initWithFrame:CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 220, [[UIScreen mainScreen] bounds].size.width - 20, 200)];
        [lblTapToCancel setText:[[NSString stringWithFormat:@"tap to cancel"] lowercaseString]];
        [lblTapToCancel setTextColor:self.darkTextColor];
        [lblTapToCancel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];

        [lblTapToCancel setBackgroundColor:[UIColor clearColor]];
        [lblTapToCancel setNumberOfLines:0];
        
        [autoStartAlarmView addSubview: lblTapToCancel];
        
        [self.view addSubview:autoStartAlarmView];
        [delay invalidate];
        delay = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(delayAutoStart) userInfo:nil repeats:NO];

    }
    
    [self getAlarmTime];
    [self setAMPMLabel];
}

-(void) sendEmail
{
    self.emailCompose = [[MFMailComposeViewController alloc] init];

    [self.emailCompose setMailComposeDelegate:self];
    [self.emailCompose setToRecipients:[[NSArray alloc] initWithObjects:@"helloDavid@brunow.org", nil]];
    [self.emailCompose setSubject:@"Howdy!"];
    [self.emailCompose setMessageBody:[NSString stringWithFormat:@"<br /><br /><br /><br />Troubleshooting Information<br />---<br />App Name: %@<br />App Version: %@<br />iOS Device: %@<br />iOS Version: %@<br />", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], [UIDevice currentDevice].model, [[UIDevice currentDevice] systemVersion]] isHTML:YES];
    
    [self presentViewController:self.emailCompose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void) hideVolumeView
{
    NSLog(@"Here");
    self.hideVolume = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
    [self.hideVolume sizeToFit];
    //[self.view addSubview:self.hideVolume];
}

-(void) doneWithNumberPad
{
    [self.timeTextField resignFirstResponder];
}

-(void) showPlaylists
{
    self.listsViewController = [[ListsViewController alloc] init];
    
    [self.navigationController pushViewController:self.listsViewController animated:YES];
}

-(void) setAMPMLabel
{
    [_lblAMPM removeFromSuperview];
    //[self getAlarmTime];
    NSString *sAMPM;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"a"];
    sAMPM = [formatter stringFromDate:[self.appDelegate.alarmClock alarmTime]];
    
    _lblAMPM = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 62, 12, 75, 50)];
    if ([sAMPM isEqualToString:@"PM"]) {
        [_lblAMPM setFrame:CGRectMake(self.view.frame.size.width - 62, 53, 75, 50)];
    }
    [_lblAMPM setBackgroundColor:[UIColor clearColor]];
    [_lblAMPM setLineBreakMode:NSLineBreakByWordWrapping];
    [_lblAMPM setText:[NSString stringWithFormat:@"%@", [sAMPM lowercaseString]]];
    [_lblAMPM setTextColor:self.darkTextColor];
    [_lblAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
    if (sAMPM.length > 0 && ![self.appDelegate.alarmClock is24h]) {
        [setAlarmView addSubview:_lblAMPM];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (delay.isValid) {
        [self cancelAutoStart];
    }
}

- (void) handleSettingsPanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:sender.view.superview];
    
    CGRect newFrame = [[UIScreen mainScreen] bounds];
    
    if ([self settingsOpen]) {
        newFrame.origin.y = -[[UIScreen mainScreen] bounds].size.height + 60;
    }
    
    newFrame.origin.y += (translate.y);
    sender.view.superview.frame = newFrame;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showSettings];
    }
}

- (void) showSettings
{
    CGRect settingsOpenFrame = [[UIScreen mainScreen] bounds];
    settingsOpenFrame.origin.y = -[[UIScreen mainScreen] bounds].size.height + 60;
    CGRect settingsClosedFrame = [[UIScreen mainScreen] bounds];

    if (![self settingsOpen]) {
        [UIView animateWithDuration:0.3 animations:^{[setAlarmView setFrame:settingsOpenFrame];}];
        setAlarmButton.enabled = false;
        [self setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SETTINGS OPENED", nil)]];
        [self setSettingsOpen:YES];
    } else {
        [UIView animateWithDuration:0.3 animations:^{[setAlarmView setFrame:settingsClosedFrame];}];
        //setAlarmButton.enabled = true;
        [self testToEnableAlarmButton];
        [self setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SETTINGS CLOSED", nil)]];
        [self setSettingsOpen:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;

    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : paragraphStyle
    };
    
    if([self.appDelegate.alarmClock playlistName]) {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [[self.appDelegate.alarmClock playlistName] lowercaseString]] attributes:ats]];
    } else {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [NSLocalizedString(@"CHOOSE PLAYLIST", nil) lowercaseString]] attributes:ats]];
    }
    //[self.lblPlaylist setText:[appDelegate.selectedPlaylist lowercaseString]];
    CGRect frame = CGRectMake(10, 154.0, 300.0, 200.0);
    [self.lblPlaylist setFrame:frame];
    [self.lblPlaylist sizeToFit];
    frame.size.height = self.lblPlaylist.frame.size.height;
    [self.lblPlaylist setFrame:frame];
        
    if ([self.appDelegate.rdioUser isLoggedIn]) {
        [_chooseMusic reloadData];
    }
    
    if ([self.appDelegate.alarmClock playlistPath] != nil && playlists != nil) {
        //[self loadSongs];
    }
    
    [self testToEnableAlarmButton];
}

- (void) testToEnableAlarmButton
{    
    if (self.appDelegate.selectedPlaylist.trackKeys != nil && self.timeTextField.text.length == 5) {
            [setAlarmButton setEnabled:YES];
    } else {
            [setAlarmButton setEnabled:NO];
    }
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"musicCell"];
    
    if ([self.appDelegate.alarmClock playlistPath] != nil) {
        [cell setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"SELECTED PLAYLIST IS", nil), [self.appDelegate.alarmClock playlistName]]];
        cell.textLabel.text = [self.appDelegate.alarmClock playlistName];
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
    int currentLength = textField.text.length;
        
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
    
    if(![self.appDelegate.alarmClock is24h]) {
        if ([firstChar isEqualToString: @"0"] && _lastLength <= textField.text.length) {
            if([secondChar isEqualToString:@"0"]) {
                textField.Text = [NSString stringWithFormat:@"0"];
            } else if(textField.text.length == 2 ) {
                textField.Text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
            } else if(textField.text.length == 4) {
                if([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
                }
            } else if(textField.text.length > 5) {
                textField.text = [NSString stringWithFormat:@"%@%@:%@%@", firstChar, secondChar, fourthChar, fifthChar];
            }
        
        } else if ([firstChar isEqualToString: @"1"] && _lastLength <= textField.text.length) {
            if([secondChar isEqualToString:@"3"] || [secondChar isEqualToString:@"4"] || [secondChar isEqualToString:@"5"]) {
                textField.Text = [NSString stringWithFormat:@"0%@:%@", firstChar, secondChar];
            } else if([secondChar isEqualToString:@"6"] || [secondChar isEqualToString:@"7"] || [secondChar isEqualToString:@"8"] || [secondChar isEqualToString:@"9"]) {
                textField.Text = [NSString stringWithFormat:@"%@", firstChar];
            } else if(textField.text.length == 2 ) {
                textField.Text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
            } else if(textField.text.length == 4) {
                if([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
                }
            } else if(textField.text.length > 5) {
                textField.text = [NSString stringWithFormat:@"%@%@:%@%@", firstChar, secondChar, fourthChar, fifthChar];
            }
            
        } else if (_lastLength <= textField.text.length) {
            textField.text = [NSString stringWithFormat:@"0%@:", firstChar];
        }
        
        if(_lastLength > textField.text.length) {
            if(textField.text.length == 2) {
                textField.Text = [NSString stringWithFormat:@"%@", firstChar];
            }
        }
    } else if ([self.appDelegate.alarmClock is24h]) {
        if ([firstChar isEqualToString: @"0"] && _lastLength <= textField.text.length) {
            if([secondChar isEqualToString:@"0"]) {
                textField.Text = [NSString stringWithFormat:@"0"];
            } else if(textField.text.length == 2 ) {
                textField.Text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
            } else if(textField.text.length == 4) {
                if([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
                }
            } else if(textField.text.length > 5) {
                textField.text = [NSString stringWithFormat:@"%@%@:%@%@", firstChar, secondChar, fourthChar, fifthChar];
            }
            
        } else if ([firstChar isEqualToString: @"1"] && _lastLength <= textField.text.length) {
            if(textField.text.length == 2 ) {
                textField.Text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
            } else if(textField.text.length == 4) {
                if([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
                }
            } else if(textField.text.length > 5) {
                textField.text = [NSString stringWithFormat:@"%@%@:%@%@", firstChar, secondChar, fourthChar, fifthChar];
            }
        } else if ([firstChar isEqualToString: @"2"] && _lastLength <= textField.text.length) {
            if([secondChar isEqualToString:@"4"] || [secondChar isEqualToString:@"5"] || [secondChar isEqualToString:@"6"] || [secondChar isEqualToString:@"7"] || [secondChar isEqualToString:@"8"] || [secondChar isEqualToString:@"9"]) {
                textField.Text = [NSString stringWithFormat:@"%@", firstChar];
            } else if(textField.text.length == 2 ) {
                textField.Text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
            } else if(textField.text.length == 4) {
                if([fourthChar isEqualToString:@"6"] || [fourthChar isEqualToString:@"7"] || [fourthChar isEqualToString:@"8"] || [fourthChar isEqualToString:@"9"]) {
                    textField.text = [NSString stringWithFormat:@"%@%@:", firstChar, secondChar];
                }
            } else if(textField.text.length > 5) {
                textField.text = [NSString stringWithFormat:@"%@%@:%@%@", firstChar, secondChar, fourthChar, fifthChar];
            }
            
        } else if (_lastLength <= textField.text.length) {
            textField.text = [NSString stringWithFormat:@"0%@:", firstChar];
        }
        
        if(_lastLength > textField.text.length) {
            if(textField.text.length == 2) {
                textField.Text = [NSString stringWithFormat:@"%@", firstChar];
            }
        }
        
        /*
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
*/
    }
    
    if (textField.text.length > _lastLength && textField.text.length == 5) {
        [textField resignFirstResponder];
    }
    [self testToEnableAlarmButton];
    [self setAMPMLabel];
    _lastLength = textField.text.length;
}

- (void) tick
{
    NSLog(@"current time: %@\nalarm time: %@", [NSDate date], [self.appDelegate.alarmClock alarmTime]);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"ss"];

    if ([[formatter stringFromDate:[NSDate date]] isEqualToString:@"00"]) {
        [self setupCurrentTimeView];
    }

    NSDate *now = [NSDate date];
    
    if([[self.appDelegate.alarmClock alarmTime] isEqualToDate:([[self.appDelegate.alarmClock alarmTime] earlierDate:now])] && !playing)
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



@end
