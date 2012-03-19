//
//  MainViewController.h
//  Rdio Alarm
//
//  Created by David Brunow on 1/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

@interface MainViewController : UIViewController <RdioDelegate, RDPlayerDelegate, RDAPIRequestDelegate>
{
    RDPlayer* player;
    UIButton *loginButton;
    UIButton *playButton;
    bool loggedIn;
    bool paused;
    bool playing;
    NSMutableArray *playlists;
    NSDate  *alarmTime;
    NSTimer *t;
}

@property (retain) RDPlayer *player;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *playButton;

- (void) playClicked;

@end
