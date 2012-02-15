//
//  Theatre+Create.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Theatre+Create.h"
#import "MovieXMLParser.h"

@implementation Theatre (Create)

+ (Theatre *)theatreWithInfo:(NSDictionary *)theatreInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Theatre *theatre = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Theatre"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", [theatreInfo objectForKey:THEATRE_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Duplicate theatres in database");
    } else if ([matches count] == 0) {
        theatre = [NSEntityDescription insertNewObjectForEntityForName:@"Theatre" inManagedObjectContext:context];
        theatre.identifier = [theatreInfo objectForKey:THEATRE_ID];
        theatre.name = [theatreInfo objectForKey:THEATRE_NAME];
        theatre.address = [theatreInfo objectForKey:THEATRE_ADDRESS];
        theatre.phone = [theatreInfo objectForKey:THEATRE_PHONE];
        theatre.latitude = [theatreInfo objectForKey:THEATRE_LATITUDE];
        theatre.longitude = [theatreInfo objectForKey:THEATRE_LONGITUDE];
    } else {
        theatre = [matches lastObject];
    }
    
    return theatre;
}

@end
