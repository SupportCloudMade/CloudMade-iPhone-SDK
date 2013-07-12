//
//  NSObject+InvokeOnMainThread.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 1/26/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "NSObjectAdditions.h"
#import "CMInvocationGrabber.h"

@implementation NSObject (InvokeExtensions)

- (id)dd_invokeOnMainThreadAndWaitUntilDone:(BOOL)waitUntilDone;
{
	CMInvocationGrabber * grabber = [CMInvocationGrabber invocationGrabber];
	[grabber setForwardInvokesOnMainThread:YES];
	[grabber setWaitUntilDone:waitUntilDone];
	return [grabber prepareWithInvocationTarget:self];
}


- (id)cm_invokeOnMainThread
{
	return [self dd_invokeOnMainThreadAndWaitUntilDone:YES];
}


-(id) performOnMainThreadSelector:(SEL) selector withObject:(id) object inBBox:(BBox*) bbox
{
	return [self dd_invokeOnMainThreadAndWaitUntilDone:YES];
}


@end
