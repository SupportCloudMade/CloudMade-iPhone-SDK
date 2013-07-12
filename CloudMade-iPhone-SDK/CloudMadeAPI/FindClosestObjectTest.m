//
//  FindClosestObjectTest.m
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/7/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "FindClosestObjectTest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"
#import "GeoCoordinates.h"

@implementation FindClosestObjectTest

- (void) testFindClosestObject {
	
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	
	GeoCodingRequest* geocodingRequest;
	geocodingRequest = [[GeoCodingRequest alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"
													withOptions:nil tokenManager:tokenManager];
	geocodingRequest.delegate = self; 
	
	resultsDidReceive = FALSE;
	shouldFindSomething = YES;
	float lat = 51.5091298;
	float lon = -0.1272225;
	GeoCoordinates* coords = [GeoCoordinates  withLat:lat Lng:lon];
	
	
	[geocodingRequest findClosestObject: @"pub" inPoint: coords];
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
}


-(void) serviceServerResponse:(NSString*) jsonResponse
{
	NSLog(@"%@\n",jsonResponse);
	STAssertNotNil(jsonResponse,@"search response should not be a nil!!!");	
	GeoCodingJsonParser* jsonParser = [[GeoCodingJsonParser alloc] init];
	NSArray* locations = [jsonParser fillLocationsArray:jsonResponse];
	
	Location* loc = [locations objectAtIndex:0]; 
	
	STAssertEquals(!!([NSNumber numberWithFloat:loc.coordinate.latitude]),!!([NSNumber numberWithFloat:0.0f]), @"Coordinates should not be 0!!!", nil);	
	
	STAssertEquals([NSNumber numberWithInt:1],[NSNumber numberWithInt:[locations count]],
				   @"There should be only 1 item with such postcode");
	
	resultsDidReceive = YES;
}

-(void) serviceServerError:(NSString*) error
{
	resultsDidReceive = YES;
	if (shouldFindSomething) {
		STAssertNotNil(nil,error);
	}
	
}


@end
