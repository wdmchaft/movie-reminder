//
//  MovieDetailsViewController.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <Twitter/Twitter.h>
#import "FBConnect.h"

#import "Movie.h"

@interface MovieDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate, UIActionSheetDelegate, FBSessionDelegate, FBDialogDelegate>

@property (nonatomic, strong) Movie *movie;
@property (nonatomic, retain) Facebook *facebook;

@end
