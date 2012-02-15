//
//  MovieHelper.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieHelper.h"

@implementation MovieHelper

static UIManagedDocument *movieDocument;

+ (void)openMovieUsingBlock:(completion_block_t)completionBlock
{
    if (movieDocument == nil) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Movie Database"];
        movieDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    NSLog(@"Document: %@", movieDocument);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[movieDocument.fileURL path]]) {
        // Document does not exist on disk, so create it
        [movieDocument saveToURL:movieDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            completionBlock(movieDocument);
        }];
    } else if (movieDocument.documentState == UIDocumentStateClosed) {
        // Document exists on disk, but we need to open it
        [movieDocument openWithCompletionHandler:^(BOOL success) {
            completionBlock(movieDocument);
        }];
    } else if (movieDocument.documentState == UIDocumentStateNormal) {
        // Document is already open and ready to use
        completionBlock(movieDocument);
    } else {
        NSLog(@"Unknown document state");
    }
}

@end
