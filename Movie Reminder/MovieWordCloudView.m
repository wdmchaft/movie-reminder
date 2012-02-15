//
//  MovieWordCloudView.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieWordCloudView.h"

#define MIN_FONT_SIZE 12.0
#define MAX_FONT_SIZE 35.0
#define BUFFER 5.0
#define MAX_TRIES 20

@interface MovieWordCloudView()
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *textRects;
@end

@implementation MovieWordCloudView

@synthesize colors = _colors;
@synthesize textRects = _textRects;
@synthesize movieWordCloudDataSource = _movieWordCloudDataSource;

- (NSMutableArray *)colors
{
    if (_colors == nil) {
        _colors = [NSMutableArray arrayWithObjects: [UIColor redColor], [UIColor yellowColor], [UIColor blueColor], [UIColor blackColor], [UIColor cyanColor], [UIColor purpleColor], [UIColor grayColor], [UIColor greenColor], [UIColor orangeColor], [UIColor darkGrayColor], [UIColor brownColor], [UIColor magentaColor], [UIColor whiteColor], [UIColor lightGrayColor], nil];
    }
    return _colors;
}

- (NSMutableArray *)textRects
{
    if (_textRects == nil) {
        _textRects = [[NSMutableArray alloc] init];
    }
    return _textRects;
}

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

- (void) awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (CGPoint)randomLocation
{
    CGFloat x = arc4random() % (int)self.bounds.size.width;
    CGFloat y = arc4random() % (int)self.bounds.size.height;
    return CGPointMake(x, y);
}

- (void)clear
{
    [self.textRects removeAllObjects];
    self.colors = nil;
}

- (void)drawString:(NSString *)text
{
	if ([text length])
	{
        int i = 0;
        while (i < MAX_TRIES) {
            CGPoint location = [self randomLocation];
            
            UIFont *font = [UIFont boldSystemFontOfSize:((arc4random() % ((int)MAX_FONT_SIZE - (int)MIN_FONT_SIZE)) + MIN_FONT_SIZE)];
            CGSize rect = [text sizeWithFont:font];
            
            if (location.x + rect.width + BUFFER > self.bounds.size.width) {
                location.x = self.bounds.size.width - rect.width - BUFFER;
            } 
            
            if (location.y + rect.height + BUFFER > self.bounds.size.height) {
                location.y = self.bounds.size.height - rect.height - BUFFER;
            }
            
            CGRect textRect;
            textRect.origin.x = location.x;
            textRect.origin.y = location.y;
            textRect.size.width = rect.width;
            textRect.size.height = rect.height;
            
            BOOL found = YES;
            for (NSValue *value in self.textRects) {
                if (CGRectIntersectsRect(textRect, [value CGRectValue])) {
                    found = NO;
                    break;
                }
            }
                
            if (found) {
                // Add to list of existing rects
                [self.textRects addObject:[NSValue valueWithCGRect:textRect]];
                
                UIColor *randColor = [self.colors objectAtIndex:(int)(arc4random() % [self.colors count])];
                [randColor set];
                [text drawInRect:textRect withFont:font];
                
                break;
            }
            
            i++;
        }
	}
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);

    UIColor *randColor = [self.colors objectAtIndex:(int)(arc4random() % [self.colors count])];
    [self.colors removeObject:randColor];
    [randColor set];
    
    CGContextFillRect(context, self.bounds);
     
    NSArray *wordList = [self.movieWordCloudDataSource getWordList:self];
    
    for (NSString *string in wordList) {
        [self drawString:string];
    }
    
    CGContextStrokePath(context);
}

@end
