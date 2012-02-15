//
//  MovieXMLParser.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieXMLParser : NSObject <NSXMLParserDelegate>

#define MOVIE_ID @"identifier"
#define MOVIE_NAME @"name"
#define MOVIE_RELEASE_DATE @"releaseDate"
#define MOVIE_IMAGE_LINK @"imageLink"
#define MOVIE_DETAILS @"details"
#define MOVIE_CAST @"cast"
#define MOVIE_LINK @"link"
#define MOVIE_THUMBNAIL @"thumbnail"
#define MOVIE_THEATRES @"theatres"
#define MOVIE_TRAILER_LINK @"trailerLink"

#define THEATRE_ID @"identifier"
#define THEATRE_NAME @"name"
#define THEATRE_ADDRESS @"address"
#define THEATRE_PHONE @"phone"
#define THEATRE_LATITUDE @"latitude"
#define THEATRE_LONGITUDE @"longitude"

@property (nonatomic, strong) NSURL *url;

- (NSArray *)parseXMLData; // Returns an array of movie data dictionaries

@end
