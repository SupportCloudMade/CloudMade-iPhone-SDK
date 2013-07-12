//
//  findObjectsAroundTest.m
//  CloudMadeApi
//
//  Created by Anatoliy Vuets on 1/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "findObjectsWithNameTypeAroundCoordinateTest.h"
#import "CMGeosearchRequestParams.h"
#import "CMSearchParameters.h"
#import "CMLocation.h"
#import "bbox.h"


@interface findObjectsWithNameTypeAroundCoordinateTest (private)


-(void) geocodingFail;

@end

@implementation findObjectsWithNameTypeAroundCoordinateTest

- (void) testFindObjectsWithNameTypeAroundCoordinate {
	shouldFindSomething = NO;
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];	
	
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: @"518f15c781b5484cb89f78925904b783"];
	_geocoder.delegate = self;	
	
	failsCounter = 0;
	
	
	
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
	
	
	
	NSString* objectsTestSetStrung = [NSString stringWithString:@"cafe, nil"];
	NSMutableArray* objectsTestSet = [[NSMutableArray alloc] initWithArray:[objectsTestSetStrung componentsSeparatedByString:@", "]];
	
	NSString* objectNamesTestSetString = [NSString stringWithString:@"Azbuka, nil"];
	NSMutableArray * objectNamesTestSet = [[NSMutableArray alloc] initWithArray:[objectNamesTestSetString componentsSeparatedByString:@", "]];
	
	
	NSMutableArray* pointsTestSet = [[NSMutableArray alloc] init];
	
	point = CLLocationCoordinate2DMake(12, 13);
	
	[pointsTestSet addObject:[NSValue value:&point withObjCType:@encode(CLLocationCoordinate2D)]];
	
	point = CLLocationCoordinate2DMake(11, 11);
	[pointsTestSet addObject:[NSValue value:&point withObjCType:@encode(CLLocationCoordinate2D)]];
	
	
	int numberOfCasesForGeocoderParameters = [bboxOnlyTestSet count]*[returnLocationTestSet count]*[returnGeometryTestSet count]*[distanceTestSet count]*[skipTestSet count]*[returnResultsTestSet count];
	
	int numberOfCasesForObjects = [returnResultsTestSet count];
	
	int numberOfCasesForObjectNames = [objectNamesTestSet count];
	
	int numberOfCasesForPoints = [pointsTestSet count];
		
	int numberOfCases = numberOfCasesForGeocoderParameters*numberOfCasesForObjects*numberOfCasesForObjectNames*numberOfCasesForPoints;
	
	//STAssertNotNil(nil,@"%i",numberOfCases);
	
	for (index = 0; index < numberOfCases; index++) {
		resultsDidReceive = FALSE;
		
		
		if (searchRequestParameters){
			[searchRequestParameters release];
			searchRequestParameters = nil;
		}
		
		searchRequestParameters = [[CMGeosearchRequestParams alloc] init];
		
		
		//searchRequestParameters.bbox;
		
		STAssertNotNil(bboxOnlyTestSet, @"bboxOnlyTestSet is nil");
		NSString* tempBboxOnlyCase = [bboxOnlyTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]).quot,[bboxOnlyTestSet count]).rem];
		if ([tempBboxOnlyCase isEqualToString:@"TRUE"]) searchRequestParameters.bboxOnly = TRUE;
		if ([tempBboxOnlyCase isEqualToString:@"FALSE"]) searchRequestParameters.bboxOnly = FALSE;
		//STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]).quot,[bboxOnlyTestSet count]).rem);
		
		STAssertNotNil(returnLocationTestSet, @"returnLocationTestSet is nil");		
		NSString* tempreturnLocationCase = [returnLocationTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]/[returnLocationTestSet count]).quot,[returnLocationTestSet count]).rem];
		if ([tempreturnLocationCase isEqualToString:@"TRUE"]) searchRequestParameters.returnLocation = TRUE;
		if ([tempreturnLocationCase isEqualToString:@"FALSE"]) searchRequestParameters.returnLocation = FALSE;
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]).quot,[returnLocationTestSet count]).rem);
		
		STAssertNotNil(returnGeometryTestSet, @"returnGeometryTestSet is nil");	
		NSString* tempreturnGeometryCase = [returnGeometryTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]).quot,[returnGeometryTestSet count]).rem];
		if ([tempreturnGeometryCase isEqualToString:@"TRUE"]) searchRequestParameters.returnGeometry = TRUE;
		if ([tempreturnGeometryCase isEqualToString:@"FALSE"]) searchRequestParameters.returnGeometry = FALSE;
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]).quot,[returnGeometryTestSet count]).rem);
		
		STAssertNotNil(distanceTestSet, @"distanceTestSet is nil");	
		NSString* tempdistanceCase = [distanceTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]).quot,[distanceTestSet count]).rem];
		searchRequestParameters.distance = [tempdistanceCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]).quot,[distanceTestSet count]).rem);
		
		STAssertNotNil(skipTestSet, @"skipTestSet is nil");	
		NSString* tempskipCase = [skipTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]).quot,[skipTestSet count]).rem];
		searchRequestParameters.skip = [tempskipCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]).quot,[skipTestSet count]).rem);
		
		STAssertNotNil(returnResultsTestSet, @"returnResultsTestSet is nil");	
		NSString* tempreturnResultsCase = [returnResultsTestSet objectAtIndex:div(div(index, numberOfCases/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]/[returnResultsTestSet count]).quot,[returnResultsTestSet count]).rem];
		searchRequestParameters.returnResults = [tempreturnResultsCase integerValue];
        //STAssertNotNil(nil,@"index: %i", div(div(index, numberOfCasesForGeocoderParameters/[bboxOnlyTestSet count]/[returnLocationTestSet count]/[returnGeometryTestSet count]/[distanceTestSet count]/[skipTestSet count]/[returnResultsTestSet count]).quot,[returnResultsTestSet count]).rem);
		
		if (objectTypes)
		{
			[objectTypes release];
			objectTypes = nil;
		}
		
		
		STAssertNotNil(objectsTestSetStrung, @"objectsTestSetStrung is nil");
		objectTypes =  [[objectsTestSet objectAtIndex:div(div(index, numberOfCasesForObjects*numberOfCasesForObjectNames*numberOfCasesForPoints/[objectsTestSet count]).quot,[objectsTestSet count]).rem] retain];
		
		if (objectNames)
		{
			[objectNames release];
			objectNames = nil;
		}
		
		
		STAssertNotNil(objectNamesTestSet, @"objectNamesTestSet is nil");
		objectNames =  [[objectNamesTestSet objectAtIndex:div(div(index, numberOfCasesForObjectNames*numberOfCasesForPoints/[objectNamesTestSet count]).quot,[objectNamesTestSet count]).rem] retain];
		
		STAssertNotNil(pointsTestSet, @"pointsTestSet is nil");
		[[pointsTestSet objectAtIndex:div(div(index,numberOfCasesForPoints/[pointsTestSet count]).quot,[pointsTestSet count]).rem] getValue:&point];
		
		
		
		
		_geocoder.requestParameters = searchRequestParameters;
		
		
		[_geocoder findObjectsWithName:objectNames type:objectTypes aroundPoint:point];
		
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
	STFail(@"--------Geocoder paremeters-----");
	STFail(@"bboxOnly:       %i",searchRequestParameters.bboxOnly);
	STFail(@"returnLocation: %i",searchRequestParameters.returnLocation);
	STFail(@"returnGeometry: %i",searchRequestParameters.returnGeometry);
	STFail(@"distance:       %i",searchRequestParameters.distance);
	STFail(@"skip:           %i",searchRequestParameters.skip);
	STFail(@"returnResults:  %i",searchRequestParameters.returnResults);
	STFail(@"---------Object paremeters------");
	STFail(@"objectType:     %s",objectTypes);
	STFail(@"objectName:     %s",objectNames);
	STFail(@" ");
	STFail(@"---------Point paremeters------");
	STFail(@"coordinate:     %f %f",point.latitude,point.longitude);
	STFail(@"--------------------------------");
	failsCounter++;
}







@end
