//
//  GeoCodingRequestTest.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 3/15/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "GeoCodingRequestTest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"

@implementation GeoCodingRequestTest


- (void) testStructuralSearch
{
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	
	GeoCodingRequest* reverseGeocoding;
	
	// creation
	reverseGeocoding = [[GeoCodingRequest alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"
													withOptions:nil tokenManager:tokenManager];
	reverseGeocoding.delegate = self; 
	
	resultsDidReceive = FALSE;
	//CLLocationCoordinate2D  POSITION = {50.43,30.53};
	[reverseGeocoding structuralSearchWithHouse:@"1001" street:@"Leavenworth Street" city:@"Sausalito" postcode:@"94965" 
										 county:nil country:@"USA"];

	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];
	
	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}


-(void) serviceServerResponse:(NSString*) jsonResponse
{
	NSLog(@"%@\n",jsonResponse);
	STAssertNotNil(jsonResponse,@"structural search response should not be a nil!!!");	
	GeoCodingJsonParser* jsonParser = [[GeoCodingJsonParser alloc] init];
	NSArray* locations = [jsonParser fillLocationsArray:jsonResponse];
	
	Location* loc = [locations objectAtIndex:0]; 
	//STAssertEquals(!([NSNumber numberWithFloat:loc.coordinate.latitude]),!([NSNumber numberWithFloat:0.0f]),
	//
	//@"Coordinates should not be 0!!!");
	
	STAssertEquals([NSNumber numberWithInt:1],[NSNumber numberWithInt:[locations count]],@"Number of results of the structural search is suspicious!!!");
	resultsDidReceive = YES;
}

-(void) serviceServerError:(NSString*) error
{
	resultsDidReceive = YES;
	STAssertNotNil(nil,@"The error is not expected here!!!");
}




@end
