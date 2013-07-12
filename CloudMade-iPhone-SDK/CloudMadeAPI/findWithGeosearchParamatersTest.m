//
//  findWithGeosearchParamatersTest.m
//  CloudMadeApi
//
//  Created by Anatoliy Vuets on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "findWithGeosearchParamatersTest.h"
#import "CMGeosearchRequestParams.h"
#import "CMSearchParameters.h"
#import "CMLocation.h"
#import "bbox.h"


@interface findWithGeosearchParamatersTest (private)


-(void) geocodingFail;

@end

@implementation findWithGeosearchParamatersTest

- (void) testfindWithGeosearchParamaters {
	shouldFindSomething = FALSE;
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];	
	
		
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: @"518f15c781b5484cb89f78925904b783"];
	_geocoder.delegate = self;	
	
	failsCounter = 0;
	
	NSString* citiesTestSetstring = [NSString stringWithString:@"Augsburg, nil"];
	NSMutableArray* citiesTestSet = [[NSMutableArray alloc] initWithArray:[citiesTestSetstring componentsSeparatedByString:@", "]];
    
	NSString* countriesTestSetstring = [NSString stringWithString:@"Germany, nil"];
	NSMutableArray* countriesTestSet = [[NSMutableArray alloc] initWithArray:[countriesTestSetstring componentsSeparatedByString:@", "]];
	
	NSString* countiesTestSetstring = [NSString stringWithString:@"Bavaria, nil"];
	NSMutableArray* countiesTestSet = [[NSMutableArray alloc] initWithArray:[countiesTestSetstring componentsSeparatedByString:@", "]];
	
	NSString* postCodesTestSetstring = [NSString stringWithString:@"210, nil"];
	NSMutableArray* postCodesTestSet = [[NSMutableArray alloc] initWithArray:[postCodesTestSetstring componentsSeparatedByString:@", "]];
	
	NSString* streetsTestSetstring = [NSString stringWithString:@"Leitershofer, nil"];
	NSMutableArray* streetsTestSet = [[NSMutableArray alloc] initWithArray:[streetsTestSetstring componentsSeparatedByString:@", "]];
	
	NSString* housesTestSetstring = [NSString stringWithString:@"2, nil"];
	NSMutableArray* housesTestSet = [[NSMutableArray alloc] initWithArray:[housesTestSetstring componentsSeparatedByString:@", "]];
	
	
//	BoundingBox bbox;
//	NSMutableArray * BoundingBoxTestSet = [[NSMutableArray alloc];
								
//	BoundingBoxTestSet
	
//	BOOL bboxOnly;	
	NSString* bboxOnlyTestSetstring = [NSString stringWithString:@"TRUE, FALSE"];
	NSMutableArray * bboxOnlyTestSet = [[NSMutableArray alloc] initWithArray:[bboxOnlyTestSetstring componentsSeparatedByString:@", "]];
	
//	BOOL returnLocation;
	NSString* returnLocationTestSetstring = [NSString stringWithString:@"TRUE, FALSE"];
	NSMutableArray * returnLocationTestSet = [[NSMutableArray alloc] initWithArray:[returnLocationTestSetstring componentsSeparatedByString:@", "]];

//	BOOL returnGeometry;
    NSString* returnGeometryTestSetstring = [NSString stringWithString:@"TRUE, FALSE"];
    NSMutableArray * returnGeometryTestSet = [[NSMutableArray alloc] initWithArray:[returnGeometryTestSetstring componentsSeparatedByString:@", "]];									   
										   
//	NSUInteger distance;
    NSString* distanceTestSetstring = [NSString stringWithString:@"0, 1000"];
    NSMutableArray * distanceTestSet = [[NSMutableArray alloc] initWithArray:[distanceTestSetstring componentsSeparatedByString:@", "]];										   
										   
//	NSUInteger skip;
	NSString* skipTestSetstring = [NSString stringWithString:@"0, 1"];
    NSMutableArray * skipTestSet = [[NSMutableArray alloc] initWithArray:[skipTestSetstring componentsSeparatedByString:@", "]];	
	
//	NSUInteger returnResults;
	NSString* returnResultsTestSetstring = [NSString stringWithString:@"0, 1"];
    NSMutableArray * returnResultsTestSet = [[NSMutableArray alloc] initWithArray:[returnResultsTestSetstring componentsSeparatedByString:@", "]];	
	
	int numberOfCasesForGeocoderParameters = [bboxOnlyTestSet count]*[returnLocationTestSet count]*[returnGeometryTestSet count]*[distanceTestSet count]*[skipTestSet count]*[returnResultsTestSet count];
	
	int numberOfCasesForSearchParameters = [citiesTestSet count]*[countriesTestSet count]*[countiesTestSet count]*[postCodesTestSet count]*[streetsTestSet count]*[housesTestSet count];
	
	int numberOfCases = numberOfCasesForSearchParameters*numberOfCasesForGeocoderParameters;
	
	//STAssertNotNil(nil,@"%i",numberOfCases);
	
	for (index = 0; index < numberOfCases; index++) {
		resultsDidReceive = FALSE;
		if (searchParameters){
			[searchParameters release];
			searchParameters = nil;
		}
		//STAssertNotNil(nil,@"index: %i", index % 3);
		
		
		searchParameters = [[CMSearchParameters alloc] init];
		
		STAssertNotNil(citiesTestSet, @"citiesTestSet is nil");
		searchParameters.city = [citiesTestSet objectAtIndex:div(index, (numberOfCases/[citiesTestSet count])).quot];
		searchParameters.city = (![searchParameters.city isEqualToString:@"nil"])? searchParameters.city:nil;
		//STAssertNotNil(nil,@"index: %i",div(index, (numberOfCases/[citiesTestSet count])).quot);
		
		STAssertNotNil(countriesTestSet, @"countriesTestSet is nil");
		searchParameters.country = [countriesTestSet objectAtIndex: div(div(index, (numberOfCases/[citiesTestSet count]/[countriesTestSet count])).quot,[countriesTestSet count]).rem];
		searchParameters.country = (![searchParameters.country isEqualToString:@"nil"])? searchParameters.country:nil;
		//STAssertNotNil(nil,@"index: %i",div(div(index, (numberOfCases/[citiesTestSet count]/[countriesTestSet count])).quot,[countriesTestSet count]).rem);
		
		STAssertNotNil(countiesTestSet, @"countiesTestSet is nil");
		searchParameters.county = [countiesTestSet objectAtIndex: div((div(index,numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]).quot),[countiesTestSet count]).rem];
		searchParameters.county = (![searchParameters.county isEqualToString:@"nil"])? searchParameters.county:nil;
		//STAssertNotNil(nil,@"index: %i", div((div(index,numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]).quot),[countiesTestSet count]).rem);
		
		STAssertNotNil(postCodesTestSet, @"postCodesTestSet is nil");
		searchParameters.postcode = [postCodesTestSet objectAtIndex: div(div(index, numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]/[postCodesTestSet count]).quot ,[postCodesTestSet count]).rem];
		searchParameters.postcode = (![searchParameters.postcode isEqualToString:@"nil"])? searchParameters.postcode:nil;
		//STAssertNotNil(nil,@"index: %i",div(div(index, numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]/[postCodesTestSet count]).quot ,[postCodesTestSet count]).rem);
		
		STAssertNotNil(streetsTestSet, @"streetsTestSet is nil");
		searchParameters.street = [streetsTestSet objectAtIndex: div(div(index, numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]/[postCodesTestSet count]/[streetsTestSet count]).quot,[streetsTestSet count]).rem];
		searchParameters.street = (![searchParameters.street isEqualToString:@"nil"])? searchParameters.street:nil;
		//STAssertNotNil(nil,@"index: %i",div(div(index, numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]/[postCodesTestSet count]/[streetsTestSet count]).quot,[streetsTestSet count]).rem);
		
		STAssertNotNil(housesTestSet, @"housesTestSet is nil");
		searchParameters.house = [housesTestSet objectAtIndex: div(div(index, numberOfCases/[citiesTestSet count]/[countriesTestSet count]/[countiesTestSet count]/[postCodesTestSet count]/[streetsTestSet count]/[housesTestSet count]).quot,[housesTestSet count]).rem];
		searchParameters.house = (![searchParameters.house isEqualToString:@"nil"])? searchParameters.house:nil;
		
		
		if (searchRequestParameters){
			[searchRequestParameters release];
			searchRequestParameters = nil;
		}
		
		searchRequestParameters = [[CMGeosearchRequestParams alloc] init];
		
		
		//searchRequestParameters.bbox;
		
		STAssertNotNil(bboxOnlyTestSet, @"bboxOnlyTestSet is nil");
		NSString* tempBboxOnlyCase = [bboxOnlyTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]).quot,[bboxOnlyTestSet count]).rem];
		if ([tempBboxOnlyCase isEqualToString:@"TRUE"]) searchRequestParameters.bboxOnly = TRUE;
		if ([tempBboxOnlyCase isEqualToString:@"FALSE"]) searchRequestParameters.bboxOnly = FALSE;
		//STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]).quot,[bboxOnlyTestSet count]).rem);
		
		STAssertNotNil(returnLocationTestSet, @"returnLocationTestSet is nil");		
		NSString* tempreturnLocationCase = [returnLocationTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]).quot,[returnLocationTestSet count]).rem];
		if ([tempreturnLocationCase isEqualToString:@"TRUE"]) searchRequestParameters.returnLocation = TRUE;
		if ([tempreturnLocationCase isEqualToString:@"FALSE"]) searchRequestParameters.returnLocation = FALSE;
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]).quot,[returnLocationTestSet count]).rem);
		
		STAssertNotNil(returnGeometryTestSet, @"returnGeometryTestSet is nil");	
		NSString* tempreturnGeometryCase = [returnGeometryTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]).quot,[returnGeometryTestSet count]).rem];
		if ([tempreturnGeometryCase isEqualToString:@"TRUE"]) searchRequestParameters.returnGeometry = TRUE;
		if ([tempreturnGeometryCase isEqualToString:@"FALSE"]) searchRequestParameters.returnGeometry = FALSE;
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]).quot,[returnGeometryTestSet count]).rem);
		
		STAssertNotNil(distanceTestSet, @"distanceTestSet is nil");	
		NSString* tempdistanceCase = [distanceTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]).quot,[distanceTestSet count]).rem];
		searchRequestParameters.distance = [tempdistanceCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]).quot,[distanceTestSet count]).rem);
		
		STAssertNotNil(skipTestSet, @"skipTestSet is nil");	
		NSString* tempskipCase = [skipTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]).quot,[skipTestSet count]).rem];
		searchRequestParameters.skip = [tempskipCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]).quot,[skipTestSet count]).rem);
		
		STAssertNotNil(returnResultsTestSet, @"returnResultsTestSet is nil");	
		NSString* tempreturnResultsCase = [returnResultsTestSet objectAtIndex:div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]/[returnResultsTestSet count]).quot,[returnResultsTestSet count]).rem];
		searchRequestParameters.returnResults = [tempreturnResultsCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]/[returnResultsTestSet count]).quot,[returnResultsTestSet count]).rem);
	
		

		
		_geocoder.requestParameters = searchRequestParameters;
		
		
		[_geocoder findWithGeosearchParamaters:searchParameters];
		while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
		
	}
	

	STAssertNotNil(nil,@"Total cases:%i fails:%i",numberOfCases, failsCounter);
}


-(void) geocoder:(CMGeocoder*) geocoder didFindLocations:(NSArray*) locations
{
	//NSLog(@"%@\n",locations);
	//STAssertNotNil(locations,@"search response should not be a nil!!!");
	if (!locations){
		STAssertNotNil(locations,@"Nil locations!");
		[self geocodingFail];
	}
	CMLocation *firstLocation = [[locations objectAtIndex:0] retain];
	if ([[NSNumber numberWithFloat:firstLocation.coordinate.latitude] isEqualToNumber:[NSNumber numberWithFloat:0.0f]]){

		STAssertEquals(!!([NSNumber numberWithFloat:firstLocation.coordinate.latitude]),!!([NSNumber numberWithFloat:0.0f]), @"Coordinates should not be 0!!!", nil);
		[self geocodingFail];
    }
	
	
	//STFail(@"!!!!!");
//	[firstLocation release];
	resultsDidReceive = YES;
}

-(void) geocoder:(CMGeocoder*) geocoder didFailWithError:(NSError*) error
{
    NSLog(@"%s %i",__func__,shouldFindSomething);
    if (shouldFindSomething){
		STFail(@"error:      %d",[error code]);	
		[self geocodingFail];
		//STFail(@"!!!1111!!");
	}	
	resultsDidReceive = YES;
}

-(void) geocodingFail
{
//	STFail(@"Fail index: %i",index);
	STFail(@" ");
    STFail(@" ");
    STFail(@"GeoCoder fail");
	STFail(@"Fail index: %d",index);
	STFail(@" ");
	STFail(@"--------Geosearch paremeters----");
	STFail(@"city:       %s",[searchParameters.city UTF8String]);
	STFail(@"country:    %s",[searchParameters.country UTF8String]);
	STFail(@"county:     %s",[searchParameters.county UTF8String]);
	STFail(@"postcode:   %s",[searchParameters.postcode UTF8String]);
	STFail(@"street:     %s",[searchParameters.street UTF8String]);
	STFail(@"house:      %s",[searchParameters.house UTF8String]);
	STFail(@" ");
	STFail(@"--------Geocoder paremeters-----");
	STFail(@"bboxOnly:       %i",searchRequestParameters.bboxOnly);
	STFail(@"returnLocation: %i",searchRequestParameters.returnLocation);
	STFail(@"returnGeometry: %i",searchRequestParameters.returnGeometry);
	STFail(@"distance:       %i",searchRequestParameters.distance);
	STFail(@"skip:           %i",searchRequestParameters.skip);
	STFail(@"returnResults:  %i",searchRequestParameters.returnResults);
	STFail(@"--------------------------------");
	failsCounter++;
}







@end
