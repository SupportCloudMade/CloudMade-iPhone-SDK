//
//  GeoCoordinates.m
//  NavigationView
//
//  Created by Dmytro Golub on 2/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "GeoCoordinates.h"


@implementation GeoCoordinates

@synthesize fLatitude;
@synthesize fLongitude;

+(id) withLat:(float) lat Lng:(float) lng
{
	return [[[GeoCoordinates alloc] initWithCoordinates:lat :lng] autorelease];
}

-(id) initWithCoordinates:(float) lat :(float) lng
{
	[super init];
	self.fLatitude = lat;
	self.fLongitude = lng;
	return self;
}
@end
