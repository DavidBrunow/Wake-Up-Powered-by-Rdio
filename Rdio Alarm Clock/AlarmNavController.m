//
//  AlarmNavController.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmNavController.h"
#import "AlarmViewController.h"

@implementation AlarmNavController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    alarmVC = [[MainViewController alloc] init];
    logIn = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self action:@selector(loginClicked)];
    
    alarmVC.title = @"Wake Up";
    [self pushViewController:alarmVC animated:true];
    
    [[alarmVC navigationItem] setRightBarButtonItem:logIn animated:YES];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	// Do any additional setup after loading the view.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInChanged:) name:@"logInNotification" object:nil];
    
    NSString *accessToken = [SFHFKeychainUtils getPasswordForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    
    NSLog(@"access token: %@", accessToken);
    
    if(!appDelegate.loggedIn && accessToken != nil) {
        [[AppDelegate rdioInstance] authorizeUsingAccessToken:accessToken fromController:self];
        [logIn setTitle:@"Log Out"];
        appDelegate.loggedIn = YES;
    } else if(appDelegate.loggedIn) {
        [logIn setTitle:@"Log Out"];
    } else {
        [logIn setTitle:@"Log In"];
    }
}

- (void) loginClicked {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.loggedIn) {
        [[AppDelegate rdioInstance] logout];
        [logIn setTitle:@"Log In"];
        appDelegate.loggedIn = NO;
        bool success = [SFHFKeychainUtils deleteItemForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Successful" message:@"You have been logged out of your Rdio account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        [[AppDelegate rdioInstance] authorizeFromController:alarmVC];
        [logIn setTitle:@"Log Out"];
        appDelegate.loggedIn = YES;
        
    }
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    //[self setLoggedIn:YES];
    [logIn setTitle:@"Log Out"];
    bool success = [SFHFKeychainUtils storeUsername:@"rdioUser" andPassword:accessToken forServiceName:@"rdioAlarm" updateExisting:TRUE error:nil]; 
    if(!success)
    {
        NSLog(@"Saving keychain entry not successful.");
    }
}

#pragma mark -
#pragma mark RdioDelegate

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

- (void) setLoggedIn:(BOOL)logged_in {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.loggedIn = logged_in;
    if (logged_in) {
        [logIn setTitle:@"Log Out"];
    } else {
        [logIn setTitle:@"Log In"];
    }
}

@end
