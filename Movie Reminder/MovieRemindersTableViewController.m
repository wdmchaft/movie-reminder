//
//  MovieRemindersTableViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieRemindersTableViewController.h"
#import "MovieHelper.h"
#import "Movie+Create.h"

@interface MovieRemindersTableViewController() <EKEventEditViewDelegate>
@property (strong, nonatomic) NSMutableArray *movieList;
@property (strong, nonatomic) NSMutableArray *reminderList;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) EKCalendar *calendar;
@end

@implementation MovieRemindersTableViewController

@synthesize movieList = _movieList;
@synthesize reminderList = _reminderList;
@synthesize eventStore = _eventStore;
@synthesize calendar = _calendar;

- (NSMutableArray *)movieList
{
    if (_movieList == nil) {
        _movieList = [[NSMutableArray alloc] init];
    }
    return _movieList;
}

- (NSMutableArray *)reminderList
{
    if (_reminderList == nil) {
        _reminderList = [[NSMutableArray alloc] init];
    }
    return _reminderList;
}

- (EKEventStore *)eventStore
{
    if (_eventStore == nil) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void)startSpinner:(NSString *)activity
{
    self.navigationItem.title = activity;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)stopSpinner
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.title = self.title;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)fetchReminderEvents:(UIManagedDocument *)movieDocument
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"eventId"
                                                                                     ascending:NO 
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];

    NSError *error;
    NSArray *fetchedMovies = [movieDocument.managedObjectContext executeFetchRequest:request error:&error];
    
    [self.movieList removeAllObjects];
    [self.reminderList removeAllObjects];
    
    // Rebuild the model
    if (error == nil) {
        for (Movie *movie in fetchedMovies) {
            EKEvent *event = [self.eventStore eventWithIdentifier:movie.eventId];
            if (event) {
                [self.movieList addObject:movie];
                [self.reminderList addObject:event];
            }
        }
    }
}

- (void)updateReminders
{
    [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
        [self fetchReminderEvents:movieDocument];
        [self.tableView reloadData];
    }];
}

- (void)eventStoreChanged:(NSNotification *)sender
{
    EKEventStore *eventStore = (EKEventStore *)[sender object];
    if (eventStore == self.eventStore) {
        BOOL changed = NO;
        for (int i = 0; i < [self.movieList count]; i++) {
            Movie *movie = [self.movieList objectAtIndex:i];
            EKEvent *checkEvent = [self.eventStore eventWithIdentifier:movie.eventId];
            // Check if the event was deleted from an external application
            if (checkEvent == nil) {
                // Unset the movie event id
                movie.eventId = @"";
                [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                    // Save movie back in the movie document
                    [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                }];
                changed = YES;
            }
        }
        
        if (changed) {
            [self updateReminders];
        }
    }
}

- (void)willShowController:(NSNotification *)sender
{
    UIViewController *controller = (UIViewController *)[sender object];
    if ([controller isKindOfClass:EKEventEditViewController.class]){
        UINavigationController *navController = [(UINavigationController *)controller visibleViewController].navigationController;
        navController.navigationBar.tintColor = [UIColor purpleColor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.calendar = [self.eventStore defaultCalendarForNewEvents];
    
    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(willShowController:) 
                                                 name:@"UINavigationControllerWillShowViewControllerNotification" 
                                               object:nil];
    
    [self updateReminders];
    
    // Sign up for event store notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification 
                                               object:self.eventStore];
}

- (void)viewDidUnload
{
    // Remove event store notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:EKEventStoreChangedNotification 
                                                  object:self.eventStore];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:@"UINavigationControllerWillShowViewControllerNotification" 
                                               object:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.reminderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Reminder Cell";
    
    // Add disclosure to cell
	UITableViewCellAccessoryType editableCellAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.accessoryType = editableCellAccessoryType;
    cell.textLabel.text = [[self.reminderList objectAtIndex:indexPath.row] title];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[[self.reminderList objectAtIndex:indexPath.row] startDate]];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKEventViewController *eventViewController = [[EKEventViewController alloc] init];
	eventViewController.event = [self.reminderList objectAtIndex:indexPath.row];
	eventViewController.allowsEditing = YES;
    eventViewController.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    [self.navigationController pushViewController:eventViewController animated:YES];
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{	
	NSError *error;
	EKEvent *event = controller.event;
	
	switch (action) {
		case EKEventEditViewActionCanceled:
			break;
			
		case EKEventEditViewActionSaved:
			[controller.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
			break;
			
		case EKEventEditViewActionDeleted:
			[controller.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&error];
            if (error == nil) {
                // Update core data, since the event has been removed
                [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                    Movie *movie = [Movie movieWithEventId:controller.event.eventIdentifier inManagedObjectContext:movieDocument.managedObjectContext];
                    // Update the event id
                    movie.eventId = @"";
                    // Save the movie back in the movie document
                    [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
                }];
                [self updateReminders];
            }
			break;
			
		default:
			break;
	}
    
	[controller dismissModalViewControllerAnimated:YES];
}

- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
    return self.calendar;
}

@end
