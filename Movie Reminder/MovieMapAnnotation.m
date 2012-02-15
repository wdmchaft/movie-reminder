//
//  MovieMapAnnotation.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/3/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieMapAnnotation.h"

@implementation MovieMapAnnotation

@synthesize theatre = _theatre;

+ (MovieMapAnnotation *)annotationForTheatre:(Theatre *)theatre;
{
    MovieMapAnnotation *annotation = [[MovieMapAnnotation alloc] init];
    annotation.theatre = theatre;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.theatre.name;
}

- (NSString *)subtitle
{
    return self.theatre.address;
}   

- (CLLocationCoordinate2D)coordinate
{
    // Return the coordinates for the annotation
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.theatre.latitude doubleValue];
    coordinate.longitude = [self.theatre.longitude doubleValue];
    return coordinate;
}

@end
