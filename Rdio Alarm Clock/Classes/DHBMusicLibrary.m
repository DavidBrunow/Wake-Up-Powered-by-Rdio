//
//  DHBMusicLibrary.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/5/13.
//
//

#import "DHBMusicLibrary.h"
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation DHBMusicLibrary


- (id)init
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.playlists = [[NSMutableArray alloc] init];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        if([appDelegate.rdioUser isLoggedIn]) {
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"trackKeys", @"extras", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:trackInfo delegate:self];
        }
    } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
        [self getMediaPlaylists];
    }
    
    return self;
}

- (void) getMediaPlaylists
{
    self.playlists = [[NSMutableArray alloc] init];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    MPMediaQuery *playlistQuery = [[MPMediaQuery alloc] init];
    [playlistQuery setGroupingType:MPMediaGroupingPlaylist];
    NSArray *playlists = [playlistQuery collections];
    
    for(int x = 0; x < playlists.count; x++) {
        DHBPlaylist *playlist = [[DHBPlaylist alloc] init];
        
        [playlist setPlaylistKey:[[[playlists objectAtIndex:x] valueForProperty:MPMediaItemPropertyPersistentID] stringValue]];
        [playlist setPlaylistName:[[playlists objectAtIndex:x] valueForProperty:@"name"]];
        
        NSString *playlistName = playlist.playlistName;
        MPMediaPropertyPredicate *playlistPredicate = [MPMediaPropertyPredicate predicateWithValue:playlistName forProperty:MPMediaPlaylistPropertyName];
        
        NSNumber *mediaTypeNumber = [NSNumber numberWithInteger:MPMediaTypeMusic]; // == 1
        MPMediaPropertyPredicate *mediaTypePredicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
        
        NSSet *predicateSet = [NSSet setWithObjects:playlistPredicate, mediaTypePredicate, nil];
        MPMediaQuery *mediaTypeQuery = [[MPMediaQuery alloc] initWithFilterPredicates:predicateSet];
        [mediaTypeQuery setGroupingType:MPMediaGroupingPlaylist];
        
        NSArray *playlistItems = [mediaTypeQuery items];
        NSMutableArray *trackKeys = [[NSMutableArray alloc] init];
        
        [playlistItems enumerateObjectsUsingBlock:^(MPMediaItem *song, NSUInteger idx, BOOL *stop) {
            NSString *trackKey = [song valueForProperty:MPMediaItemPropertyPersistentID];
            [trackKeys addObject:trackKey];
        }];
        
        [playlist setTrackKeys:trackKeys];
        [self.playlists addObject:playlist];
    }
    
    if(self.playlists.count == 0) {
        [self setHasNoPlaylists:YES];
        appDelegate.selectedPlaylist = nil;
        appDelegate.sleepPlaylist = nil;
    }
    
    if([self getPlaylistFromKey:appDelegate.alarmClock.playlistKey]) {
        [[self getPlaylistFromKey:appDelegate.alarmClock.playlistKey] setIsSelected:YES];
        appDelegate.selectedPlaylist = [self getPlaylistFromKey:appDelegate.alarmClock.playlistKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Playlist Found" object:nil];
    
    if([self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey]) {
        [[self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey] setIsSelected:YES];
        appDelegate.sleepPlaylist = [self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Sleep Playlist Found" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload Playlists" object:nil];
}

#pragma mark -
#pragma mark RDAPIRequestDelegate
/**
 * Our API call has returned successfully.
 * the data parameter can be an NSDictionary, NSArray, or NSData
 * depending on the call we made.
 *
 * Here we will inspect the parameters property of the returned RDAPIRequest
 * to see what method has returned.
 */
- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSString *method = [request.parameters objectForKey:@"method"];
    
    if([method isEqualToString:@"getPlaylists"]) {
        // we are returned a dictionary but it will be easier to work with an array
        // for our needs
        
        appDelegate.playlistsInfo = [[NSMutableArray alloc] init];
        DHBPlaylist *playlist = [[DHBPlaylist alloc] init];
        
        //For each type of playlist in data ([0] = collab; [1] = owned; [2] = subscribed)
        for(NSString *key in [data allKeys]) {
            //[self.playlists addObject:[data objectForKey:key]];
            for (int x = 0; x < [[data objectForKey:key] count]; x++) {
                [playlist setPlaylistCategory:key];
                [playlist setPlaylistName:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"name"]];
                [playlist setPlaylistKey:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"key"]];
                [playlist setTrackKeys:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"trackKeys"] clean:YES];
                [self.playlists addObject:playlist];
                playlist = [[DHBPlaylist alloc] init];
            }
        }
        
        if(self.playlists.count == 0) {
            [self setHasNoPlaylists:YES];
        }
        
        if([self getPlaylistFromKey:appDelegate.alarmClock.playlistKey]) {
            [[self getPlaylistFromKey:appDelegate.alarmClock.playlistKey] setIsSelected:YES];
            appDelegate.selectedPlaylist = [self getPlaylistFromKey:appDelegate.alarmClock.playlistKey];
        }
        
        if(appDelegate.selectedPlaylist == nil) {
            if([self getPlaylistFromName:appDelegate.alarmClock.playlistName]) {
                [[self getPlaylistFromName:appDelegate.alarmClock.playlistName] setIsSelected:YES];
                appDelegate.selectedPlaylist = [self getPlaylistFromName:appDelegate.alarmClock.playlistName];
                appDelegate.alarmClock.playlistKey = appDelegate.selectedPlaylist.playlistKey;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playlist Found" object:nil];

        
        if([self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey]) {
            [[self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey] setIsSelected:YES];
            appDelegate.sleepPlaylist = [self getPlaylistFromKey:appDelegate.alarmClock.sleepPlaylistKey];
        }
        
        if(appDelegate.alarmClock.sleepTime > 0 && appDelegate.sleepPlaylist == nil && appDelegate.selectedPlaylist != nil) {
            appDelegate.sleepPlaylist = appDelegate.selectedPlaylist;
            appDelegate.alarmClock.sleepPlaylistKey = appDelegate.sleepPlaylist.playlistKey;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Sleep Playlist Found" object:nil];


        [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload Playlists" object:nil];
        
    } 
}

- (NSArray *) getPlaylistsInCategory: (NSString *)category
{
    NSMutableArray *thisCategory = [[NSMutableArray alloc] init];
    
    for(int x = 0; x < self.playlists.count; x++) {
        if([[[self.playlists objectAtIndex:x] playlistCategory] isEqualToString:category]) {
            [thisCategory addObject:[self.playlists objectAtIndex:x]];
        }
    }
    
    return thisCategory;
}

- (DHBPlaylist *) getPlaylistFromKey:(id) key
{
    DHBPlaylist *playlist = [[DHBPlaylist alloc] init];
    bool playlistFound = false;
    
    for(int x = 0; x < self.playlists.count; x++) {
        if([[[self.playlists objectAtIndex:x] playlistKey] isEqualToString:key]) {
            playlist = [self.playlists objectAtIndex:x];
            playlistFound = true;
        }
    }
    
    if(!playlistFound) {
        playlist = nil;
    }
    
    return playlist;
}

- (DHBPlaylist *) getPlaylistFromName:(id) name
{
    DHBPlaylist *playlist = [[DHBPlaylist alloc] init];
    bool playlistFound = false;
    
    for(int x = 0; x < self.playlists.count; x++) {
        if([[[[self.playlists objectAtIndex:x] playlistName] lowercaseString] isEqualToString:[name lowercaseString]]) {
            playlist = [self.playlists objectAtIndex:x];
            playlistFound = true;
        }
    }
    
    if(!playlistFound) {
        playlist = nil;
    }
    
    return playlist;
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:request.parameters delegate:self];
}


@end
