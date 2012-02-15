//
//  TheatreDetailsTableViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "TheatreDetailsTableViewController.h"
#import "Movie.h"

#define THEATRE_DETAILS_NUM_SECTIONS 4
#define THEATRE_DETAILS_NUM_ROWS_PER_SECTION 1

@implementation TheatreDetailsTableViewController
@synthesize theatre = _theatre;
@synthesize userLocation = _userLocation;

- (void)setTheatre:(Theatre *)theatre
{
    if (_theatre != theatre) {
        _theatre = theatre;
        self.title = theatre.name;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return THEATRE_DETAILS_NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 3) {
        return [self.theatre.movies count];
    } else {
        return THEATRE_DETAILS_NUM_ROWS_PER_SECTION;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Directions";
            break;
        case 1:
            return @"Phone";
            break;
        case 2:
            return @"Address";
            break;
        case 3:
            return @"Now Playing";
            break;
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if (indexPath.section == 2) {
        CGSize size = [self.theatre.address sizeWithFont:[UIFont boldSystemFontOfSize:17.0f] constrainedToSize:CGSizeMake(280, MAXFLOAT)];
        height = 20 + size.height;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Theatre Details Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"To Here";
            } else {
                cell.textLabel.text = @"From Here";
            }
            break;
        case 1:
            cell.textLabel.text = self.theatre.phone;    
            break;
        case 2:
            cell.textLabel.text = self.theatre.address;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            [cell.textLabel sizeToFit];
            break;
        case 3:
            cell.textLabel.text = ((Movie *)[[self.theatre.movies allObjects] objectAtIndex:indexPath.row]).name;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *mapString;
        if (indexPath.row == 0) {
            mapString = [@"http://maps.google.com/maps?daddr=" stringByAppendingFormat:@"%g,%g", [self.theatre.latitude doubleValue], [self.theatre.longitude doubleValue]];
            if (self.userLocation.longitude != 0) {
                mapString = [mapString stringByAppendingFormat:@"&saddr=%g,%g", self.userLocation.latitude, self.userLocation.longitude];
            }
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: mapString]];
        } else {
            mapString = [@"http://maps.google.com/maps?saddr=" stringByAppendingFormat:@"%g,%g", [self.theatre.latitude doubleValue], [self.theatre.longitude doubleValue]];
            if (self.userLocation.longitude != 0) {
                mapString = [mapString stringByAppendingFormat:@"&daddr=%g,%g", self.userLocation.latitude, self.userLocation.longitude];
            }
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: mapString]];
        }
        
    } else if (indexPath.section == 1) {
        NSString *telephoneString = [self.theatre.phone stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        telephoneString = [telephoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
        telephoneString = [telephoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
        telephoneString = [telephoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        telephoneString = [telephoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        telephoneString = [@"tel://" stringByAppendingString:telephoneString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneString]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
