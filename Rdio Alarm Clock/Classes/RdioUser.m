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
    [[AppDelegate rdioInstance] setDelegate:self];
    [self setIsLoggedIn:NO];

    NSString *accessToken = [SFHFKeychainUtils getPasswordForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"Log In User" object:nil];
    
    if(accessToken != nil) {
        [[AppDelegate rdioInstance] authorizeUsingAccessToken:accessToken];

        [self setIsLoggedIn:YES];
    }
    
    return self;
}

- (void) login {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [[AppDelegate rdioInstance] authorizeFromController:[appDelegate.window rootViewController]];
}

- (void) logout {
    [self setIsLoggedIn:NO];
    [[AppDelegate rdioInstance] logout];
    bool success = [SFHFKeychainUtils deleteItemForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
    NSLog(@"Success: %d", success);
}

#pragma mark -
#pragma mark RdioDelegate
- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    NSLog(@"got here rdio did auth");
    NSLog(@"got here");
    [self setIsLoggedIn:YES];
    bool success = [SFHFKeychainUtils storeUsername:USER_NAME andPassword:accessToken forServiceName:SERVICE_NAME updateExisting:TRUE error:nil];
    if(!success)
    {
        bool success = [SFHFKeychainUtils deleteItemForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
        if(!success)
        {
            NSLog(@"Deleting keychain entry not successful.");
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"User Logged In" object:nil];

}

- (void) rdioAuthorizationFailed:(NSString *)error {
    [self setIsLoggedIn:NO];
    
    bool success = [SFHFKeychainUtils deleteItemForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
    if(!success)
    {
        NSLog(@"Deleting keychain entry not successful.");
    }
}

- (void) rdioAuthorizationCancelled {
    [self setIsLoggedIn:NO];
}

- (void) rdioDidLogout {
    [self setIsLoggedIn:NO];
    
    bool success = [SFHFKeychainUtils deleteItemForUsername:USER_NAME andServiceName:SERVICE_NAME error:nil];
    if(!success)
    {
        NSLog(@"Deleting keychain entry not successful.");
    }
}

@end
