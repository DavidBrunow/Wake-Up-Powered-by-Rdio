//
//  AlarmClock.h
//  Rdio Alarm
//
//  Created by David Brunow on 3/1/13.
//
//

#import <Foundation/Foundation.h>

@interface DHBAlarmClock : NSObject

@property (nonatomic) int snoozeTime;
@property (nonatomic) int sleepTime;
@property (nonatomic) bool isAutoStart;
@property (nonatomic) bool isShuffle;
@property (nonatomic) bool is24h;
@property (nonatomic) NSDictionary *settings;
@property (nonatomic) NSString *settingsPath;
@property (nonatomic, retain) NSString *playlistName;
@property (nonatomic, retain) NSIndexPath *playlistPath;
@property (nonatomic, retain) NSDate *alarmTime;

-(NSString *) getAlarmTimeString;
-(void) setAlarmTime:(NSDate *)alarmTime save:(bool)needToSave;

@end
