//
//  MovieReminderAppDelegate.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/22/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieReminderAppDelegate.h"
#import "MovieXMLParser.h"
#import "MovieHelper.h"
#import "Movie+Create.h"
#import "MovieTableViewController.h"

#define LAST_SYNC_TIME @"Last Sync Time"

@implementation MovieReminderAppDelegate

@synthesize window = _window;

- (void)fetchAndUpdateMovieDatabase
{
    NSMutableArray *movieControllers = [[NSMutableArray alloc] init];
    NSArray *viewControllers = ((UITabBarController *)self.window.rootViewController).viewControllers;
    
    // Set the loading spinner on view controllers
    for (UIViewController *controller in viewControllers) {
        UIViewController *viewController = [((UINavigationController *)controller).viewControllers objectAtIndex:0];
        [movieControllers addObject:viewController];
        if ([viewController respondsToSelector:@selector(startSpinner:)]) {
            [viewController performSelector:@selector(startSpinner:) withObject:@"Loading..."];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Load movie data aynchronously
    dispatch_queue_t movieFetchQueue = dispatch_queue_create("Movie Fetcher", NULL);
    dispatch_async(movieFetchQueue, ^{
        
        MovieXMLParser *parser = [[MovieXMLParser alloc] init];
        [parser setUrl:[[NSURL alloc] initWithString:@"http://www.stripedapps.com/mr/index.php?mini=1"]];
        NSArray *movieInfoDictionaryList = [parser parseXMLData];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Add items to core database
            [MovieHelper openMovieUsingBlock:^(UIManagedDocument *movieDocument) {
                for (NSDictionary *movieInfo in movieInfoDictionaryList) {
                    [Movie movieWithInfo:movieInfo inManagedObjectContext:movieDocument.managedObjectContext];
                }
            }];
            
            // Stop the spinner on controllers
            for (UIViewController *controller in movieControllers) {
                if ([controller respondsToSelector:@selector(stopSpinner)]) {
                    [controller performSelector:@selector(stopSpinner)];
                }
            }
            
            // Update the last sync time
            NSDate *syncFinishTime = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:syncFinishTime forKey:LAST_SYNC_TIME];
        });
    });
    
    dispatch_release(movieFetchQueue);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Determining the last data sync time
    NSDate *lastSyncTime = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYNC_TIME];
    
    NSTimeInterval timeSinceSync;
    if (lastSyncTime != nil) {
        timeSinceSync = [lastSyncTime timeIntervalSinceNow];
    }
    
    // Sync data once a day at most
    if (lastSyncTime == nil || timeSinceSync > 86400) {
        [self fetchAndUpdateMovieDatabase];
    }   
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
