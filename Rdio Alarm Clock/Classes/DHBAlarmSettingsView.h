//
//  DHBAlarmSettingsView.h
//  Rdio Alarm
//
//  Created by David Brunow on 4/6/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"

@interface DHBAlarmSettingsView : UIView <MFMailComposeViewControllerDelegate>

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) MFMailComposeViewController *emailCompose;
@property (nonatomic) UIColor *lightTextColor;
@property (nonatomic) UIColor *darkTextColor;
@property (nonatomic) UILabel *lblSnooze;
@property (nonatomic) UILabel *lblSleep;
@property (nonatomic) UILabel *lblSleepAmount;
@property (nonatomic) UISlider *sliderSleep;
@property (nonatomic) UISlider *sliderSnooze;
@property (nonatomic) UILabel *lblSnoozeAmount;
@property (nonatomic) UISlider *sliderAutoStart;
@property (nonatomic) UILabel *lblAutoStart;
@property (nonatomic) UILabel *lblAutoStartYES;
@property (nonatomic) UILabel *lblAutoStartNO;
@property (nonatomic) UISlider *sliderShuffle;
@property (nonatomic) UILabel *lblShuffle;
@property (nonatomic) UILabel *lblShuffleYES;
@property (nonatomic) UILabel *lblShuffleNO;
@property (nonatomic, retain) UIViewController *myViewController;

@end
