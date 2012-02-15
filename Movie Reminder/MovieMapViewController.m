//
//  MovieMapViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieMapViewController.h"
#import "TheatreDetailsTableViewController.h"
#import "MovieMapAnnotation.h"

@interface MovieMapViewController() <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapType;
@end

@implementation MovieMapViewController
@synthesize mapView = _mapView;
@synthesize mapType = _mapType;
@synthesize annotations = _annotations;

- (void)updateMapView
{
    if (self.mapView.annotations) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    if (self.annotations) {
        [self.mapView addAnnotations:self.annotations];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return  nil;
    }
    
    MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Map"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Map"];
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    pinView.annotation = annotation;
    [(UIImageView *)pinView.leftCalloutAccessoryView setImage:nil];
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)pinView
{
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (view.annotation != mapView.userLocation) {
        TheatreDetailsTableViewController *theatreDetailsTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TheatreDetailsTableViewController"];
        
        if (theatreDetailsTableViewController != nil && self.navigationController) {
            Theatre *theatre = ((MovieMapAnnotation *)view.annotation).theatre;
            [theatreDetailsTableViewController setTheatre:theatre];
            [theatreDetailsTableViewController setUserLocation:self.mapView.userLocation.coordinate];
            [self.navigationController pushViewController:theatreDetailsTableViewController animated:YES];
        }
    }
}

- (void)changeMapType:(UISegmentedControl *)sender
{   
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        case 2:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.mapView isUserLocationVisible]) {
        
        MKCoordinateRegion region;
        region.center = self.mapView.userLocation.coordinate;
        [self.mapView.userLocation removeObserver:self forKeyPath:@"location"]; 
    
        MKCoordinateSpan span; 
        span.latitudeDelta  = 1;
        span.longitudeDelta = 1; 
        region.span = span;
    
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    self.mapType.selectedSegmentIndex = 0;
    [self.mapType addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
    
    [self.mapView.userLocation addObserver:self  
                                forKeyPath:@"location"  
                                   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)  
                                   context:NULL];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidUnload
{
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location"];
    [self setMapView:nil];
    [self setMapType:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
