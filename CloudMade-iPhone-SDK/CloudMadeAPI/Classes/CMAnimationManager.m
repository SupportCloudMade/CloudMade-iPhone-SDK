//
//  CMAnimationManager.m
//  CloudMadeApi
//
//  Created by pigeon on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMAnimationManager.h"


//@implementation CMAnimationManager




@implementation CMAnimationManager


+ (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
                               duration:(NSTimeInterval)duration delegate:(id)delegate 
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector
                                   name:(NSString *)name type:(NSString *)type {
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithArray:animations];
	group.delegate = self;
	group.duration = duration;
	group.removedOnCompletion = NO;
	if([type isEqualToString:kFTAnimationTypeOut]) {
		group.fillMode = kCAFillModeBoth;
	}
	group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[group setValue:view forKey:kFTAnimationTargetViewKey];
	[group setValue:delegate forKey:kFTAnimationCallerDelegateKey];
	if(!startSelector) {
		startSelector = @selector(animationDidStart:);
	}
	[group setValue:NSStringFromSelector(startSelector) forKey:kFTAnimationCallerStartSelectorKey];
	if(!stopSelector) {
		stopSelector = @selector(animationDidStop:finished:);
	}
	[group setValue:NSStringFromSelector(stopSelector) forKey:kFTAnimationCallerStopSelectorKey];
	[group setValue:name forKey:kFTAnimationName];
	[group setValue:type forKey:kFTAnimationType];
	return group;
}

+ (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
	CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scale.duration = duration;
	scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
					[NSNumber numberWithFloat:1.2f],
					[NSNumber numberWithFloat:.85f],
					[NSNumber numberWithFloat:1.f],
					nil];
	
	CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeIn.duration = duration * .4f;
	fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
	fadeIn.toValue = [NSNumber numberWithFloat:1.f];
	fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	fadeIn.fillMode = kCAFillModeForwards;
	
	CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeIn, nil] withView:view duration:duration 
											 delegate:delegate startSelector:startSelector stopSelector:stopSelector 
												 name:kFTAnimationPopIn type:kFTAnimationTypeIn];
	group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	return group;
}

+ (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
	CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scale.duration = duration;
	scale.removedOnCompletion = NO;
	scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.f],
					[NSNumber numberWithFloat:1.2f],
					[NSNumber numberWithFloat:.75f],
					nil];
	
	CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeOut.duration = duration * .4f;
	fadeOut.fromValue = [NSNumber numberWithFloat:1.f];
	fadeOut.toValue = [NSNumber numberWithFloat:0.f];
	fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	fadeOut.beginTime = duration * .6f;
	fadeOut.fillMode = kCAFillModeBoth;
	
	return [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeOut, nil] withView:view duration:duration 
						  delegate:delegate startSelector:startSelector stopSelector:stopSelector 
							  name:kFTAnimationPopOut type:kFTAnimationTypeOut];
}



@end
