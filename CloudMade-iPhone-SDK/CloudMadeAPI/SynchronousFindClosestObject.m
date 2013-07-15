//
//  SynchronousFindClosestObject.m
//  CloudMadeApi
//
//  Created by user on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SynchronousFindClosestObject.h"
#import "TokenManager.h"
#import "CMSynchronousGeocodingRequest.h"

@implementation SynchronousFindClosestObject


-(void) testSynchronousFindClosestObject
{
	
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	
	
	CMSynchronousGeocodingRequest *geoCoder = [[CMSynchronousGeocodingRequest alloc] 
											   initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af" 
											   withOptions:nil 
											   tokenManager:tokenManager];

	GeoCoordinates *geoCoordinate = [[GeoCoordinates alloc] initWithCoordinates:51.17f :0.62f];
	NSString *jsonResponse = [geoCoder synchronousFindClosestObject:@"City" inPoint:geoCoordinate];	
	NSLog(@"%@\n",jsonResponse);
	STAssertNotNil(jsonResponse,@"CMSynchronousGeocodingRequest response is nil");
}

@end
