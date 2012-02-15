//
//  MovieWordCloudViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieWordCloudViewController.h"
#import "MovieWordCloudView.h"

#define EMAIL_CLOUD @"Email to Friend"
#define SAVE_CLOUD @"Save to Photos"
#define SHAKE_CLOUD @"Shake!"
#define CANCEL @"Cancel"

@interface MovieWordCloudViewController() <UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MovieWordCloudViewDataSource>
@property (strong, nonatomic) IBOutlet MovieWordCloudView *movieWordCloudView;
@property (weak, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) NSMutableArray *wordList;
@property (strong, nonatomic) NSArray *commonWords;
@end

@implementation MovieWordCloudViewController

@synthesize movie = _movie;
@synthesize movieWordCloudView = _movieWordCloudView;
@synthesize actionSheet = _actionSheet;
@synthesize wordList = _wordList;
@synthesize commonWords = _commonWords;

- (NSArray *)commonWords
{
    if (_commonWords == nil) {
        _commonWords = [NSArray arrayWithObjects:@"", @"\"\"", @"i", @"if", @"is", @"as", @"its", @"us", @"the", @"are", @"to", @"into", @"of", @"for", @"in", @"a", @"it", @"this", @"you", @"your", @"with", @"on", @"and", @"how", @"an", @"by", @"be", @"at", @"that", @"why", @"when", @"where", @"who", @"what", @"will", nil];
    }
    return _commonWords;
}

- (NSMutableArray *)wordList
{
    if (_wordList == nil) {
        _wordList = [[NSMutableArray alloc] init];
    }
    return _wordList;
}

- (UIImage *)viewAsImage
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()]; 
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void)saveImageToPhotosAlbum:(UIImage *)image
{
     UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)emailImage:(UIImage *)image
{
    MFMailComposeViewController *emailViewController = [[MFMailComposeViewController alloc] init];
    emailViewController.mailComposeDelegate = self;
    emailViewController.navigationBar.tintColor = [UIColor purpleColor];
    
    [emailViewController setSubject:[@"Movie Word Cloud for " stringByAppendingString:self.movie.name]];

    NSString *emailBody = @"Movie Word Cloud by Movie Reminder";
    [emailViewController setMessageBody:emailBody isHTML:NO];
    
    NSData *data = UIImagePNGRepresentation(image);
    [emailViewController addAttachmentData:data mimeType:@"image/png" fileName:@"MovieWordCloud"];
    
    [self presentModalViewController:emailViewController animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)generateWordCloud
{
    NSMutableArray *movieStrings = [[NSMutableArray alloc] init];
    [movieStrings addObjectsFromArray:[self.movie.name componentsSeparatedByString:@" "]];
    [movieStrings addObjectsFromArray:[self.movie.cast componentsSeparatedByString:@", "]];
    [movieStrings addObjectsFromArray:[self.movie.details componentsSeparatedByString:@" "]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    [movieStrings addObject:[dateFormatter stringFromDate:self.movie.releaseDate]];
    
    // Clear out existing word list
    [self.wordList removeAllObjects];
    
    for (NSString *string in movieStrings) {
        
        NSString *cleanString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cleanString = [cleanString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        cleanString = [cleanString stringByReplacingOccurrencesOfString:@"." withString:@""];
        cleanString = [cleanString stringByReplacingOccurrencesOfString:@"," withString:@""];
        cleanString = [cleanString stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        if (![self.commonWords containsObject:[cleanString lowercaseString]]) {
            [self.wordList addObject:cleanString];
        }
    }
    
    // Update the view
    [self.movieWordCloudView clear];
    [self.movieWordCloudView setNeedsDisplay];
}

- (void)setMovie:(Movie *)movie
{
    if (_movie != movie) {
        _movie = movie;
        self.title = [movie.name stringByAppendingString:@" Word Cloud"];
        [self generateWordCloud];
    }
}

- (void)setMovieWordCloudView:(MovieWordCloudView *)movieWordCloudView
{
    _movieWordCloudView = movieWordCloudView;
    self.movieWordCloudView.movieWordCloudDataSource = self;
}

- (IBAction)actionPressed:(UIBarButtonItem *)sender
{
    if (self.actionSheet) {
        // do nothing
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Word Cloud Actions" delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:SHAKE_CLOUD, SAVE_CLOUD, EMAIL_CLOUD, nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.actionSheet = actionSheet;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:SHAKE_CLOUD]) {
        [self generateWordCloud];
    } else if ([choice isEqualToString:SAVE_CLOUD]) {
        [self saveImageToPhotosAlbum:[self viewAsImage]];
    } else if ([choice isEqualToString:EMAIL_CLOUD]) {
        [self emailImage:[self viewAsImage]];
    }
}

#pragma mark - MovieWordCloudViewDataSource

- (NSArray *)getWordList:(MovieWordCloudView *)sender
{
    return self.wordList;
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // Generate a new cloud
    [self generateWordCloud];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidUnload
{
    [self setMovieWordCloudView:nil];
    [super viewDidUnload];
}
@end
