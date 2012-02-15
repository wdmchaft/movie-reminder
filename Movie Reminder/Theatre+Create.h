//
//  Theatre+Create.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Theatre.h"

@interface Theatre (Create)

+ (Theatre *)theatreWithInfo:(NSDictionary *)theatreInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
