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
