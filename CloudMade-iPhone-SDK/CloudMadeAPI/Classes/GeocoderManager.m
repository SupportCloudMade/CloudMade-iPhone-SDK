//
//  RequestSynhronizer.m
//  GeocodingExample
//
//  Created by Dmytro Golub on 7/28/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "GeocoderManager.h"
#import "GeoCodingRequest.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"
#import "CMSynchronousGeocodingRequest.h" 
#import "RunLoopSource.h"
#import "NSObjectAdditions.h"

@implementation GeocoderManager

@synthesize delegate , returnResults = _returnResults;


-(void) analizeSearchRequest:(NSString*) request
{
	@synchronized(self)
	{
	NSArray *listItems = [request componentsSeparatedByString:@","];
	switch([listItems count])
	{
		case 1:
		{
			//we assume we are loking just for everything !!!
			[searchOptions setObject:[listItems objectAtIndex:0] forKey:SP_UNDETERMINATE];
		};break;
		case 2:
		{
			// we assume we are looking for city in country
			[searchOptions setObject:[listItems objectAtIndex:0] forKey:SP_CITY_NAME];
			[searchOptions setObject:[listItems objectAtIndex:1] forKey:SP_COUNTRY_NAME];
		};break;
		case 3: 
		{
			//success, we assume that first parameter is street name,
			//second is city name and third is country name
			[searchOptions setObject:[listItems objectAtIndex:0] forKey:SP_STREET_NAME];
			[searchOptions setObject:[listItems objectAtIndex:1] forKey:SP_CITY_NAME];
			[searchOptions setObject:[listItems objectAtIndex:2] forKey:SP_COUNTRY_NAME];
		};break;
	}
	
	}	
}

-(id) initWithApikey:(NSString*) apikey searchFor:(NSString*) searchRequest
{
	if([super init])
	{
		apiKey = apikey;
		tokenManager = [[TokenManager alloc] initWithApikey:apikey];
		operationCompleteCondition = [[NSCondition alloc] init];
		operationComplete = FALSE;
		gCounter = 0;
		operationExecuting = NO;
		searchResults = [[NSMutableDictionary alloc] init];	
		searchOptions = [[NSMutableDictionary alloc] init];	
		countOfStartedSearches = 0;
		[self analizeSearchRequest:searchRequest];
		boundsArray = [[NSMutableArray alloc] init];
   }
	return self;
}
		
-(void) stopThread:(id) notification
{
	PLog(@"%s\n",__FUNCTION__);
	operationComplete = TRUE;
}
		
		
-(void) search
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init]; 
	CMGeosearchOptionalParamaters* parameters = [CMGeosearchOptionalParamaters createWithNumberOfResults:10 
																							  skipResults:0
																								 withBBox:FALSE 
																						   returnGeometry:FALSE 
																					   returnLocationInfo:FALSE];
	CMSynchronousGeocodingRequest* geocoder = [[CMSynchronousGeocodingRequest alloc] initWithApikey:tokenManager.accessKey
																						withOptions:parameters tokenManager:tokenManager];
	[parameters release];	
		
	NSString* res;
		
	if([searchOptions count] == 3)
	{
		NSString* searchString = [NSString stringWithFormat:@"%@,%@,%@",
								  [searchOptions objectForKey:SP_STREET_NAME],
								  [searchOptions objectForKey:SP_CITY_NAME],
								  [searchOptions objectForKey:SP_COUNTRY_NAME]
								  ]; 
		res = [[NSString alloc] initWithString: [geocoder synchronousFindObjects:searchString :nil] ];
		//[self collectSearchResult:res];
	}
		
	if([searchOptions count] == 2)
	{
		res = [[NSString alloc] initWithString:[geocoder synchronousFindCityWithName:[searchOptions objectForKey:SP_CITY_NAME] 
										  inCountry:[searchOptions objectForKey:SP_COUNTRY_NAME]] ];
		//[self collectSearchResult:res];
	}
	
	if([searchOptions count] == 1)
	{
		res = [[NSString alloc] initWithString:[geocoder synchronousFindObjects:[searchOptions 
												objectForKey:SP_UNDETERMINATE] 
											  :nil] ];
}

	
	GeoCodingJsonParser* jsonParser = [[GeoCodingJsonParser alloc] init];
	NSArray* objects = [jsonParser fillLocationsArray:res];		
	BBox* bb = [jsonParser boundBox:res];
	NSMutableArray *results = [[NSMutableArray alloc] init];
	for(Location* location in objects)
{
		//[results setObject:location forKey:location.strID];
		[results addObject:location];
}
	[[(id)delegate cm_invokeOnMainThread] searchIsFinished:[results autorelease] inBounds:bb];
	[res release];
	[geocoder release];
	[jsonParser release];
	[pool release];	
}
/*
-(void) main
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init]; 
	[tokenManager requestToken];
    NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	threadRunLoop = myRunLoop;
    do
		
    {
		NSDate* date = [[NSDate alloc] initWithTimeIntervalSinceNow:1]; 
       [myRunLoop runUntilDate:date];
		[date release];
    }
	
    while (!operationComplete);	
	
	
	PLog(@"Reached end operation!!!\n");
	[pool release];
}
*/


-(void) addSearchTask:(NSString*) searchRequest
{
	@synchronized(self)
{
	[searchOptions removeAllObjects];
	[self analizeSearchRequest:searchRequest];	
		[self performSelectorInBackground:@selector(search) withObject:nil];
	}
}


@end
