//
//  CMGeosearchParams.m
//  CloudMadeApi
//
//  Created by user on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMGeosearchRequestParams.h"
#import <objc/runtime.h>

@implementation CMGeosearchRequestParams

//@synthesize objectType;
//@synthesize around;
@synthesize bbox;
@synthesize bboxOnly;
@synthesize returnLocation;
@synthesize returnGeometry;
@synthesize distance;
@synthesize skip;
@synthesize returnResults;


//const CLLocationCoordinate2D CLLocationCoordinate2DZero = {0.0,0.0};
const BoundingBox BoundingBoxZero = {{0.0,0.0},{0.0,0.0}};

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            //return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
			return (const char *)[[NSData dataWithBytes:(attribute) length:strlen(attribute)] bytes];
        }
    }
    return "@";
}

-(id) init
{
	if (self = [super init])
	{
		self.returnResults = 10;
		self.skip = 0;
		self.returnGeometry = FALSE;
		self.returnLocation = FALSE;
		self.distance = 100;
		self.bboxOnly = TRUE;
	}
	return self;
}

- (void)myMethod {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
			const char *propType = getPropertyType(property);
			NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
			//PLog(@"%@ - %s\n",propertyName,propType);
			SEL method = NSSelectorFromString(propertyName);
			if ([self respondsToSelector:method])
			{
				if (propType[1]!='{')
				{
					id value = [self performSelector:method];
					if (value)
						[_dict setValue:value forKey:propertyName];
				}
			}
        }
    }
    free(properties);
	//PLog(@"%@\n",_dict);
}


//NSStringFromGCRect

//NSString *NSStringFromClass(Class aClass);

CLLocationCoordinate2D CLLocationCoordinate2DMake(CLLocationDegrees lat,CLLocationDegrees lng)
{
	CLLocationCoordinate2D coordinate = {lat,lng};
	return coordinate;
}

BoundingBox CMBoundingBoxMake(CLLocationCoordinate2D northeast,CLLocationCoordinate2D southwest)
{
	BoundingBox bb;
	bb.northeast = northeast;
	bb.southwest = southwest;
	return bb;
}

NSString* NSStringFromGeosearchRequestParams(CMGeosearchRequestParams* parameters)
{
	NSString* partialUrl = [NSString stringWithFormat:@"results=%d&skip=%d&return_geometry=%d&return_location=%d&bbox_only=%d",
					 parameters.returnResults,parameters.skip,parameters.returnGeometry,parameters.returnLocation,parameters.bboxOnly];
	
//	if (parameters.objectType)
//	{
//		partialUrl = [NSString stringWithFormat:@"%@&object_type=%@",partialUrl,parameters.objectType];
//	}
	
	//if (self.location.latitude != 0.0f && self.location.longitude != 0.0f)
	
	if (parameters.distance)
	{
		partialUrl = [NSString stringWithFormat:@"%@&distance=%d",partialUrl,parameters.distance];
	}
	else
	{
		partialUrl = [NSString stringWithFormat:@"%@&distance=closest",partialUrl];
	}

	
	if (parameters.bbox.northeast.latitude != 0.0f && parameters.bbox.northeast.longitude != 0.0f && 
		parameters.bbox.southwest.latitude != 0.0f && parameters.bbox.southwest.longitude != 0.0f)
	{
		//southern_latitude,western_longitude,northern_latitude, eastern_longitude
		partialUrl = [NSString stringWithFormat:@"%@&bbox=%f,%f,%f,%f",partialUrl,parameters.bbox.southwest.latitude,
					  parameters.bbox.southwest.longitude,parameters.bbox.northeast.latitude,parameters.bbox.northeast.longitude];
	}
	
//	if (parameters.around.latitude!=0 && parameters.around.longitude!=0)
//	{
//		partialUrl = [NSString stringWithFormat:@"around=%@&%f,%f",partialUrl,parameters.around.latitude,parameters.around.longitude];
//	}
	
	return partialUrl;	
}

@end