//
//  MovieWordCloudView.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MovieWordCloudView;

@protocol MovieWordCloudViewDataSource
- (NSArray *)getWordList:(MovieWordCloudView *)sender;
@end

@interface MovieWordCloudView : UIView

@property (nonatomic, weak) IBOutlet id <MovieWordCloudViewDataSource> movieWordCloudDataSource;

- (void)clear;

@end
