/*
 * Copyright 2009 CloudMade.
 *
 * Licensed under the GNU Lesser General Public License, Version 3.0;
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "Location.h"
#import "Utils.h"
#import "HelperConstant.h"


#define __REVERSED__ORDER__		

@implementation Location

@synthesize strName;
@synthesize  strDesc;
@synthesize  strTag;
@synthesize  strID;
@synthesize strURL;
@synthesize fLatitude;
@synthesize fLongitude;
@synthesize strPhotoName;
@synthesize bStaticPlace;
@synthesize coordinate;
@synthesize houseNumber,road,postcode,city,street,county;


-(void) reset
{
	strName = @"";
    strDesc = @"";
	strTag = @"";
	strID = @"";
	strPhotoName = @"";
	fLatitude = 0.0f;
	fLongitude = 0.0f;
	bStaticPlace = FALSE;
}
+(NSString*) setName:(NSDictionary*) features
{
	NSString* name = [[features objectForKey:@"properties"] objectForKey:@"name"];
	if(![name length])
	{
		name = [[features objectForKey:@"properties"] objectForKey:@"int_name"];
	}
	else
	{
		NSString* alt_name = [[features objectForKey:@"properties"] objectForKey:@"int_name"];
		if([alt_name length]>0)
		{
			name = [NSString stringWithFormat:@"%@ (%@)",name,alt_name];
		}
	}
	return name;
}

+(NSString*) setDescription:(NSDictionary*) features
{
	NSString* tags = nil;
	NSString* city = [[features objectForKey:@"location"] objectForKey:@"city"];
	NSString* postcode = [[features objectForKey:@"location"] objectForKey:@"postcode"];
	if(city)
	{
		if(postcode)
			tags = [NSString stringWithFormat:@"%@, %@",city,postcode];
		else
			tags = [NSString stringWithFormat:@"%@",city];
	}
	else
		if(postcode)
		{
			tags = [NSString stringWithFormat:@"%@",postcode];
		}
	return tags;
}


-(void) locationFeature:(NSDictionary*) features
{
	self.city = [[features objectForKey:@"location"] objectForKey:@"city"];
	self.postcode = [[features objectForKey:@"location"] objectForKey:@"postcode"];
	self.road = [[features objectForKey:@"location"] objectForKey:@"road"];
	self.houseNumber =  [[features objectForKey:@"properties"] objectForKey:@"addr:housenumber"];
	self.county = [[features objectForKey:@"location"] objectForKey:@"county"];
}


+(NSString*) setTags:(NSDictionary*) features
{
	NSString* tags = [[features objectForKey:@"location"] objectForKey:@"country"];
	return tags;
}

+(Location*) initWithFeatures:(NSDictionary*) features
{
	Location* loc = [[Location alloc] init];
	//loc.strName = [[features objectForKey:@"properties"] objectForKey:@"name"];
	//TODO: should be deleted in the next release v.0.2.6
	loc.strName = [Location setName:features];	
	loc.street = [Location setName:features];	
	
	loc.strTag = [Location setTags:features];
	loc.strDesc = [Location setDescription:features];
	loc.strURL  = [NSString stringWithFormat:@"%s%s",IMAGE_URL,DEFAULT_IMAGE_NAME];
    loc.strPhotoName = [NSString stringWithFormat:@"%s%@",PHOTO_URL,DEFAULT_PHOTO_NAME]; 
	loc.bStaticPlace = TRUE;
	
	NSDecimalNumber* objectID = [features objectForKey:@"id"];
	loc.strID = [objectID stringValue]; 
	NSDictionary* centroid = [features objectForKey:@"centroid"];
	if( [[centroid objectForKey:@"type"] isEqualToString:@"POINT"])
	{
		NSArray* coordinates = [centroid objectForKey:@"coordinates"];
#ifndef __REVERSED__ORDER__		
		loc.fLongitude = [[coordinates objectAtIndex:0] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:1] doubleValue];
#else		
		loc.fLongitude = [[coordinates objectAtIndex:1] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:0] doubleValue];
#endif // __REVERSED__ORDER__				
		//loc.coordinate.latitude = [[coordinates objectAtIndex:0] doubleValue];
		//loc.coordinate.longitude = [[coordinates objectAtIndex:1] doubleValue];
		CLLocationCoordinate2D cd = {[[coordinates objectAtIndex:0] doubleValue],[[coordinates objectAtIndex:1] doubleValue]};
		loc.coordinate = cd;
	}
	return [loc autorelease];
}


+(Location*) locationWithFeatures:(NSDictionary*) features
{
	Location* loc = [[[Location alloc] init] autorelease];

	loc.strName = [Location setName:features];	
	loc.strTag = [Location setTags:features];
	loc.strDesc = [Location setDescription:features];
	NSDecimalNumber* objectID = [features objectForKey:@"id"];
	loc.strID = (objectID == nil)?[objectID stringValue]:@""; 
	NSDictionary* centroid = [features objectForKey:@"centroid"];
	if( [[centroid objectForKey:@"type"] isEqualToString:@"POINT"])
	{
		NSArray* coordinates = [centroid objectForKey:@"coordinates"];
#ifndef __REVERSED__ORDER__		
		loc.fLongitude = [[coordinates objectAtIndex:0] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:1] doubleValue];
#else		
		loc.fLongitude = [[coordinates objectAtIndex:1] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:0] doubleValue];
#endif // __REVERSED__ORDER__		
		CLLocationCoordinate2D cd = {[[coordinates objectAtIndex:0] doubleValue],[[coordinates objectAtIndex:1] doubleValue]};
		loc.coordinate = cd;
	}
	[loc locationFeature:features];
	return loc;
}

-(void) dealloc
{
	[super dealloc];
}


@end
