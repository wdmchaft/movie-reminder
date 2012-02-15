//
//  MovieImageViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieImageViewController.h"

@interface MovieImageViewController() <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *movieScrollView;
@end

@implementation MovieImageViewController
@synthesize movieImageView = _movieImageView;
@synthesize movieScrollView = _movieScrollView;
@synthesize movie = _movie;

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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.movieImageView;
}

- (void)setupImage:(NSData *)data
{
    self.movieImageView.image = [UIImage imageWithData:data];
    self.movieScrollView.delegate = self;
    self.movieScrollView.contentSize = self.movieImageView.image.size;
    self.movieImageView.frame = CGRectMake(0, 0, self.movieScrollView.contentSize.width, self.movieScrollView.contentSize.height);
    
    CGFloat widthScale = (self.movieScrollView.bounds.size.width / self.movieScrollView.contentSize.width);
    CGFloat heightScale = (self.movieScrollView.bounds.size.height / self.movieScrollView.contentSize.height);
    
    self.movieScrollView.minimumZoomScale = MIN(widthScale, heightScale);
    self.movieScrollView.maximumZoomScale = 5;
    self.movieScrollView.zoomScale = MAX(widthScale, heightScale);
}

- (void)loadImage
{
    if (self.movieImageView) {
        if (self.movie.imageLink) {
            [self startSpinner:@"Loading..."];
            dispatch_queue_t downloadQueue = dispatch_queue_create("Movie Image Downloader", NULL);
            dispatch_async(downloadQueue, ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.movie.imageLink]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setupImage:data];
                    [self stopSpinner];
                });
            });
            dispatch_release(downloadQueue);
        } else {
            self.movieImageView.image = nil;
        }
    }
}

- (void)setMovie:(Movie *)movie
{
    if (![_movie isEqual:movie]) {
        _movie = movie;
        self.title = movie.name;
        if (self.movieImageView.window) {
            [self loadImage];           
        } else {                     
            self.movieImageView.image = nil;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.movieImageView.image && self.movie.imageLink) {
        [self loadImage];
    }
}

- (void)viewDidUnload
{
    self.movieImageView = nil;
    [self setMovieScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
