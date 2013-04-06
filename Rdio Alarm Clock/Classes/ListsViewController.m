//
//  ListsViewController.m
//  Rdio Alarm
//
//  Created by David Brunow on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListsViewController.h"
#import "AppDelegate.h"

@interface ListsViewController ()

@end

@implementation ListsViewController

@synthesize typesInfo = _typesInfo, playlistsInfo = _playlistsInfo, tracksInfo = _tracksInfo, numberOfPlaylistsOwned = _numberOfPlaylistsOwned, numberOfPlaylistsCollab = _numberOfPlaylistsCollab, numberOfPlaylistsSubscr = _numberOfPlaylistsSubscr, selectedPlaylistPath = _selectedPlaylistPath, selectedPlaylist = _selectedPlaylist;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect chooseMusicFrame = [[UIScreen mainScreen] bounds];
    if ([self.navigationController isNavigationBarHidden]) {
        chooseMusicFrame.size.height = [[UIScreen mainScreen] bounds].size.height;
        
    } else {
        chooseMusicFrame.size.height = [[UIScreen mainScreen] bounds].size.height - self.navigationController.navigationBar.bounds.size.height;
    }
    
    self.chooseMusic = [[UITableView alloc] initWithFrame:chooseMusicFrame style:UITableViewStylePlain];
    
    [self.chooseMusic setBackgroundColor:[UIColor clearColor]];
    [self.chooseMusic setSeparatorColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [self.chooseMusic setBackgroundView:nil];
    [self.chooseMusic setDelegate:self];
    [self.chooseMusic setDataSource:self];
    
    [self.view addSubview:self.chooseMusic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *cellLabel = @"";

    if (indexPath.section == 0) {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue]] playlistName];
    } else if (indexPath.section == 1) {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue] + [[self.numberOfRows objectAtIndex:1] integerValue]] playlistName];
    } else {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row] playlistName];
    }
    
    return [cellLabel sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20, 100) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    int selectedSection = 0;
    
    if(section == 0) {
        selectedSection = 1;
    } else if(section == 1) {
        selectedSection = 2;
    } else if(section == 2) {
        selectedSection = 0;
    }
    
    int numberOfRows = 0;
    
    numberOfRows = [[self.numberOfRows objectAtIndex:selectedSection] integerValue];
    
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.numberOfRows = [[NSMutableArray alloc] init];
    
    int numberOfSections = 0;
    int numberOfRows = 0;
    NSString *lastPlaylistCategory = @"";
    
    for(int x = 0; x < appDelegate.musicLibrary.playlists.count; x++) {
        if([lastPlaylistCategory isEqualToString:@""]) {
            lastPlaylistCategory = [[appDelegate.musicLibrary.playlists objectAtIndex:x] playlistCategory];
        }
        if(![lastPlaylistCategory isEqualToString:[[appDelegate.musicLibrary.playlists objectAtIndex:x] playlistCategory]]) {
            numberOfSections++;
            [self.numberOfRows addObject:[NSNumber numberWithInt:numberOfRows]];
            numberOfRows = 0;
        }
        numberOfRows++;
        lastPlaylistCategory = [[appDelegate.musicLibrary.playlists objectAtIndex:x] playlistCategory];
    }
    
    if(appDelegate.musicLibrary.playlists.count > 0) {
        [self.numberOfRows addObject:[NSNumber numberWithInt:numberOfRows]];
        numberOfSections++;
    }
    
    return numberOfSections;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shoppingListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shoppingListCell"];
    }
    
    NSString *cellLabel = @"";
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (indexPath.section == 0) {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue]] playlistName];
    } else if (indexPath.section == 1) {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue] + [[self.numberOfRows objectAtIndex:1] integerValue]] playlistName];
    } else {
        cellLabel = [[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row] playlistName];
    }
    
    cell.textLabel.textColor = [UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0];
    cell.textLabel.text = [cellLabel lowercaseString];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0]];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cell.textLabel setNumberOfLines:0];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [cell setSelectedBackgroundView:bgColorView];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //UILabel *sectionView = [[UILabel alloc] initWithFrame:[tableView rectForHeaderInSection:section]];
    UILabel *sectionView = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 0.0, 200.0, 30.0)];
    
    [sectionView setTextColor:[UIColor colorWithRed:0.48 green:0.37 blue:0.58 alpha:1.0]];
    [sectionView setBackgroundColor:[UIColor colorWithRed:.09 green:.06 blue:.117 alpha:1.0]];
    [sectionView setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]];
    
    if (section == 0) {
        sectionView.text = [[NSString stringWithFormat:NSLocalizedString(@"OWNED HEADER", nil)] uppercaseString];
    } else if (section == 1) {
        sectionView.text = [[NSString stringWithFormat:NSLocalizedString(@"SUBSCRIBED HEADER", nil)] uppercaseString];
    } else {
        sectionView.text = [[NSString stringWithFormat:NSLocalizedString(@"COLLAB HEADER", nil)] uppercaseString];
    }
    
    return sectionView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"";
    
    if (section == 0) {
        sectionName = [NSString stringWithFormat:NSLocalizedString(@"COLLAB", nil)];
    } else if (section == 1) {
        sectionName = [NSString stringWithFormat:NSLocalizedString(@"OWNED", nil)];
    } else {
        sectionName = [NSString stringWithFormat:NSLocalizedString(@"SUBSCRIBED", nil)];    }
    
    return sectionName;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];

    int selectedSection = 0;

    if(indexPath.section == 0) {
        selectedSection = 1;
    } else if(indexPath.section == 1) {
        selectedSection = 2;
    } else if(indexPath.section == 2) {
        selectedSection = 0;
    }
    [appDelegate.alarmClock setPlaylistPath:[NSIndexPath indexPathForItem:indexPath.row inSection:selectedSection]];
    
    if (indexPath.section == 0) {
        [appDelegate setSelectedPlaylist:[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue]]];
    } else if (indexPath.section == 1) {
        [appDelegate setSelectedPlaylist:[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row + [[self.numberOfRows objectAtIndex:0] integerValue] + [[self.numberOfRows objectAtIndex:1] integerValue]]];
    } else {
        [appDelegate setSelectedPlaylist:[appDelegate.musicLibrary.playlists objectAtIndex:indexPath.row]];
    }
    
    NSLog(@"section selected: %d, row selected: %d", indexPath.section, indexPath.row);
    [appDelegate.alarmClock setPlaylistName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
