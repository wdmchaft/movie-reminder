//
//  Movie+Create.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Movie+Create.h"
#import "MovieXMLParser.h"
#import "Theatre+Create.h"

@implementation Movie (Create)

+ (Movie *)movieWithInfo:(NSDictionary *)movieInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Movie *movie = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", [movieInfo objectForKey:MOVIE_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Duplicate movies in database");
    } else if ([matches count] == 0) {
        movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:context];
        movie.identifier = [movieInfo objectForKey:MOVIE_ID];
        movie.name = [movieInfo objectForKey:MOVIE_NAME];
        movie.details = [movieInfo objectForKey:MOVIE_DETAILS];
        movie.cast = [movieInfo objectForKey:MOVIE_CAST];
        movie.link = [movieInfo objectForKey:MOVIE_LINK];
        movie.releaseDate = [movieInfo objectForKey:MOVIE_RELEASE_DATE];
        movie.thumbnail = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[movieInfo objectForKey:MOVIE_THUMBNAIL]]];
        movie.imageLink = [movieInfo objectForKey:MOVIE_IMAGE_LINK];
        movie.trailerLink = [movieInfo objectForKey:MOVIE_TRAILER_LINK];
        movie.favorite = [NSNumber numberWithBool:NO];
        movie.eventId = @"";
        
        NSArray *theatres = [movieInfo objectForKey:MOVIE_THEATRES];
        NSMutableSet *theatreSet = [[NSMutableSet alloc] init];
        for (NSDictionary *theatreInfo in theatres) {
           [theatreSet addObject:[Theatre theatreWithInfo:theatreInfo inManagedObjectContext:context]];
        }
        movie.playingAt = theatreSet;
        
    } else {
        movie = [matches lastObject];
    }
    
    return movie;
}

+ (Movie *)movieWithEventId:(NSString *)eventId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Movie *movie;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventId = %@", eventId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    if (!matches || ([matches count] > 1)) {
        NSLog(@"Duplicate movies with same eventId in database");
    } else if ([matches count] == 1) {
        movie = [matches lastObject];
    }
    
    return movie;
}

@end
