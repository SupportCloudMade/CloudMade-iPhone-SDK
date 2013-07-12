//
//  RMMarkerAnimationManager.m
//  SponsoredPOIs
//
//  Created by user on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RMMarkerAnimationManager.h"
#import "RMMarker.h"

@implementation RMMarkerAnimationManager


@synthesize markersAppearForFirstTime = _markersAppearForFirstTime;
@synthesize data;

-(id) init
{
	self = [super init];
	_markersAppearForFirstTime = YES;
	_markerCounter = 0; 
	return self;
}

- (id<CAAction>)actionForLayer:(CALayer*)layer
						forKey:(NSString*)key
{
	CAKeyframeAnimation *animation = nil;
	//NSLog(@"%s,%@\n",__FUNCTION__,key);
	//if ([key isEqualToString:@"hidden"])
	if( _markersAppearForFirstTime && ([key isEqualToString:kCAOnOrderIn] || [key isEqualToString:@"onLayout"]))
	{	
		
		CGPoint px = layer.position;
		//NSLog(@"center %@\n",NSStringFromCGPoint(px));
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path,NULL,px.x,0.0 - (_markerCounter-5));
		
		CGPathAddCurveToPoint(path,NULL,px.x,0.0,
							  px.x,px.y,
							  px.x,px.y);
		
		animation = [CAKeyframeAnimation 
					 animationWithKeyPath:@"position"];
		
		//animation.delegate =  self;
		animation.delegate = ((RMMarker*)(layer));
		
		
		[animation setPath:path];
		[animation setDuration:0.3];
		
		//[animation setAutoreverses:YES];
		
		CFRelease(path);
	}
	
	return animation;
	
}

-(void) setMarkersAppearForFirstTime:(BOOL) firstTime
{
	_markersAppearForFirstTime = firstTime;
	if( firstTime )
		_markerCounter = 0;
}
/*
 - (id < CAAction >)actionForKey:(NSString *)aKey
 {
 NSLog(@"%s,%@\n",__FUNCTION__,aKey);
 return nil;
 }
 */
/*
 - (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
 {
 NSLog(@"%s,%@\n",__FUNCTION__,anim);
 }
 */

@end