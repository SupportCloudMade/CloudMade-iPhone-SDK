//
//  CRouteSammury.m
//  Routing
//
//  Created by Dmytro Golub on 12/11/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "CMRouteSummary.h"


@implementation CMRouteSummary

@synthesize startPoint = _startPoint, endPoint = _endPoint ,totalDistance = _totalDistance,totalTime =_totalTime ;

-(id) initWithDictionary:(NSDictionary*) properties
{
	self = [super init];
	_startPoint = [[properties objectForKey:@"start_point"] retain];
	_endPoint  = [[properties objectForKey:@"end_point"] retain]; 
	_totalDistance = [[properties objectForKey:@"total_distance"] intValue];
	_totalTime = [[properties objectForKey:@"total_time"] intValue];
	
	//total_time
	return self;
}

-(void) dealloc
{
	[_startPoint release];
	[_endPoint release];
	[super dealloc];
}

@end
