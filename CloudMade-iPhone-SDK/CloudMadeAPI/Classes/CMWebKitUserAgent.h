//
//  WebKitUserAgent.h
//  UserAgent
//
//  Created by Dmytro Golub on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CMWebKitUserAgent : NSObject <UIWebViewDelegate>
{
	NSString *userAgent;
	UIWebView *webView;
}

@property (nonatomic, retain) NSString *userAgent;
-(NSString*)userAgentString;

@end
