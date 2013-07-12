//
//  CMGeosearchParams.h
//  CloudMadeApi
//
//  Created by user on 12/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef struct {
	CLLocationCoordinate2D northeast;
	CLLocationCoordinate2D southwest;
} BoundingBox;


@interface CMGeosearchParams : NSObject {
	NSString* objectType;
	CLLocationCoordinate2D around;
	BoundingBox bbox;
	BOOL bboxOnly;	
	BOOL returnLocation;
	BOOL returnGeometry;
	NSUInteger distance;
	NSUInteger skip;
	NSUInteger returnResults;
	NSDictionary* _dict;
}

@property (nonatomic, retain) NSString *objectType;
@property (nonatomic, assign) CLLocationCoordinate2D around;
@property (nonatomic, assign) BoundingBox bbox;
@property (nonatomic, assign) BOOL bboxOnly;
@property (nonatomic, assign) BOOL returnLocation;
@property (nonatomic, assign) BOOL returnGeometry;
@property (nonatomic, assign) NSUInteger distance;
@property (nonatomic, assign) NSUInteger skip;
@property (nonatomic, assign) NSUInteger returnResults;
@end