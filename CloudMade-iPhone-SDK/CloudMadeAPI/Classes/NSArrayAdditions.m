//
//  NSArray+URLCustomHeaders.m
//  CloudMadeApi
//
//  Created by user on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSArrayAdditions.h"


@implementation NSArray (CustomURLHeaders)

+(NSArray*) executeRequest:(NSURL*) url headers:(NSDictionary*) headers
{
	NSData* data = nil;
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:20.0];
	
	for (NSString* key in [headers allKeys])
	{
		//[theRequest setValue:@"CloudMadeIphoneLib" forHTTPHeaderField:@"X-ServiceSource"];
		[theRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
	}
	
	
	NSURLResponse* response;
	NSError*       error; 
	data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	

	if (!data)
	{
		//NSLog(@"%@",error);
		return nil;
	}
	
	NSString* errorMsg;
	NSPropertyListFormat format;
	id array = [NSPropertyListSerialization propertyListFromData:data
											  mutabilityOption:NSPropertyListImmutable
														format:&format 
											  errorDescription:&errorMsg];
	if (!errorMsg)  errorMsg = [[NSString alloc] initWithString:@""];
    [errorMsg release];
    
	if ([array isKindOfClass:[NSArray class]])
		return (NSArray*)array; 
	return nil;
}


+(id) arrayWithContentsOfURL:(NSURL*) url headers:(NSDictionary*) headers
{
	return [NSArray executeRequest:url headers:headers];
}

@end
