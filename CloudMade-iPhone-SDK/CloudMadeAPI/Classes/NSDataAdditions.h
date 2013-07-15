//
//  NSData+URLCustomHeaders.h
//  CloudMadeApi
//
//  Created by user on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (CustomURLHeaders)
+(id) dataWithContentsOfURL:(NSURL*) url headers:(NSDictionary*) headers; 
@end
