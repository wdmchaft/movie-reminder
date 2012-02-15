//
//  Movie.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Theatre;

@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString * cast;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * eventId;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * trailerLink;
@property (nonatomic, retain) NSSet *playingAt;
@end

@interface Movie (CoreDataGeneratedAccessors)

- (void)addPlayingAtObject:(Theatre *)value;
- (void)removePlayingAtObject:(Theatre *)value;
- (void)addPlayingAt:(NSSet *)values;
- (void)removePlayingAt:(NSSet *)values;
@end
