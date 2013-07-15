//
//  OldGeocodingCavarage.h
//  LBA
//
//  Created by user on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "bbox.h"
#import "GeoCoordinates.h"
#import <CoreLocation/CoreLocation.h>
#import "CMGeocoder.h"

@interface CMOldGeocodingCoverage : NSObject <CMGeocoderDelegate> 
{
	NSString* _apikey;
};

/**
 *  Initializes and returns a newly allocated view object with the specified frame rectangle.
 *  @param apiKey apikey
 *  @param searchOptions search options \sa CMGeosearchOptionalParamaters
 *  @param tokenManager token manager \sa TokenManager
 */
-(id) initWithApikey:(NSString*) apiKey;
/**
 *  Searches for objects
 *  @param object searching object name
 *  @param bbox bounding box for searching in  
 *  @param results number of result
 */
-(void) findObjects:(NSString*) object :(BBox*) bbox ;
/**
 *  Searches for place by postcode
 *  @param postcode postcode
 *  @param countryName country where search should be done  
 */
-(void) findByPostcode:(NSString*) postcode inCountry:(NSString*) countryName;
/**
 *  Searches for place by zipcode
 *  @param zipcode zipcode
 *  @param countryName country in where search should be done  
 */
-(void) findByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName;
/**
 *  Searches for city with given name
 *  @param name city name
 *  @param countryName country in where search should be done  
 */
-(void) findCityWithName:(NSString*) name inCountry:(NSString*) countryName;
/**
 *  Searches for closest object to given point object 
 *  @param name object type
 *  @param coordinate where search should be done
 */
-(void) findClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate;
/**
 *  Searches for geoobject in given bounding box 
 *  @param object object type
 *  @param bbox where search should be done
 */
-(void) findGeoObject:(NSString*) object inBBox:(BBox*) bbox;
/**
 *  Searches for geoobject around given city 
 *  @param city city name
 *  @param distance distance around city
 *  @param objectType object type
 *  @param objectName object name
 *  @param country country where search should be done   
 */
-(void) findGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
					   withName:(NSString*) objectName inCountry:(NSString*) country;
/**
 *  Searches for geoobject around given point 
 *  @param point coordinate where search should be done
 *  @param distance distance around point
 *  @param objectType object type
 *  @param objectName object name
 */
-(void) findGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
						withName:(NSString*) objectName;
/**
 *  Searches for geoobject around given street 
 *  @param streetName where search should be done
 *  @param distance distance around street
 *  @param objectType object type
 *  @param objectName object type 
 *  @param city city name 
 *  @param country country in where search should be done  
 */
-(void) findGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
						 withName:(NSString*) objectName inCity:(NSString*) city inCountry:(NSString*) country;
/**
 *  Searches for street in given city 
 *  @param street where search should be done
 *  @param city city name 
 *  @param country country in where search should be done  
 */
-(void) findStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country;
/**
 *  Reverse geocoding http://developers.cloudmade.com/wiki/geocoding-http-api/Examples#Reverse-geocoding
 *  @param objName object you are looking for Details are here http://developers.cloudmade.com/wiki/geocoding-http-api/Object_Types
 *  @param coordinate coordinate
 *  @param distance distance. If distance is nil, closest object will be returned  
 */


-(void) findObject:(NSString*) objName around:(CLLocationCoordinate2D) coordinate withDistance:(NSNumber*) distance; 
/**  
 *  Structural search http://developers.cloudmade.com/wiki/geocoding-http-api/Examples#Using-structured-search 
 *  @param houseNumber number of the house 
 *  @param street where search should be done
 *  @param city city name
 *  @param postcode postcode. Can be nil 
 *  @param county county in where search should be done.Can be nil  
 *  @param country country in where search should be done.Can be nil   
 */
-(void) structuralSearchWithHouse:(NSString*) houseNumber  street:(NSString*) street city:(NSString*) city 
						 postcode:(NSString*) postcode county:(NSString*) county country:(NSString*) country;



@end
