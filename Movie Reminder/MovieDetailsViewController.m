//
//  MovieDetailsViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MovieDetailsViewController.h"
#import "MovieImageViewController.h"
#import "MovieMapViewController.h"
#import "MovieMapAnnotation.h"
#import "MovieHelper.h"
#import "MoviePlayerViewController.h"
#import "MovieWebViewController.h"
#import "MovieWordCloudViewController.h"

#define MOVIE_DETAILS_NUM_SECTIONS  4
#define MOVIE_DETAILS_NUM_ROWS_PER_SECTION 1

#define ADD_FAVORITES @"Add Favorite"
#define REMOVE_FAVORITES @"Remove Favorite"
#define ADD_REMINDER @"Add Reminder"
#define REMOVE_REMINDER @"Remove Reminder"
#define TWEET @"Tweet on Twitter"
#define FACEBOOK @"Post on Facebook"
#define WORD_CLOUD @"Make Word Cloud!"
#define NEARBY @"Find Playing Nearby"
#define TRAILER @"Watch Trailer"
#define CANCEL @"Cancel"

#define FACEBOOK_APP_ID @"176356365716222"

#define UNKNOWN @"Unknown"
#define RELEASE_DATE @"Release Date"
#define STORYLINE @"Storyline"
#define CAST @"Cast"
#define WEBSITE @"Website"

@interface MovieDetailsViewController() <UIActionSheetDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *detailsTable;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UIButton *favoritesButton;
@property (strong, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *calendar;
@property (strong, nonatomic) NSMutableArray *detailsTableData;
@end

@implementation MovieDetailsViewController

@synthesize detailsTable = _detailsTable;
@synthesize imageButton = _imageButton;
@synthesize favoritesButton = _favoritesButton;
@synthesize reminderButton = _reminderButton;
@synthesize movie = _movie;
@synthesize eventStore = _eventStore;
@synthesize calendar = _calendar;
@synthesize detailsTableData = _detailsTableData;
@synthesize facebook = _facebook;
@synthesize actionSheet = _actionSheet;

- (void)setMovie:(Movie *)movie
{
    if (_movie != movie) {
        _movie = movie;
        self.title = movie.name;
    }
}

- (EKEventStore *)eventStore
{
    if (_eventStore == nil) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (Facebook *)facebook
{
    if (_facebook == nil) {
        _facebook = [[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self];
    }
    return _facebook;
}

-(NSMutableArray *)detailsTableData
{
    if (_detailsTableData == nil) {
        _detailsTableData = [[NSMutableArray alloc] init];
        
        // Set up static table data
        NSString *releaseDate;
        NSString *cast;
        NSString *details;
        NSString *link;
        
        if (self.movie.releaseDate) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            releaseDate = [dateFormatter stringFromDate:self.movie.releaseDate];
        } else {
            releaseDate = UNKNOWN;
        }
        [_detailsTableData addObject:releaseDate];
        
        if (self.movie.cast) {
            cast = self.movie.cast;
        } else {
            cast = UNKNOWN;
        }
        [_detailsTableData addObject:cast];
        
        if (self.movie.details) {
            details = self.movie.details;
        } else {
            details = UNKNOWN;
        }
        [_detailsTableData addObject:details];
        
        if (self.movie.link) {
            link = self.movie.link;
        } else {
            link = UNKNOWN;
        }
        [_detailsTableData addObject:link];
    }
    
    return _detailsTableData;
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Set up the view as a UITableViewController delegate
    self.detailsTable.delegate = self;
    self.detailsTable.dataSource = self;
    
    // Set background image for movie image button
    UIImage *buttonImage;
    if (self.movie.thumbnail) {
        buttonImage = [UIImage imageWithData:self.movie.thumbnail];
    } else {
        buttonImage = [UIImage imageNamed:@"placeholder.png"];
        self.imageButton.adjustsImageWhenDisabled = NO;
        self.imageButton.enabled = NO;
    }
    [self.imageButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    // Set the title of the favorites button
    if ([self.movie.favorite boolValue]) {
        [self.favoritesButton setTitle:REMOVE_FAVORITES forState:UIControlStateNormal];
    } else {
        [self.favoritesButton setTitle:ADD_FAVORITES forState:UIControlStateNormal];
    }
    
    // Set up event store and calendar
    self.calendar = [self.eventStore defaultCalendarForNewEvents];
    
    // Set the title of the reminder button
    EKEvent *checkEvent = [self.eventStore eventWithIdentifier:self.movie.eventId];
    if (checkEvent == nil) {
        [self.reminderButton setTitle:ADD_REMINDER forState:UIControlStateNormal];
        // Maybe the movie reminder was deleted from the calendar app
        if (![self.movie.eventId isEqualToString:@""]) {
            // Update the state of the movie
            self.movie.eventId = @"";
            [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                // Save movie back in the movie document
                [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            }];
        }
    } else {
        [self.reminderButton setTitle:REMOVE_REMINDER forState:UIControlStateNormal];
    }
    
    // Sign up for event store notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification 
                                               object:self.eventStore];
}

- (void)viewWillUnload
{
    // Remove event store notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:EKEventStoreChangedNotification 
                                               object:self.eventStore];
    [super viewWillUnload];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MOVIE_DETAILS_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MOVIE_DETAILS_NUM_ROWS_PER_SECTION;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if (indexPath.section == 3) {
        NSString *link = [self.detailsTableData objectAtIndex:indexPath.section];
        if (![link isEqualToString:UNKNOWN]) {
            NSURL *movieWebLink = [NSURL URLWithString:link];
            MovieWebViewController *movieWebController = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieWebViewController"];
            [movieWebController setLoadURL:movieWebLink];
            [movieWebController setTitle:self.movie.name];
            [self presentModalViewController:movieWebController animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return RELEASE_DATE;
        case 1:
            return CAST;
        case 2:
            return STORYLINE;
        case 3:
            return WEBSITE;
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    CGSize size = [[self.detailsTableData objectAtIndex:indexPath.section] sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, MAXFLOAT)];
    height = 20 + size.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Movie Detail Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.detailsTableData objectAtIndex:indexPath.section];
    
    // Make only the website link selectable
    if (indexPath.section != 3) {
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    // Set up for multi line text in the cell
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel sizeToFit];
    
    return cell;
}

- (IBAction)favoritesPressed:(UIButton *)sender
{
    NSString *buttonTitle;
    
    if ([self.favoritesButton.titleLabel.text isEqualToString:ADD_FAVORITES]) {
        self.movie.favorite = [NSNumber numberWithBool:YES];
        buttonTitle = REMOVE_FAVORITES;
    } else {
        self.movie.favorite = [NSNumber numberWithBool:NO];
        buttonTitle = ADD_FAVORITES;
    }
    
    [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
        [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        [self.favoritesButton setTitle:buttonTitle forState:UIControlStateNormal];
    }];
}

- (IBAction)trailerPressed:(UIButton *)sender
{    
    NSURL *url = [NSURL URLWithString:self.movie.trailerLink];
    MoviePlayerViewController *moviePlayer = [[MoviePlayerViewController alloc] init];
    [moviePlayer setTrailerLink:url];
    [self presentModalViewController:moviePlayer animated:YES];
    [moviePlayer startTrailer];
}

- (void)wordCloudPressed
{
    MovieWordCloudViewController *wordCloudController = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieWordCloudViewController"];
    [wordCloudController setMovie:self.movie];
    [self.navigationController pushViewController:wordCloudController animated:YES];
}

#pragma mark - MKMapViewDelegate

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.movie.playingAt count]];
    for (Theatre *theatre in self.movie.playingAt) {
        [annotations addObject:[MovieMapAnnotation annotationForTheatre:theatre]];
    }
    return annotations;
}

- (void)nearbyPressed
{
    MovieMapViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieMapViewController"];
    [mapViewController setAnnotations:[self mapAnnotations]];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)tweetPressed
{
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    if (self.movie.thumbnail) {
        [twitter addImage:[UIImage imageWithData:self.movie.thumbnail]];
    }
    
    if (self.movie.link) {
        [twitter addURL:[NSURL URLWithString:[NSString stringWithString:self.movie.link]]];
    }
    
    [twitter setInitialText:[[@"Check out " stringByAppendingString:self.movie.name] stringByAppendingString:@" on Movie Reminder!"]];
    
    [self presentModalViewController:twitter animated:YES];
    
    // Block to be executed once the tweet view is closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        [self dismissModalViewControllerAnimated:YES];
    };
}

#pragma mark - FBSessionDelegate

- (void)facebookPressed
{
    // Set up Facebook
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                @"publish_stream",
                                nil];
        [self.facebook authorize:permissions];
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   FACEBOOK_APP_ID, @"app_id",
                                   self.movie.link, @"link",
                                   self.movie.imageLink, @"picture",
                                   nil];
    
    [self.facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id) annotation
{
    return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void) fbDidLogout
{
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)presentAddReminderView
{
    EKEventEditViewController *addEventController = [[EKEventEditViewController alloc] init];
    addEventController.eventStore = self.eventStore;
    addEventController.navigationBar.tintColor = [UIColor purpleColor];
    
    EKEvent *addEvent = addEventController.event;
    addEvent.title = self.movie.name;
    NSTimeInterval timeDiff = [self.movie.releaseDate timeIntervalSinceNow];
    if (timeDiff > 0) {
        addEvent.startDate = self.movie.releaseDate;
    } else {
        addEvent.startDate = [NSDate date];
    }
    addEvent.endDate = [addEventController.event.startDate dateByAddingTimeInterval:10800];
    addEvent.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithRelativeOffset:-300]];
    addEvent.URL = [NSURL URLWithString:self.movie.link];
    addEvent.notes = [[@"Let's go watch " stringByAppendingString:self.movie.name] stringByAppendingString:@"!"];
       
    [self presentModalViewController:addEventController animated:YES];
    addEventController.editViewDelegate = self;
}

- (void)deleteReminder
{
    NSString *eventId = self.movie.eventId;
    EKEvent *deleteEvent = [self.eventStore eventWithIdentifier:eventId];
    
    NSError *error;
    [self.eventStore removeEvent:deleteEvent span:EKSpanThisEvent commit:YES error:&error];
    
    if (error == nil) {
        // Set the button title
        [self.reminderButton setTitle:ADD_REMINDER forState:UIControlStateNormal];
        // Unset the movie event id
        self.movie.eventId = @"";
        [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
            // Save movie back in the movie document
            [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    } else {
        NSLog(@"Error while deleting movie event: %@", error);
    }
}

- (IBAction)reminderPressed:(id)sender
{
    if ([self.reminderButton.titleLabel.text isEqualToString:ADD_REMINDER]) {
        [self presentAddReminderView];
    } else {
        [self deleteReminder];
    }
}

#pragma mark - UIActionSheetDelegate

- (IBAction)actionPressed:(UIBarButtonItem *)sender
{
    if (self.actionSheet) {
        // do nothing
    } else {
        UIActionSheet *actionSheet;
        NSTimeInterval timeDiff = [self.movie.releaseDate timeIntervalSinceNow];
        if (timeDiff < 0) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Movie Detail Actions" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:WORD_CLOUD, NEARBY, TWEET, FACEBOOK, nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Movie Detail Actions" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:WORD_CLOUD, TWEET, FACEBOOK, nil];
        }
        
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:NEARBY]) {
        [self nearbyPressed];
    } else if ([choice isEqualToString:TWEET]) {
        [self tweetPressed];
    } else if ([choice isEqualToString:FACEBOOK]) {
        [self facebookPressed];
    } else if ([choice isEqualToString:WORD_CLOUD]) {
        [self wordCloudPressed];
    }
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
	NSError *error;
	switch (action) {
		case EKEventEditViewActionCanceled:
			break;
		case EKEventEditViewActionSaved:
        {
            // Save the event
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent commit:YES error:&error];
            if (error == nil) {
                // Set reminder button title
                [self.reminderButton setTitle:REMOVE_REMINDER forState:UIControlStateNormal];
                // Update the event id of the movie
                self.movie.eventId = controller.event.eventIdentifier;
                [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                    // Save the event id in the movie document
                    [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                }];
            } else {
                NSLog(@"Error while saving movie event");
            }
			break;
        }
		default:
			break;
	}
	[controller dismissModalViewControllerAnimated:YES];	
}

- (void)eventStoreChanged:(NSNotification *)sender
{
    EKEventStore *eventStore = (EKEventStore *)[sender object];
    if (eventStore == self.eventStore) {
        EKEvent *checkEvent = [self.eventStore eventWithIdentifier:self.movie.eventId];
        // Check if the event was deleted from an external application
        if (checkEvent == nil) {
            [self.reminderButton setTitle:ADD_REMINDER forState:UIControlStateNormal];
            // Unset the movie event id
            self.movie.eventId = @"";
            [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                // Save movie back in the movie document
                [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
            }];
        }
    }
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
	return self.calendar;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Movie Image"]) {
        [segue.destinationViewController setMovie:self.movie];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setDetailsTable:nil];
    [self setImageButton:nil];
    [self setFavoritesButton:nil];
    [self setReminderButton:nil];
    [super viewDidUnload];
}

@end
