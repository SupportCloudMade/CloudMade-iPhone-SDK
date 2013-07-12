
#import <UIKit/UIKit.h>
#import "RunLoopSource.h"
#import "CMSynchronousGeocodingRequest.h"
#import "GeoCodingJsonParser.h"
#import "Location.h"

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)

{
  RunLoopSource* obj = (RunLoopSource*)info;
  RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
  [obj performSelector:@selector(registerSource:) withObject:theContext];
}


void RunLoopSourcePerformRoutine (void *info)

{
 RunLoopSource* obj = (RunLoopSource*)info;
 [obj sourceFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)

{
 RunLoopSource* obj = (RunLoopSource*)info;
 RunLoopContext* theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
 [obj performSelectorOnMainThread:@selector(removeSource:) withObject:theContext waitUntilDone:YES];
}


@implementation RunLoopSource

@synthesize commands;
@synthesize tokenManager,owner;

-(id)initWithDelegate:(id) delegate

{
    CFRunLoopSourceContext    context = {0, self, NULL, NULL, NULL, NULL, NULL,
                                        &RunLoopSourceScheduleRoutine,
                                        RunLoopSourceCancelRoutine,
                                        RunLoopSourcePerformRoutine};

    runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    //commands = [[NSMutableArray alloc] init];
	_delegate = delegate;
    return self;
}


- (void) addToRunLoop:(NSRunLoop*) rLoop
{
    CFRunLoopRef runLoop = [rLoop getCFRunLoop];
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
}


- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop

{
  CFRunLoopSourceSignal(runLoopSource);
  CFRunLoopWakeUp(runloop);
}


-(void) sourceFired
{
	
	//+(id) createWithNumberOfResults:(int) number skipResults:(int) skipnumber withBBox:(BOOL) bbox returnGeometry:(BOOL) geometry returnLocationInfo:(BOOL) locationInfo;
	CMGeosearchOptionalParamaters* pearameters = [CMGeosearchOptionalParamaters createWithNumberOfResults:10 
																							   skipResults:0
																								 withBBox:FALSE 
																						   returnGeometry:FALSE 
																					   returnLocationInfo:FALSE];
	CMSynchronousGeocodingRequest* geocoder = [[CMSynchronousGeocodingRequest alloc] initWithApikey:tokenManager.accessKey
																						withOptions:pearameters tokenManager:tokenManager];
	
	
	NSString* res;
	if([commands count] == 3)
	{
		NSString* searchString = [NSString stringWithFormat:@"%@,%@,%@",
								  [commands objectForKey:SP_STREET_NAME],
								  [commands objectForKey:SP_CITY_NAME],
								  [commands objectForKey:SP_COUNTRY_NAME]
								  ]; 
		res = [geocoder synchronousFindObjects:searchString :nil];
		//[self collectSearchResult:res];
	}
	
	if([commands count] == 2)
	{
		res = [geocoder synchronousFindCityWithName:[commands objectForKey:SP_CITY_NAME] 
													inCountry:[commands objectForKey:SP_COUNTRY_NAME]];
		//[self collectSearchResult:res];
	}		
	
	if([commands count] == 1)
	{
		res = [geocoder synchronousFindObjects:[commands 
												objectForKey:SP_UNDETERMINATE] 
											  :nil];
	}		
	
	
	GeoCodingJsonParser* jsonParser = [[GeoCodingJsonParser alloc] init];
	NSArray* objects = [jsonParser getObjects:res];		
	BBox* bb = [jsonParser boundBox:res];
	NSMutableDictionary *searchResults = [[NSMutableDictionary alloc] init];
	for(Location* location in objects)
	{
		[searchResults setObject:location forKey:location.strID];
	}
	//PLog(@"%@\n",searchResults);
	
	[_delegate searchIsFinished:[searchResults allValues] inBounds:bb];

}

- (void)registerSource:(RunLoopContext*)sourceInfo;
{
}

@end


@implementation RunLoopContext

@synthesize runLoop;
@synthesize source;

- (id)initWithSource:(RunLoopSource*)src andLoop:(CFRunLoopRef)loop
{
	self = [super init];
	runLoop = loop;
	source = src;
	return self;
}

@end