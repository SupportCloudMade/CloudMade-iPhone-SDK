//
//  WebKitUserAgent.m
//  UserAgent
//
//  Created by Dmytro Golub on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMWebKitUserAgent.h"


@implementation CMWebKitUserAgent

@synthesize userAgent;

-(NSString*)userAgentString
{
	webView = [[UIWebView alloc] init];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tiles.cloudmade.com"]]];
	// Wait for the web view to load our bogus request and give us the secret user agent.
	while (self.userAgent == nil) 
	{
		// This executes another run loop. 
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	return self.userAgent;
}

//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	self.userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
	
	// Return no, we don't care about executing an actual request.
	return NO;
}

- (void)dealloc 
{
	[webView release];
	[userAgent release];
	[super dealloc];
}

@end
