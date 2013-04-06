//
//  RdioUser.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/5/13.
//
//

#import "RdioUser.h"
#import "Credentials.h"
#import "AppDelegate.h"

@implementation RdioUser

-(id)init
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[AppDelegate rdioInstance] setDelegate:self];

    NSString *accessToken = [SFHFKeychainUtils getPasswordForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
    
    if(accessToken != nil) {
        [[AppDelegate rdioInstance] authorizeUsingAccessToken:accessToken fromController:[appDelegate.window rootViewController]];
        [self setIsLoggedIn:YES];
    } else {
        [self login];
    }
    
    return self;
}

- (void) login {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[AppDelegate rdioInstance] authorizeFromController:[appDelegate.window rootViewController]];
    [self setIsLoggedIn:YES];
}

- (void) logout {
    [self setIsLoggedIn:NO];
    bool success = [SFHFKeychainUtils deleteItemForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    NSLog(@"Success: %d", success);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Successful" message:@"You have been logged out of your Rdio account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
#pragma mark RdioDelegate
- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    NSLog(@"got here rdio did auth");
    NSLog(@"got here");
    [self setIsLoggedIn:YES];
    bool success = [SFHFKeychainUtils storeUsername:@"USER_NAME" andPassword:accessToken forServiceName:@"rdioAlarm" updateExisting:TRUE error:nil];
    if(!success)
    {
        bool success = [SFHFKeychainUtils deleteItemForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
        if(!success)
        {
            NSLog(@"Deleting keychain entry not successful.");
        }
    }
}

- (void) rdioAuthorizationFailed:(NSString *)error {
    [self setIsLoggedIn:NO];
}

- (void) rdioAuthorizationCancelled {
    [self setIsLoggedIn:NO];
}

- (void) rdioDidLogout {
    [self setIsLoggedIn:NO];
    
    bool success = [SFHFKeychainUtils deleteItemForUsername:@"rdioUser" andServiceName:@"rdioAlarm" error:nil];
    if(!success)
    {
        NSLog(@"Deleting keychain entry not successful.");
    }
}

@end
