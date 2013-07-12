//
//  JsonRoutingParser.m
//  NavigationView
//
//  Created by Dmytro Golub on 2/10/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import "JsonRoutingParser.h"
#import "JSON.h"
#import "NSString+SBJSON.h"
#import "GeoCoordinates.h"
#import "CMRouteInstruction.h"
//#import "RoutingManager.h"

@implementation JsonRoutingParser

-(NSArray*) routeInstructions:(NSString*) json
{
	NSMutableArray* resultArray = [[[NSMutableArray alloc] init] autorelease];
	id result = [json JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSArray* route = [res objectForKey:@"route_instructions"];
		for( NSArray* instr in route )
		{
			CMRouteInstruction* instruction = [[CMRouteInstruction alloc] init];
			instruction.instruction = [instr objectAtIndex:0];
			instruction.distance = [instr objectAtIndex:4];
			[resultArray addObject:instruction];
			[instruction release];
		}	
	}				
	return resultArray;
}

-(NSArray*) route:(NSString*) json
{
	_routeBounds.maxLat = _routeBounds.maxLng = -250.0;
	_routeBounds.minLng = _routeBounds.minLat = 250.0;
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	id result = [json JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSArray* route = [res objectForKey:@"route_geometry"];
		for( NSArray* coord in route )
		{
			float fLongitude = [[coord objectAtIndex:1] doubleValue];
			
			if(_routeBounds.maxLng < fLongitude)
				_routeBounds.maxLng = fLongitude;
			if(_routeBounds.minLng > fLongitude)
				_routeBounds.minLng = fLongitude;
			
			float fLatitude = [[coord objectAtIndex:0] doubleValue];
			
			if(_routeBounds.maxLat < fLatitude)
				_routeBounds.maxLat = fLatitude;
			if(_routeBounds.minLat > fLatitude)
				_routeBounds.minLat = fLatitude;
			
			
			GeoCoordinates* point = [[GeoCoordinates alloc] initWithCoordinates:fLatitude :fLongitude];
			[resultArray addObject:point];
			[point release];
		}
//		[[RoutingManager shareSingleton] setBounds:minLat :maxLat :minLng :maxLng];		
	}				
		
	return resultArray;
}

-(RouteSummary*) routeSummury:(NSString*) json
{
	RouteSummary* summary = 0;
	
	id result = [json JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSDictionary* routeSummary = [res objectForKey:@"route_summary"];
		if( routeSummary )
		{
			summary = [[RouteSummary alloc] init];
			NSString* strLocName = [routeSummary objectForKey:@"start_point"]; 
			const char* point = [strLocName UTF8String];
			summary.startPoint = [NSString stringWithUTF8String:point];			
			//NSUnicodeStringEncoding
			
			//summary.start_point = [routeSummary objectForKey:@"start_point"]; 						
			summary.endPoint= [routeSummary objectForKey:@"end_point"];
			summary.totalDistance = [[routeSummary objectForKey:@"total_distance"] intValue];
			summary.totalTime = [[routeSummary objectForKey:@"total_time"] intValue];
		}
			
	}				
    return summary;
}

-(BOOL) responceStatus:(NSString*) json
{
	id result = [json JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSNumber* rStatus = [res objectForKey:@"status"];
		return [rStatus boolValue]?FALSE:TRUE;
	}
	return FALSE;
}

-(NSString*) errMsg:(NSString*) json
{
	id result = [json JSONValue];
	NSString* rStatus = nil;
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		rStatus = [res objectForKey:@"status_message"];
	}
	return rStatus;		
}

-(struct bounds) routeBounds
{
	return _routeBounds;
}

@end
