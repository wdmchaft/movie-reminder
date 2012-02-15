//
//  MovieWebViewController.m
//  Movie Reminder
//
//  Created by Ruchi Varshney on 12/10/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MovieWebViewController.h"

@interface MovieWebViewController() <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation MovieWebViewController

@synthesize loadURL = _loadURL;
@synthesize webView = _webView;
@synthesize toolbar = _toolbar;
@synthesize navigationBar = _navigationBar;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)startSpinner:(NSString *)activity
{
    self.navigationBar.topItem.title = activity;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

- (void)stopSpinner
{
    self.navigationBar.topItem.rightBarButtonItem = nil;
    self.navigationBar.topItem.title = self.title;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startSpinner:@"Loading..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopSpinner];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopSpinner];
    if (error != nil) {
        NSLog(@"Error in webview: %@", [error localizedDescription]);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.toolbar.translucent = YES;
    self.toolbar.tintColor = [UIColor blackColor];
    self.navigationBar.tintColor = [UIColor blackColor];
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.loadURL]];
}

- (IBAction)backPressed:(UIBarButtonItem *)sender
{
    [self.webView goBack];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setToolbar:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
}
@end
