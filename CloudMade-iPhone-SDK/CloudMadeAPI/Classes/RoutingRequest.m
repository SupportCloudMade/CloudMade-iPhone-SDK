//
//  RoutingRequest.m
//  NavigationView
//
//  Created by Dmytro Golub on 2/9/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "RoutingRequest.h"
#import "HelperConstant.h"
#import <CoreLocation/CoreLocation.h>


@implementation RoutingRequest

-(id) initWithApikey:(NSString*) apiKey
{
	[super init];
	apikey = apiKey;
	return self;
}

-(NSString*) getRoutingUrl
{
	return [NSString stringWithFormat:@"http://routes.cloudmade.com/%@/api/%@",apikey,ROUTING_VERSION];	
}

-(NSString*) composeURL:(CLLocationCoordinate2D) fromPoint  to:(CLLocationCoordinate2D) toPoint vehicle:(NSString*) object 
{

	if([object isEqualToString:@"car"])
		return [NSString stringWithFormat:@"%@/%f,%f,%f,%f/%@/shortest.js",[self getRoutingUrl],fromPoint.latitude,fromPoint.longitude,toPoint.latitude,toPoint.longitude,object];
	return [NSString stringWithFormat:@"%@/%f,%f,%f,%f/%@.js",[self getRoutingUrl],fromPoint.latitude,fromPoint.longitude,toPoint.latitude,toPoint.longitude,object];
}


-(void) findRoute:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) toPoint vehicle:(NSString*) object 
{
	NSString* strUrl = [self composeURL:from to:toPoint vehicle:object];
	PLog(@"url = %@\n",strUrl);
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:20.0];
	
	NSURLResponse* response;
	NSError*       error; 
	NSData* data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	if(data)
	{
		return; //[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	}
	else
		return ;	
	
	
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	 NSInteger nContentLength = [receivedData length];
	 PLog(@"Succeeded! Received %d bytes of data",nContentLength);
	 if( nContentLength > 250000 ) 
	 {
		 [delegate serviceServerError:@"Path is very long!!!"];
		 return;
	 }
	
	 [delegate serviceServerResponse:[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]];
	 [connection release];
	 [receivedData release];
}


@end
