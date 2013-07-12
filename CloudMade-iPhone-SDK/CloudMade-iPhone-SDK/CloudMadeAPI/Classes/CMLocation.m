//
//  CMLocation.m
//  LBA
//
//  Created by user on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMLocation.h"


@implementation CMLocation
@synthesize coordinate;
@synthesize geometry;

-(id) initWithProperties:(NSDictionary*) properties
{
	if (self = [super init])
	{
		//self.geometry = 
		//NSArray* propArray = [properties objectAtIndex:1];
		NSDictionary* coord = [properties objectForKey:@"centroid"];//[[propArray objectForKey:@"centroid"] objectForKey:@"lat"];
		CLLocationCoordinate2D  locationCoordinate = {[[[coord objectForKey:@"lat"] objectForKey:@"lat"] floatValue],[[[coord objectForKey:@"lat"] objectForKey:@"lon"] floatValue]};
		NSDictionary* objectProperties = [properties objectForKey:@"properties"];
		NSMutableDictionary* dict = nil;
		if (objectProperties)
		{
			dict = [[NSMutableDictionary alloc] init];
			NSString* name = [objectProperties objectForKey:@"name:en"];
			if (name)
				[dict setObject:name forKey:@"name"];
			else
				[dict setObject:[objectProperties objectForKey:@"synthesized_name"] forKey:@"name"];

		}
		
		NSDictionary* locationProperties = [properties objectForKey:@"location"];
		if (locationProperties)
		{
			if (!dict)
				dict = [[NSMutableDictionary alloc] init];
			
			NSString* city = [locationProperties objectForKey:@"city"];
			if (city)
				[dict setObject:city forKey:@"city"];
			NSString* country = [locationProperties objectForKey:@"country"];
			if (country)
				[dict setObject:country forKey:@"country"];
			NSString* county = [locationProperties objectForKey:@"county"];
			if (county)
				[dict setObject:county forKey:@"county"];
			NSString* street = [locationProperties objectForKey:@"street"];
			if (street)
				[dict setObject:street forKey:@"street"];
	
			NSString* house = [locationProperties objectForKey:@"house"];
			if (house)
				[dict setObject:house forKey:@"house"];
			
			
		}		
		
		NSDictionary* geometryProperties = [properties objectForKey:@"geometry"];	
		if (geometryProperties)
		{
			NSMutableArray* geom = [[NSMutableArray alloc] init];
			CLLocationCoordinate2D coord;
			for (NSDictionary* coordDict in [[properties objectForKey:@"geometry"] objectForKey:@"coordinates"] )
			{
				coord.latitude = [[coordDict objectForKey:@"lat"] doubleValue];
				coord.longitude = [[coordDict objectForKey:@"lon"] doubleValue];
				NSValue *nodeCoord = [NSValue value:&coord withObjCType:@encode(CLLocationCoordinate2D)]; 
				[geom addObject:nodeCoord];			    
			}
			self.geometry = geom;
			[geom release];
		}
        

		
		addressDictionary = dict;
		self.coordinate = locationCoordinate;
		
	}
	return self;
}

+(id) locationWithProperties:(NSDictionary*) properties
{
	return [[[CMLocation alloc] initWithProperties:properties] autorelease];
}

-(NSString*) name
{
    return [addressDictionary objectForKey:@"name"];
}

-(NSString*) city
{
	return [addressDictionary objectForKey:@"city"];
}

-(NSString*) country
{
	return [addressDictionary objectForKey:@"country"];	
}
-(NSString*) county
{
	return [addressDictionary objectForKey:@"county"];		
}
-(NSString*) street
{
	return [addressDictionary objectForKey:@"street"];		
}

-(NSString*) house
{
	return [addressDictionary objectForKey:@"house"];		
}


-(void) dealloc
{
	[addressDictionary release];
	[super dealloc];
}

@end