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
    [timeTextField resignFirstResponder];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
   
    NSString *tempDateString = [formatter stringFromDate:[NSDate date]];    
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"]; //still using military time - need to change to civilian
    tempDateString = [NSString stringWithFormat:@"%@T%@", tempDateString, timeTextField.text];
    appDelegate.alarmTime = [formatter dateFromString:tempDateString];
    if ([appDelegate.alarmTime earlierDate:[NSDate date]]==appDelegate.alarmTime) {
        appDelegate.alarmTime = [appDelegate.alarmTime dateByAddingTimeInterval:86400];
    }
    NSLog(@"%@", appDelegate.alarmTime);
    //alarmTime = [[NSDate date] dateFromString:@"2012-03-23T11:45:00.000000"];

    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    self.navigationController.navigationBarHidden = YES;
    
    [self displaySleepScreen];
    awake = [[MMPDeepSleepPreventer alloc] init];
    [awake startPreventSleep];

}

- (void) displaySleepScreen {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = YES;
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, 480.0);
    CGRect labelRect = CGRectMake(40.0, 200.0, 240.0, 50.0);
    
    NSString *alarmTimeText = [[NSString alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm"];
    alarmTimeText = [formatter stringFromDate:appDelegate.alarmTime];
    
    sleepView = [[UIView alloc] initWithFrame:screenRect];
    [sleepView setBackgroundColor:[UIColor blackColor]];
    UILabel *sleepLabel = [[UILabel alloc] initWithFrame:labelRect];
    [sleepLabel setText:[NSString stringWithFormat:@"please sleep peacefully. You will wake up to music at %@.", alarmTimeText]];
    [sleepLabel setTextColor:[UIColor grayColor]];
    [sleepLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [sleepLabel setBackgroundColor:[UIColor blackColor]];
    [sleepLabel setNumberOfLines:10];
    [sleepView addSubview:sleepLabel];
    [self.view addSubview:sleepView]; 
    [[UIScreen mainScreen] setBrightness:0.0];
    appDelegate.appBrightness = 0.0;
}

- (void) alarmSounding {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.alarmIsSet = NO;
    [awake stopPreventSleep];
    [[UIScreen mainScreen] setBrightness:appDelegate.originalBrightness];
    appDelegate.appBrightness = originalBrightness;
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, 480.0);
    [sleepView removeFromSuperview];
    [[[AppDelegate rdioInstance] player] playSource:@"t5732462"];
    
    wakeView = [[UIView alloc] initWithFrame:screenRect];
    
    CGRect snoozeFrame = CGRectMake(100, 140, 120, 30);
    UIButton *snoozeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [snoozeButton setFrame:snoozeFrame];
    
    [snoozeButton setTitle:@"Snooze" forState: UIControlStateNormal];
    [snoozeButton setBackgroundColor:[UIColor clearColor]];
    [snoozeButton addTarget:self action:@selector(startSnooze) forControlEvents:UIControlEventTouchUpInside];
    [wakeView addSubview:snoozeButton];
    
    CGRect offFrame = CGRectMake(100, 190, 120, 30);
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [offButton setFrame:offFrame];
    
    [offButton setTitle:@"Off" forState: UIControlStateNormal];
    [offButton setBackgroundColor:[UIColor clearColor]];
    [offButton addTarget:self action:@selector(stopAlarm) forControlEvents:UIControlEventTouchUpInside];
    [wakeView addSubview:offButton];
    [self.view addSubview:wakeView];
}

- (void) startSnooze {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [awake startPreventSleep];
    [[[AppDelegate rdioInstance] player] stop];
    
    int snoozeTime = 60;
    
    appDelegate.alarmTime = [NSDate dateWithTimeIntervalSinceNow:snoozeTime];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self displaySleepScreen];
}

- (void) stopAlarm {
    self.navigationController.navigationBarHidden = NO;
    [[[AppDelegate rdioInstance] player] stop];
    [wakeView removeFromSuperview];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    CGRect fullScreen = CGRectMake(0.0, 0.0, 320.0, 480.0);
    
    setAlarmView = [[UIView alloc] initWithFrame:fullScreen];
    
    CGRect setAlarmFrame = CGRectMake(100, 140, 120, 30);
    UIButton *setAlarmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [setAlarmButton setFrame:setAlarmFrame];
    
    [setAlarmButton setTitle:@"Set Alarm" forState: UIControlStateNormal];
    [setAlarmButton setBackgroundColor:[UIColor clearColor]];
    [setAlarmButton addTarget:self action:@selector(setAlarmClicked) forControlEvents:UIControlEventTouchUpInside];
    [setAlarmView addSubview:setAlarmButton];
    
    CGRect timeTextFrame = CGRectMake(100.0, 100, 120, 30);
    timeTextField = [[UITextField alloc] initWithFrame:timeTextFrame];
    //[timeTextField setDelegate:self];
    [timeTextField setBackgroundColor:[UIColor blackColor]];
    [timeTextField setTextAlignment:UITextAlignmentCenter];
    [timeTextField setTextColor:[UIColor whiteColor]];
    [timeTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [setAlarmView addSubview:timeTextField];
    
    [self.view addSubview:setAlarmView];
    //UILocalNotification *alarmTime = [[UILocalNotification alloc] init];
    
    //alarmTime.fireDate = [NSDate dateWithTimeIntervalSinceNow:50];
    //NSLog(@"alarm will go off: %@", alarmTime.fireDate);
    //alarmTime.timeZone = [NSTimeZone systemTimeZone];
    
    //alarmTime.alertBody = @"Did you forget something?";
    //alarmTime.alertAction = @"Show me";
    //alarmTime.soundName = UILocalNotificationDefaultSoundName;
    
    //[[UIApplication sharedApplication] scheduleLocalNotification:alarmTime];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playClicked) name:@"alarmUp" object:nil];
    //[alarmTime performSelector:@selector(playClicked)];
    
    if(appDelegate.loggedIn) {
        NSLog(@"Got here!");        
        NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"trackKeys", @"extras", nil];
        [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:trackInfo delegate:self];
    }
    
    //t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    NSLog(@"Timer set!");
    //originalBrightness = [UIScreen mainScreen].brightness;

    //MPMusicPlayerController *musicPlayer = [[MPMusicPlayerController iPodMusicPlayer];
    
    //originalVolume = [[UIDevice currentDevice] ];
    //[[UIScreen mainScreen] setBrightness:0.0];
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
    if([method isEqualToString:@"getHeavyRotation"]) {
        if(playlists != nil) {
            playlists = nil;
        }
        playlists = [[NSMutableArray alloc] initWithArray:data];
        playlists = data;
        //[self getTrackKeysForAlbums];
    }
    else if([method isEqualToString:@"getPlaylists"]) {
        // we are returned a dictionary but it will be easier to work with an array
        // for our needs
        playlists = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for(NSString *key in [data allKeys]) {
            [playlists addObject:[data objectForKey:key]];
            NSLog(@"playlist added: %@", [data objectForKey:key]);
        }
        //[self loadAlbumChoices];
    }
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    
}

@end
