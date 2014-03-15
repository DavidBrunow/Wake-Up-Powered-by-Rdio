//
//  AlarmClock.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/1/13.
//
//

#import "DHBAlarmClock.h"

@implementation DHBAlarmClock

-(id)init
{
    [self moveSettingsToDocumentsDir];
        
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:self.settingsPath];
    self.settings = (NSDictionary *)[NSPropertyListSerialization
                                 propertyListFromData:plistXML
                                 mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                 format:&format
                                 errorDescription:&errorDesc];
    if (!self.settings) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    
    [self setIs24h:(amRange.location == NSNotFound && pmRange.location == NSNotFound)];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    self.timeSeparator = @":";
    
    if([language isEqualToString:@"en"]) {
        self.timeSeparator = @":";
    } else if([language isEqualToString:@"fr"] || [language isEqualToString:@"pt-PT"]) {
        self.timeSeparator = @"h";
    } else if([language isEqualToString:@"de"] || [language isEqualToString:@"da"] || [language isEqualToString:@"fi"]) {
        self.timeSeparator = @".";
    }
    
    self.sleepTime = [[self.settings valueForKey:@"Sleep Time"] integerValue];
    self.snoozeTime = [[self.settings valueForKey:@"Snooze Time"] integerValue];
    self.isAutoStart = [[self.settings valueForKey:@"Auto Start Alarm"] boolValue];
    self.isShuffle = [[self.settings valueForKey:@"Shuffle"] boolValue];
    self.playlistKey = [self.settings valueForKey:@"Playlist Key"];
    self.sleepPlaylistKey = [self.settings valueForKey:@"Sleep Playlist Key"];

    [self setAlarmTimeFromString:[self.settings valueForKey:@"Alarm Time"]];
    
    return self;
}

-(void) refreshAlarmTime
{
    [self setAlarmTimeFromString:[self.settings valueForKey:@"Alarm Time"]];
}

-(NSString *) getAlarmTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.is24h) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"hh:mm"];
    }

    NSString *alarmTimeString = [dateFormatter stringFromDate:_alarmTime];
    
    return alarmTimeString;
}
     
-(void)setAlarmTimeFromString:(NSString *)alarmTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.is24h) {
        [dateFormatter setDateFormat:@"HH:mm"];
    } else {
        [dateFormatter setDateFormat:@"hh:mm"];
    }
    NSLog(@"Setting this string as the alarm time: %@", alarmTime);
    NSLog(@"Setting this date as the alarm time: %@", [dateFormatter dateFromString:alarmTime]);

    [self setAlarmTime:[dateFormatter dateFromString:alarmTime] save:NO];
}

-(void)setAlarmTime:(NSDate *)alarmTime save:(bool)needToSave
{
    if (alarmTime) {
        _alarmTime = alarmTime;
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (self.is24h) {
            [dateFormatter setDateFormat:@"HH:mm"];
        } else {
            [dateFormatter setDateFormat:@"hh:mm"];
        }
        NSString *alarmTimeString = [dateFormatter stringFromDate:alarmTime];
        NSLog(@"alarmTime: %@", alarmTime);

        NSLog(@"alarmTimeString: %@", alarmTimeString);
        if (needToSave) {
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self writeSettings];
        }
    }
}

-(void)setSleepPlaylistKey:(NSString *)sleepPlaylistKey
{
    if(sleepPlaylistKey) {
        _sleepPlaylistKey = sleepPlaylistKey;
        
        [self.settings setValue:sleepPlaylistKey forKey:@"Sleep Playlist Key"];
        [self writeSettings];
    }
}

-(void)setPlaylistKey:(NSString *)playlistKey
{
    if(playlistKey) {
        _playlistKey = playlistKey;
    
        [self.settings setValue:playlistKey forKey:@"Playlist Key"];
        [self writeSettings];
    }
}

-(void)setSnoozeTime:(int)snoozeTime
{
    if(snoozeTime) {
        _snoozeTime = snoozeTime;
        
        [self.settings setValue:[NSString stringWithFormat:@"%d", snoozeTime] forKey:@"Snooze Time"];
        
        [self writeSettings];
    }
}

-(void)setSleepTime:(int)sleepTime
{
    _sleepTime = sleepTime;
    
    [self.settings setValue:[NSString stringWithFormat:@"%d", sleepTime] forKey:@"Sleep Time"];
    NSLog(@"Setting sleep time: %d", sleepTime);
    [self writeSettings];
}

-(void)setIsAutoStart:(bool)isAutoStart
{
    _isAutoStart = isAutoStart;
    
    [self.settings setValue:[NSString stringWithFormat:@"%d", isAutoStart] forKey:@"Auto Start Alarm"];
    
    [self writeSettings];
}

-(void)setIsShuffle:(bool)isShuffle
{
    _isShuffle = isShuffle;
    
    [self.settings setValue:[NSString stringWithFormat:@"%d", isShuffle] forKey:@"Shuffle"];
    
    [self writeSettings];
}

-(void)writeSettings
{
    //NSString* docFolder = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString * path = [docFolder stringByAppendingPathComponent:@"Settings.plist"];
    
    if([self.settings writeToFile:self.settingsPath atomically: YES]){
    } else {
        
    }
    
}

- (void)moveSettingsToDocumentsDir
{
    /* get the path to save the favorites */
    self.settingsPath = [self currentSettingsPath];
    NSString *_v1SettingsPath = [self v1SettingsPath];
    NSString *_v2SettingsPath = [self v2SettingsPath];
    NSString *_v3SettingsPath = [self v3SettingsPath];

    /* check to see if there is already a file saved at the favoritesPath
     * if not, copy the default FavoriteUsers.plist to the favoritesPath
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.settingsPath])
    {
        if([fileManager fileExistsAtPath:_v3SettingsPath]) {
            //update from the latest settings file
            
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:_v3SettingsPath];
            
            self.settings = (NSDictionary *)[NSPropertyListSerialization
                                             propertyListFromData:plistXML
                                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                             format:&format
                                             errorDescription:&errorDesc];
            if (!self.settings) {
                NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
            }
            NSString *sleepTimeString = [self.settings valueForKey:@"Sleep Time"];
            NSString *snoozeTimeString = [self.settings valueForKey:@"Snooze Time"];
            NSString *alarmTimeString = [self.settings valueForKey:@"Alarm Time"];
            NSString *autoStartAlarmString = [self.settings valueForKey:@"Auto Start Alarm"];
            NSString *isShuffleString = [self.settings valueForKey:@"Shuffle"];
            self.playlistName = [self.settings valueForKey:@"Playlist Name"];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settingsv4" ofType:@"plist"];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            
            [self.settings setValue:sleepTimeString forKey:@"Sleep Time"];
            [self.settings setValue:snoozeTimeString forKey:@"Snooze Time"];
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self.settings setValue:autoStartAlarmString forKey:@"Auto Start Alarm"];
            [self.settings setValue:isShuffleString forKey:@"Shuffle"];
            [self writeSettings];
        } else if([fileManager fileExistsAtPath:_v2SettingsPath]) {
            
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:_v2SettingsPath];
            
            self.settings = (NSDictionary *)[NSPropertyListSerialization
                                             propertyListFromData:plistXML
                                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                             format:&format
                                             errorDescription:&errorDesc];
            if (!self.settings) {
                NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
            }
            NSString *sleepTimeString = [self.settings valueForKey:@"Sleep Time"];
            NSString *snoozeTimeString = [self.settings valueForKey:@"Snooze Time"];
            NSString *alarmTimeString = [self.settings valueForKey:@"Alarm Time"];
            NSString *autoStartAlarmString = [self.settings valueForKey:@"Auto Start Alarm"];
            self.playlistName = [self.settings valueForKey:@"Playlist Name"];
            
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settingsv4" ofType:@"plist"];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            
            [self.settings setValue:sleepTimeString forKey:@"Sleep Time"];
            [self.settings setValue:snoozeTimeString forKey:@"Snooze Time"];
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self.settings setValue:autoStartAlarmString forKey:@"Auto Start Alarm"];
            
            [self writeSettings];
        } else if([fileManager fileExistsAtPath:_v1SettingsPath]) {
            //if there is only the original settings file - so the user never upgraded from the original version
            
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:_v1SettingsPath];
            
            self.settings = (NSDictionary *)[NSPropertyListSerialization
                                         propertyListFromData:plistXML
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                         format:&format
                                         errorDescription:&errorDesc];
            if (!self.settings) {
                NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
            }
            //NSDictionary *root = [temp objectForKey:@"root"];
            NSString *sleepTimeString = [self.settings valueForKey:@"Sleep Time"];
            NSString *snoozeTimeString = [self.settings valueForKey:@"Snooze Time"];
            NSString *alarmTimeString = [self.settings valueForKey:@"Alarm Time"];
            //this is not a likely scenario, since the file structures will most likely be different if they are different versions
            //in that case, this would be the right place to take each value in the old file and put it in the new one
            //[[NSFileManager defaultManager]moveItemAtPath:_oldSettingsPath toPath:self.settingsPath error:nil];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settingsv4" ofType:@"plist"];
            //NSArray *settingsArray = [NSArray arrayWithContentsOfFile:path];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            
            [self.settings setValue:sleepTimeString forKey:@"Sleep Time"];
            [self.settings setValue:snoozeTimeString forKey:@"Snooze Time"];
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self writeSettings];
        
        } else {
            //if there are no other settings files - so this is a clean installation
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settingsv4" ofType:@"plist"];
            //NSArray *settingsArray = [NSArray arrayWithContentsOfFile:path];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            //[settingsArray writeToFile:self.settingsPath atomically:YES];
        }
    }
}

- (NSString *)currentSettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv4.plist"];
    
    return settingsPath;
}

- (NSString *)v3SettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv3.plist"];
    
    return settingsPath;
}

- (NSString *)v2SettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv2.plist"];
    
    return settingsPath;
}

- (NSString *)v1SettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv1.plist"];
    
    return settingsPath;
}


@end
