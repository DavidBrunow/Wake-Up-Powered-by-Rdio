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
    //#TODO: Add shuffle to setting plist.
    //self.isShuffle = [[self.settings valueForKey:@"Shuffle"] boolValue];
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

-(void)setAlarmTime:(NSDate *)alarmTime
{
    if (alarmTime) {
        _alarmTime = alarmTime;
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm"];
        NSString *alarmTimeString = [dateFormatter stringFromDate:alarmTime];
        NSLog(@"alarmTime: %@", alarmTime);

        NSLog(@"alarmTimeString: %@", alarmTimeString);
        [self.settings setValue:alarmTimeString forKey:@"Alarm Time"];
        [self writeSettings];
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
    if(sleepTime) {
        _sleepTime = sleepTime;
        
        [self.settings setValue:[NSString stringWithFormat:@"%d", sleepTime] forKey:@"Sleep Time"];
        
        [self writeSettings];
    }
}

-(void)setIsAutoStart:(bool)isAutoStart
{
    if(isAutoStart) {
        _isAutoStart = isAutoStart;
        
        [self.settings setValue:[NSString stringWithFormat:@"%d", isAutoStart] forKey:@"Auto Start Alarm"];
        
        [self writeSettings];
    }
}

-(void)setIsShuffle:(bool)isShuffle
{
    if(isShuffle) {
        _isShuffle = isShuffle;
        
        [self.settings setValue:[NSString stringWithFormat:@"%d", isShuffle] forKey:@"Shuffle"];
        
        [self writeSettings];
    }
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
    self.settingsPath = [self settingsPath];
    NSString *_oldSettingsPath = [self oldSettingsPath];
    
    /* check to see if there is already a file saved at the favoritesPath
     * if not, copy the default FavoriteUsers.plist to the favoritesPath
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.settingsPath])
    {
        if(![fileManager fileExistsAtPath:_oldSettingsPath]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
            //NSArray *settingsArray = [NSArray arrayWithContentsOfFile:path];
            [[NSFileManager defaultManager]copyItemAtPath:path toPath:self.settingsPath error:nil];
            //[settingsArray writeToFile:self.settingsPath atomically:YES];
        } else {
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:_oldSettingsPath];
            
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
        }
    }
}

- (NSString *)settingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv2.plist"];
    
    return settingsPath;
}

- (NSString *)oldSettingsPath
{
    /* get the path for the Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /* append the path component for the FavoriteUsers.plist */
    NSString *settingsPath = [documentsPath stringByAppendingPathComponent:@"WakeUpRdioSettingsv1.plist"];
    
    return settingsPath;
}


@end
