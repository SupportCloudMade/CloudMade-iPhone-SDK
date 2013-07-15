//
//  RoutingTests.m
//  CloudMadeApi
//
//  Created by user on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RoutingTests.h"
#import "GeoCodingRequest.h"
#import "TokenManager.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"
#import "CMRouteSummary.h"

@implementation RoutingTests

-(void) testRouting
{
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	CMRoutingManager* _routingManager = [[CMRoutingManager alloc] initWithMapView:nil tokenManager:tokenManager];
	_routingManager.delegate = self;	
	_routingManager.measureUnit = CMNavigationMeasureMiles;
	[_routingManager setSimplifyRoute:FALSE];
	
	CLLocationCoordinate2D from = {51.49, -0.11};
	CLLocationCoordinate2D to = {50.81, -0.16};

	
	[_routingManager findRouteFrom:from to:to onVehicle:CMVehicleCar];	
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];
	
	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);	
}


-(void) testRoutingWithTransitPoints
{
	resultsDidReceive = NO;	
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	CMRoutingManager* _routingManager = [[CMRoutingManager alloc] initWithMapView:nil tokenManager:tokenManager];
	_routingManager.delegate = self;	
	
	[_routingManager setSimplifyRoute:TRUE];
	_routingManager.language = @"nl";
	CLLocationCoordinate2D from = {51.49, -0.11};
	CLLocationCoordinate2D to = {50.81, -0.16};
	
	CLLocationCoordinate2D node0 = {51.38,0.44};
	CLLocationCoordinate2D node1 = {51.14,0.88};
	
	NSValue *nodeCoord0 = [NSValue value:&node0 withObjCType:@encode(CLLocationCoordinate2D)];
	NSValue *nodeCoord1 = [NSValue value:&node1 withObjCType:@encode(CLLocationCoordinate2D)];
	
	NSArray* transitPoints = [NSArray arrayWithObjects:nodeCoord0,nodeCoord1,nil];
	[_routingManager findRouteFrom:from to:to withTransitPoints:transitPoints onVehicle:CMVehicleCar];
	
	NSRunLoop *theRunLoop = [NSRunLoop currentRunLoop];
	
	
	while (!resultsDidReceive && [theRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);	
}

-(void) routeDidFind:(CMRoute*) _route summary:(CMRouteSummary*) routeSummary
{
	resultsDidReceive = YES;	
    NSLog(@"%@  %@\n",routeSummary.startPoint,routeSummary.endPoint);
}

-(void) routeDidFind:(CMRouteDetails*) details
{
	NSLog(@"%s\n",__FUNCTION__);	
	resultsDidReceive = YES;
	//STAssertNotNil(nil,@"The error is not expected here!!!");
}


-(void) routeNotFound:(NSString*) desc
{
	NSLog(@"%s\n",__FUNCTION__);	
	resultsDidReceive = YES;
	STAssertNotNil(nil,@"Route wasn't found");
}


-(void) routeSearchWillStarted
{
	//resultsDidReceive = YES;
	// claer route
	NSLog(@"%s\n",__FUNCTION__);
}


@end
