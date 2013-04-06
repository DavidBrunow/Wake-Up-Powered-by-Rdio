//
//  DHBMusicLibrary.h
//  Rdio Alarm
//
//  Created by David Brunow on 4/5/13.
//
//

#import <Foundation/Foundation.h>
#import <Rdio/Rdio.h>
#import "DHBPlaylist.h"

@interface DHBMusicLibrary : NSObject <RDAPIRequestDelegate>

@property (nonatomic, retain) NSMutableArray *playlists;
@property (nonatomic) DHBPlaylist *selectedPlaylist;

@end
