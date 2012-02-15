//
//  MovieTableViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieTableViewController.h"
#import "MovieDetailsViewController.h"
#import "Movie.h"
#import "MovieHelper.h"
#import "MovieReminderAppDelegate.h"

#define RAND(x) arc4random() % x

@interface MovieTableViewController() <UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@end

@implementation MovieTableViewController
@synthesize type = _type;
@synthesize searchBar = _searchBar;
@synthesize refreshButton = _refreshButton;

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
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    self.navigationItem.title = self.title;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender
{
    // Update the data in the model
    [((MovieReminderAppDelegate *)[[UIApplication sharedApplication] delegate]) fetchAndUpdateMovieDatabase];
}

- (void)setupFetchedResultsController:(UIManagedDocument *)movieDocument
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"releaseDate"
                                                                                     ascending:NO 
                                                                                      selector:@selector(compare:)]];
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    switch (self.type) {
        case MovieTableViewNowPlaying:
        {
            NSDate *now = [[NSDate alloc] init];
            [subPredicates addObject:[NSPredicate predicateWithFormat:@"(releaseDate <= %@)", now]];
            break;
        }
        case MovieTableViewComingSoon:
        {
            NSDate *now = [[NSDate alloc] init];
            [subPredicates addObject:[NSPredicate predicateWithFormat:@"(releaseDate > %@)", now]];
            break;
        }
        case MovieTableViewMyMovies:
        {
            [subPredicates addObject:[NSPredicate predicateWithFormat:@"favorite = 1"]];
            break;
        }
        default:
            break;
    }

    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"name beginswith[c] %@", self.searchBar.text]];
    }
    
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:movieDocument.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        // Get a movie from a random index path and push the related details view controller
        NSUInteger section = RAND([self.fetchedResultsController.sections count]);
        NSUInteger row = RAND([[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects]);
        Movie *randomMovie = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        MovieDetailsViewController *movieDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MovieDetailsViewController"];
        [movieDetailsViewController setMovie:randomMovie];
        [self.navigationController pushViewController:movieDetailsViewController animated:YES];
    }
}

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.showsCancelButton = NO;
    
    switch (self.tabBarController.selectedIndex) {
        case 0:
            self.type = MovieTableViewNowPlaying;
            break;
        case 1:
            self.type = MovieTableViewComingSoon;
            break;
        case 2:
            self.type = MovieTableViewMyMovies;
            break;
        default:
            break;
    }
    
    [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
        [self setupFetchedResultsController:movieDocument];
    }];
    
    // Detect shake gestures
    [self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Set navigation bar and search bar colors
    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    self.searchBar.tintColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Movie Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Get the movie at the given row
    Movie *movie = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell
    cell.textLabel.text = movie.name;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:movie.releaseDate];
    
    if (movie.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:movie.thumbnail];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
    }
       
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Reset the fetchResultsController to include a predicate based on the search text
    [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
        [self setupFetchedResultsController:movieDocument];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text= @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Movie *movie = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [segue.destinationViewController setMovie:movie];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload {
    [self setRefreshButton:nil];
    [super viewDidUnload];
}
@end
