//
//  DHBPlaylist.h
//  Rdio Alarm
//
//  Created by David Brunow on 3/1/13.
//
//

#import <Foundation/Foundation.h>
#import <Rdio/Rdio.h>

@interface DHBPlaylist : NSObject <RDAPIRequestDelegate>

@property (nonatomic) NSString *playlistName;
@property (nonatomic) NSString *playlistKey;
@property (nonatomic) NSString *playlistCategory;
@property (nonatomic) NSMutableArray *trackKeys;
@property (nonatomic) bool isSelected;

- (void)setTrackKeys:(NSMutableArray *)trackKeys clean:(bool) isClean;
- (NSMutableArray *)getShuffledTrackKeys;

@end
