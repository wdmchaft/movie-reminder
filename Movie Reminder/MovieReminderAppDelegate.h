//
//  MovieReminderAppDelegate.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/22/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieReminderAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)fetchAndUpdateMovieDatabase;

@end
