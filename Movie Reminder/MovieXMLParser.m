//
//  MovieXMLParser.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieXMLParser.h"

@interface MovieXMLParser()
@property (nonatomic, strong) NSString *currentProperty;
@property (nonatomic, strong) NSMutableDictionary *movieInfo;
@property (nonatomic, strong) NSMutableDictionary *theatreInfo;
@property (nonatomic, strong) NSMutableArray *theatres;
@property (nonatomic, strong) NSMutableArray *movieList;
@end

@implementation MovieXMLParser

@synthesize url = _url;
@synthesize movieList = _movieList;
@synthesize movieInfo = _movieInfo;
@synthesize theatreInfo = _theatreInfo;
@synthesize theatres = _theatres;
@synthesize currentProperty = _currentProperty;

- (NSMutableDictionary *)movieInfo
{
    // Lazily instantiate the mutable dictionary
    if (_movieInfo == nil) {
        _movieInfo = [[NSMutableDictionary alloc] init];
    }
    return _movieInfo;
}

- (NSMutableDictionary *)theatreInfo
{
    // Lazily instantiate the mutable dictionary
    if (_theatreInfo == nil) {
        _theatreInfo = [[NSMutableDictionary alloc] init];
    }
    return _theatreInfo;
}

- (NSMutableArray *)theatres
{
    // Lazily instantiate the mutable dictionary
    if (_theatres == nil) {
        _theatres = [[NSMutableArray alloc] init];
    }
    return _theatres;
}

- (NSMutableArray *)movieList
{
    // Lazily instantiate the mutable dictionary
    if (_movieList == nil) {
        _movieList = [[NSMutableArray alloc] init];
    }
    return _movieList;
}

- (NSArray *)parseXMLData
{    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:self.url];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    return self.movieList;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if (qName) {
        elementName = qName;
    }
    
    self.currentProperty = elementName;
    
    if ([elementName isEqualToString:@"movie"]) {
        self.movieInfo = [[NSMutableDictionary alloc] init];
        self.theatres = [[NSMutableArray alloc] init];
    } else if ([elementName isEqualToString:@"theatre"]) {
        self.theatreInfo = [[NSMutableDictionary alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (qName) {
        elementName = qName;
    }
    
    if([elementName isEqualToString:@"movie"]) {
        // Add movie to the movie list
        [self.movieList addObject:self.movieInfo];
        self.movieInfo = nil;
    } else if ([elementName isEqualToString:@"movie_theatre_list"]) {
        [self.movieInfo setObject:self.theatres forKey:MOVIE_THEATRES];
        self.theatres = nil;
    } else if([elementName isEqualToString:@"theatre"]) {
        [self.theatres addObject:self.theatreInfo];
        self.theatreInfo = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.movieInfo == nil) {
        NSLog(@"Parsing error");
        return;
    }
    
    if ([self.currentProperty isEqualToString:@"movie_mid"]) {
        [self.movieInfo setObject:[NSNumber numberWithInt:
                                   [string intValue]] forKey:MOVIE_ID];
    } else if ([self.currentProperty isEqualToString:@"movie_title"]) {
        NSString *parsedName = [string stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *movieName = [self.movieInfo objectForKey:MOVIE_NAME];
        if (movieName == nil) {
            movieName = parsedName;
        } else {
            movieName = [movieName stringByAppendingString:parsedName];
        }
        [self.movieInfo setObject:movieName forKey:MOVIE_NAME];
    } else if ([self.currentProperty isEqualToString:@"movie_description"]) {
        NSString *parsedDescription = [string stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *movieDescription = [self.movieInfo objectForKey:MOVIE_DETAILS];
        if (movieDescription == nil) {
            movieDescription = parsedDescription;
        } else {
            movieDescription = [movieDescription stringByAppendingString:parsedDescription];
        }
        [self.movieInfo setObject:movieDescription forKey:MOVIE_DETAILS];
    } else if ([self.currentProperty isEqualToString:@"movie_cast"]) {
        [self.movieInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MOVIE_CAST];
    } else if ([self.currentProperty isEqualToString:@"movie_link"]) {
        [self.movieInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MOVIE_LINK];
    } else if ([self.currentProperty isEqualToString:@"movie_icon"]) {
        [self.movieInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MOVIE_THUMBNAIL];
    } else if ([self.currentProperty isEqualToString:@"movie_icon_large"]) {
        [self.movieInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MOVIE_IMAGE_LINK];
    } else if ([self.currentProperty isEqualToString:@"movie_release_date"]) {
        [self.movieInfo setObject:[NSDate dateWithTimeIntervalSince1970:
                                   [string longLongValue]] forKey:MOVIE_RELEASE_DATE];
    } else if ([self.currentProperty isEqualToString:@"movie_trailer_url"]) {
        [self.movieInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:MOVIE_TRAILER_LINK];
    } else if ([self.currentProperty isEqualToString:@"theatre_tid"]) {
        [self.theatreInfo setObject:[NSNumber numberWithInt:
                                   [string intValue]] forKey:THEATRE_ID]; 
    } else if ([self.currentProperty isEqualToString:@"theatre_name"]) {
        [self.theatreInfo setObject:[string stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:THEATRE_NAME];
    } else if ([self.currentProperty isEqualToString:@"theatre_address"]) {
        [self.theatreInfo setObject:[string stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:THEATRE_ADDRESS];
    } else if ([self.currentProperty isEqualToString:@"theatre_phone"]) {
        [self.theatreInfo setObject:[string stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:THEATRE_PHONE];
    } else if ([self.currentProperty isEqualToString:@"theatre_latitude"]) {
        [self.theatreInfo setObject:[NSNumber numberWithDouble:
                                     [string doubleValue]] forKey:THEATRE_LATITUDE];
    } else if ([self.currentProperty isEqualToString:@"theatre_longitude"]) {
        [self.theatreInfo setObject:[NSNumber numberWithDouble:
                                     [string doubleValue]] forKey:THEATRE_LONGITUDE];
    } else {
        NSLog(@"Unknown element in foundCharacters");
    }
}
@end
