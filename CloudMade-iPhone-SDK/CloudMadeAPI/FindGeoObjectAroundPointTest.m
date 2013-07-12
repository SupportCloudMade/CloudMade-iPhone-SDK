//
//  FindGeoObjectAroundCityTest.m
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/8/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "FindGeoObjectAroundPointTest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"
#import "GeoCoordinates.h"

@implementation FindGeoObjectAroundPointTest


- (void) testFindGeoObjectAroundPoint {
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	
	GeoCodingRequest* geocodingRequest;
	geocodingRequest = [[GeoCodingRequest alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"
													withOptions:nil tokenManager:tokenManager];
	geocodingRequest.delegate = self; 
	
	resultsDidReceive = FALSE;
	shouldFindSomething = YES;
	//51.04903
	//13.73819c
	
	float lat = 51.5091298;
	float lon = -0.1272225;
	GeoCoordinates* coords = [GeoCoordinates  withLat:lat Lng:lon];
	
	
	[geocodingRequest findGeoObjectAroundPoint: coords inDistance: 1000 withType: @"pub" withName: @"cafe"];
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	resultsDidReceive = FALSE;
	[geocodingRequest findGeoObjectAroundPoint: coords inDistance: 1000 withType: nil withName: nil];
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
	
	STAssertTrue([NSNumber numberWithInt:[locations count]] > 0,
				 @"There should be >= 1 item in response ");
	
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
