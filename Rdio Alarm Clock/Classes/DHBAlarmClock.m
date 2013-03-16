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
    
    self.sleepTime = [[self.settings valueForKey:@"Sleep Time"] integerValue];
    self.snoozeTime = [[self.settings valueForKey:@"Snooze Time"] integerValue];
    self.isAutoStart = [[self.settings valueForKey:@"Auto Start Alarm"] boolValue];
    self.isShuffle = [[self.settings valueForKey:@"Shuffle"] boolValue];
    [self setAlarmTimeFromString:[self.settings valueForKey:@"Alarm Time"]];

    NSIndexPath *ipPlaylistPath = [NSIndexPath indexPathForRow:[[self.settings valueForKey:@"Playlist Number"] intValue] inSection:[[self.settings valueForKey:@"Playlist Section"] intValue]] ;
    
    if(ipPlaylistPath.section != -1 && self.playlistPath == nil) {
        self.playlistPath = ipPlaylistPath;
        self.playlistName = [self.settings valueForKey:@"Playlist Name"];
        NSLog(@"Playlist Name1: %@", self.playlistName);
    }
    
    
    return self;
}

-(NSString *) getAlarmTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];

    NSString *alarmTimeString = [dateFormatter stringFromDate:self.alarmTime];
    
    return alarmTimeString;
}
     
-(void)setAlarmTimeFromString:(NSString *)alarmTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    [self setAlarmTime:[dateFormatter dateFromString:alarmTime]];
}

-(void)setAlarmTime:(NSDate *)alarmTime save:(bool)needToSave
{
    if (alarmTime) {
        _alarmTime = alarmTime;
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm"];
        NSString *alarmTimeString = [dateFormatter stringFromDate:alarmTime];
        NSLog(@"alarmTime: %@", alarmTime);

        NSLog(@"alarmTimeString: %@", alarmTimeString);
        if (needToSave) {
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self writeSettings];
        }
    }
}

-(void)setPlaylistName:(NSString *)playlistName
{
    if(playlistName) {
        _playlistName = playlistName;
    
        [self.settings setValue:playlistName forKey:@"Playlist Name"];
        [self writeSettings];
    }
}

-(void)setPlaylistPath:(NSIndexPath *)playlistPath
{
    if (playlistPath) {
        _playlistPath = playlistPath;
    
        [self.settings setValue:[NSString stringWithFormat:@"%d", playlistPath.section] forKey:@"Playlist Section"];
        [self.settings setValue:[NSString stringWithFormat:@"%d", playlistPath.row] forKey:@"Playlist Number"];

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

    /* check to see if there is already a file saved at the favoritesPath
     * if not, copy the default FavoriteUsers.plist to the favoritesPath
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.settingsPath])
    {
        if(![fileManager fileExistsAtPath:_v1SettingsPath] && ![fileManager fileExistsAtPath:_v2SettingsPath]) {
            //if there are no other settings files - so this is a clean installation

            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
            //NSArray *settingsArray = [NSArray arrayWithContentsOfFile:path];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            //[settingsArray writeToFile:self.settingsPath atomically:YES];
        } else if(![fileManager fileExistsAtPath:_v2SettingsPath]) {
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
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
            //NSArray *settingsArray = [NSArray arrayWithContentsOfFile:path];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            
            [self.settings setValue:sleepTimeString forKey:@"Sleep Time"];
            [self.settings setValue:snoozeTimeString forKey:@"Snooze Time"];
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self writeSettings];
        } else {
            //update from the latest settings file
            
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
            NSString *playlistNumberString = [self.settings valueForKey:@"Playlist Number"];
            NSString *playlistNameString = [self.settings valueForKey:@"Playlist Name"];
            NSString *playlistSectionString = [self.settings valueForKey:@"Playlist Section"];

            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            
            [self.settings setValue:sleepTimeString forKey:@"Sleep Time"];
            [self.settings setValue:snoozeTimeString forKey:@"Snooze Time"];
            [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
            [self.settings setValue:autoStartAlarmString forKey:@"Auto Start Alarm"];
            [self.settings setValue:playlistNumberString forKey:@"Playlist Number"];
            [self.settings setValue:playlistNameString forKey:@"Playlist Name"];
            [self.settings setValue:playlistSectionString forKey:@"Playlist Section"];

            [self writeSettings];
        }
    }
}

- (NSString *)currentSettingsPath
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
