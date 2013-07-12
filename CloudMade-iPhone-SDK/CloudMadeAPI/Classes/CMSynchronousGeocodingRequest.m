//
//  CMSynchronousGeocodingRequest.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 8/4/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "CMSynchronousGeocodingRequest.h"
#import "LibUtils.h"

@implementation CMSynchronousGeocodingRequest

-(NSString*) executeSynchronousRequest:(NSString*) url
{
	NSData* data = nil;
	url = [_tokenManager appendRequestWithToken:url];
	//NSLog(@"%s, url = %@\n",__FUNCTION__,url);
#ifdef __NETWORK_LOGGING__	
	logMsg2("%s, url = %s\n",__FUNCTION__,[url UTF8String]);
#endif	
	
	NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
														timeoutInterval:20.0];
	// create the connection with the request
	// and start loading the data
	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 nil];
	for (NSString* key in [headers allKeys])
	{
		//[theRequest setValue:@"CloudMadeIphoneLib" forHTTPHeaderField:@"X-ServiceSource"];
		[theRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
	}		
	
	NSURLResponse* response;
	NSError*       error; 
	data = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	if(data)
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	else
	{
		if(error)
		{
#ifdef __NETWORK_LOGGING__			
			logMsg2("Token request error. %s\n",[[error localizedDescription] UTF8String]);
#endif			
		}
		return nil;
	}

}


-(NSString*) synchronousFindObjects:(NSString*) object :(BBox*) bbox 
{  
	
	NSMutableDictionary* params = [self optionsDictionary];
	if(bbox)
	{
		[params setObject:bbox forKey:@"bbox"];
	}
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",[CMGeosearchURLBuilder buildUrlForObject:object withApikey:apikey],
					 options];
	
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	//NSLog(@"%s, url = %@\n",__FUNCTION__,url);
	
	return [self executeSynchronousRequest:url];	
}

-(NSString*) synchronousFindByPostcode:(NSString*) postcode inCountry:(NSString*) countryName
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(countryName)
	{
		[params setObject:countryName forKey:@"country_name"];
	}
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",[CMGeosearchURLBuilder buildUrlWithPostcode:postcode withApikey:apikey],
					 options];
	
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(countryName)
	{
		[params setObject:countryName forKey:@"country_name"];
	}
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",[CMGeosearchURLBuilder buildUrlWithZipcode:zipcode withApikey:apikey],
					 options];
	
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindCityWithName:(NSString*) name inCountry:(NSString*) countryName
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(countryName)
	{
		[params setObject:countryName forKey:@"country_name"];
	}
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",[CMGeosearchURLBuilder buildUrlWithCity:name withApikey:apikey],
					 options];
	
	//[params release];
	//[options release];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	//[NSString stringWithFormat:@"%@/%@.js?country_name=results=%d&return_geometry=false",[self getGeocodingUrl],postcode,results,[bbox asString]];
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate
{  
	NSMutableDictionary* params = [self optionsDictionary];
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForClosest:name withApikey:apikey inPoint:coordinate],options];
	
	//[params release];
	//[options release];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindGeoObject:(NSString*) object inBBox:(BBox*) bbox
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(bbox)
	{
		[params setObject:bbox forKey:@"bbox"];
	}	
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForGeoobject:object withApikey:apikey],options];
	
	//[params release];
	//[options release];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
					   withName:(NSString*) objectName inCountry:(NSString*) country
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(objectType)
	{
		[params setObject:objectType forKey:@"object_type"];
	}	
	
	if(objectName)
	{
		[params setObject:objectName forKey:@"object_name"];
	}	
	
	if(country)
	{
		[params setObject:country forKey:@"country_name"];
	}
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForGeoobjectAroundCity:city withApikey:apikey inDistance:distance],options];
					 
	
	//[params release];
	//[options release];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
						withName:(NSString*) objectName
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(objectType)
	{
		[params setObject:objectType forKey:@"object_type"];
	}	
	
	if(objectName)
	{
		[params setObject:objectName forKey:@"object_name"];
	}	
	
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForGeoobjectAroundPoint:point withApikey:apikey inDistance:distance ],options];
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [self executeSynchronousRequest:url];	
}

-(NSString*) synchronousFindGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
						 withName:(NSString*) objectName inCity:(NSString*) city inCountry:(NSString*) country
{  
	NSMutableDictionary* params = [self optionsDictionary];
	if(objectType)
	{
		[params setObject:objectType forKey:@"object_type"];
	}	
	
	if(objectName)
	{
		[params setObject:objectName forKey:@"object_name"];
	}	
	
	if(city)
	{
		[params setObject:city forKey:@"city_name"];
	}	
	
	if(country)
	{
		[params setObject:country forKey:@"country_name"];
	}	
	
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForGeoobjectAroundStreet:streetName withApikey:apikey inDistance:distance ],options];
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [self executeSynchronousRequest:url];	
}


-(NSString*) synchronousFindStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country
{
	NSMutableDictionary* params = [self optionsDictionary];
	
	if(city)
	{
		[params setObject:city forKey:@"city_name"];
	}	
	
	if(country)
	{
		[params setObject:country forKey:@"country_name"];
	}	
	
	
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlToFindStreet:street withApikey:apikey],options];
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [self executeSynchronousRequest:url];	
}

@end
