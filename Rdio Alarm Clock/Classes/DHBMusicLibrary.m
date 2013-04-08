//
//  DHBMusicLibrary.m
//  Rdio Alarm
//
//  Created by David Brunow on 4/5/13.
//
//

#import "DHBMusicLibrary.h"
#import "AppDelegate.h"

@implementation DHBMusicLibrary


- (id)init
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.playlists = [[NSMutableArray alloc] init];
    
    if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
        if([appDelegate.rdioUser isLoggedIn]) {
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"trackKeys", @"extras", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:trackInfo delegate:self];
        }// else {
            //choose songs from top songs chart
        //    NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Track", @"type", nil];
        //    [[AppDelegate rdioInstance] callAPIMethod:@"getTopCharts" withParameters:trackInfo delegate:self];
        //}
    }
    
    //self.selectedPlaylist = [[DHBPlaylist alloc] init];
    
    return self;
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
            //NSLog(@"playlist added: %@", [data objectForKey:key]);
            for (int x = 0; x < [[data objectForKey:key] count]; x++) {
                [playlist setPlaylistCategory:key];
                [playlist setPlaylistName:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"name"]];
                [playlist setPlaylistKey:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"key"]];
                [playlist setTrackKeys:[[[data objectForKey:key] objectAtIndex:x] objectForKey:@"trackKeys"] clean:NO];
                [self.playlists addObject:playlist];
                playlist = [[DHBPlaylist alloc] init];
            }
        }
        
        if(self.playlists.count == 0) {
            [self setHasNoPlaylists:YES];
        }
        
        appDelegate.selectedPlaylist = [self getPlaylistFromKey:appDelegate.alarmClock.playlistKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Playlist Found" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Reload Playlists" object:nil];
        
        /*[appDelegate.alarmClock setPlaylistPath:nil];
        for (int i = 0; i < [self.playlists count]; i++) {
            for(int j = 0; j < [[self.playlists objectAtIndex:i] count]; j++) {
                if ([[[[self.playlists objectAtIndex:i] objectAtIndex:j] objectForKey:@"name"] isEqualToString:[appDelegate.alarmClock playlistName]]) {
                    [self.selectedPlaylist setPlaylistIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                    [self.selectedPlaylist setPlaylistName:[[[self.playlists objectAtIndex:i] objectAtIndex:j] objectForKey:@"name"]];
                }
            }
        }*/
        
        //if(([self.selectedPlaylist playlistIndexPath] == nil && [self.selectedPlaylist playlistName] != nil) || [appDelegate.alarmClock alarmTime] == nil) {
            //alert the user that the playlist could not be found
            //#TODO: Send a message to do these things
            //[self cancelAutoStart];
            //[self.selectedPlaylist setPlaylistName:nil];
            
        //}
        
        //if([appDelegate.alarmClock playlistPath]) {
            //#TODO: Send a message to do these things
            //[self testToEnableAlarmButton];
            //[[self.listsViewController chooseMusic] reloadData];
        //}
        
    } 
}

- (DHBPlaylist *) getPlaylistFromKey:(id) key
{
    DHBPlaylist *playlist = [[DHBPlaylist alloc] init];
    
    for(int x = 0; x < self.playlists.count; x++) {
        if([[[self.playlists objectAtIndex:x] playlistKey] isEqualToString:key]) {
            playlist = [self.playlists objectAtIndex:x];
        }
    }
    
    return playlist;
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    [[AppDelegate rdioInstance] callAPIMethod:@"getPlaylists" withParameters:request.parameters delegate:self];
}


@end
