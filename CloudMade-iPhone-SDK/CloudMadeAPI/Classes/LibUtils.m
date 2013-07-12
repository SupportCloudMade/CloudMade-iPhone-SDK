/*
 *  LibUtils.c
 *  SponsoredPOIs
 *
 *  Created by Dmytro Golub on 10/16/09.
 *  Copyright 2009 CloudMade. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#include "LibUtils.h"


NSString* PathForBundleResource(NSString* relativePath)
{
	NSString* resourcePath =@"SPOI.bundle";
	return [resourcePath stringByAppendingPathComponent:relativePath];
}


void printBBox(RMSphericalTrapezium bbox,NSString* msg)
{
	PLog(@"%@ BBox  ne = (%f,%f) sw = (%f,%f)\n",msg,bbox.northeast.latitude,bbox.northeast.longitude,
		  bbox.southwest.latitude,bbox.southwest.longitude);
}


NSString* ApplicationNameFromBundle()
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

NSString* ApplicationVersion()
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

