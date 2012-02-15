//
//  MoviePlayerViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController() 
@property (nonatomic, strong) MPMoviePlayerController *player;
@end

@implementation MoviePlayerViewController

@synthesize trailerLink = _trailerLink;
@synthesize player = _player;

- (void) moviePlayerLoadStateChanged:(NSNotification *)notification 
{
	// Start playback unless the movie load state is unknown
	if ([self.player loadState] != MPMovieLoadStateUnknown) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                         name:MPMoviePlayerLoadStateDidChangeNotification 
                                                       object:nil];
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if(UIInterfaceOrientationIsLandscape(orientation)) {
            [self.view setBounds:CGRectMake(0, 0, 480, 320)];
            [self.view setCenter:CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2)];
            [self.player.view setFrame:CGRectMake(0, 0, 480, 320)];
        } else {
            [self.view setBounds:screenBounds];
            [self.view setCenter:CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2)];
            [self.player.view setFrame:screenBounds];
        }
        [self.view addSubview:[self.player view]];
        
        [self.player play];
	}
}

- (void)moviePlaybackDidFinish:(NSNotification *)notification 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:nil];
    
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)startTrailer
{
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:self.trailerLink];
    self.player.controlStyle = MPMovieControlStyleFullscreen;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.player setFullscreen:YES animated:YES];
    [self.player prepareToPlay];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayerLoadStateChanged:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlaybackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setView:[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
	[self.view setBackgroundColor:[UIColor blackColor]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
        [self.view setBounds:screenBounds];
        [self.view setCenter:CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2)];
        [self.player.view setFrame:CGRectMake(0, 0, 480, 320)];
    } else {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        [self.view setBounds:screenBounds];
        [self.view setCenter:CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2)];
        [self.player.view setFrame:CGRectMake(0, 0, 320, 460)];
    }
    [self.player setControlStyle:MPMovieControlStyleFullscreen];

}

@end
