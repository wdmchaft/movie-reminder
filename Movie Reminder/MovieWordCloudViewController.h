//
//  MovieWordCloudViewController.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "Movie.h"

@interface MovieWordCloudViewController : UIViewController

@property (nonatomic, strong) Movie *movie;

@end
