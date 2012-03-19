//
//  MainViewController.m
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "SimpleKeychain.h"
#import <Rdio/Rdio.h>

@implementation MainViewController

@synthesize player, loginButton, playButton;

-(RDPlayer*)getPlayer
{
    if (player == nil) {
        player = [AppDelegate rdioInstance].player;
    }
    return player;
}

- (void) playClicked {
    if (!playing) {
        NSArray* keys = [@"t2742133,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        [[self getPlayer] playSources:keys];
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
        playing = true;
        paused = false;
    } else {
        [[self getPlayer] togglePause];
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
        playing = false;
        paused = true;
    }
}

- (void) loginClicked {
    if (loggedIn) {
        [[AppDelegate rdioInstance] logout];
    } else {
        [[AppDelegate rdioInstance] authorizeFromController:self];
    }
}

- (void) setLoggedIn:(BOOL)logged_in {
    loggedIn = logged_in;
    if (logged_in) {
        [loginButton setTitle:@"Log Out" forState: UIControlStateNormal];
    } else {
        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
    }
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
    
    CGRect loginFrame = CGRectMake(60, 60, 60, 60);
    loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setFrame:loginFrame];
    if (loggedIn) {
        [loginButton setTitle:@"Log Out" forState: UIControlStateNormal];
    } else {
        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
    }
    [loginButton setBackgroundColor:[UIColor blackColor]];
    [loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    CGRect playFrame = CGRectMake(140, 140, 140, 140);
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playButton setFrame:playFrame];
    if (playing) {
        [playButton setTitle:@"Pause" forState: UIControlStateNormal];
    } else {
        [playButton setTitle:@"Play" forState: UIControlStateNormal];
    }
    [playButton setBackgroundColor:[UIColor blackColor]];
    [playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    
    //[[self getPlayer] playSource:@"t1992210"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSString *accessToken = [SFHFKeychainUtils getPasswordForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    
    NSLog(@"access token: %@", accessToken);
    
    if(!loggedIn && accessToken != nil) {
        [[AppDelegate rdioInstance] authorizeUsingAccessToken:accessToken fromController:self];
        //[[AppDelegate rdioInstance] authorizeFromController:self];
    }
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
    alarmTime = [NSDate dateWithTimeIntervalSinceNow:500];
    
    t = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    NSLog(@"Timer set!");
    float originalBrightness = [UIScreen mainScreen].brightness;
    [[UIScreen mainScreen] setBrightness:0.0];
}

- (void) tick
{
    NSLog(@"current time: %@ & alarm time: %@", [NSDate date], alarmTime);
    
    NSDate *now = [NSDate date];
    
    if([alarmTime isEqualToDate:([alarmTime earlierDate:now])] && !playing)
    {
        [self playClicked];
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
#pragma mark RdioDelegate

- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    [self setLoggedIn:YES];
    bool success = [SFHFKeychainUtils storeUsername:@"rdioUser" andPassword:accessToken forServiceName:@"rdioAlarm" updateExisting:TRUE error:nil]; 
    if(!success)
    {
        NSLog(@"Saving keychain entry not successful.");
    }
    
    if(loggedIn) {
        NSLog(@"Got here!");        
        [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:nil delegate:self];
    }
}

- (void) rdioAuthorizationFailed:(NSString *)error {
    [self setLoggedIn:NO];
}

- (void) rdioAuthorizationCancelled {
    [self setLoggedIn:NO];
}

- (void) rdioDidLogout {
    [self setLoggedIn:NO];
    bool success = [SFHFKeychainUtils deleteItemForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    if(!success)
    {
        NSLog(@"Deleting keychain entry not successful.");
    }
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
