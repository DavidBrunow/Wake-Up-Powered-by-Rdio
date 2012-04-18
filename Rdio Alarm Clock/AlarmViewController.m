//
//  MainViewController.m
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmViewController.h"
#import "AppDelegate.h"
#import "SimpleKeychain.h"
#import <Rdio/Rdio.h>

@implementation MainViewController

@synthesize player, playButton;

-(RDPlayer*)getPlayer
{
    if (player == nil) {
        player = [AppDelegate rdioInstance].player;
    }
    return player;
}

- (void) setAlarmClicked {
    NSRange colonRange = NSRangeFromString(@"2,1");
    
    if (timeTextField.text.length == 4 && [[timeTextField.text substringWithRange:colonRange] isEqualToString:@":"]) {
        timeTextField.text = [timeTextField.text stringByReplacingOccurrencesOfString:@":" withString:@""];
        timeTextField.text = [NSString stringWithFormat:@"%@:%@", [timeTextField.text substringToIndex:1], [timeTextField.text substringFromIndex:1]];
        NSLog(@"newtime: %@", timeTextField.text);
    }
    
    NSString *tempTimeString = timeTextField.text;
    tempTimeString = [NSString stringWithFormat:@"%@ AM", tempTimeString];
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Set alarm for %@?", tempTimeString] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    //[alert show];
    [self setAlarm];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        
    } else {
        [self setAlarm];
    }
}

- (void) setAlarm {
    [timeTextField resignFirstResponder];
    //[timeTextField removeFromSuperview];
    //[remindMe removeFromSuperview];
    //[setAlarmView removeFromSuperview];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *tempTimeString = @"";
    if (timeTextField.text.length == 4) {
        tempTimeString = [NSString stringWithFormat:@"0%@", timeTextField.text];
    } else {
        tempTimeString = timeTextField.text;
    }
   
    NSString *tempDateString = [formatter stringFromDate:[NSDate date]];    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];

    tempDateString = [NSString stringWithFormat:@"%@T%@", tempDateString, tempTimeString];
    appDelegate.alarmTime = [formatter dateFromString:tempDateString];
    
    if ([appDelegate.alarmTime earlierDate:[NSDate date]]==appDelegate.alarmTime) {
        appDelegate.alarmTime = [appDelegate.alarmTime dateByAddingTimeInterval:43200];
        if ([appDelegate.alarmTime earlierDate:[NSDate date]]==appDelegate.alarmTime) {
            appDelegate.alarmTime = [appDelegate.alarmTime dateByAddingTimeInterval:43200];
        }
    }
    
    NSLog(@"alarm time: %@", appDelegate.alarmTime);
    
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
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, 480.0);
    CGRect sleepLabelRect = CGRectMake(40.0, 200.0, 240.0, 50.0);
    CGRect alarmLabelRect = CGRectMake(40.0, 150.0, 240.0, 50.0);
    
    NSString *alarmTimeText = [[NSString alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    alarmTimeText = [formatter stringFromDate:appDelegate.alarmTime];
    
    sleepView = [[UIView alloc] initWithFrame:screenRect];
    
    //[sleepView gestureRecognizers];
    UIPanGestureRecognizer *slideViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    //[sleepView addGestureRecognizer:slideViewGesture];
    //[sleepView 
    [sleepView setBackgroundColor:[UIColor blackColor]];
    UILabel *sleepLabel = [[UILabel alloc] initWithFrame:sleepLabelRect];
    [sleepLabel setText:[NSString stringWithFormat:@"please rest peacefully"]];
    [sleepLabel setTextColor:[UIColor grayColor]];
    [sleepLabel setFont:[UIFont fontWithName:@"Helvetica" size:22.0]];
    [sleepLabel setBackgroundColor:[UIColor blackColor]];
    [sleepLabel setNumberOfLines:10];
    [sleepView addSubview:sleepLabel];
    
    _alarmLabel = [[UILabel alloc] initWithFrame:alarmLabelRect];
    [_alarmLabel setText:[NSString stringWithFormat:@"your alarm is set for %@", alarmTimeText]];
    [_alarmLabel setTextColor:[UIColor grayColor]];
    [_alarmLabel setFont:[UIFont fontWithName:@"Helvetica" size:22.0]];
    [_alarmLabel setBackgroundColor:[UIColor blackColor]];
    [_alarmLabel setNumberOfLines:10];
    [sleepView addSubview:_alarmLabel];
    
    CGRect cancelFrame = CGRectMake(261, 421, 49, 49);
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:cancelFrame];
    
    UIImage *cancelButtonImage = [UIImage imageNamed:@"x"];
    
    [cancelButton setBackgroundColor:[UIColor blackColor]];
    [cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor blackColor]];
    [cancelButton setAccessibilityLabel:@"Cancel Alarm"];
    //[cancelButton addTarget:self action:@selector(cancelAlarm) forControlEvents:UIControlEventTouchUpInside];
    //[cancelButton addTarget:self action:@selector(slideViewUp) forControlEvents:UIControlEventTouchDragInside];
    [cancelButton addGestureRecognizer:slideViewGesture];
    [cancelButton addTarget:self action:@selector(bounceView) forControlEvents:UIControlEventTouchUpInside];
    
    //[cancelButton setEnabled:NO];
    [sleepView addSubview:cancelButton]; 
    
    [self.view addSubview:sleepView]; 
    
    [fader invalidate];
    fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenOut) userInfo:nil repeats:YES]; 
    
    MPMusicPlayerController *music = [[MPMusicPlayerController alloc] init];
    appDelegate.originalVolume = music.volume;
    //[music setVolume:0.0];
    //[[UIScreen mainScreen] setBrightness:0.0];
    //appDelegate.appBrightness = 0.0;
}

- (void) handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:sender.view.superview];
    
    CGRect newFrame = CGRectMake(0.0, 0.0, 320, 480);

    newFrame.origin.y += (translate.y);
    sender.view.superview.frame = newFrame;
        
         
    //}
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (translate.y < -100.0) {
            [UIView animateWithDuration:0.3 animations:^{[sender.view.superview setFrame:CGRectMake(0.0, -480, 320, 480)];} completion:^(BOOL finished){[sender.view.superview removeFromSuperview];[self cancelAlarm];}];
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
    
    if ([UIScreen mainScreen].brightness <= 0.0) {
        [fader invalidate];
        appDelegate.appBrightness = 0.0;
        [_alarmLabel removeFromSuperview];
    } else {
        float increment = (appDelegate.originalBrightness - 0.0)/100.0;
        float newBrightness = [UIScreen mainScreen].brightness - increment;
        [[UIScreen mainScreen] setBrightness:newBrightness];
        
        float incrementVolume = (appDelegate.originalVolume - 0.0)/100.0;
        float newVolume = music.volume - incrementVolume;
        [music setVolume:newVolume];
        appDelegate.appVolume = newVolume;
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
            [music setVolume:newVolume];
            appDelegate.appVolume = newVolume;
        }
    }
}

- (void) alarmSounding {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = NO;
    [fader invalidate];
    fader = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeScreenIn) userInfo:nil repeats:YES];
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, 480.0);
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
    
    [snoozeButton setTitle:@"Snooze" forState: UIControlStateNormal];
    [snoozeButton setTintColor:[UIColor redColor]];
    [snoozeButton setBackgroundColor:[UIColor clearColor]];
    [snoozeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:58.0]];
    [snoozeButton.titleLabel setTextColor:[UIColor blackColor]];
    [snoozeButton addTarget:self action:@selector(startSnooze) forControlEvents:UIControlEventTouchUpInside];
    [wakeView addSubview:snoozeButton];
    
    CGRect offFrame = CGRectMake(261, 421, 49, 49);
    UIImage *offButtonImage = [UIImage imageNamed:@"orangex"];
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [offButton setImage:offButtonImage forState:UIControlStateNormal];
    [offButton setAccessibilityLabel:@"Turn Off Alarm"];
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
    
    CGRect bounceUpFrameFirst = CGRectMake(0.0, -30.0, 320.0, 480.0);
    CGRect bounceUpFrameSecond = CGRectMake(0.0, -15.0, 320.0, 480.0);
    CGRect bounceUpFrameThird = CGRectMake(0.0, -10.0, 320.0, 480.0);
    CGRect bounceDownFrame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    
    [UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameFirst]; [sleepView setFrame:bounceUpFrameFirst];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameSecond]; [sleepView setFrame:bounceUpFrameSecond];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceUpFrameThird]; [sleepView setFrame:bounceUpFrameThird];} completion:^(BOOL finished){[UIView animateWithDuration:0.1 animations:^{[wakeView setFrame:bounceDownFrame]; [sleepView setFrame:bounceDownFrame];}];}];}];}];}];}];
    
    if (UIAccessibilityIsVoiceOverRunning())
    {
        if (appDelegate.alarmIsSet) {
            [sleepView removeFromSuperview];
            [self cancelAlarm];
            [self setAccessibilityLabel:@"Alarm Canceled"]; 
        } else {
            [wakeView removeFromSuperview];
            [self stopAlarm];
            [self setAccessibilityLabel:@"Alarm Stopped"]; 
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
        if ([_canBeStreamed objectAtIndex:listIndex] == @"YES") {
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

- (void) startSnooze {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //double currentPosition = [[AppDelegate rdioInstance] player].position; 
    [[[AppDelegate rdioInstance] player] togglePause];
    
    int snoozeTime = 540; //9 minutes
    snoozeTime = 900; //15 minutes
    
    appDelegate.alarmTime = [NSDate dateWithTimeIntervalSinceNow:snoozeTime];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [wakeView removeFromSuperview];
    [self displaySleepScreen];
}

- (void) stopAlarm {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = NO;
    self.navigationController.navigationBarHidden = NO;
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBounds:[[UIScreen mainScreen] bounds]];
    //[self.view setBackgroundColor:[UIColor whiteColor]];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    listsViewController = [[ListsViewController alloc] init];
    
    CGRect fullScreen = CGRectMake(0.0, 0.0, 320.0, 480.0);
    
    setAlarmView = [[UIView alloc] initWithFrame:fullScreen];
    [setAlarmView setBackgroundColor:[UIColor colorWithRed:68.0/255 green:11.0/255 blue:104.0/255 alpha:1.0]];
    
    CGRect setAlarmFrame = CGRectMake(40, 165, 240, 50);
    setAlarmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setAlarmButton setFrame:setAlarmFrame];
    
    [setAlarmButton setTitle:@"Set Alarm" forState: UIControlStateNormal];
    [setAlarmButton setBackgroundColor:[UIColor clearColor]];
    [setAlarmButton addTarget:self action:@selector(setAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
    [setAlarmButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:42.0]];
    [setAlarmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [setAlarmButton setEnabled:NO];
    [setAlarmView addSubview:setAlarmButton];
    
    /*
     CGRect remindMeFrame = CGRectMake(40.0, 180.0, 120, 30);
     remindMe = [[UISwitch alloc] initWithFrame:remindMeFrame];
     [remindMe setOn:YES animated:YES];
     [setAlarmView addSubview:remindMe]; */
    
    CGRect timeTextFrame = CGRectMake(40.0, 87, 240, 60);
    UIImage *timeTextBackground = [UIImage imageNamed:@"timeSetRoundedRect"];
    UIImageView *timeTextBackgroundView = [[UIImageView alloc] initWithImage:timeTextBackground];
    [timeTextBackgroundView setFrame:timeTextFrame];
    [setAlarmView addSubview:timeTextBackgroundView];
    
    timeTextField = [[UITextField alloc] initWithFrame:timeTextFrame];
    [timeTextField setDelegate:self];
    [timeTextField setBackgroundColor:[UIColor clearColor]];
    [timeTextField setTextAlignment:UITextAlignmentCenter];
    [timeTextField setTextColor:[UIColor whiteColor]];
    [timeTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [timeTextField setFont:[UIFont fontWithName:@"Helvetica" size:48.0]];
    [timeTextField setContentMode:UIViewContentModeScaleToFill];
    [timeTextField setAccessibilityLabel:@"Choose Alarm Time"];
    [timeTextField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    [timeTextField setPlaceholder:@":"];
    [setAlarmView addSubview:timeTextField];
    
    CGRect chooseMusicFrame = CGRectMake(30.0, 15.0, 260.0, 100.0);
    _chooseMusic = [[UITableView alloc] initWithFrame:chooseMusicFrame style:UITableViewStyleGrouped];
    [_chooseMusic setScrollEnabled:NO];
    [_chooseMusic setBackgroundColor:[UIColor clearColor]];
    [_chooseMusic setDelegate:self];
    [_chooseMusic setDataSource:self];
    
    if (appDelegate.loggedIn) {
        [setAlarmView addSubview:_chooseMusic];
    } else {
        CGRect notLoggedInLabelFrame = CGRectMake(40.0, -5.0, 240.0, 100.0);
        UIButton *notLoggedInButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [notLoggedInButton setFrame:notLoggedInLabelFrame];
        [notLoggedInButton setTitle:@"To wake up to full tracks from your playlists, you must sign into Rdio®. Not yet an Rdio user? \nTap here for more information." forState:UIControlStateNormal];
        [notLoggedInButton setBackgroundColor:[UIColor clearColor]];
        [notLoggedInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [notLoggedInButton.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [notLoggedInButton.titleLabel setNumberOfLines:0];        
        [notLoggedInButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
        [notLoggedInButton.titleLabel setTextAlignment:UITextAlignmentCenter];
        [notLoggedInButton addTarget:self action:@selector(RdioSignUp) forControlEvents:UIControlEventTouchUpInside];
        
        [setAlarmView addSubview:notLoggedInButton];
    }
    
    /* This is supposed to hide the volume controls, but has a problem where the controls are initially shown when this view is added.
    MPVolumeView *hideVolume = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    [hideVolume setHidden:YES];
    [hideVolume setAlpha:0.0];
    [hideVolume setShowsVolumeSlider:NO];
    [hideVolume setShowsRouteButton:NO];
    
    [self.view addSubview:hideVolume];
     */
    
    [self.view addSubview:setAlarmView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.loggedIn) {
        [_chooseMusic reloadData];
    }
    
    if(playlists == nil) {
        if(appDelegate.loggedIn) {
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"trackKeys", @"extras", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:trackInfo delegate:self];
            _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
            [_loadingView setBackgroundColor:[UIColor blackColor]];
            [_loadingView setAlpha:0.9];
            UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [aiView setCenter:CGPointMake(160, 200)];
            [aiView startAnimating];
            UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 200.0, 120.0, 100.0)];
            [loadingLabel setText:@"Loading..."];
            [loadingLabel setBackgroundColor:[UIColor clearColor]];
            [loadingLabel setTextColor:[UIColor whiteColor]];
            [loadingLabel setFont:[UIFont fontWithName:@"Helvetica" size:24.0]];
            [loadingLabel setTextAlignment:UITextAlignmentCenter];
            [_loadingView addSubview:loadingLabel];
            [_loadingView addSubview:aiView];
            [self.view addSubview:_loadingView];
        } else {
            //choose songs from top songs chart
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Track", @"type", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getTopCharts" withParameters:trackInfo delegate:self];
            //[self loadSongs]; //just a test to see if "get" works since "getTopCharts" doesn't
        }
    } else {
        [self loadSongs];
    }
    
    //[self determineStreamableSongs];
    
    NSString *firstChar = @"";
    NSString *secondChar = @"";
    NSString *thirdChar = @"";
    NSString *fourthChar = @"";
    
    if (timeTextField.text.length > 0) {
        firstChar = [timeTextField.text substringToIndex:1];
    }
    
    NSRange secondCharRange = NSRangeFromString(@"1,1");
    //NSLog(@"%@", secondCharRange);
    if (timeTextField.text.length > 1) {
        secondChar = [timeTextField.text substringWithRange:secondCharRange];
        if ([secondChar isEqualToString:@":"]) {
            //pastColon = YES;
        }
    }
    
    NSRange thirdCharRange = NSRangeFromString(@"2,1");
    if (timeTextField.text.length > 2) {
        thirdChar = [timeTextField.text substringWithRange:thirdCharRange];
    }
    
    NSRange fourthCharRange = NSRangeFromString(@"3,1");
    if (timeTextField.text.length > 3) {
        fourthChar = [timeTextField.text substringWithRange:fourthCharRange];
    }
    
    if (songsToPlay != nil && timeTextField.text.length == 5 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"])) {
        [setAlarmButton setEnabled:YES];
    } else if (songsToPlay != nil && timeTextField.text.length == 4 ) {
        [setAlarmButton setEnabled:YES];
    } else {
        [setAlarmButton setEnabled:NO];
    }

    //songsToPlay = [self shuffle:songsToPlay];
}

- (void) determineStreamableSongs 
{
    songsToPlay = [self removeDuplicatesInPlaylist:songsToPlay];
    _canBeStreamed = [[NSMutableArray alloc] initWithCapacity:songsToPlay.count];
    NSString *songsToPlayString = [songsToPlay objectAtIndex:0];
    for (int x = 1; x < songsToPlay.count; x++) {
        songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [songsToPlay objectAtIndex:x]];
    }
    NSLog(@"string: %@", songsToPlayString);
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

    CGRect webViewRect = CGRectMake(0.0, 0.0, 320.0, 480.0);
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
    
    if (appDelegate.selectedPlaylist != nil) {
        [cell setAccessibilityLabel:[NSString stringWithFormat:@"Selected Playlist is %@", appDelegate.selectedPlaylist]];
        cell.textLabel.text = appDelegate.selectedPlaylist;
    } else {
        cell.textLabel.text = @"Choose Playlist...";
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
    
    [self.navigationController pushViewController:listsViewController animated:YES];
}

- (void) textFieldValueChange:(UITextField *) textField
{
    static BOOL toggle = NO;
    static BOOL pastColon = NO;
    NSString *firstChar = @"";
    NSString *secondChar = @"";
    NSString *thirdChar = @"";
    NSString *fourthChar = @"";
    
    if (textField.text.length > 0) {
        firstChar = [textField.text substringToIndex:1];
    }
    
    NSRange secondCharRange = NSRangeFromString(@"1,1");
    //NSLog(@"%@", secondCharRange);
    if (textField.text.length > 1) {
        secondChar = [textField.text substringWithRange:secondCharRange];
        if ([secondChar isEqualToString:@":"]) {
            pastColon = YES;
        }
    }
    
    NSRange thirdCharRange = NSRangeFromString(@"2,1");
    if (textField.text.length > 2) {
        thirdChar = [textField.text substringWithRange:thirdCharRange];
    }
    
    NSRange fourthCharRange = NSRangeFromString(@"3,1");
    if (textField.text.length > 3) {
        fourthChar = [textField.text substringWithRange:fourthCharRange];
    }
        
    /*NSLog(@"got here!");
    NSLog(@"textfield: %@", textField.text);
    NSLog(@"length: %d", textField.text.length);
    NSLog(@"pastColon: %d", pastColon);
    NSLog(@"firstChar: %@", firstChar);
    NSLog(@"secondChar: %@", secondChar);
    NSLog(@"enabled? %d", setAlarmButton.enabled);
    NSLog(@"thirdChar: %@", thirdChar);*/
    
    if (songsToPlay != nil && textField.text.length == 5 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"])) {
        [setAlarmButton setEnabled:YES];
    } else if (songsToPlay != nil && textField.text.length == 4 ) {
        [setAlarmButton setEnabled:YES];
    } else {
        [setAlarmButton setEnabled:NO];
    }
    
    if (toggle) {
        toggle = NO;
        return;
    }
    
    toggle = YES;
    
    if (textField.text.length > 5 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"])) {
        textField.text = [textField.text substringToIndex:5];
    } else if (textField.text.length > 3 && [firstChar isEqualToString:@"1"] && !([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"])) {
        textField.text = [textField.text substringToIndex:4];
    } else if (textField.text.length > 3 && ![firstChar isEqualToString:@"1"]) {
        textField.text = [textField.text substringToIndex:4];
    } else if ([textField.text isEqualToString:@"1"]) {
        [textField setText:[NSString stringWithFormat:@"%@", textField.text]];
        pastColon = NO;
    } else if (textField.text.length == 2 && [firstChar isEqualToString:@"1"] && pastColon) {
        [textField setText:@"1"];
        pastColon = NO;
    } else if (textField.text.length == 2 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"])) {
        [textField setText:[NSString stringWithFormat:@"%@:", textField.text]];
        pastColon = YES;
    } else if (textField.text.length == 2 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"3"] || [secondChar isEqualToString:@"4"] || [secondChar isEqualToString:@"5"])) {
        [textField setText:[NSString stringWithFormat:@"%@:%@", firstChar, secondChar]];
        pastColon = YES;
    }  else if (textField.text.length == 2 && [firstChar isEqualToString:@"1"] && ([secondChar isEqualToString:@"6"] || [secondChar isEqualToString:@"7"] || [secondChar isEqualToString:@"8"] || [secondChar isEqualToString:@"9"])) {
        textField.text = [textField.text substringToIndex:1];
    } else if (![textField.text isEqualToString:@"1"] && pastColon && textField.text.length == 1) {
        [textField setText:@""];
        pastColon = NO;
    } else if (![textField.text isEqualToString:@"1"] && textField.text.length == 1) {
        [textField setText:[NSString stringWithFormat:@"%@:", textField.text]];
        pastColon = YES;
    } else if (textField.text.length == 3 && !([thirdChar isEqualToString:@"0"] || [thirdChar isEqualToString:@"1"] || [thirdChar isEqualToString:@"2"] || [thirdChar isEqualToString:@"3"] || [thirdChar isEqualToString:@"4"] || [thirdChar isEqualToString:@"5"] || [thirdChar isEqualToString:@":"])) {
        textField.text = [textField.text substringToIndex:2];
    } else if (textField.text.length == 2 && !([secondChar isEqualToString:@"0"] || [secondChar isEqualToString:@"1"] || [secondChar isEqualToString:@"2"] || [secondChar isEqualToString:@"3"] || [secondChar isEqualToString:@"4"] || [secondChar isEqualToString:@"5"] || [secondChar isEqualToString:@":"])) {
        textField.text = [textField.text substringToIndex:1];
    } else if (pastColon && textField.text.length == 1) {
        [textField setText:@""];
        pastColon = NO;
    } else if (textField.text.length == 1) {
        pastColon = NO;
    } else if (textField.text.length == 0) {
        [textField setText:@""];
        pastColon = NO;
    }
}

- (void) tick
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"current time: %@ & alarm time: %@", [NSDate date], appDelegate.alarmTime);
    
    NSDate *now = [NSDate date];
    
    if([appDelegate.alarmTime isEqualToDate:([appDelegate.alarmTime earlierDate:now])] && !playing)
    {
        [self alarmSounding];
        [t invalidate];
    }

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
        appDelegate.typesInfo = [[NSMutableArray alloc] initWithCapacity:(1000)];
        appDelegate.playlistsInfo = [[NSMutableArray alloc] initWithCapacity:(1000)];
        appDelegate.tracksInfo = [[NSMutableArray alloc] initWithCapacity:(1000)];
        
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

    if (appDelegate.selectedPlaylistPath != nil) {
        songsToPlay = [[NSMutableArray alloc] initWithArray:[[[playlists objectAtIndex:appDelegate.selectedPlaylistPath.section] objectAtIndex:appDelegate.selectedPlaylistPath.row] objectForKey:@"trackKeys"]];
        NSLog(@"section selected: %d, row selected: %d", appDelegate.selectedPlaylistPath.section, appDelegate.selectedPlaylistPath.row);
        songsToPlay = [[[playlists objectAtIndex:appDelegate.selectedPlaylistPath.section] objectAtIndex:appDelegate.selectedPlaylistPath.row] objectForKey:@"trackKeys"];
    } /* else {
        songsToPlay = [[NSMutableArray alloc] initWithArray:[[[playlists objectAtIndex:1] objectAtIndex:1] objectForKey:@"trackKeys"]];
        songsToPlay = [[[playlists objectAtIndex:1] objectAtIndex:1] objectForKey:@"trackKeys"];
    } */
    [self determineStreamableSongs];
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    
}

@end
