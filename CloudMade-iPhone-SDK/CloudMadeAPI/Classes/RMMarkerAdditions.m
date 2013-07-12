//
//  RMMarkerAdditions.m
//  CloudMadeApi
//
//  Created by Dmytro Golub on 3/10/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "RMMarkerAdditions.h"
#import "CMAnnotationView.h"

@implementation RMMarker (AnnotationExtensions)

-(void) addAnnotationViewWithTitle:(NSString*) title
{
	CMAnnotationView* spView = [[CMAnnotationView alloc] initWithFrame:CGRectZero andTitle:title withImage:nil];
	CGRect frame = spView.frame;
	CGPoint px =  CGPointMake(self.bounds.size.width/2,-frame.size.height/2);
	spView.center = px;
	[self setLabel:spView];
	spView.layer.delegate = self;
}

-(void) addAnnotationViewWithTitle:(NSString*) title atPoint:(CGPoint) point 
{
	CMAnnotationView* spView = [[CMAnnotationView alloc] initWithFrame:CGRectZero andTitle:title withImage:nil];
	spView.center = point;
	[self setLabel:spView];
	spView.layer.delegate = self;
}

- (id<CAAction>)actionForLayer:(CALayer*)layer
						forKey:(NSString*)key
{
	CAAnimationGroup *theAnimation = nil;
	if([key isEqualToString:kCAOnOrderIn] || [key isEqualToString:@"onLayout"])
	{
		CABasicAnimation *theAnimationScale = nil;
		
		theAnimationScale=[CABasicAnimation animationWithKeyPath:@"transform"];
		theAnimationScale.duration=0.5;
		
		CATransform3D startTransformation = CATransform3DMakeScale(1.0/2.0,1.0/2.0,1);
		CATransform3D endTransformation = CATransform3DMakeScale(1.5,1.5,1);
		
		
		theAnimationScale.fromValue=[NSValue valueWithCATransform3D:startTransformation];
		theAnimationScale.toValue=[NSValue valueWithCATransform3D:endTransformation];
		
		CABasicAnimation *theAnimationOpacity = nil;
		theAnimationOpacity=[CABasicAnimation animationWithKeyPath:@"opacity"];
		theAnimationOpacity.duration=0.5;
		
		theAnimationOpacity.fromValue=[NSNumber numberWithFloat:0.0];
		theAnimationOpacity.toValue=[NSNumber numberWithFloat:1.0];	
		
		theAnimation = [CAAnimationGroup animation];
		theAnimation.animations = [NSArray arrayWithObjects:theAnimationScale,theAnimationOpacity,nil];
    }
	return theAnimation;
}


@end
