//
//  AlarmNavController.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlarmNavController.h"
#import "AlarmViewController.h"
#import "AppDelegate.h"

@implementation AlarmNavController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    
    NSArray *array = [[NSArray alloc] initWithArray:[super popToRootViewControllerAnimated:animated]];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        if(array.count == 0) {
            [self popViewControllerAnimated:YES];
            self.alarmVC = nil;
            
            [self viewDidAppear:YES];
        } else {
            [self handleLoginState];
        }
    }
    
    return array;
}

- (void) handleLoginState
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if([appDelegate.rdioUser isLoggedIn]) {
        
    } else {
        [appDelegate.rdioUser login];
    }
}

- (void) viewDidAppear:(BOOL)animated
{    
    [self handleLoginState];
    
    self.alarmVC = [[AlarmViewController alloc] init];
    
    [self pushViewController:self.alarmVC animated:NO];
    
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


@end
