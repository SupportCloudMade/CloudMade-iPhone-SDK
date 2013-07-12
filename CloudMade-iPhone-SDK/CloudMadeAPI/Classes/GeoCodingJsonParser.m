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

#import "GeoCodingJsonParser.h"
#import "JSON.h"
#import "Location.h"

@implementation GeoCodingJsonParser



-(NSArray*) fillLocationsArray:(NSString*) jsonObjects
{
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	CM_SBJsonParser *parser = [CM_SBJsonParser new];
	id result = [parser objectWithString:jsonObjects]; //[jsonObjects JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSArray* features = [res objectForKey:@"features"];
		PLog(@"%@\n",features);
		for( NSDictionary* features_dict in features )
		{
			Location* loc = [Location locationWithFeatures:features_dict];
			[resultArray addObject:loc]; 
		}
	}
	[parser release];
	return [resultArray autorelease];
}


-(NSArray*) getObjects:(NSString*) jsonObjects
{
	NSMutableArray* resultArray = [[NSMutableArray alloc] init];
	CM_SBJsonParser *parser = [CM_SBJsonParser new];
	id result = [parser objectWithString:jsonObjects]; //[jsonObjects JSONValue];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSArray* features = [res objectForKey:@"features"];
		for( NSDictionary* features_dict in features )
		{
			Location* loc = [[Location initWithFeatures:features_dict] autorelease];
			[resultArray addObject:loc]; 
		}
	}
	[parser release];
	return [resultArray autorelease];
}

-(BBox*) boundBox:(NSString*) json
{
	//id result = [json JSONValue];
	CM_SBJsonParser *parser = [[CM_SBJsonParser new] autorelease];
	id result = [parser objectWithString:json]; //[jsonObjects JSONValue];
	//[result release];
	if(result)
	{
		NSDictionary *res = (NSDictionary*)result;	
		NSArray* bounds = [res objectForKey:@"bounds"];
		BBox* bbox = nil;
		if(bounds)
			bbox = [[[BBox alloc] init] autorelease];
		int nCounter = 0;
		for( NSArray* bound in bounds)
		{
			if(!nCounter)
			{
				bbox.southernLatitude = (float)[[bound objectAtIndex:0] doubleValue];
				bbox.westernLongitude = (float)[[bound objectAtIndex:1] doubleValue];
			}
			else
			{
				bbox.northernLatitude = (float)[[bound objectAtIndex:0] doubleValue];
				bbox.easternLongitude = (float)[[bound objectAtIndex:1] doubleValue];
			}
			++nCounter;
		}
		return bbox;
	}

	return nil;	
}

@end
