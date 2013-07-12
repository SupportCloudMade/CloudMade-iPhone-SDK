//
//  FindClosestObjectTest.m
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/7/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "FindGeoObjectTest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"
#import "bbox.h"

@implementation FindGeoObjectTest

- (void) testFindGeoObject {
	
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4 552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	
	GeoCodingRequest* geocodingRequest;
	geocodingRequest = [[GeoCodingRequest alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"
													withOptions:nil tokenManager:tokenManager];
	geocodingRequest.delegate = self; 
	
	resultsDidReceive = FALSE;
	shouldFindSomething = YES;
	
	//http://ec2-184-73-50-234.compute-1.amazonaws.com:5000/geocoding/geoobject/Berlin.js?object_type=road&bbox=47.27571,10.86563,55.05564,15.03937
	BBox* bbox = [[BBox alloc] init];
	bbox.easternLongitude = 15.03937;
	bbox.westernLongitude = 10.86563;
	bbox.southernLatitude = 47.27571;
	bbox.northernLatitude = 55.05564;
	
	[geocodingRequest findGeoObject: @"Berlin" inBBox: bbox];
		
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
