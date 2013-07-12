//
//  CMGeosearchParams.m
//  CloudMadeApi
//
//  Created by user on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMGeosearchParams.h"
#import <objc/runtime.h>

@implementation CMGeosearchParams

@synthesize objectType;
@synthesize around;
@synthesize bbox;
@synthesize bboxOnly;
@synthesize returnLocation;
@synthesize returnGeometry;
@synthesize distance;
@synthesize skip;
@synthesize returnResults;


 
- (void)myMethod {
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
			//const char *propType = getPropertyType(property);
			NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
			//NSLog(@"%@",propertyName);
			SEL method = NSSelectorFromString(propertyName);
			if ([self respondsToSelector:method])
			{
				id value = [self performSelector:method];
				if (value)
					[_dict setValue:value forKey:propertyName];
			}
        }
    }
    free(properties);
	NSLog(@"%@\n",_dict);
}


@end