/*
 *  LibUtils.h
 *  SponsoredPOIs
 *
 *  Created by Dmytro Golub on 10/16/09.
 *  Copyright 2009 CloudMade. All rights reserved.
 *
 */

#import "RMLatLong.h"



#define _BI(NAME) PathForBundleResource(NAME)
#define PRINTBBOX(BBox,MSG) printBBox(BBox,MSG)

#define CM_REQUEST_HEADER_NAME  @"X-ServiceSource"
#define CM_REQUEST_HEADER_VALUE @"CloudMadeIphoneLib"

#define CM_REQUEST_APP_NAME  @"X-ApplicationName"
#define CM_REQUEST_APP_VERSION  @"X-ApplicationVersion"

//  CM_LIB_VERSION % 100 is the patch level
//  CM_LIB_VERSION / 100 % 1000 is the minor version
//  CM_LIB_VERSION / 100000 is the major version

#define CM_LIB_VERSION 026000

//
//  CM_LIB_VERSION_STR must be defined to be the same as CM_LIB_VERSION
//  but as a *string* in the form "x_y[_z]" where x is the major version
//  number, y is the minor version number, and z is the patch level if not 0.

#define CM_REQUEST_LIB_VERSION  @"X-LibVersion"
#define CM_LIB_VERSION_STR      @"0.2.7"
#define CM_USER_AGENT           @"User-Agent"






NSString* PathForBundleResource(NSString* relativePath);
void printBBox(RMSphericalTrapezium,NSString*);
NSString* ApplicationVersion();
NSString* ApplicationNameFromBundle();

