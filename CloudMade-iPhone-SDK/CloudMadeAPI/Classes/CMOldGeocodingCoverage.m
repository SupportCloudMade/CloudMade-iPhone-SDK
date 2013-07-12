//
//  OldGeocodingCavarage.m
//  LBA
//
//  Created by user on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMOldGeocodingCoverage.h"
#import "CMGeosearchRequestParams.h"
#import "CMSearchParameters.h"
#import "CMGeocoder.h"


@implementation CMOldGeocodingCoverage


-(id) initWithApikey:(NSString*) apiKey
{
	if (self = [super init])
	{
		_apikey = [apiKey retain];
	}
	return self;
}

-(void) findObjects:(NSString*) object :(BBox*) bbox 
{
//	CMGeosearchRequestParams* searchParams = [[CMGeosearchRequestParams alloc] init];
//	searchParams.bboxOnly = YES;
//	searchParams.bbox = CMBoundingBoxMake( CLLocationCoordinate2DMake(bbox.northernLatitude,bbox.easternLongitude),CLLocationCoordinate2DMake(bbox.southernLatitude,bbox.westernLongitude));
//	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: @"BC9A493B41014CAABB98F0471D759707"];
//	_geocoder.requestParameters = searchParams;
//	_geocoder.delegate = self;	
//	
//	[_geocoder find:object around:nil];
	
	PLog(@"%s\n",__func__);
	CMGeosearchRequestParams* searchParams = [[CMGeosearchRequestParams alloc] init];
	searchParams.bboxOnly = YES;
	searchParams.bbox = CMBoundingBoxMake( CLLocationCoordinate2DMake(bbox.northernLatitude,bbox.easternLongitude),CLLocationCoordinate2DMake(bbox.southernLatitude,bbox.westernLongitude));
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.requestParameters = searchParams;
	_geocoder.delegate = self;	
	
	[_geocoder findWithQuery:object];	
	
}


-(void) findByPostcode:(NSString*) postcode inCountry:(NSString*) countryName
{
	PLog(@"%s\n",__func__);
	
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	//parameters.street = @"Пимоненко";
	//parameters.house = @"12";
	parameters.country = countryName;//@"UK";
	parameters.postcode = postcode;//@"w8 5tt";
	//parameters.city = @"Киев";

	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	//_geocoder.requestParameters = parameters;
	_geocoder.delegate = self;	
	[_geocoder findWithGeosearchParamaters:parameters];
	
}


-(void) findByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName
{
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	parameters.country = countryName;//@"UK";
	parameters.postcode = zipcode;//@"w8 5tt";
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.delegate = self;	
	[_geocoder findWithGeosearchParamaters:parameters];	
}


-(void) findCityWithName:(NSString*) name inCountry:(NSString*) countryName
{
	PLog(@"%s\n",__func__);
	
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	//parameters.street = @"Пимоненко";
	//parameters.house = @"12";
	parameters.country = countryName;//@"UK";
	//parameters.postcode = postcode;//@"w8 5tt";
	parameters.city = name;
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	//_geocoder.requestParameters = parameters;
	_geocoder.delegate = self;	
	[_geocoder findWithGeosearchParamaters:parameters];	
}


-(void) findClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate
{
	PLog(@"%s\n",__func__);

	//-(void) findObjects:(NSString*) object aroundCoordinate:(CLLocationCoordinate2D) coordinate;
	
	//CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	//parameters.street = @"Пимоненко";
	//parameters.house = @"12";
	//parameters.country = countryName;//@"UK";
	//parameters.postcode = postcode;//@"w8 5tt";
	//parameters.city = name;
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	CMGeosearchRequestParams* requestParams = [[[CMGeosearchRequestParams alloc] init] autorelease];
	//_geocoder.requestParameters = parameters;
	requestParams.distance = 0;
	_geocoder.requestParameters = requestParams;
	_geocoder.delegate = self;	
	[_geocoder findObjects:name aroundCoordinate:CLLocationCoordinate2DMake(coordinate.fLatitude,coordinate.fLongitude)];			
}


-(void) findGeoObject:(NSString*) object inBBox:(BBox*) bbox
{
	PLog(@"%s\n",__func__);

	CMGeosearchRequestParams* searchParams = [[CMGeosearchRequestParams alloc] init];
	searchParams.bboxOnly = YES;
	searchParams.bbox = CMBoundingBoxMake( CLLocationCoordinate2DMake(bbox.northernLatitude,bbox.easternLongitude),CLLocationCoordinate2DMake(bbox.southernLatitude,bbox.westernLongitude));
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.requestParameters = searchParams;
	_geocoder.delegate = self;	
	
	[_geocoder find:object around:nil];	
}


-(void) findGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
					   withName:(NSString*) objectName inCountry:(NSString*) country

{
	PLog(@"%s\n",__func__);

	// implement a new method in CMGeocoder for this function
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	//parameters.street = street;
	parameters.country = country;//@"UK";
	parameters.city = city;	
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.requestParameters.distance = distance;
	_geocoder.delegate = self;		
	[_geocoder findObjectsWithName:objectName type:objectType around:parameters];
	
}

-(void) findGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
						withName:(NSString*) objectName
{
	PLog(@"%s\n",__func__);
	
	//-(void) findObjectsWithName:(NSString*) name type:(NSString*) objectType aroundPoint:(CLLocationCoordinate2D) coordinate;
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.requestParameters.distance = distance;
	_geocoder.delegate = self;		
	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.fLatitude,point.fLongitude);
	[_geocoder findObjectsWithName:objectName 
							  type:objectType 
							aroundPoint:coordinate];
	
}


-(void) findGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
						 withName:(NSString*) objectName inCity:(NSString*) city inCountry:(NSString*) country
{
	PLog(@"%s\n",__func__);

	// implement a new method in CMGeocoder for this function
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	parameters.street = streetName;
	parameters.country = country;//@"UK";
	parameters.city = city;	
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.requestParameters.distance = distance;
	_geocoder.delegate = self;		
	[_geocoder findObjectsWithName:objectName type:objectType around:parameters];
	
}


-(void) findStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country
{
	PLog(@"%s\n",__func__);
	
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	parameters.street = street;
	parameters.country = country;//@"UK";
	parameters.city = city;
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	//_geocoder.requestParameters = parameters;
	_geocoder.delegate = self;	
	[_geocoder findWithGeosearchParamaters:parameters];		
}


-(void) findObject:(NSString*) objName around:(CLLocationCoordinate2D) coordinate withDistance:(NSNumber*) distance
{
	PLog(@"%s\n",__func__);
	
	//-(void) findObjects:(NSString*) object aroundCoordinate:(CLLocationCoordinate2D) coordinate;
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	_geocoder.delegate = self;	
	_geocoder.requestParameters.distance = 0;
	_geocoder.requestParameters.returnLocation = YES;
	[_geocoder findObjects:objName aroundCoordinate:coordinate];
}


-(void) structuralSearchWithHouse:(NSString*) houseNumber  street:(NSString*) street city:(NSString*) city 
						 postcode:(NSString*) postcode county:(NSString*) county country:(NSString*) country
{
	PLog(@"%s\n",__func__);
	
	CMSearchParameters* parameters = [[[CMSearchParameters alloc] init] autorelease];
	
	parameters.street = street;
	parameters.country = country;//@"UK";
	parameters.city = city;
	parameters.county = county;
	parameters.house = houseNumber;
	parameters.postcode = postcode;
	
	CMGeocoder* _geocoder = [CMGeocoder geocoderWithApikey: _apikey];
	//_geocoder.requestParameters = parameters;
	_geocoder.delegate = self;	
	[_geocoder findWithGeosearchParamaters:parameters];		
}

-(void) dealloc
{
	[_apikey release];
	[super dealloc];
}

#pragma mark CMGeocoder Methods

-(void) geocoder:(CMGeocoder*) geocoder didFindLocations:(NSArray*) locations
{
	//NSLog(@"%s,{%f,%f,%f,%f}@\n",__func__,geocoder.foundLocationsBBox.northeast.latitude,geocoder.foundLocationsBBox.northeast.longitude,
	//	  geocoder.foundLocationsBBox.southwest.latitude,geocoder.foundLocationsBBox.southwest.longitude);
}

@end
