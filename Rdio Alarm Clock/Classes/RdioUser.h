//
//  RdioUser.h
//  Rdio Alarm
//
//  Created by David Brunow on 4/5/13.
//
//

#import <Foundation/Foundation.h>
#import <Rdio/Rdio.h>

@interface RdioUser : NSObject <RdioDelegate>

@property (nonatomic) bool isLoggedIn;


- (void) login;
- (void) logout;

@end
