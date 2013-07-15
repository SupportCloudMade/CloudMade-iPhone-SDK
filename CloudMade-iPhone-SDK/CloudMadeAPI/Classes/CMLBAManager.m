//
//  CMLBAManager.m
//  LBAApp
//
//  Created by Dmytro Golub on 1/5/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "CMLBAManager.h"
#import "TokenManager.h"
#import "CMLBABanner.h"
#import "CMBannerView.h"
#import "BrowserViewController.h"
#import "NSObjectAdditions.h"
#import "NSArrayAdditions.h"
#import "LibUtils.h"
#import "NSDataAdditions.h"
#import "CMWebKitUserAgent.h"

//TODO: disable test mode
//#define __TEST_MODE__
#define LBAURL @"http://lba.cloudmade.com"

//#ifdef DEBUG 
//	#define LBAURL @"http://10.1.0.159"
//#else
//    #error : Local Server is included in release mode 
//#endif


const CLLocationCoordinate2D CLLocationCoordinate2DZero = {0.0};

@interface AdsParameters : NSObject
{
	CMAdType _type;
    RMSphericalTrapezium _bbox;
    NSUInteger _size;	
	CGSize _cgSize;
}

@property (readwrite) CMAdType type;
@property (readwrite) RMSphericalTrapezium bbox;
@property (readwrite) NSUInteger size;	
@property (readwrite) CGSize cgSize;

-(id) initWithSizes:(NSUInteger) sizes inBBox:(RMSphericalTrapezium) bbox;
-(id) initWithSize:(CGSize) size inBBox:(RMSphericalTrapezium) bbox;


@end


@implementation AdsParameters


@synthesize type = _type,bbox=_bbox,size = _size,cgSize = _cgSize;

-(id) initWithSizes:(NSUInteger) sizes inBBox:(RMSphericalTrapezium) bbox
{
	self = [super init];
	_size = sizes;
	_bbox = bbox;
	return self;
}

-(id) initWithSize:(CGSize) size inBBox:(RMSphericalTrapezium) bbox
{
	self = [super init];
	_cgSize = size;
	_size = -1;
	_bbox = bbox;
	return self;
}


+(id) adParametersWithSizes:(NSUInteger) sizes inBBox:(RMSphericalTrapezium) bbox
{
	return [[[AdsParameters alloc] initWithSizes:sizes inBBox:bbox] autorelease];
}


+(id) adParametersWith:(CGSize) size inBBox:(RMSphericalTrapezium) bbox
{
	return [[[AdsParameters alloc] initWithSize:size inBBox:bbox] autorelease];
}

@end


@interface CMLBAManager (ExtendedDelegate) <UIWebViewDelegate>
@end

@implementation CMLBAManager

@synthesize mapViewController = _mapViewController, alighment = _adsAlighment , behavior = _adsBehavior;
@synthesize keywords = _keywords,delegate,testingMode=_testingMode,location = _location,query=_query;

-(CMAdsAlighment) checkBannerAlighmentForSize:(CMAdsSize) size
{
	if(self.alighment == CMAdsAlighmentDefault)
	{
		switch(size)
		{
			case ADSize_125x125: /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentTop;
				break;
			case ADSize_300x250: /* default alighment CMAdsAlighmentCenter */
				return CMAdsAlighmentTop;
				break;
			case ADSize_300x50:  /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentTop;
				break;
			case ADSize_300x75:   /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentTop;
				break;
			case ADSize_216x36:   /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentBottom;
			case ADSize_216x54:   /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentBottom;				
			case ADSize_168x28:   /* default alighment CMAdsAlighmentTop */
				return CMAdsAlighmentBottom;				
				
			default:
				return CMAdsAlighmentBottom;
		}
	}
	
	return self.alighment;
}

-(id) init
{
	NSAssert(nil,@"\n-(id) initWithTokenManager:(TokenManager*) tokenManager inView:(RMMapView*)\n has to be used to init the class");
	return nil;
}

-(void) initUserAgent
{
	CMWebKitUserAgent* webKitUserAgent = [[CMWebKitUserAgent alloc] init];
	NSString* userAgent = [webKitUserAgent userAgentString];
	_userAgent = [[NSString alloc] initWithString:userAgent];
	[webKitUserAgent release];
}


-(id) initWithTokenManager:(TokenManager*) tokenManager inView:(RMMapView*) mapView
{
	NSAssert(mapView,@"mapView musn't be nil!!!");
	NSAssert(tokenManager,@"tokenManager musn't be nil!!!");	
	self = [super init];
	_tokenManager = tokenManager;
	_mapView = mapView;	
	[self initUserAgent];
	NSArray* keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:ADSize_125x125],
					 [NSNumber numberWithInt:ADSize_300x250],
					 [NSNumber numberWithInt:ADSize_300x50],[NSNumber numberWithInt:ADSize_300x75],
					 [NSNumber numberWithInt:ADSize_216x36],[NSNumber numberWithInt:ADSize_216x54],
					 [NSNumber numberWithInt:ADSize_168x28],[NSNumber numberWithInt:ADSize_320x50],
					 [NSNumber numberWithInt:ADSize_120x20],nil]; 
	
	
	NSArray* objects = [NSArray arrayWithObjects:@"125x125",@"300x250",@"300x50"
						,@"300x75",@"216x36",@"216x54",@"168x28",@"320x50",@"120x20",nil]; 

	
	_adSize = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	self.alighment = CMAdsAlighmentDefault;
	self.behavior = CMAdsDissapearsIn30;
	_disabledForCurrentSession = NO;
	self.location = CLLocationCoordinate2DZero;
	return self;
}

-(void) dealloc
{
	[_adSize release];
	[super dealloc];
}

-(NSString*) sizeForAds:(NSUInteger) size
{
	int i=1;

	NSMutableString* adSizeStr = [[NSMutableString alloc] initWithString:@""];
	for (;i<=ADSize_MaxValue;i<<=1)
	{
		if (size & i)
		{
			if ([adSizeStr length] > 1)
			{
				[adSizeStr appendString:@","];
			}
			[adSizeStr appendString:[_adSize objectForKey:[NSNumber numberWithInt:i]]];
		}
		
	}
	return [adSizeStr autorelease];
}

-(NSString*) boundsForAds:(CGSize) size
{
	//NSMutableString* adSizeStr = [[NSMutableString alloc] initWithString:@""];
	//return [adSizeStr autorelease];
	
	NSString* bounds = [NSString stringWithFormat:@"0..%dx0..%d",(int)size.width,(int)size.height];
	return bounds;
}


-(NSString*) _appendUrlWithExtraParameters:(NSString*) partialUrl
{
	
	NSMutableString* url = [[NSMutableString alloc] initWithString:partialUrl];
	if( [self.keywords length] > 0  )
		[url appendFormat:@"&keyword=%@",self.keywords];
	
	if (self.testingMode)
		[url appendString:@"&mode=test"];
	
	if (self.location.latitude != 0.0f && self.location.longitude != 0.0f)
	{
		[url appendFormat:@"&location=%f,%f",self.location.latitude,self.location.longitude];
	}
	
	if (self.query)
	{
		[url appendFormat:@"&query=%@",self.query];
	}
	
    PLog(@"url=%@\n",url);	
	return [url autorelease];
}

-(NSString*) urlForAdWithBBox:(RMSphericalTrapezium) bbox withSizes:(NSUInteger) sizes
{

	NSString* partialUrl;
	
	{
		partialUrl = [NSString stringWithFormat:@"%@/%@/api/v2/%f,%f,%f,%f/%d.iphone?size=%@&token=%@"
			   ,LBAURL,_tokenManager.accessKey,bbox.northeast.latitude,
			   bbox.northeast.longitude,bbox.southwest.latitude,bbox.southwest.longitude,16,
			   [self sizeForAds:sizes],_tokenManager.accessToken];
	}

	return [self _appendUrlWithExtraParameters:partialUrl];
}

-(NSString*) urlForAdWithBBox:(RMSphericalTrapezium) bbox withSize:(CGSize) size
{
	
	NSString* partialUrl;
	partialUrl = [NSString stringWithFormat:@"%@/%@/api/v2/%f,%f,%f,%f/%d.iphone?size=%@&token=%@"
					  ,LBAURL,_tokenManager.accessKey,bbox.northeast.latitude,
					  bbox.northeast.longitude,bbox.southwest.latitude,bbox.southwest.longitude,16,
					  [self boundsForAds:size],_tokenManager.accessToken];
	return [self _appendUrlWithExtraParameters:partialUrl];
}

#pragma mark -
#pragma mark main thread function 

-(void) adWithType:(AdsParameters*) arg 
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString* url;
	
	if (arg.size != -1)
	{
		url = [self urlForAdWithBBox:arg.bbox withSizes:arg.size];
	}
	else
	{
		url = [self urlForAdWithBBox:arg.bbox withSize:arg.cgSize];
	}

	
	if([(id)delegate respondsToSelector:@selector(bannerWillBeRequested)])
		[delegate bannerWillBeRequested];
	
	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 _userAgent,CM_USER_AGENT,nil];
	PLog(@"%@",headers);
	NSArray* dict = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:url] headers:headers];

	PLog(@"%@",dict);
	
	if([dict count] <= 0 )
	{
		if([(id)delegate respondsToSelector:@selector(bannerDidFailToLoad)])
			[delegate bannerDidFailToLoad];	
		return;
	}
	
	if(_bannerView)
	{
		[_bannerView closeButtonClicked:nil];
		[_bannerView performSelector:@selector(release) withObject:nil afterDelay:1];
	}
	
	CMLBABanner* banner;
	@try
	{
		NSDictionary* bannerProperties = [dict objectAtIndex:0];
		NSMutableDictionary* extendedDict = [NSMutableDictionary dictionaryWithDictionary:bannerProperties];
		[extendedDict setObject:_userAgent forKey:@"userAgent"];
		banner = [[CMLBABanner alloc] initWithProperties:extendedDict withBehavior:self.behavior];
		if (_bannerView)
		{
			[_bannerView release];
		}
		
		_bannerView = [[CMBannerView alloc] initWithBanner:banner inView:_mapView]; 
		_bannerView.bannerDelegate = self;
	
		_bannerView.adsAlighment = [self checkBannerAlighmentForSize:arg.size];
	
		if([(id)delegate respondsToSelector:@selector(bannerWillAppear)])
			[delegate bannerWillAppear];	

		PLog(@"\nimg bounds = %@ image frame = %@ img center = %@\n",
			  NSStringFromCGRect(_bannerView.bounds),NSStringFromCGRect(_bannerView.frame),NSStringFromCGPoint(_bannerView.center));
		
		[_mapView addSubview:_bannerView];
		[banner release];
	}
	@catch (NSException* exception)
	{
		PLog(@"exception was raisen %@\n",[exception reason]);
	}
	[pool release];
}


-(void) adForBBox:(RMSphericalTrapezium) bbox withSizes:(NSUInteger) sizes;
{
	if(_disabledForCurrentSession)
		return;
	AdsParameters* arg = [AdsParameters adParametersWithSizes:sizes inBBox:bbox];
	[self performSelectorInBackground:@selector(adWithType:) withObject:arg];	
}

-(void) adWithType:(CMAdType) type forBBox:(RMSphericalTrapezium) bbox withSize:(CMAdsSize) size
{
	if(_disabledForCurrentSession)
		return;
	AdsParameters* arg = [AdsParameters adParametersWithSizes:size inBBox:bbox];
	[self performSelectorInBackground:@selector(adWithType:) withObject:arg];
}


-(void) adForBBox:(RMSphericalTrapezium)bbox  boundBySize:(CGSize) size
{
	if(_disabledForCurrentSession)
		return;
	AdsParameters* arg = [AdsParameters adParametersWith:size inBBox:bbox];
	[self performSelectorInBackground:@selector(adWithType:) withObject:arg];
}

 
-(void) bannerDidTap:(CMLBABanner*) banner
{
	if([(id)delegate respondsToSelector:@selector(bannerDidTap)])
		[delegate bannerDidTap];	
	BrowserViewController* browser = [[BrowserViewController alloc] initWithUrl:[banner webSiteUrl]];
	if ([(id)delegate respondsToSelector:@selector(titleForAdBrowser)])
	{
		browser.title = [delegate titleForAdBrowser];
	}
	
	if(_mapViewController)
	  [_mapViewController.navigationController pushViewController:browser animated:YES];
	PLog(@"website url = %@\n",[banner webSiteUrl]);
	[browser release];
}	

-(void) bannerDidAppear:(CMLBABanner*) banner
{
	[banner validateURLs];
	if([(id)delegate respondsToSelector:@selector(bannerDidAppear)])
		[delegate bannerDidAppear];
}

-(void) bannerWillDisappear:(CMLBABanner*) banner
{
	if([(id)delegate respondsToSelector:@selector(bannerWillDisappear)])
		[delegate bannerWillDisappear];
}

-(void) closeButtonTapped:(CMLBABanner*) banner
{
	_disabledForCurrentSession = YES;
}




@end