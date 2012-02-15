//
//  MovieHelper.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *movieDocument);

@interface MovieHelper : NSObject

+ (void)openMovieUsingBlock:(completion_block_t)completionBlock;

@end
