//
//  DHBAlarmself.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/6/13.
//
//

#import "DHBAlarmSettingsView.h"

@implementation DHBAlarmSettingsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) updateSnoozeLabel {
    if ((int)_sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT", nil), (int)_sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 91) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];
    } else {
        if(_sliderSnooze.value < 10) {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 106) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];
        } else {
            [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 126) / 2, self.lblSnoozeAmount.frame.origin.y, 126, 43)];
            
        }
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)_sliderSnooze.value]];
    }
    [_sliderSnooze setAccessibilityLabel:self.lblSnoozeAmount.text];
    
    [self.appDelegate.alarmClock setSnoozeTime:(int)_sliderSnooze.value];
}

- (void) updateSleepLabel {
    float sleepTimeValue;
    double svalue = _sliderSleep.value / 10.0;
    double dvalue = svalue - floor(svalue);
    //Check if the decimal value is closer to a 5 or not
    if(dvalue >= 0.25 && dvalue < 0.75)
        dvalue = floorf(svalue) + 0.5f;
    else
        dvalue = roundf(svalue);
    sleepTimeValue = dvalue * 10;
    //NSLog(@"%f", sleepTimeValue);
    //if ((int)_sliderSleep.value == 1) {
    
    //
    /*} else */
    if (sleepTimeValue < 5) {
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"INNER TIME BUBBLE TEXT DISABLED", nil) uppercaseString]]];
        [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 124) / 2, 212, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [_sliderSleep setValue:0.0];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];
        
        if(sleepTimeValue < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 106) / 2, 215, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 126) / 2, 215, 126, 43)];
            
        }
        [_sliderSleep setValue:sleepTimeValue];
        [self.lblSleepAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)sleepTimeValue]];
    }
    [_sliderSleep setAccessibilityLabel:self.lblSnoozeAmount.text];
    
    [self.appDelegate.alarmClock setSleepTime:(int)_sliderSleep.value];
}

- (void) updateAutoStart {
    if ([self.appDelegate.alarmClock isAutoStart]) {
        [self.lblAutoStartNO setHidden:NO];
        [self.lblAutoStartYES setHidden:YES];
        [self.sliderAutoStart setValue:0.05 animated:YES];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
        [self.appDelegate.alarmClock setIsAutoStart:NO];
        [self.sliderAutoStart setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    } else {
        [self.lblAutoStartNO setHidden:YES];
        [self.lblAutoStartYES setHidden:NO];
        [self.sliderAutoStart bringSubviewToFront:self.inputView];
        [self.sliderAutoStart setValue:0.95 animated:YES];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.appDelegate.alarmClock setIsAutoStart:YES];
        [self.sliderAutoStart setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    }
}

- (void) updateShuffle {
    if ([self.appDelegate.alarmClock isShuffle]) {
        [self.lblShuffleNO setHidden:NO];
        [self.lblShuffleYES setHidden:YES];
        [self.sliderShuffle setValue:0.05 animated:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
        [self.appDelegate.alarmClock setIsShuffle:NO];
    } else {
        [self.lblShuffleNO setHidden:YES];
        [self.lblShuffleYES setHidden:NO];
        [self.sliderShuffle setValue:0.95 animated:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.appDelegate.alarmClock setIsShuffle:YES];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    }
}

-(void) sendEmail
{
    self.emailCompose = [[MFMailComposeViewController alloc] init];
    
    [self.emailCompose setMailComposeDelegate:self];
    [self.emailCompose setToRecipients:[[NSArray alloc] initWithObjects:@"helloDavid@brunow.org", nil]];
    [self.emailCompose setSubject:@"Howdy!"];
    [self.emailCompose setMessageBody:[NSString stringWithFormat:@"<br /><br /><br /><br />Troubleshooting Information<br />---<br />App Name: %@<br />App Version: %@<br />iOS Device: %@<br />iOS Version: %@<br />", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], [UIDevice currentDevice].model, [[UIDevice currentDevice] systemVersion]] isHTML:YES];

    [self.myViewController presentViewController:self.emailCompose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)layoutSubviews
{
    self.appDelegate = [[UIApplication sharedApplication] delegate];

    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"settings-darkbg"]]];
    
    CGRect frameBtnSignOut = CGRectMake((self.frame.size.width - 78) / 4, self.frame.size.height - 125, 78, 28);
    if([[UIScreen mainScreen] bounds].size.height <= 480) {
        frameBtnSignOut = CGRectMake((self.frame.size.width - 78) / 4, self.frame.size.height - 40, 78, 28);
    }
    UIButton *btnSignOut = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSignOut setFrame:frameBtnSignOut];
    [btnSignOut setTitle:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SIGN OUT", nil) uppercaseString]] forState:UIControlStateNormal];
    [btnSignOut.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [btnSignOut.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btnSignOut setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout"] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout-pressed"] forState:UIControlStateHighlighted];
    
    [btnSignOut addTarget:self action:@selector(logoutClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    CGRect frameBtnContactUs = CGRectMake(((self.frame.size.width - 78) * 3) / 4, self.frame.size.height - 125, 78, 28);
    if([[UIScreen mainScreen] bounds].size.height <= 480) {
        frameBtnContactUs = CGRectMake(((self.frame.size.width - 78) * 3) / 4, self.frame.size.height - 40, 78, 28);
    }
    UIButton *btnContactUs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnContactUs setFrame:frameBtnContactUs];
    [btnContactUs setTitle:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"CONTACT US", nil) uppercaseString]] forState:UIControlStateNormal];
    [btnContactUs.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [btnContactUs.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [btnContactUs setTitleColor:self.lightTextColor forState:UIControlStateNormal];
    [btnContactUs setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout"] forState:UIControlStateNormal];
    [btnContactUs setBackgroundImage:[UIImage imageNamed:@"settings-btn-signout-pressed"] forState:UIControlStateHighlighted];
    
    [btnContactUs addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
    
    if([MFMailComposeViewController canSendMail]) {
        [self addSubview:btnContactUs];
    } else {
        frameBtnSignOut = CGRectMake((self.frame.size.width - 78) / 2, self.frame.size.height - 125, 78, 28);
        if([[UIScreen mainScreen] bounds].size.height <= 480) {
            frameBtnSignOut = CGRectMake((self.frame.size.width - 78) / 2, self.frame.size.height - 40, 78, 28);
        }
        [btnSignOut setFrame:frameBtnSignOut];
    }
    
    self.sliderSnooze = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width - 270) / 2, 130, 270, 50)];
    [self.sliderSnooze setMinimumValue:1.0];
    [self.sliderSnooze setMaximumValue:30.0];
    [self.sliderSnooze setValue:[self.appDelegate.alarmClock snoozeTime] animated:NO];
    [self.sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [self.sliderSnooze setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];
    
    [self.sliderSnooze setMinimumTrackImage:[[UIImage imageNamed:@"settings-sliderbase"] stretchableImageWithLeftCapWidth:9 topCapHeight:0] forState:UIControlStateNormal];
    [self.sliderSnooze setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];
    
    [self.sliderSnooze addTarget:self action:@selector(updateSnoozeLabel) forControlEvents:UIControlEventAllEvents];
    
    [self addSubview:self.sliderSnooze];
    
    self.lblSnooze = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 280) / 2, 50, 280, 50)];
    [self.lblSnooze setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SNOOZE SLIDER LABEL", nil) uppercaseString]]];
    
    //[_lblSnooze setTextColor:self.lightTextColor];
    [self.lblSnooze setTextColor:self.darkTextColor];
    
    [self.lblSnooze setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [self.lblSnooze setBackgroundColor:[UIColor clearColor]];
    [self.lblSnooze setNumberOfLines:10];
    
    [self.lblSnooze setAdjustsFontSizeToFitWidth:YES];
    
    [self.lblSnooze setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.lblSnooze];
    
    UIImageView *snoozeBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [snoozeBubble setFrame:CGRectMake((self.frame.size.width - 136) / 2, 85, 136, 48)];
    [self addSubview:snoozeBubble];
    
    self.lblSnoozeAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 126) / 2, 90, 126, 43)];
    
    if ((int)self.sliderSnooze.value == 1) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT", nil), (int)self.sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 91) / 2, 90, 126, 43)];
    } else if(self.sliderSnooze.value < 10) {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)self.sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 106) / 2, 90, 126, 43)];
    } else {
        [self.lblSnoozeAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), (int)self.sliderSnooze.value]];
        [self.lblSnoozeAmount setFrame:CGRectMake((self.frame.size.width - 126) / 2, 90, 126, 43)];
    }
    [self.sliderSnooze setAccessibilityLabel:self.lblSnoozeAmount.text];
    
    [self.lblSnoozeAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSnoozeAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSnoozeAmount setTextColor:self.lightTextColor];
    
    [self addSubview:self.lblSnoozeAmount];
    
    UIImageView *imgFirstSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgFirstSettingsSeparator setFrame:CGRectMake(0.0, 185.0, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [self addSubview:imgFirstSettingsSeparator];
    
    self.sliderSleep = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width - 270) / 2, 255, 270, 50)];
    [self.sliderSleep setMinimumValue:0.0];
    [self.sliderSleep setMaximumValue:60.0];
    [self.sliderSleep setValue:[self.appDelegate.alarmClock sleepTime] animated:NO];
    [self.sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateNormal];
    [self.sliderSleep setThumbImage:[UIImage imageNamed:@"settings-sliderknob"] forState:UIControlStateHighlighted];
    
    [self.sliderSleep setMinimumTrackImage:[[UIImage imageNamed:@"settings-sliderbase"] stretchableImageWithLeftCapWidth:9 topCapHeight:0] forState:UIControlStateNormal];
    [self.sliderSleep setMaximumTrackImage:[UIImage imageNamed:@"settings-sliderbase"] forState:UIControlStateNormal];
    
    [self.sliderSleep addTarget:self action:@selector(updateSleepLabel) forControlEvents:UIControlEventAllEvents];
    
    self.lblSleep = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 280) / 2, 175, 280, 50)];
    [self.lblSleep setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"SLEEP SLIDER LABEL", nil) uppercaseString]]];
    //[_lblSleep setTextColor:self.lightTextColor];
    [self.lblSleep setTextColor:self.darkTextColor];
    [self.lblSleep setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]];
    [self.lblSleep setBackgroundColor:[UIColor clearColor]];
    [self.lblSleep setNumberOfLines:10];
    [self.lblSleep setAdjustsFontSizeToFitWidth:YES];
    
    [self.lblSleep setTextAlignment:NSTextAlignmentCenter];
    
    UIImageView *sleepBubble = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-timebubble"]];
    [sleepBubble setFrame:CGRectMake((self.frame.size.width - 136) / 2, 210, 136, 48)];
    [self addSubview:sleepBubble];
    
    self.lblSleepAmount = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 126) / 2, 215, 126, 43)];
    NSLog(@"Sleep time: %d", [self.appDelegate.alarmClock sleepTime]);
    if ([self.appDelegate.alarmClock sleepTime] == 0) {
        [self.lblSleepAmount setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"INNER TIME BUBBLE TEXT DISABLED", nil) uppercaseString]]];
        [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 124) / 2, 212, 126, 43)];
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:YES];
        [self.sliderSleep setValue:[self.appDelegate.alarmClock sleepTime]];
    } else {
        [self.lblSleepAmount setAdjustsFontSizeToFitWidth:NO];
        
        if([self.appDelegate.alarmClock sleepTime] < 10) {
            [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 106) / 2, 215, 126, 43)];
        } else {
            [self.lblSleepAmount setFrame:CGRectMake((self.frame.size.width - 126) / 2, 215, 126, 43)];
            
        }
        [self.sliderSleep setValue:[self.appDelegate.alarmClock sleepTime]];
        [self.lblSleepAmount setText:[NSString stringWithFormat:NSLocalizedString(@"INNER TIME BUBBLE TEXT PLURAL", nil), [self.appDelegate.alarmClock sleepTime]]];
    }
    [self.sliderSnooze setAccessibilityLabel:self.lblSleepAmount.text];
    
    [self.lblSleepAmount setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:34.0]];
    [self.lblSleepAmount setBackgroundColor:[UIColor clearColor]];
    [self.lblSleepAmount setTextColor:self.lightTextColor];
    
    [self addSubview:self.lblSleepAmount];
    
    UIImageView *imgSecondSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgSecondSettingsSeparator setFrame:CGRectMake(0.0, 307, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [self addSubview:imgSecondSettingsSeparator];
    
    self.sliderAutoStart = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width - 88), 322, 78, 28)];
    [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
    [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateHighlighted];
    
    [self.sliderAutoStart setMinimumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderAutoStart setMaximumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderAutoStart addTarget:self action:@selector(updateAutoStart) forControlEvents:UIControlEventTouchCancel | UIControlEventValueChanged];
    [self.sliderAutoStart setContinuous:NO];
    
    [self addSubview:self.sliderAutoStart];
    
    self.lblAutoStartNO = [[UILabel alloc] initWithFrame:CGRectMake(38,0,30,28)];
    [self.lblAutoStartNO setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    [self.lblAutoStartNO setBackgroundColor:[UIColor clearColor]];
    [self.lblAutoStartNO setTextColor:self.darkTextColor];
    [self.lblAutoStartNO setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    self.lblAutoStartYES = [[UILabel alloc] initWithFrame:CGRectMake(18,0,30,28)];
    [self.lblAutoStartYES setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    [self.lblAutoStartYES setBackgroundColor:[UIColor clearColor]];
    [self.lblAutoStartYES setTextColor:self.lightTextColor];
    [self.lblAutoStartYES setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [self.sliderAutoStart addSubview:self.lblAutoStartYES];
    [self.sliderAutoStart addSubview:self.lblAutoStartNO];
    
    if ([self.appDelegate.alarmClock isAutoStart]) {
        [self.lblAutoStartNO setHidden:YES];
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.sliderAutoStart setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateHighlighted];
        [self.sliderAutoStart setValue:0.95 animated:NO];
    } else {
        [self.sliderShuffle setAccessibilityLabel:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
        [self.lblAutoStartYES setHidden:YES];
        [self.sliderAutoStart setValue:0.05 animated:NO];
    }
    
    self.lblAutoStart = [[UILabel alloc] initWithFrame:CGRectMake(15, 306, 200, 60)];
    [self.lblAutoStart setText:[NSString stringWithFormat:NSLocalizedString(@"AUTO ALARM", nil)]];
    [self.lblAutoStart setTextColor:self.lightTextColor];
    
    [self.lblAutoStart setTextAlignment:NSTextAlignmentLeft];
    [self.lblAutoStart setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [self.lblAutoStart setBackgroundColor:[UIColor clearColor]];
    [self.lblAutoStart setLineBreakMode:NSLineBreakByWordWrapping];
    [self.lblAutoStart setNumberOfLines:2];
    [self.lblAutoStart setAdjustsFontSizeToFitWidth:YES];
    
    [self addSubview:self.lblAutoStart];
    
    UIImageView *imgThirdSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgThirdSettingsSeparator setFrame:CGRectMake(0.0, 363, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [self addSubview:imgThirdSettingsSeparator];
    
    self.sliderShuffle = [[UISlider alloc] initWithFrame:CGRectMake((self.frame.size.width - 88), 377, 78, 28)];
    [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateNormal];
    [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knoboff"] forState:UIControlStateHighlighted];
    
    [self.sliderShuffle setMinimumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderShuffle setMaximumTrackImage:[[UIImage imageNamed:@"settings-onoff-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0)] forState:UIControlStateNormal];
    [self.sliderShuffle sendActionsForControlEvents:UIControlEventValueChanged];
    [self.sliderShuffle addTarget:self action:@selector(updateShuffle) forControlEvents:UIControlEventTouchCancel | UIControlEventValueChanged];
    [self.sliderShuffle setContinuous:NO];
    
    [self addSubview:self.sliderShuffle];
    
    self.lblShuffleNO = [[UILabel alloc] initWithFrame:CGRectMake(38,0,30,28)];
    [self.lblShuffleNO setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERNO", nil) uppercaseString]]];
    [self.lblShuffleNO setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffleNO setTextColor:self.darkTextColor];
    [self.lblShuffleNO setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    self.lblShuffleYES = [[UILabel alloc] initWithFrame:CGRectMake(18,0,30,28)];
    [self.lblShuffleYES setText:[NSString stringWithFormat:@"%@", [NSLocalizedString(@"LBLSLIDERYES", nil) uppercaseString]]];
    [self.lblShuffleYES setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffleYES setTextColor:self.lightTextColor];
    [self.lblShuffleYES setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    [self.sliderShuffle addSubview:self.lblShuffleYES];
    [self.sliderShuffle addSubview:self.lblShuffleNO];
    
    if ([self.appDelegate.alarmClock isShuffle]) {
        [self.lblShuffleNO setHidden:YES];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateNormal];
        [self.sliderShuffle setThumbImage:[UIImage imageNamed:@"settings-onoff-knobon"] forState:UIControlStateHighlighted];
        [self.sliderShuffle setValue:0.95 animated:NO];
    } else {
        [self.lblShuffleYES setHidden:YES];
        [self.sliderShuffle setValue:0.05 animated:NO];
    }
    
    self.lblShuffle = [[UILabel alloc] initWithFrame:CGRectMake(15, 359, 200, 60)];
    [self.lblShuffle setText:[NSString stringWithFormat:NSLocalizedString(@"SHUFFLE", nil)]];
    [self.lblShuffle setTextColor:self.lightTextColor];
    //[_lblAutoStart setTextColor:self.darkTextColor];
    
    [self.lblShuffle setTextAlignment:NSTextAlignmentLeft];
    [self.lblShuffle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]];
    [self.lblShuffle setBackgroundColor:[UIColor clearColor]];
    [self.lblShuffle setLineBreakMode:NSLineBreakByWordWrapping];
    [self.lblShuffle setNumberOfLines:2];
    [self.lblShuffle setAdjustsFontSizeToFitWidth:YES];
    
    [self addSubview:self.lblShuffle];
    
    UIImageView *imgFourthSettingsSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-div"]];
    [imgFourthSettingsSeparator setFrame:CGRectMake(0.0, 417, [[UIScreen mainScreen] bounds].size.width, 1.0)];
    [self addSubview:imgFourthSettingsSeparator];
    
    if ([self.appDelegate.rdioUser isLoggedIn]) {
        [self addSubview:btnSignOut];
        [self addSubview:self.lblSleep];
        [self addSubview:self.sliderSleep];
    }
    
    UIImageView *ivTexas = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ThickTexasVector"]];
    [ivTexas setFrame:CGRectMake((self.frame.size.width - 32) / 2, self.frame.size.height - 90, 31, 30)];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 60, [[UIScreen mainScreen] bounds].size.width, 50)];
    [lblName setText:[NSString stringWithFormat:@"David Brunow\n@davidbrunow\nhelloDavid@brunow.org"]];
    [lblName setText:[NSString stringWithFormat:@"Designed and Developed in Texas by\nJenni Leder          @thoughtbrain      jenni.leder@gmail.com\nDavid Brunow        @davidbrunow      helloDavid@brunow.org"]];
    [lblName setTextColor:self.darkTextColor];
    [lblName setTextColor:[UIColor blackColor]];
    
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0]];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setNumberOfLines:10];
    
    [lblName setTextAlignment:NSTextAlignmentCenter];
    
    if([[UIScreen mainScreen] bounds].size.height > 480) {
        [self addSubview:ivTexas];
        [self addSubview:lblName];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
