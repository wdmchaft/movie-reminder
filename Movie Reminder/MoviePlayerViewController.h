//
//  MoviePlayerViewController.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MoviePlayerViewController : UIViewController

@property (nonatomic, strong) NSURL *trailerLink;
- (void)startTrailer;

@end
