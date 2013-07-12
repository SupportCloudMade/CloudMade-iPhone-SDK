//
//  CMRoutingManager.m
//  Routing
//
//  Created by Dmytro Golub on 12/7/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "CMRoutingManager.h"
#import "RMMapView.h"
#import "CMRoute.h"
#import "RMMapContents.h"
#import "RMMarkerManager.h"
#import "CMRouteSummary.h"
#import "TokenManager.h"
#import "RouteSimplification.h"
#import "NSArrayAdditions.h"
#import "LibUtils.h"
#import "RMPath.h"
#import "CMRouteInstruction.h"

//TODO: add APIKEY to request
#define ROUTING_BASE_URL   @"http://routes.cloudmade.com" //@"http://10.1.3.255:8180/routing/api/0.3"

@interface CMRouteArgs : NSObject
{
	CLLocationCoordinate2D _from;
	CLLocationCoordinate2D _to;
	CMRoutingVehicle       _vehicle; 
	NSArray*               _transitPoints;
}


@property (readwrite) CLLocationCoordinate2D from;
@property (readwrite) CLLocationCoordinate2D to;
@property (readwrite) CMRoutingVehicle vehicle;
@property (nonatomic,retain) NSArray*  transitPoints;

@end


@implementation CMRouteArgs

@synthesize from = _from,to = _to,vehicle = _vehicle,transitPoints=_transitPoints;


//-(void) dealloc
//{
//	PLog(@"%s\n",__func__);
//	[super dealloc];
//}

@end

@interface CMRoutingManager (private)
-(void) addStartPointMarker:(CLLocationCoordinate2D) startPosition;
-(void) addEndPointMarker:(CLLocationCoordinate2D) endPosition;
-(void) sendCallbackRouteDidFindToDelegate;
@end

@implementation CMRoutingManager

@synthesize delegate;
@synthesize simplifyRoute = _simplifyRoute,distance = _distance,measureUnit=_measureUnit,language=_language;

-(id) initWithMapView:(RMMapView*) mapView tokenManager:(TokenManager*) tokenManager
{
	[super init];
	_mapView = mapView;
	_tokenManager = tokenManager;
	_simplifyRoute = FALSE;
	_distance = 100;
	//_routeInstructions = nil;
	routeData = nil;
	_route = nil;
    _threadForCallbackToDelegate = nil;
	_measureUnit = CMNavigationMeasureKilometers;
	self.language = @"en";
	_isActive = FALSE;
	return self;
}



-(UIImage*) imageFor:(CMRoutePoint) point
{
	UIImage* resImg = nil;
	switch (point)
	{
		case CMRouteStartPoint:
		{
			if(!_startRoutePointImage)
			{
				_startRoutePointImage = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
																			[[NSBundle mainBundle] resourcePath], @"p_flag_green.png"]];
			}
			resImg = _startRoutePointImage;
		}
		break;
		case CMRouteFinishPoint:
		{
			if(!_endRoutePointImage)
			{
				_endRoutePointImage = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",
																			[[NSBundle mainBundle] resourcePath], @"p_flag_finish.png"]];
			}
			resImg = _endRoutePointImage;
		}
		break;
			
		default:
			NSAssert(YES,@"WTF!!!");
			break;
	}
	return resImg;
}

-(NSString*) mapEnumToString:(CMRoutingVehicle) vehicle
{
	NSString* vehicleName;
	switch (vehicle) {
		case CMVehicleCar:
			vehicleName = @"car";
			break;
		case CMVehicleBike:
			vehicleName = @"bicycle";
			break;		
		case CMVehicleWalking:
			vehicleName = @"foot";
			break;			
		default:
			NSAssert(TRUE,@"Something bad happens!!!");
			break;
	}
	return vehicleName;
}

-(NSString*) composeRoutingURL:(CMRouteArgs*) parameters
{
	NSMutableString* url = [[NSMutableString alloc] init];
	if (parameters.transitPoints)
	{
		[url appendFormat:@"%f,%f,[",parameters.from.latitude,parameters.from.longitude];
		int n=0;
		for (NSValue* transitPoint in parameters.transitPoints)
		{
			CLLocationCoordinate2D nd;
			[transitPoint getValue:&nd];
			if (n>0)
			{
				[url appendFormat:@","];
			}
			[url appendFormat:@"%f,%f",nd.latitude,nd.longitude]; // add missing parameters
			++n;
		}
		[url appendFormat:@"],%f,%f",parameters.to.latitude,parameters.to.longitude];
	}
	else
	{
		[url appendFormat:@"%f,%f,%f,%f",parameters.from.latitude,parameters.from.longitude,
		 parameters.to.latitude,parameters.to.longitude];
	}

	return [url autorelease];
}

-(NSString*) navigationMeasureUnit
{
	if (self.measureUnit == CMNavigationMeasureKilometers)
		return @"km";
	return @"miles";
}

-(NSArray*) routeInstructions
{
	NSMutableArray* _routeInstructions = nil;
	
	if (routeData && [routeData count]>=4){
		NSDictionary* status = [routeData objectAtIndex:0];
		if ([[status objectForKey:@"status"] intValue]==0) {
			NSArray* tempRouteInstructionsDictionary = [routeData objectAtIndex:3];
			NSMutableArray* dict = [routeData objectAtIndex:2];
			_routeInstructions = [[[NSMutableArray alloc] init] autorelease];
			
			for (NSDictionary* tempRouteInstructionDictionary in tempRouteInstructionsDictionary){
				
				CMRouteInstruction* tempRouteInstruction = [[CMRouteInstruction alloc] init];
				tempRouteInstruction.instruction = [tempRouteInstructionDictionary objectForKey:@"instruction"];
				tempRouteInstruction.distance =  [tempRouteInstructionDictionary objectForKey:@"length_formatted"];
				tempRouteInstruction.turnInstruction =  [tempRouteInstruction extractTurnInstruction:tempRouteInstructionDictionary];
				
				if (_simplifyRoute) {
					tempRouteInstruction.location = CLLocationCoordinate2DMake(0,0);
					
				}
				else {
					tempRouteInstruction.location = CLLocationCoordinate2DMake([[[dict objectAtIndex:[[tempRouteInstructionDictionary objectForKey:@"offset"] integerValue]] objectForKey:@"lat"] doubleValue], [[[dict objectAtIndex:[[tempRouteInstructionDictionary objectForKey:@"offset"] integerValue]] objectForKey:@"lon"] doubleValue]);
					
				}
				
				
				[_routeInstructions addObject:tempRouteInstruction];
				[tempRouteInstruction release];
			}
			
			
		}
		
	}
	else {
		return nil;
	}
	
	return _routeInstructions;
	
}

-(void) findRouteFrom:(id) args
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	CMRouteArgs* arguments = args;
	
	if (routeData)
	{
		[routeData release];
		routeData = nil;
	}
	
	NSString* url = [NSString stringWithFormat:@"%@/%@/api/0.3/%@/%@.js?units=%@&lang=%@&templateId=iphone/raw.xml.ftl",ROUTING_BASE_URL,
					 _tokenManager.accessKey,[self composeRoutingURL:arguments],[self mapEnumToString:arguments.vehicle],[self navigationMeasureUnit],
					 self.language];
	
	url = [_tokenManager appendRequestWithToken:url];
	
	PLog(@"%@",url);
	
	//added custom header to request 
	//NSArray* routeData = [[NSArray alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
	
	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 nil];
	routeData = [[NSArray arrayWithContentsOfURL:[NSURL URLWithString:url] headers:headers] retain];
	
	
	NSDictionary* status = [routeData objectAtIndex:0];
	if([[status objectForKey:@"status"] intValue])
	{
		if([(id)delegate respondsToSelector:@selector(routeNotFound:)])
		{
	//		[delegate routeNotFound:[status objectForKey:@"status_message"]];
            if (![_threadForCallbackToDelegate isCancelled] && ![_threadForCallbackToDelegate isFinished]) {
                [(id)delegate performSelector:@selector(routeNotFound:) onThread:_threadForCallbackToDelegate withObject:[status objectForKey:@"status_message"] waitUntilDone:NO];
            }
			_isActive = FALSE;
			return;
		}
	}
		
	if([routeData count]<4)
	{
	//	[delegate routeNotFound:@"Server error!!!"];
        if ([_threadForCallbackToDelegate isExecuting]) {
            [(id)delegate performSelector:@selector(routeNotFound:) onThread:_threadForCallbackToDelegate withObject:@"Server error!!!" waitUntilDone:NO];
        }
		_isActive = FALSE;
		return;
	}
	
	[self removeRouteFromMap];
	
	NSArray* dict = [routeData objectAtIndex:2];
	NSDictionary* summary = [routeData objectAtIndex:1];
	
	
	if (_routeSammury)
	{
		[_routeSammury release];
		_routeSammury = nil;
	}
	_routeSammury = [[CMRouteSummary alloc] initWithDictionary:summary];
	
//	if (_routeInstructions)
//	{
//		[_routeInstructions release];
//		_routeInstructions = nil;
//	}
//	
//	_routeInstructions = [routeData objectAtIndex:3];
//	[_routeInstructions retain];

	CLLocationCoordinate2D ne = { [[summary objectForKey:@"bbox.NE.lat"] floatValue],[[summary objectForKey:@"bbox.NE.lon"] floatValue] };
	CLLocationCoordinate2D sw = { [[summary objectForKey:@"bbox.SW.lat"] floatValue],[[summary objectForKey:@"bbox.SW.lon"] floatValue] };
			
	if([(id)delegate respondsToSelector:@selector(routeDidFind:)])
	{
		CMRouteDetails* details = [[[CMRouteDetails alloc] init] autorelease];
		details.ne = ne;
		details.sw = sw;
	//	[(id)delegate performSelectorOnMainThread:@selector(routeDidFind:) withObject:details waitUntilDone:NO];
        if (![_threadForCallbackToDelegate isCancelled] && ![_threadForCallbackToDelegate isFinished]) {
            [(id)delegate performSelector:@selector(routeDidFind:) onThread:_threadForCallbackToDelegate withObject:details waitUntilDone:NO];
        }
	}
	
	NSMutableArray* routeNodes = [[NSMutableArray alloc] init];
	CLLocationCoordinate2D* rawRoute;
	if(_simplifyRoute)
		rawRoute = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D)*[dict count]);
	int i=0;
	for(NSDictionary* point in dict)
	{
		CLLocationCoordinate2D node = { [[point objectForKey:@"lat"] floatValue] ,[[point objectForKey:@"lon"] floatValue]  };
		if(_simplifyRoute)
		{
			rawRoute[i] = node;
			++i;
		}
		NSValue *nodeCoord = [NSValue value:&node withObjCType:@encode(CLLocationCoordinate2D)]; 
		[routeNodes addObject:nodeCoord];
	}
	
	if (_route)
	{
		[_route release];
	}
	
	if(_simplifyRoute)
	{
	
		int nCount = [routeNodes count];
		CLLocationCoordinate2D* simplifiedRoute = simplifyRoute(rawRoute, &nCount,_distance);
        free(rawRoute);///!!!///
	
		NSMutableArray* simplifiedRouteNodes = [[NSMutableArray alloc] init];
	
		for(i=0;i<nCount;i++)
		{
			NSValue *nodeCoord = [NSValue value:&simplifiedRoute[i] withObjCType:@encode(CLLocationCoordinate2D)]; 
			[simplifiedRouteNodes addObject:nodeCoord]; 
		}
  
	   _route = [[CMRoute alloc] initWithNodes:simplifiedRouteNodes forMap:_mapView]; 
		[simplifiedRouteNodes release];
		free(simplifiedRoute);
	}	
	else
	{
		_route = [[CMRoute alloc] initWithNodes:routeNodes forMap:_mapView]; 
	}
  
	[_mapView.contents.overlay addSublayer:_route.path];
    // fix for the CMIPN-111: Organize correct z order for controls.
	// I hardcoded the -10 because then higher z position of the layer then higher layer is on screen 
	_route.path.zPosition = -10;
	[routeNodes release];
	
	CLLocationCoordinate2D startPosition =  { [[[dict objectAtIndex:0] objectForKey:@"lat"] floatValue] ,[[[dict objectAtIndex:0] objectForKey:@"lon"] floatValue]};
	CLLocationCoordinate2D endPosition =  { [[[dict lastObject] objectForKey:@"lat"] floatValue] ,[[[dict lastObject] objectForKey:@"lon"] floatValue]};
		
	RMMarkerManager* markerManager = _mapView.markerManager;
	NSArray* markers = [markerManager markers];

    
    BOOL isStartMarkerFound = FALSE;
    BOOL isEndMarkerFound = FALSE;
    
	if([markers count] > 1)
	{
		//NSAssert([markers count]>2,@"This never should happen!!!");
		for(id marker in markers)
		{
			if( [marker isKindOfClass:[RMMarker class]] )
			{
				//if([(NSString*)((RMMarker*)marker).data isEqualToString:@"Start"])
				//	[markerManager moveMarker:marker AtLatLon:startPosition];
				//else
				//	if([(NSString*)((RMMarker*)marker).data isEqualToString:@"End"])
				//		[markerManager moveMarker:marker AtLatLon:endPosition];
				
				if ([[marker data] isKindOfClass:[NSString class]])
				{
					if([(NSString*)((RMMarker*)marker).data isEqualToString:@"Start"])
                    {
						[markerManager moveMarker:marker AtLatLon:startPosition];
                        isStartMarkerFound = TRUE;
                    }
					else
						if([(NSString*)((RMMarker*)marker).data isEqualToString:@"Finish"])
                        {
                            [markerManager moveMarker:marker AtLatLon:endPosition];
                            isEndMarkerFound = TRUE;
                        }
				}
			}
			 
		}
        if (!isStartMarkerFound) [self addStartPointMarker:startPosition];
        if(!isEndMarkerFound) [self addEndPointMarker:endPosition];
            
	}
	else
	{
        [self addStartPointMarker:startPosition];
        [self addEndPointMarker:endPosition];
//         NSLog(@"Total markers count1:%d", [[_mapView.contents.markerManager markers] count]);
//		UIImage *startMarkerImage = [self imageFor:CMRouteStartPoint];//[UIImage imageNamed:@"p_flag_green.png"];
//		RMMarker *newMarker;
//		newMarker = [[RMMarker alloc] initWithUIImage:startMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
//		newMarker.data = @"Start";
//		[_mapView.contents.markerManager addMarker:newMarker AtLatLong:startPosition];
//		[newMarker release];
//        NSLog(@"Total markers count2:%d", [[_mapView.contents.markerManager markers] count]);
//		UIImage *finishMarkerImage = [self imageFor:CMRouteFinishPoint];//[UIImage imageNamed:@"p_flag_finish.png"];
//		newMarker = [[RMMarker alloc] initWithUIImage:finishMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
//		newMarker.data = @"Finish";
//		[_mapView.contents.markerManager addMarker:newMarker AtLatLong:endPosition];
//         NSLog(@"Total markers count3:%d", [[_mapView.contents.markerManager markers] count]);
//		[newMarker release];
	}
	
//	[delegate routeDidFind:_route summary:_routeSammury];
    if (![_threadForCallbackToDelegate isCancelled] && ![_threadForCallbackToDelegate isFinished]) {
        [self performSelector:@selector(sendCallbackRouteDidFindToDelegate) onThread:_threadForCallbackToDelegate withObject:nil waitUntilDone:NO];
    }
	_isActive = FALSE;
	
	//PLog(@"ne={%f,%f} sw={%f,%f}\n",ne.latitude,ne.longitude,sw.latitude,sw.longitude);	
	
	//[mapView zoomWithLatLngBoundsNorthEast:ne SouthWest:sw];
	//[mapView.contents.overlay addSublayer:route];
    //route.lineWidth = 20;
	
	[pool release];
}

#pragma mark Private

-(void) sendCallbackRouteDidFindToDelegate
{
    if ([(id)delegate respondsToSelector:@selector(routeDidFind:summary:)]) {
        [delegate routeDidFind:_route summary:_routeSammury];
    }
}

-(void) addStartPointMarker:(CLLocationCoordinate2D) startPosition
{
    UIImage *startMarkerImage = [self imageFor:CMRouteStartPoint];//[UIImage imageNamed:@"p_flag_green.png"];
    
    RMMarker* newMarker = [[RMMarker alloc] initWithUIImage:startMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
        
    newMarker.data = @"Start";
    [_mapView.contents.markerManager addMarker:newMarker AtLatLong:startPosition];
    [newMarker release];
    
}


-(void) addEndPointMarker:(CLLocationCoordinate2D) endPosition
{
    UIImage *finishMarkerImage = [self imageFor:CMRouteFinishPoint];
    RMMarker* newMarker = [[RMMarker alloc] initWithUIImage:finishMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
    //[finishMarkerImage release];
    newMarker.data = @"Finish";
    [_mapView.contents.markerManager addMarker:newMarker AtLatLong:endPosition];
    [newMarker release];
}

#pragma mark -

-(void) removeRouteFromMap
{
	[_route.path removeFromSuperlayer];	
}

-(void) packArgsAndStartSearch:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to 
			 withTransitPoints:(NSArray*) transitPoints onVehicle:(CMRoutingVehicle) vehicle
{
    _threadForCallbackToDelegate = [NSThread currentThread];
    
	CMRouteArgs* args = [[[CMRouteArgs alloc] init] autorelease];
	args.from = from;
	args.to = to;
	args.vehicle = vehicle;
	args.transitPoints = transitPoints;
	_startRoutePoint = from;
	_endRoutePoint = to;
	_isActive = TRUE;
	if([(id)delegate respondsToSelector:@selector(routeSearchWillStarted)])
		[delegate routeSearchWillStarted];
  	[self performSelectorInBackground:@selector(findRouteFrom:) withObject:args];
}

-(void) image:(UIImage*) image forPoint:(CMRoutePoint) point
{
	if(point == CMRouteStartPoint)
	{
		if(_startRoutePointImage)
			[_startRoutePointImage release];
		_startRoutePointImage = image;
		[_startRoutePointImage retain];
		
	}
	else if(point == CMRouteFinishPoint)
	{
		if(_endRoutePointImage)
			[_endRoutePointImage release];
		_endRoutePointImage = image;
		[_endRoutePointImage retain];		
	}
}

-(void) findRouteFrom:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to onVehicle:(CMRoutingVehicle) vehicle
{
	
	if (_isActive)
		return;
	
	[self packArgsAndStartSearch:from to:to withTransitPoints:nil onVehicle:vehicle];
}

-(void) findRouteFrom:(CLLocationCoordinate2D) from to:(CLLocationCoordinate2D) to withTransitPoints:(NSArray*) transitPoints 
			onVehicle:(CMRoutingVehicle) vehicle
{
	if (_isActive)
		return;	
	[self packArgsAndStartSearch:from to:to withTransitPoints:transitPoints onVehicle:vehicle];
}


-(CMRouteSummary*) routeSummary
{
	return _routeSammury;
}

//-(NSArray*) routeInstructions
//{
//	return _routeInstructions;
//}

-(void) reloadRouteWithVehicle:(CMRoutingVehicle) vehicle
{
	if (_isActive)
		return;
		
	if(fabs(_startRoutePoint.latitude) > 0.00001f && fabs(_startRoutePoint.longitude) > 0.000001f && 
	   fabs(_endRoutePoint.latitude) > 0.00001f && fabs(_endRoutePoint.longitude) > 0.000001f)
	{
		[self packArgsAndStartSearch:_startRoutePoint to:_endRoutePoint  withTransitPoints:nil onVehicle:vehicle];
	}
}

-(void) dealloc
{
    if (_startRoutePointImage) [ _startRoutePointImage release];
    if (_endRoutePointImage) [_endRoutePointImage release];
	[routeData release];;
	[super dealloc];
}

@end
