//
//  ListsViewController.h
//  Rdio Alarm
//
//  Created by David Brunow on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 

@property (nonatomic) UITableView *chooseMusic;
@property (nonatomic, retain) NSMutableArray *numberOfRows;

@end
