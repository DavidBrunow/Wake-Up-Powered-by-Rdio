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
            if ([[[data objectForKey:key] objectForKey:@"canStream"] isEqual:[NSNumber numberWithBool:YES]]) {
            } else {
                [self.trackKeys removeObjectIdenticalTo:key];
            }
        }
    }
    /*
    for(NSString *trackKey in self.trackKeys) {
        NSLog(@"Key: %@", trackKey);
    }
    */
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError*)error {
    if([[[error userInfo] objectForKey:@"NSLocalizedDescription"] isEqualToString:@"The request timed out."]) {
        [self determineStreamableSongs];
    }
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

    NSString *songsToPlayString = [self.trackKeys objectAtIndex:0];
    for (int x = 1; x < self.trackKeys.count; x++) {
        songsToPlayString = [NSString stringWithFormat:@"%@, %@", songsToPlayString, [self.trackKeys objectAtIndex:x]];
    }
    
    NSDictionary *trackInfo = [[NSDictionary alloc] initWithObjectsAndKeys:songsToPlayString, @"keys", @"canStream", @"type", nil];
    [[AppDelegate rdioInstance] callAPIMethod:@"get" withParameters:trackInfo delegate:self];
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
