//
//  CMSearchParameters.m
//  LBA
//
//  Created by user on 12/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMSearchParameters.h"


@implementation CMSearchParameters
@synthesize city;
@synthesize country;
@synthesize county;
@synthesize postcode;
@synthesize street;
@synthesize house;

NSString* NSStringFromCMSearchParameters(CMSearchParameters* parameters)
{
	if (parameters == nil)
	{
		return @"";
	}
	NSString* url = [NSString stringWithFormat:@""];
	if (parameters.city)
	{
		url = [NSString stringWithFormat:@"%@city:%@;",url,parameters.city];
	}
	
	if (parameters.county)
	{
		url = [NSString stringWithFormat:@"%@county:%@;",url,parameters.county];
	}
	
	if (parameters.country)
	{
		url = [NSString stringWithFormat:@"%@country:%@;",url,parameters.country];
	}
	
	if (parameters.postcode)
	{
		url = [NSString stringWithFormat:@"%@postcode:%@;",url,parameters.postcode];
	}
	if (parameters.street)
	{
		url = [NSString stringWithFormat:@"%@street:%@;",url,parameters.street];
	}	
	if (parameters.house)
	{
		url = [NSString stringWithFormat:@"%@house:%@;",url,parameters.house];
	}	
	
	return url;
}

@end

