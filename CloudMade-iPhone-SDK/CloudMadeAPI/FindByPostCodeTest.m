//
//  FindByPostCodeTest.m
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/6/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "FindByPostCodeTest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"

@implementation FindByPostCodeTest


- (void) testFindByPostcode {
	
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	
	GeoCodingRequest* geocodingRequest;
	geocodingRequest = [[GeoCodingRequest alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"
													withOptions:nil tokenManager:tokenManager];
	geocodingRequest.delegate = self; 
	
	resultsDidReceive = FALSE;
	//CLLocationCoordinate2D  POSITION = {50.43,30.53};
	
	[geocodingRequest findByPostcode: @"SE1 9PG" inCountry: @"UK"];
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	resultsDidReceive = FALSE;
	[geocodingRequest findByPostcode: @"90210" inCountry: nil];
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	resultsDidReceive = FALSE;
	[geocodingRequest findByPostcode: @"90210" inCountry: @"Україна" ];
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);

	//find by zip code - logic is the same, but different method
	resultsDidReceive = FALSE;
	[geocodingRequest findByZipcode: @"90210" inCountry: nil];
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
	
	resultsDidReceive = FALSE;
	[geocodingRequest findByZipcode: @"90210" inCountry: @"Україна" ];
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
	STAssertNotNil(nil,error);
}


@end
