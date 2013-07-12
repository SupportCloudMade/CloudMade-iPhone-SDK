//
//  CMLBABanner.m
//  LBAApp
//
//  Created by Dmytro Golub on 1/5/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "CMLBABanner.h"
#import "NSDataAdditions.h"
#import "LibUtils.h"

@implementation CMLBABanner

@synthesize bannerImage = _bannerImage,validationUrls = _validationUrls,webSiteUrl = _webSiteUrl,behavior = _bannerBehavior;

-(CGSize) obtainSize:(NSDictionary*) propertiesList
{
	float width = [[propertiesList objectForKey:@"width"] floatValue];
	float height = [[propertiesList objectForKey:@"height"] floatValue];
	CGSize imgSize = CGSizeMake(width,height);
	return imgSize;
}



-(id) initWithProperties:(NSDictionary*) propertiesList withBehavior:(CMAdsBehavior) behaviour
{
	self = [super init];
	_imageUrl = [[propertiesList objectForKey:@"imageUrl"] copy];
	_webSiteUrl = [[propertiesList objectForKey:@"websiteUrl"] copy];
	_validationUrls = [[propertiesList objectForKey:@"validationUrls"] copy];
	_userAgent = [[propertiesList objectForKey:@"userAgent"] copy];
	_size = [self obtainSize:propertiesList];
	_bannerBehavior = behaviour;
	PLog(@"%@\n",_imageUrl);
	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 _userAgent,CM_USER_AGENT,nil];
	
	//NSUserDefaults
	
	NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl] headers:headers];

	//NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
	if(imgData == nil)
	{
		@throw [NSException exceptionWithName:@"CMImageNotFound" reason:@"Banner image not found" userInfo:nil];
		
	}
	self.bannerImage = [UIImage imageWithData:imgData];
	return self;
}

-(void) validateURLs
{
	NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
							 CM_REQUEST_HEADER_VALUE,CM_REQUEST_HEADER_NAME,
							 ApplicationNameFromBundle(),CM_REQUEST_APP_NAME,
							 ApplicationVersion(),CM_REQUEST_APP_VERSION,
							 CM_LIB_VERSION_STR,CM_REQUEST_LIB_VERSION,
							 _userAgent,CM_USER_AGENT,nil];
	for (NSString* url in _validationUrls)
	{
		[NSData dataWithContentsOfURL:[NSURL URLWithString:url] headers:headers];
	}
}


-(void) dealloc
{
	[_imageUrl release];	
	[_webSiteUrl release];
	[_validationUrls release];
	[_userAgent release];
	[super dealloc]; 
}

@end