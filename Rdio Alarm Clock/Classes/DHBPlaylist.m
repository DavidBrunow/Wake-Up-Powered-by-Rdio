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
    self.trackKeys = [self getEnough:self.trackKeys];
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

- (void)setIsSelected:(bool)isSelected
{
    _isSelected = isSelected;
    
    if(isSelected) {
        if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Rdio-Alarm"]) {
            [self setTrackKeys:self.trackKeys clean:NO];
        } else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.DavidBrunow.Wake-Up-to-Music"]) {
            self.trackKeys = [self getEnough:self.trackKeys];
        }
    }
}

- (void) determineStreamableSongs
{
    self.trackKeys = [self removeDuplicatesInPlaylist:self.trackKeys];

    NSString *songsToPlayString = @"";
    int totalNumberOfTracks = self.trackKeys.count;
    int chunkSize = 500;
    
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

- (NSMutableArray *)getShuffledTrackKeys
{
    NSMutableArray *tempTrackKeys = [[NSMutableArray alloc] initWithArray:_trackKeys];
    
    tempTrackKeys = [self shuffle:tempTrackKeys];
    
    return tempTrackKeys;
}

- (NSMutableArray *) getEnough: (NSMutableArray *) list
{
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:[list count]];
    
    while (newList.count < 120 && list.count > 0) {
        [newList addObjectsFromArray:list];
    }
    
    if(newList.count > 500) {
        [newList removeObjectsInRange:NSMakeRange(500, newList.count - 501)];
    }
    
    return newList;
}

- (NSMutableArray *) shuffle: (NSMutableArray *) list
{
    NSMutableArray *newList = [[NSMutableArray alloc] initWithCapacity:[list count]];
    int oldListCount = list.count;
    
    while (oldListCount != newList.count) {
        int listIndex = (arc4random() % list.count);
        NSString *testObject = [list objectAtIndex:listIndex];
        
        [newList  addObject:testObject];
        [list removeObjectAtIndex:listIndex];
    }
    
    return newList;
}

@end
