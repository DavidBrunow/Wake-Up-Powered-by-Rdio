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
#import "DHBAlarmSettingsView.h"
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
    CGRect alarmLabelRect = CGRectMake(10.0, -20.0, [[UIScreen mainScreen] bounds].size.width, 45.0);
    CGRect chargingLabelRect = CGRectMake(10.0, 260.0, 280.0, 200.0);
    
    NSString *alarmTimeText;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (![self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"h:mm a"];
    } else if ([self.appDelegate.alarmClock is24h]) {
        [formatter setDateFormat:@"H:mm"];
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
    
    if ([self.appDelegate.alarmClock sleepTime] != 0 && ![self isSnoozing]) {
        if([self.appDelegate.alarmClock isShuffle]) {
            self.songsToPlay = [self.appDelegate.sleepPlaylist getShuffledTrackKeys];
        } else {
            self.songsToPlay = self.appDelegate.sleepPlaylist.trackKeys;
        }
        
        if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
            [[[AppDelegate rdioInstance] player] playSources:self.songsToPlay];
        } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
            NSMutableArray *songsForPlaying = [[NSMutableArray alloc] init];
            for(int x = 0; x < self.songsToPlay.count; x++) {
                MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[self.songsToPlay objectAtIndex:x] forProperty:MPMediaItemPropertyPersistentID];
                
                //finding songs for predicate
                MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
                [mySongQuery addFilterPredicate: predicate];
                [songsForPlaying addObject:[[mySongQuery items] objectAtIndex:0]];
            }
            
            [self.music setQueueWithItemCollection:[[MPMediaItemCollection alloc] initWithItems:songsForPlaying]];
            [self.music play];
        }
        fader = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES];
    } else {
        fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES];
    }
    
    self.appDelegate.originalVolume = self.music.volume;
    //AVAudioPlayer *thisPlayer = [[AVAudioPlayer alloc] init];
    
}

- (void) setupCurrentWeatherView
{
    if(self.currentWeatherView == nil) {
        self.currentWeatherView = [[UIView alloc] initWithFrame:CGRectMake(0, 124.0, [UIScreen mainScreen].bounds.size.width, 200.0)];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 28.0f;
    paragraphStyle.maximumLineHeight = 28.0f;
    paragraphStyle.minimumLineHeight = 28.0f;
    
    NSMutableParagraphStyle *medParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    medParagraphStyle.lineHeightMultiple = 50.0f;
    medParagraphStyle.maximumLineHeight = 50.0f;
    medParagraphStyle.minimumLineHeight = 50.0f;

    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : medParagraphStyle
                          };
    
    NSDictionary *atsSmall = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                               NSParagraphStyleAttributeName : paragraphStyle
                               };
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, [[UIScreen mainScreen] bounds].size.width, 40.0)];
    [currentLabel setTextColor:[UIColor whiteColor]];
    [currentLabel setBackgroundColor:[UIColor clearColor]];
    [currentLabel setNumberOfLines:1];
    [currentLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"TODAY WILL BE", nil)] uppercaseString] attributes:atsSmall]];
    
    UILabel *currentWeatherLabel = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 100, 40.0, 90.0, 120.0)];
    [currentWeatherLabel setTextColor:[UIColor whiteColor]];
    [currentWeatherLabel setBackgroundColor:[UIColor clearColor]];
    [currentWeatherLabel setNumberOfLines:0];
    [currentWeatherLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"now:\t%.0fº\nhigh:\t%.0fº\nlow:\t%.0fº", [self.appDelegate.currentWeather currentTempF], [self.appDelegate.currentWeather highTempF], [self.appDelegate.currentWeather lowTempF]] lowercaseString] attributes:atsSmall]];
    [currentWeatherLabel sizeToFit];
    
    UILabel *currentConditionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 40.0, 200, 120.0)];
    [currentConditionsLabel setTextColor:[UIColor whiteColor]];
    [currentConditionsLabel setBackgroundColor:[UIColor clearColor]];
    [currentConditionsLabel setNumberOfLines:0];
    [currentConditionsLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:@"%@", [self.appDelegate.currentWeather conditions]] lowercaseString] attributes:ats]];
    [currentConditionsLabel sizeToFit];
    
    UILabel *weatherAPIAcknowledgment = [[UILabel alloc] initWithFrame:CGRectMake(25.0, [[UIScreen mainScreen] bounds].size.height - 142.0, [[UIScreen mainScreen] bounds].size.width - 50, 20.0)];
    [weatherAPIAcknowledgment setTextColor:[UIColor whiteColor]];
    [weatherAPIAcknowledgment setBackgroundColor:[UIColor clearColor]];
    [weatherAPIAcknowledgment setNumberOfLines:0];
    [weatherAPIAcknowledgment setTextAlignment:NSTextAlignmentCenter];
    [weatherAPIAcknowledgment setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0]];
    [weatherAPIAcknowledgment setText:[[NSString stringWithFormat:@"%@", @"Weather Provided by World Weather Online"] lowercaseString]];
    [weatherAPIAcknowledgment sizeToFit];
    
    UIImageView *currentConditionsImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.appDelegate.currentWeather.conditions]];
    [currentConditionsImage setFrame:CGRectMake(30.0, 60.0, 96.0, 96.0)];
    
    if([self.appDelegate.currentWeather conditions] == nil) {
    } else {
        [self.currentWeatherView addSubview:currentConditionsLabel];
        [self.currentWeatherView addSubview:currentLabel];
        [self.currentWeatherView addSubview:currentWeatherLabel];
        [self.currentWeatherView addSubview:weatherAPIAcknowledgment];
    }
}

- (void) setupCurrentTimeView
{
    //#TODO: Fix bug where time doesn't update on first minute change
    if (self.currentTimeView == nil) {
        self.currentTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 150.0)];
    } else {
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
    
    UILabel *currentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -20.0, [[UIScreen mainScreen] bounds].size.width, 45.0)];
    [currentLabel setTextColor:self.darkTextColor];
    if(self.appDelegate.alarmIsPlaying) {
        [currentLabel setTextColor:[UIColor whiteColor]];
    } else {
        [currentLabel setTextColor:self.darkTextColor];
    }
    
    [currentLabel setBackgroundColor:[UIColor clearColor]];
    [currentLabel setNumberOfLines:1];
    [currentLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"CURRENT TIME IS", nil)] uppercaseString] attributes:atsSmall]];
    
    UILabel *currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, [[UIScreen mainScreen] bounds].size.width, 120.0)];
    [currentTimeLabel setTextColor:self.darkTextColor];
    if(self.appDelegate.alarmIsPlaying) {
        [currentTimeLabel setTextColor:[UIColor whiteColor]];
    } else {
        [currentTimeLabel setTextColor:self.darkTextColor];
    }
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
        if(self.appDelegate.alarmIsPlaying) {
            [lblCurrentAMPM setTextColor:[UIColor whiteColor]];
        }
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
    
    if (self.music.volume <= 0.0) {
        [fader invalidate];
        if ([self.appDelegate.alarmClock sleepTime] != 0) {
            if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
                [[[AppDelegate rdioInstance] player] togglePause];
            } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
                [self.music pause];
            }
        }
        self.appDelegate.appBrightness = 0.0;
        [self.alarmTimeView setHidden:YES];
        [_chargingLabel removeFromSuperview];
    } else { 
        //float increment = (self.appDelegate.originalBrightness - 0.0)/(sleepTimeSeconds);
        //float newBrightness = [UIScreen mainScreen].brightness - increment;
        //[[UIScreen mainScreen] setBrightness:newBrightness];
        
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
            //float incrementScreen = (self.appDelegate.originalBrightness - 0.0)/100.0;
            //float newBrightness = [UIScreen mainScreen].brightness + incrementScreen;
            //[[UIScreen mainScreen] setBrightness:newBrightness];
            //self.appDelegate.appBrightness = newBrightness;
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
    
    if([self.appDelegate.alarmClock isShuffle]) {
        self.songsToPlay = [self.appDelegate.selectedPlaylist getShuffledTrackKeys];
    } else {
        self.songsToPlay = self.appDelegate.selectedPlaylist.trackKeys;
    }
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        [[[AppDelegate rdioInstance] player] playSources:self.songsToPlay];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        NSMutableArray *songsForPlaying = [[NSMutableArray alloc] init];
        for(int x = 0; x < self.songsToPlay.count; x++) {
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:[self.songsToPlay objectAtIndex:x] forProperty:MPMediaItemPropertyPersistentID];
            
            //finding songs for predicate
            MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
            [mySongQuery addFilterPredicate: predicate];
            [songsForPlaying addObject:[[mySongQuery items] objectAtIndex:0]];
        }
        
        [self.music setQueueWithItemCollection:[[MPMediaItemCollection alloc] initWithItems:songsForPlaying]];

        [self.music play];
    }
    
    wakeView = [[UIView alloc] initWithFrame:screenRect];
    [wakeView setBackgroundColor:[UIColor colorWithRed:241.0/255 green:147.0/255 blue:20.0/255 alpha:1.0]];
    
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    //[wakeView addGestureRecognizer:slideViewGesture];
    
    CGRect snoozeFrame = CGRectMake(40, self.view.frame.size.height - 210, 240, 80);
    UIButton *snoozeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [snoozeButton setFrame:snoozeFrame];
    
    [snoozeButton setTitle:NSLocalizedString(@"SNOOZE", nil) forState: UIControlStateNormal];
    //[snoozeButton setTintColor:[UIColor colorWithRed:241.0/255 green:147.0/255 blue:20.0/255 alpha:1.0]];
    
    [snoozeButton setTintColor:[UIColor whiteColor]];
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
    [self setupCurrentTimeView];
    //[self.appDelegate.currentWeather addObserver:self forKeyPath:@"isUpdated" options:NSKeyValueObservingOptionNew context:nil];
    //[self.appDelegate.currentWeather updateWeather];
    //[self setupCurrentWeatherView];
    [self.currentTimeView setHidden:NO];
    [wakeView addSubview:self.currentTimeView];
    //[wakeView addSubview:self.currentWeatherView];
    [self.view addSubview:wakeView];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //if([self.appDelegate.currentWeather conditions] != nil) {
    //    [self setupCurrentWeatherView];
    //}
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

- (void) startSnooze {
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        [[[AppDelegate rdioInstance] player] togglePause];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        [self.music pause];
    }
    
    [self setIsSnoozing:YES];
    
    int snoozeTimeSeconds = [self.appDelegate.alarmClock snoozeTime] * 60;
    [self.appDelegate.alarmClock setAlarmTime:[NSDate dateWithTimeIntervalSinceNow:snoozeTimeSeconds] save:NO];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [wakeView removeFromSuperview];
    self.appDelegate.alarmIsPlaying = NO;

    [self displaySleepScreen];
}

- (void) stopAlarm {
    self.appDelegate.alarmIsSet = NO;
    self.appDelegate.alarmIsPlaying = NO;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    [self.music setVolume:self.appDelegate.originalVolume];

    [[UIScreen mainScreen] setBrightness:self.appDelegate.originalBrightness];
    self.navigationController.navigationBarHidden = YES;

    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        [[[AppDelegate rdioInstance] player] stop];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        [self.music stop];
    }
    //[self determineStreamableSongs];
    //[[UIApplication sharedApplication] setIdleTimerDisabled:true];
    
    [self setIsSnoozing:NO];
    [self.appDelegate.alarmClock refreshAlarmTime];
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
    
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        self.lightTextColor = [UIColor colorWithRed:(122.0/255.0) green:(94.0/255.0) blue:(148.0/255.0) alpha:(1.0)];
        self.darkTextColor = [UIColor colorWithRed:(23.0/255.0) green:(16.0/255.0) blue:(30.0/255.0) alpha:(1.0)];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        self.lightTextColor = [UIColor colorWithRed:(17.0/255.0) green:(96.0/255.0) blue:(118.0/255.0) alpha:(1.0)];
        self.darkTextColor = [UIColor colorWithRed:(4.0/255.0) green:(26.0/255.0) blue:(32.0/255.0) alpha:(1.0)];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"org.Brunow.Wake-Up-to-the-Cloud"]) {
        self.lightTextColor = [UIColor colorWithRed:(17.0/255.0) green:(96.0/255.0) blue:(118.0/255.0) alpha:(1.0)];
        self.darkTextColor = [UIColor colorWithRed:(4.0/255.0) green:(26.0/255.0) blue:(32.0/255.0) alpha:(1.0)];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
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
    
    DHBAlarmSettingsView *settingsView = [[DHBAlarmSettingsView alloc] initWithFrame:fullScreen];
    [settingsView setLightTextColor:self.lightTextColor];
    [settingsView setDarkTextColor:self.darkTextColor];
    [settingsView setMyViewController:self];
    
    [self.view addSubview:settingsView];
    
    setAlarmView = [[UIView alloc] initWithFrame:fullScreen];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        if([[UIScreen mainScreen] bounds].size.height > 480) {
            [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
        } else {
            [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]]];
        }
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        if([[UIScreen mainScreen] bounds].size.height > 480) {
            [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Defaultblue-568h"]]];
        } else {
            [setAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Defaultblue"]]];
        }
    }
    
    
    CGRect setAlarmFrame = CGRectMake((self.view.frame.size.width - 240) / 2, self.view.frame.size.height - 150, 240, 50);
    setAlarmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [setAlarmButton setFrame:setAlarmFrame];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        [setAlarmButton setBackgroundImage:[UIImage imageNamed:@"btn-setalarm"] forState:UIControlStateNormal];
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        [setAlarmButton setBackgroundImage:[UIImage imageNamed:@"btn-setalarmblue"] forState:UIControlStateNormal];
        [setAlarmButton setBackgroundImage:[UIImage imageNamed:@"btn-setalarm-pressedblue"] forState:UIControlStateHighlighted];
    }
    [setAlarmButton setTitle:NSLocalizedString(@"SET ALARM", nil) forState: UIControlStateNormal];
    [setAlarmButton.titleLabel setAdjustsFontSizeToFitWidth:TRUE];
    [setAlarmButton addTarget:self action:@selector(setAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
    [setAlarmButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35.0]];
    [setAlarmButton setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [setAlarmButton setEnabled:NO];
    [setAlarmView addSubview:setAlarmButton];
    
    CGRect airPlayButtonFrame = CGRectMake((self.view.frame.size.width - 60), self.view.frame.size.height - 49, 44, 44);
    MPVolumeView *airPlayButton = [[MPVolumeView alloc] initWithFrame:airPlayButtonFrame];
    [airPlayButton setShowsVolumeSlider:NO];
    [airPlayButton setShowsRouteButton:YES];
    [airPlayButton setRouteButtonImage:[UIImage imageNamed:@"ic-airplay-dark"] forState:UIControlStateNormal];
    [airPlayButton setRouteButtonImage:[UIImage imageNamed:@"ic-airplay-light"] forState:UIControlStateSelected];

    [setAlarmView addSubview:airPlayButton];
    
    UILabel *toolbarAutoAMPM = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 235, 30)];
    if(![self.appDelegate.alarmClock is24h]) {
        [toolbarAutoAMPM setText:[NSLocalizedString(@"AUTOSET AM PM", nil) lowercaseString]];
    }
    [toolbarAutoAMPM setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [toolbarAutoAMPM setTextColor:self.darkTextColor];
    [toolbarAutoAMPM setBackgroundColor:[UIColor clearColor]];

    
    CGRect timeTextFrame = CGRectMake(10, 10, self.view.frame.size.width, 92);
    UIImage *timeTextBackground = [UIImage imageNamed:@"timeSetRoundedRect"];
    UIImageView *timeTextBackgroundView = [[UIImageView alloc] initWithImage:timeTextBackground];
    [timeTextBackgroundView setFrame:timeTextFrame];
    //[setAlarmView addSubview:timeTextBackgroundView];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    [doneButton setTintColor:self.lightTextColor];
    
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithCustomView:toolbarAutoAMPM],
                           doneButton,
                           nil];
    [numberToolbar sizeToFit];
    
    
    self.timeTextField = [[UITextField alloc] initWithFrame:timeTextFrame];
    [self.timeTextField setTintColor:self.lightTextColor];
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
    [self.timeTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
    NSString *timeTextString = [NSString stringWithFormat:@"%@",[self.appDelegate.alarmClock getAlarmTimeString] ];
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
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LOADING", nil) lowercaseString]] attributes:ats]];
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
    
    if ([self.appDelegate.rdioUser isLoggedIn]) {
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
        //[notLoggedInButton addTarget:self action:@selector(RdioSignUp) forControlEvents:UIControlEventTouchUpInside];

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
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        settingsButtonImage = [UIImage imageNamed:@"icon-settingsblue"];
    }
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
    
    NSDictionary *atsBig = @{
                             NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:92.0],
                             NSParagraphStyleAttributeName : paragraphStyle
                             };
    
    NSDictionary *atsSmall = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0],
                               NSParagraphStyleAttributeName : paragraphStyle
                               };
    
    if ([self.appDelegate.alarmClock isAutoStart] && self.appDelegate.alarmClock.alarmTime != nil && self.appDelegate.selectedPlaylist != nil && self.appDelegate.selectedPlaylist.playlistName != nil && [self.appDelegate.rdioUser isLoggedIn]) {
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
        
        if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
            if([[UIScreen mainScreen] bounds].size.height > 480) {
                [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
            } else {
                [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]]];
            }
        } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
            if([[UIScreen mainScreen] bounds].size.height > 480) {
                [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Defaultblue-568h"]]];
            } else {
                [autoStartAlarmView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Defaultblue"]]];
            }
        }
        
        UILabel *autoStartAlarmViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -20, [[UIScreen mainScreen] bounds].size.width, 45)];
        [autoStartAlarmViewLabel setBackgroundColor:[UIColor clearColor]];
        [autoStartAlarmViewLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        [autoStartAlarmViewLabel setAttributedText:[[NSAttributedString alloc] initWithString:[[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM BEING SET", nil)] uppercaseString] attributes:atsSmall]];
        [autoStartAlarmViewLabel setNumberOfLines:0];
        [autoStartAlarmViewLabel setTextColor:self.darkTextColor];
        [autoStartAlarmView addSubview:autoStartAlarmViewLabel];
        
        UILabel *lblAutoSetPlaylist = [[UILabel alloc] initWithFrame:CGRectMake(10, 106,[[UIScreen mainScreen] bounds].size.width, 45)];
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
        
        self.lblAutoSetPlaylistName = [[UILabel alloc] initWithFrame:CGRectMake(10, 154.0, [[UIScreen mainScreen] bounds].size.width - 20, 200.0)];
        [self.lblAutoSetPlaylistName setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [NSString stringWithFormat:@"%@", [NSLocalizedString(@"LOADING", nil) lowercaseString]]] attributes:ats]];
        [self.lblAutoSetPlaylistName setTextColor:self.lightTextColor];
        [self.lblAutoSetPlaylistName setBackgroundColor:[UIColor clearColor]];
        if (self.view.frame.size.height > 480) {
            [self.lblAutoSetPlaylistName setNumberOfLines:4];
        } else {
            [self.lblAutoSetPlaylistName setNumberOfLines:3];
        }
        [self.lblAutoSetPlaylistName sizeToFit];
        [self.lblAutoSetPlaylistName setContentMode:UIViewContentModeTop];
        [autoStartAlarmView addSubview:self.lblAutoSetPlaylistName];
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

-(void) hideVolumeView
{
    self.hideVolume = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, 0, 10, 0)];
    [self.hideVolume sizeToFit];
}

-(void) doneWithNumberPad
{
    [self.timeTextField resignFirstResponder];
}

-(void) showPlaylists
{
    self.listsViewController = [[ListsViewController alloc] init];
    [self.listsViewController setLightTextColor:self.lightTextColor];
    [self.listsViewController setDarkTextColor:self.darkTextColor];
    [self.listsViewController setPlaylistType:@"Alarm"];
    
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

- (void) loadPlaylistName
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:50.0],
                          NSParagraphStyleAttributeName : paragraphStyle
                          };
    
    if(self.appDelegate.selectedPlaylist != nil && self.appDelegate.selectedPlaylist.playlistName != nil) {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [[self.appDelegate.selectedPlaylist playlistName] lowercaseString]] attributes:ats]];
        [self.lblAutoSetPlaylistName setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [[self.appDelegate.selectedPlaylist playlistName] lowercaseString]] attributes:ats]];
    } else {
        [self.lblPlaylist setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [NSLocalizedString(@"CHOOSE PLAYLIST", nil) lowercaseString]] attributes:ats]];
        [self.lblAutoSetPlaylistName setAttributedText:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n", [NSLocalizedString(@"CHOOSE PLAYLIST", nil) lowercaseString]] attributes:ats]];
    }
    
    
    
    CGRect frame = CGRectMake(10, 154.0, 300.0, 200.0);
    [self.lblPlaylist setFrame:frame];
    [self.lblPlaylist sizeToFit];
    frame.size.height = self.lblPlaylist.frame.size.height;
    [self.lblPlaylist setFrame:frame];
        
    [self.lblAutoSetPlaylistName setFrame:frame];
    [self.lblAutoSetPlaylistName sizeToFit];
    frame.size.height = self.lblAutoSetPlaylistName.frame.size.height;
    [self.lblAutoSetPlaylistName setFrame:frame];
    
    [self testToEnableAlarmButton];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPlaylistName) name:@"Playlist Found" object:nil];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        if(self.appDelegate.selectedPlaylist != nil) {
            [self loadPlaylistName];
        }
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        [self loadPlaylistName];
    }
    
    [self setIsSnoozing:NO];
}

- (void) testToEnableAlarmButton
{
    if (self.appDelegate.selectedPlaylist.trackKeys != nil && self.timeTextField.text.length == 5) {
        [setAlarmButton setEnabled:YES];
    } else {
        [setAlarmButton setEnabled:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    [self getAlarmTime];
    [self testToEnableAlarmButton];
    [self setAMPMLabel];
    _lastLength = textField.text.length;
}

- (void) updateTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"ss"];
    
    if ([[formatter stringFromDate:[NSDate date]] isEqualToString:@"00"]) {
        [self setupCurrentTimeView];
    }
}

- (void) tick
{
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

- (void)rdioRequest:(RDPlayer *)request didFailWithError:(NSError *)error andSourceKeys:keys
{
    NSLog(@"Hi! I am the RDPlayer error handler :)");
}

@end
