//
//  CMRoute.m
//  Routing
//
//  Created by Dmytro Golub on 12/9/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "CMRoute.h"
#import "RMMapView.h"
#import "RMPath.h"

@implementation CMRoute

@synthesize route = _route , path = _path;


-(id) initWithNodes:(NSArray*) nodes forMap:(RMMapView*) mapView
{
	self = [super init];
	_path = [[RMPath alloc] initForMap:mapView];
	
	_path.lineColor = [UIColor blueColor];
	_path.fillColor = [UIColor clearColor];
	_path.lineWidth = 5;
	_path.scaleLineWidth = NO;	
	_route = [[NSArray alloc] initWithArray:nodes];
    _plainRoute = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D) * [nodes count]);
	int n=0;
	for(NSValue* node in nodes)
	{
		
        CLLocationCoordinate2D nd;
        [node getValue:&nd];
		[_path addLineToLatLong:nd];
		_plainRoute[n] = nd;
		++n;
	}
	return self;
}

-(NSArray*) routePoints
{
	return _route;
}


-(void) dealloc
{
    [_route release];
	[_path release];
	free(_plainRoute);
	[super dealloc];
}

@end
