//
//  Movie+Create.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Movie.h"

@interface Movie (Create)

+ (Movie *)movieWithInfo:(NSDictionary *)movieInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Movie *)movieWithEventId:(NSString *)eventId inManagedObjectContext:(NSManagedObjectContext *)context;

@end
