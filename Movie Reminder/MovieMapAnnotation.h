//
//  MovieMapAnnotation.h
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Theatre.h"

@interface MovieMapAnnotation : NSObject <MKAnnotation>

+ (MovieMapAnnotation *)annotationForTheatre:(Theatre *)theatre;
@property (nonatomic, strong) Theatre *theatre;

@end
