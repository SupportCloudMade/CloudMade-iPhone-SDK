/*
 * Copyright 2009 CloudMade.
 *
 * Licensed under the GNU Lesser General Public License, Version 3.0;
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GeoCodingRequest.h"
#import "HelperConstant.h"
#import "GeoCoordinates.h" 
#import "GeoCodingJsonParser.h"
#import "LibUtils.h"

#define GEOCODING_SERVER @"http://geocoding.cloudmade.com"

//#define GEOCODING_SERVER @"http://geocoding.qa01.cm.kyiv.cogniance.com"


@implementation CMGeosearchURLBuilder
+(NSString*) buildUrlForObject:(NSString*) object withApikey:(NSString*) apikey
{
   return [NSString stringWithFormat:@"%@/%@/geocoding/find/%@.js",GEOCODING_SERVER,apikey,object];	
}
+(NSString*) buildUrlWithPostcode:(NSString*) postcode withApikey:(NSString*) apikey
{
	return [NSString stringWithFormat:@"%@/%@.js",[NSString stringWithFormat:@"%@/%@/geocoding/postcode",GEOCODING_SERVER,apikey],postcode];
}

+(NSString*) buildUrlWithZipcode:(NSString*) zipcode withApikey:(NSString*) apikey
{
	return [NSString stringWithFormat:@"%@/%@.js",[NSString stringWithFormat:@"%@/%@/geocoding/zipcode",GEOCODING_SERVER,apikey],zipcode];
}

+(NSString*) buildUrlWithCity:(NSString*) name withApikey:(NSString*) apikey
{
	return [NSString stringWithFormat:@"%@/%@.js",[NSString stringWithFormat:@"%@/%@/geocoding/city",GEOCODING_SERVER,apikey],name];
}
+(NSString*) buildUrlForClosest:(NSString*) name withApikey:(NSString*) apikey inPoint:(GeoCoordinates*) coordinate
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/closest/%@/%f,%f.js",GEOCODING_SERVER,apikey,name,coordinate.fLatitude,coordinate.fLongitude];
}

+(NSString*) buildUrlForGeoobject:(NSString*) name withApikey:(NSString*) apikey
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/geoobject/%@.js",GEOCODING_SERVER,apikey,name];
}

+(NSString*) buildUrlForGeoobjectAroundCity:(NSString*) name withApikey:(NSString*) apikey inDistance:(int) distance
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/geoobject_around_city/%@/%i.js",GEOCODING_SERVER,apikey,name,distance];
}

+(NSString*) buildUrlForGeoobjectAroundPoint:(GeoCoordinates*) point withApikey:(NSString*) apikey inDistance:(int) distance
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/geoobject_around_point/%f,%f/%i.js",GEOCODING_SERVER,apikey,point.fLatitude,point.fLongitude,distance];
}

+(NSString*) buildUrlForGeoobjectAroundStreet:(NSString*) street withApikey:(NSString*) apikey inDistance:(int) distance
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/geoobject_around_street/%@/%i.js",GEOCODING_SERVER,apikey,street,distance];
}

+(NSString*) buildUrlToFindStreet:(NSString*) street withApikey:(NSString*) apikey 
{
	return [NSString stringWithFormat:@"%@/%@/geocoding/street/%@.js",GEOCODING_SERVER,apikey,street];
}


+(NSString*) buildUrlToFindObject:(NSString*) objName  around:(CLLocationCoordinate2D)coordinate 
						 distance:(NSNumber*) distance  withApikey:(NSString*) apikey extraParams:(NSDictionary*) parameters
{
	NSString* strDistance;
	if(distance)
	{
		strDistance = [distance stringValue];
	}
	else
	{
		strDistance = @"closest";
	}
	
	NSString *url =  [NSString stringWithFormat:@"%@/%@/geocoding/v2/find.js?object_type=%@&distance=%@&around=%f,%f",
			GEOCODING_SERVER,apikey,objName,strDistance,coordinate.latitude,coordinate.longitude];
	
	for (id key in parameters)
	{
		NSString* delimeter = @"&";
		id object = [parameters objectForKey:key];
		if( [object isKindOfClass:[BBox class]] )
		{
			url = [url stringByAppendingFormat:@"%@%@=%@",delimeter,key,[((BBox*)object) asString]];
		}
		else
			url = [url stringByAppendingFormat:@"%@%@=%@",delimeter,key,object];
	}
	
	return url;
	
}


@end


@implementation GeoCodingRequest

@synthesize parameters;
#ifdef __GEO_CACHING__	
@synthesize requestedURL;

#endif

-(NSString*) appendWithSearchOptions:(NSDictionary*) options
{
	int i=0;
	NSString* url = [[NSString alloc] init];
	for (id key in options)
	{
		NSString* delimeter = i?@"&":@"?";
		id object = [options objectForKey:key];
		if( [object isKindOfClass:[BBox class]] )
		{
			url = [url stringByAppendingFormat:@"%@%@=%@",delimeter,key,[((BBox*)object) asString]];
		}
		else
			url = [url stringByAppendingFormat:@"%@%@=%@",delimeter,key,object];
		++i;
	}	
	return url;
}

-(NSMutableDictionary*) optionsDictionary
{
	NSMutableDictionary* params = [[NSMutableDictionary alloc] init];

	if(parameters)
	{
		if(parameters.bboxOnly)
			[params setObject:parameters.bboxOnly forKey:@"bbox_only"];
		if(parameters.numberOfResults)
			[params setObject:parameters.numberOfResults forKey:@"results"];
		if(parameters.returnLocation)
			[params setObject:parameters.returnLocation forKey:@"return_location"];
		if(parameters.returntGeometry)
			[params setObject:parameters.returntGeometry forKey:@"return_geometry"];
		if(parameters.skipResults)
			[params setObject:parameters.skipResults forKey:@"skip"];
	}	
	return [params autorelease];
}

-(id) initWithApikey:(NSString*) apiKey withOptions:(CMGeosearchOptionalParamaters*) searchOptions tokenManager:(TokenManager*) tokenManager;
{
	self = [super init];
	apikey = apiKey;
	errorStatus	= FALSE;
	self.parameters = searchOptions;
	_tokenManager = tokenManager;
	return self;
}

-(NSString*) getGeocodingUrl
{
//#ifdef __PRODUCTION__		
	return [NSString stringWithFormat:@"http://geocoding.cloudmade.com/%@/geocoding/find",apikey];	
//#else
//	return [NSString stringWithFormat:@"%@",GEOCODING_URL];		
//#endif //__PRODUCTION__			
}

-(NSString*) composeURL:(NSString*) object withBB:(BBox*) bbox results:(int) results :(BOOL) location 
{
/*	
	if(location)
		return [NSString stringWithFormat:@"%@/%@.js?results=%d&bbox=%@&bbox_only=false&return_location=true",[self getGeocodingUrl],object,results,[bbox asString]];		
	
	return [NSString stringWithFormat:@"%@/%@.js?results=%d&bbox=%@&bbox_only=false&return_geometry=false",[self getGeocodingUrl],object,results,[bbox asString]];
*/ 
	if(location)
		return [NSString stringWithFormat:@"%@/%@.js?results=%d&return_location=true",[self getGeocodingUrl],object,results,[bbox asString]];		
	
	return [NSString stringWithFormat:@"%@/%@.js?results=%d&return_geometry=false",[self getGeocodingUrl],object,results,[bbox asString]];
}

-(void) executeRequest:(NSString*) url
{
	#ifdef __GEO_CACHING__		
		self.requestedURL = url;
		NSString* response = [[SQLManager mainDB] findResponse:url];
		if(response)
		{
			PLog(@"response taken from DB\n%@\n",response);
			[delegate serviceServerResponse:response];
			return;
		}
		#endif	
	
	url = [_tokenManager appendRequestWithToken:url];
	PLog(@"url = %@\n",url);	
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
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
	// Create the NSMutableData that will hold
	// the received data
	// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
	// inform the user that the download could not be made
	}
}



-(void) findObjects:(NSString*) object :(BBox*) bbox 
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
	[self executeRequest:url];	
}

-(void) findByPostcode:(NSString*) postcode inCountry:(NSString*) countryName
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
	[self executeRequest:url];
}


-(void) findByZipcode:(NSString*) zipcode inCountry:(NSString*) countryName
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
	[self executeRequest:url];
}


-(void) findCityWithName:(NSString*) name inCountry:(NSString*) countryName
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
	[self executeRequest:url];
}


-(void) findClosestObject:(NSString*) name inPoint:(GeoCoordinates*) coordinate
{  
	NSMutableDictionary* params = [self optionsDictionary];
	NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [NSString stringWithFormat:@"%@/%@",
					 [CMGeosearchURLBuilder buildUrlForClosest:name withApikey:apikey inPoint:coordinate],options];
	
	//[params release];
	//[options release];
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[self executeRequest:url];
}


-(void) findGeoObject:(NSString*) object inBBox:(BBox*) bbox
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
	
	[self executeRequest:url];
}


-(void) findGeoObjectAroundCity:(NSString*) city inDistance:(int) distance withType:(NSString*) objectType 
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
	
	[self executeRequest:url];
}


-(void) findGeoObjectAroundPoint:(GeoCoordinates*) point inDistance:(int) distance withType:(NSString*) objectType 
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
	
	[self executeRequest:url];
}

-(void) findGeoObjectAroundStreet:(NSString*) streetName inDistance:(int) distance withType:(NSString*) objectType 
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
	[self executeRequest:url];
}


-(void) findStreetWithName:(NSString*) street inCity:(NSString*) city inCountry:(NSString*) country
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
	[self executeRequest:url];	
}


-(void) findObject:(NSString*) objectName around:(CLLocationCoordinate2D) coordinate withDistance:(NSNumber*) distance
{
	NSMutableDictionary* params = [self optionsDictionary];
	//NSString* options = [self appendWithSearchOptions:params];
	NSString* url = [CMGeosearchURLBuilder buildUrlToFindObject:objectName around:coordinate 
													   distance:distance withApikey:apikey extraParams:params];
	
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	
	
	[self executeRequest:url];	
}


-(void) structuralSearchWithHouse:(NSString*) houseNumber  street:(NSString*) street city:(NSString*) city 
						 postcode:(NSString*) postcode county:(NSString*) county country:(NSString*) country
{
   	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if(houseNumber)
	   [dict setObject:houseNumber forKey:@"house"];
	
	if(street)
		[dict setObject:street forKey:@"street"];
	
	if(city)
		[dict setObject:city forKey:@"city"];
	
	if(postcode)
		[dict setObject:postcode forKey:@"postcode"];
	
	if(county)
		[dict setObject:county forKey:@"county"];
	
	if(country)
		[dict setObject:country forKey:@"country"];	
	
	NSString* url = [NSString stringWithFormat:@"http://geocoding.cloudmade.com/%@/geocoding/v2/find.js?query=",apikey];
	int nCount = 0;
	for(NSString* key in [dict allKeys])
	{
		if(nCount != ([dict count] -1))
			url = [url stringByAppendingFormat:@"%@:%@&",key,[dict objectForKey:key]];
		else
			url = [url stringByAppendingFormat:@"%@:%@",key,[dict objectForKey:key]];
		nCount++;
	}
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[self executeRequest:url];
	[dict release];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //unsigned char* pData = malloc([receivedData length]);
    //PLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	//[receivedData getBytes:pData];
	//pData[[receivedData length]] = '\0';
    //PLog(@"connectionDidFinishLoading \n\ndata %s", (char *)pData);

	if(!errorStatus)
	{
		NSString* response = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		[(id)delegate performSelectorOnMainThread:@selector(serviceServerResponse:) withObject:response waitUntilDone:YES];
#ifdef __GEO_CACHING__			
		[[SQLManager mainDB] cacheURL:self.requestedURL :response];
#endif		
		[response release];
	}
	
	//free(pData);
    [connection release];
    [receivedData release];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    PLog(@"Connection failed! Error - %@ %@",
		 [error localizedDescription],
		 [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);	
	id del = delegate;
	if([del respondsToSelector:@selector(serviceServerError:)])
		[delegate serviceServerError:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;	
	PLog(@"Server response %d\n",[httpResponse statusCode]);
	
	switch ([httpResponse statusCode])
	{
		case 400:case 401:case 403:case 404:case 500:
			errorStatus = YES;
			//@throw [NSException exceptionWithName: @"Server response" reason:@"Wrong parameters!!!" userInfo:nil];
			break; 
		default:
			break;
	}
	
	// inform the user
	if(errorStatus)
	{
		PLog(@"Connection failed! Error - %d" ,[httpResponse statusCode]);			
		id del = delegate;
		if([del respondsToSelector:@selector(serviceServerError:)])
			[delegate serviceServerError:@""];	
	}
    [receivedData setLength:0];
}

@end
