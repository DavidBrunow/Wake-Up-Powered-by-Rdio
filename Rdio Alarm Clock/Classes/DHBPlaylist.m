//
//  DHBPlaylist.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/1/13.
//
//

#import "DHBPlaylist.h"
#import "AppDelegate.h"

@implementation DHBPlaylist

- (id)init
{
    self.trackKeys = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(id)data {
    NSString *method = [request.parameters objectForKey:@"method"];
    
    if ([method isEqualToString:@"get"]) {
        for(NSString *key in [data allKeys]) {
            //NSLog(@"CanStream: %@", [[data objectForKey:key] objectForKey:@"canStream"]);
            if ([[[data objectForKey:key] objectForKey:@"canStream"] isEqual:[NSNumber numberWithBool:YES]]) {
            } else {
                //NSLog(@"Number of trackKeys: %d - current key: %@", [self.trackKeys count], key);
                for(int x = 0; x < self.trackKeys.count; x++) {
                    if([[self.trackKeys objectAtIndex:x] isEqualToString:key]) {
                        [self.trackKeys removeObjectAtIndex:x];
                    }
                }
                //NSLog(@"Number of trackKeys: %d - current key: %@", [self.trackKeys count], key);
            }
        }
    }
    //NSLog(@"Got tracks for playlist name: %@", self.playlistName);
    /*
    int x = 0;
    for(NSString *trackKey in self.trackKeys) {
        NSLog(@"Key %d: %@", x, trackKey);
        x++;
    }
    */
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    //NSLog(@"Got error on playlist name: %@", self.playlistName);
    [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:request.parameters delegate:self];
}

- (void)setTrackKeys:(NSMutableArray *)trackKeys clean:(bool) isClean
{
    _trackKeys = trackKeys;
    
    if(!isClean) {
        [self determineStreamableSongs];
    }
}

- (void) determineStreamableSongs
{
    self.trackKeys = [self removeDuplicatesInPlaylist:self.trackKeys];

    NSString *songsToPlayString = @"";
    int totalNumberOfTracks = self.trackKeys.count;
    int chunkSize = 250;
    
    if(totalNumberOfTracks < chunkSize) {
        for (int x = 0; x < self.trackKeys.count; x++) {
            if([songsToPlayString isEqualToString:@""]) {
                songsToPlayString = [NSString stringWithFormat:@"%@", [self.trackKeys objectAtIndex:x]];
            } else {
                songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [self.trackKeys objectAtIndex:x]];
            }
        }
        NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:songsToPlayString, @"keys", @"0", @"canStream", nil];
        [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:trackInfo delegate:self];
    } else {
        int numberOfChunks = totalNumberOfTracks / chunkSize;
        int numberInLastChunk = totalNumberOfTracks - (numberOfChunks * chunkSize);
        
        for (int x = 0; x <= numberOfChunks; x++) {
            for (int y = x * chunkSize; y < numberOfChunks * chunkSize; y++) {
                if([songsToPlayString isEqualToString:@""]) {
                    songsToPlayString = [NSString stringWithFormat:@"%@", [self.trackKeys objectAtIndex:y]];
                } else {
                    songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [self.trackKeys objectAtIndex:y]];
                //NSLog(@"Submitted Key %d: %@", y, [self.trackKeys objectAtIndex:y]);
                }
            }
            NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:songsToPlayString, @"keys", @"0", @"canStream", nil];
            [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:trackInfo delegate:self];
            songsToPlayString = @"";
        }
        for(int y = numberOfChunks * chunkSize; y < numberOfChunks * chunkSize + numberInLastChunk; y++) {
            if([songsToPlayString isEqualToString:@""]) {
                songsToPlayString = [NSString stringWithFormat:@"%@", [self.trackKeys objectAtIndex:y]];
            } else {
                songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [self.trackKeys objectAtIndex:y]];
                //NSLog(@"Submitted Key %d: %@", y, [self.trackKeys objectAtIndex:y]);
            }
        }
        NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:songsToPlayString, @"keys", @"0", @"canStream", nil];
        [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:trackInfo delegate:self];
    }
}

- (NSMutableArray *) removeDuplicatesInPlaylist: (NSMutableArray *) playlist
{
    for (int x = 0; x < playlist.count; x++) {
        for (int y = x+1; y < playlist.count; y++) {
            if ([[playlist objectAtIndex:x] isEqual:[playlist objectAtIndex:y]]) {
                [playlist removeObjectAtIndex:y];
            }
        }
    }
    
    return playlist;
}

@end
