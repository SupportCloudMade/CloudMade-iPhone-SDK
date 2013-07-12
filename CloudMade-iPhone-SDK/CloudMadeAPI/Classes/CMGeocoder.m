//
//  CMGeosearchManager.m
//  LBA
//
//  Created by user on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMGeocoder.h"
#import "TokenManager.h"
#import "LibUtils.h"
#import "CMLocation.h"
#import "NSArrayAdditions.h"
#import "NSObjectAdditions.h"

@implementation CMGeocoder 
@synthesize requestParameters,delegate,foundLocationsBBox;

BoundingBox BoundingBoxFromDictionary(NSDictionary* dictionary)
{
	BoundingBox bbox;
	bbox.northeast.latitude = [[dictionary objectForKey:@"bbox.NE.lat"] doubleValue];
	bbox.northeast.longitude = [[dictionary objectForKey:@"bbox.NE.lon"] doubleValue];
	bbox.southwest.latitude = [[dictionary objectForKey:@"bbox.SW.lat"] doubleValue];
	bbox.southwest.longitude = [[dictionary objectForKey:@"bbox.SW.lon"] doubleValue];
	return bbox;
}

-(id) initWithApikey:(NSString*) apikey
{
	if (self = [super init])
	{
		tokenManager = [[TokenManager alloc] initWithApikey:apikey];
		self.requestParameters = [[[CMGeosearchRequestParams alloc] init] autorelease];
	}
	return self;
}

+(id) geocoderWithApikey:(NSString*) apikey
{
	return [[[CMGeocoder alloc] initWithApikey:apikey] autorelease];
}

-(void) dealloc
{
	[tokenManager release];
	[requestParameters release];
	[super dealloc];
}


-(NSString*) getGeocodingUrl
{
	return [NSString stringWithFormat:@"http://geocoding.cloudmade.com/%@/geocoding/v2/find.plist",tokenManager.accessKey];
	//return [NSString stringWithFormat:@"http://10.1.6.133:5000/geocoding/v2/find.plist"];
}


-(void) executeRequest:(NSString*) url
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	url = [tokenManager appendRequestWithToken:url];
	PLog(@"url = %@\n",url);	

	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 nil];

	
	NSArray* response = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:url] headers:headers];

	NSError* error = nil; 
	//NSString* strResponse = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];

	if (error)
	{
		PLog(@"%@ - user info %@",error,error.userInfo);
	}
	
	//NSLog(@"%@",strResponse);
	

	
    if (response && ![response count])
	{
		if ([delegate respondsToSelector:@selector(geocoder:didFailWithError:)])
		{
			[[(id)delegate cm_invokeOnMainThread] geocoder:self didFailWithError:[NSError errorWithDomain:@"Nothing was found" code:404 userInfo:nil]];
		}
	}
	else
	{
		NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	
		for (NSDictionary* properties in [response objectAtIndex:1])
		{
			CMLocation* location = [CMLocation locationWithProperties:properties];
			[resultArray addObject:location];
		}
		
		self.foundLocationsBBox = BoundingBoxFromDictionary([response objectAtIndex:0]); 
		[[(id)delegate cm_invokeOnMainThread] geocoder:self didFindLocations:[resultArray autorelease]];
	}
	[pool release];
}

-(void) findWithGeosearchParamaters:(CMSearchParameters*) parameters
{
	NSString* url = [NSString stringWithFormat:@"%@?query=%@&%@",[self getGeocodingUrl],NSStringFromCMSearchParameters(parameters),NSStringFromGeosearchRequestParams(self.requestParameters)];
	PLog(@"%@\n",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];
}


-(void) findObjects:(NSString*) object aroundCoordinate:(CLLocationCoordinate2D) coordinate
{
	NSString* url = [NSString stringWithFormat:@"%@?object_type=%@&around=%f,%f&%@",[self getGeocodingUrl],object,coordinate.latitude,coordinate.longitude,NSStringFromGeosearchRequestParams(self.requestParameters)];
	PLog(@"%@\n",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];
}

-(void) find:(NSString*) object around:(CMSearchParameters*) parameters
{
	NSString* url = nil;
	if (parameters != nil)
	{
		url = [NSString stringWithFormat:@"%@?object_type=%@&around=%@,%@",[self getGeocodingUrl],object,
					 NSStringFromCMSearchParameters(parameters),NSStringFromGeosearchRequestParams(self.requestParameters)];
	}
	else
	{
		url = [NSString stringWithFormat:@"%@?object_type=%@&%@",[self getGeocodingUrl],object,
			   NSStringFromGeosearchRequestParams(self.requestParameters)];
	}

	PLog(@"%@\n",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];
}


-(void) findWithQuery:(NSString *) query
{
	NSString* url = [NSString stringWithFormat:@"%@?query=%@&%@",[self getGeocodingUrl],query,NSStringFromGeosearchRequestParams(self.requestParameters)];
	PLog(@"%@\n",[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];	
}

-(void) findObjectsWithName:(NSString*) name type:(NSString*) objectType around:(CMSearchParameters*) parameters
{
	NSString* url = nil;
	if (parameters != nil)
	{
		url = [NSString stringWithFormat:@"%@?query=%@&object_type=%@&around=%@&%@",[self getGeocodingUrl],name,objectType,
			   NSStringFromCMSearchParameters(parameters),NSStringFromGeosearchRequestParams(self.requestParameters)];
	}
	else
	{
		url = [NSString stringWithFormat:@"%@?query=%@&object_type=%@&%@",[self getGeocodingUrl],name,objectType,objectType,
			   NSStringFromGeosearchRequestParams(self.requestParameters)];
	}
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];	
}

-(void) findObjectsWithName:(NSString*) name type:(NSString*) objectType aroundPoint:(CLLocationCoordinate2D) coordinate
{
	NSString* url = nil;
	url = [NSString stringWithFormat:@"%@?query=%@&object_type=%@&around=%f,%f&%@",[self getGeocodingUrl],name,objectType,
			    coordinate.latitude,coordinate.longitude,NSStringFromGeosearchRequestParams(self.requestParameters)];
	
	[self  performSelectorInBackground:@selector(executeRequest:) withObject:url];		
}

@end