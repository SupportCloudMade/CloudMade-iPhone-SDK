//
//  BrowserViewController.m
//  SponsoredPOIs
//
//  Created by Dmytro Golub on 9/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "BrowserViewController.h"
#import "LibUtils.h"

@interface BrowserViewController (Private)
	-(void) disableButtons;
@end



@implementation BrowserViewController


-(id) initWithUrl:(NSString*) url
{
	self = [super init];
	_url = url;
	[_url retain];
	return self;
}

-(void) goBack
{
	[self disableButtons];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
	[_webView goBack];
}

-(void) goForward
{
	[self disableButtons];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
	[_webView goForward];
}



-(UIToolbar*) createToolbar
{
	UIToolbar* mainToolbar = [[UIToolbar new] autorelease];
	//mainToolbar.barStyle = 1;//UIBarStyleBlackTranslucent;//UIBarStyleBlackOpaque; //UIBarStyleBlackTranslucent;//UIBarStyleDefault;
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	[mainToolbar setFrame:CGRectMake(0,screenRect.size.height-44,screenRect.size.width,44)];
	[self.view addSubview:mainToolbar];
	//  UIBarButtonSystemItemRewind

	goBackBtn = [[UIBarButtonItem alloc] 
					initWithImage:[UIImage imageNamed:_BI(@"browser_prev.png")] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
	
	goBackBtn.enabled = NO;
	
	
	goForwardBtn = [[UIBarButtonItem alloc] 
					initWithImage:[UIImage imageNamed:_BI(@"browser_next.png")] style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
	
	goForwardBtn.enabled = NO;

	UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];	
	
	
	
	NSArray* items = [NSArray arrayWithObjects:fixedSpace,goBackBtn,fixedSpace,goForwardBtn,fixedSpace,nil];
	[mainToolbar setItems:items animated:NO];
	mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	[fixedSpace release];
	return mainToolbar;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	CGRect rc = [[UIScreen mainScreen] applicationFrame];
	UIView* contentView = [[UIView alloc] initWithFrame:rc];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	contentView.autoresizesSubviews = YES;
	CGRect rcWebView = CGRectMake(0,0,rc.size.width,rc.size.height - 44);
	_webView = [[UIWebView alloc] initWithFrame:rcWebView];
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	_webView.delegate = self;
	_webView.scalesPageToFit = YES;
	self.view = contentView;
	[contentView addSubview:_webView];
	NSURL* url = [NSURL URLWithString:_url];
	
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url ];
    //[urlRequest setValue: @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16" forHTTPHeaderField: @"User_Agent"]; // Or any other User-Agent value.	
	
	[_webView loadRequest:urlRequest];
	[self createToolbar];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[urlRequest release];
	[contentView release];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = TRUE;
}

-(void) disableButtons
{
	goBackBtn.enabled = NO;
	goForwardBtn.enabled = NO;
}

-(void) checkGoAndForwardButtons:(UIWebView*) webView
{
	if([webView canGoBack])
		goBackBtn.enabled = YES;
	else
		goBackBtn.enabled = NO;
	if([webView canGoForward])
		goForwardBtn.enabled = YES;
	else
		goForwardBtn.enabled = NO;
}

- (void)dealloc {
	[goBackBtn release];
	[goForwardBtn release];
	[_webView release];
    [super dealloc];
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self checkGoAndForwardButtons:webView];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self checkGoAndForwardButtons:webView];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
/*

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
	
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)])
	{
        //[request setValue:@"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16" 
	   //forHTTPHeaderField:@"User_Agent"];
    }
    return YES; 
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return TRUE;
}

@end
