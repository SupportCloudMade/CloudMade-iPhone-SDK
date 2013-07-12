//
//  CMGeosearchOptionalParamaters.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 6/23/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "CMGeosearchOptionalParamaters.h"


@implementation CMGeosearchOptionalParamaters

@synthesize numberOfResults;
@synthesize skipResults;
@synthesize bboxOnly;
@synthesize returntGeometry;
@synthesize returnLocation;

-(id) initWithNumberOfResults:(int) number skipResults:(int) skipnumber withBBox:(BOOL) bbox 
			   returnGeometry:(BOOL) geometry returnLocationInfo:(BOOL) locationInfo
{
	[super init];
	self.bboxOnly = [NSNumber numberWithBool:bbox];
	self.numberOfResults = [NSNumber numberWithInt:number];
	self.skipResults = [NSNumber numberWithInt:skipnumber];
	self.returntGeometry = [NSNumber numberWithBool:geometry];
	self.returnLocation = [NSNumber numberWithBool:locationInfo];
	return self;
}


+(id) createWithNumberOfResults:(int) number skipResults:(int) skipnumber withBBox:(BOOL) bbox 
				 returnGeometry:(BOOL) geometry returnLocationInfo:(BOOL) locationInfo
{
    return  [[[CMGeosearchOptionalParamaters alloc] initWithNumberOfResults: number skipResults:skipnumber withBBox:bbox
															returnGeometry:geometry returnLocationInfo:locationInfo] autorelease];
	
}

@end

