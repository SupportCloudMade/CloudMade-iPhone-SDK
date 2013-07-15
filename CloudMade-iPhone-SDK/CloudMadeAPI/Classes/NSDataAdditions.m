//
//  NSData+URLCustomHeaders.m
//  CloudMadeApi
//
//  Created by user on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSDataAdditions.h"


@implementation NSData (CustomURLHeaders)

+(NSData*) executeRequest:(NSURL*) url headers:(NSDictionary*) headers
{
	NSData* data = nil;
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:20.0];
	
	for (NSString* key in [headers allKeys])
	{
		[theRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
	}
	
	
	NSURLResponse* response;
	NSError*       error; 
	data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	
	if (!data)
		return nil;
	
	return data;
}


+(id) dataWithContentsOfURL:(NSURL*) url headers:(NSDictionary*) headers
{
	return [NSData executeRequest:url headers:headers];
}

@end
