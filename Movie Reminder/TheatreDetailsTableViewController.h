//
//  TheatreDetailsTableViewController.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Theatre.h"

@interface TheatreDetailsTableViewController : UITableViewController

@property (nonatomic, strong) Theatre *theatre;
@property CLLocationCoordinate2D userLocation;

@end
