//
//  NSObject+InvokeOnMainThread.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 1/26/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBox;

@interface NSObject (InvokeExtensions)
- (id)cm_invokeOnMainThread;  
@end
