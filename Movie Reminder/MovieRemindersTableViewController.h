//
//  MovieRemindersTableViewController.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <CoreData/CoreData.h>

@interface MovieRemindersTableViewController : UITableViewController

- (void)startSpinner:(NSString *)activity;
- (void)stopSpinner;

@end
