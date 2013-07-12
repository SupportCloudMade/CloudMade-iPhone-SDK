//
//  CMBannerView.m
//  LBAApp
//
//  Created by Dmytro Golub on 1/21/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "CMBannerView.h"
#import "CMLBABanner.h"
#import <QuartzCore/QuartzCore.h>
#import "RMMapView.h"
#import "CMLBAManager.h"
#import "LibUtils.h"

#define kFTAnimationName  @"kFTAnimationName"
#define kFTAnimationType  @"kFTAnimationType"
#define kFTAnimationTypeIn  @"kFTAnimationTypeIn"
#define kFTAnimationTypeOut  @"kFTAnimationTypeOut"

#define kFTAnimationSlideOut  @"kFTAnimationNameSlideOut"
#define kFTAnimationSlideIn  @"kFTAnimationNameSlideIn"
#define kFTAnimationBackOut  @"kFTAnimationNameBackOut"
#define kFTAnimationBackIn  @"kFTAnimationNameBackIn"
#define kFTAnimationFadeOut  @"kFTAnimationFadeOut"
#define kFTAnimationFadeIn  @"kFTAnimationFadeIn"
#define kFTAnimationFadeBackgroundOut  @"kFTAnimationFadeBackgroundOut"
#define kFTAnimationFadeBackgroundIn  @"kFTAnimationFadeBackgroundIn"
#define kFTAnimationPopIn  @"kFTAnimationPopIn"
#define kFTAnimationPopOut  @"kFTAnimationPopOut"
#define kFTAnimationFallIn  @"kFTAnimationFallIn"
#define kFTAnimationFallOut  @"kFTAnimationFallOut"
#define kFTAnimationFlyOut  @"kFTAnimationFlyOut"

#define kFTAnimationCallerDelegateKey  @"kFTAnimationCallerDelegateKey"
#define kFTAnimationCallerStartSelectorKey  @"kFTAnimationCallerStartSelectorKey"
#define kFTAnimationCallerStopSelectorKey  @"kFTAnimationCallerStopSelectorKey"
#define kFTAnimationTargetViewKey  @"kFTAnimationTargetViewKey"
#define kFTAnimationIsChainedKey  @"kFTAnimationIsChainedKey"
#define kFTAnimationNextAnimationKey  @"kFTAnimationNextAnimationKey"
#define kFTAnimationPrevAnimationKey  @"kFTAnimationPrevAnimationKey"
#define kFTAnimationWasInteractionEnabledKey  @"kFTAnimationWasInteractionEnabledKey"


@implementation CMBannerView

@synthesize bannerDelegate,adsAlighment=_adsAlighment;

- (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view 
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

- (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
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

- (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
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

-(void) setAdsAlighment:(int) alighment
{
	_adsAlighment = alighment;
	CGRect rc = _parentView.bounds;
	CGRect rcFrame  = _parentView.frame;
	switch( alighment )
	{
		case CMAdsAlighmentTop:
			self.center = CGPointMake(rc.size.width/2,self.frame.size.height/2);
			break;		
		case CMAdsAlighmentBottom:
		{
			//CGRect appRect = [[UIScreen mainScreen] applicationFrame];
			//self.center = CGPointMake(rc.size.width/2,rc.size.height-/*_bannerImage.image.size.height*/self.bounds.size.height/2
			self.frame = CGRectMake(rc.size.width/2 - self.bounds.size.width/2,(rc.size.height-self.bounds.size.height)/* - rcFrame.origin.y*/, 
									self.bounds.size.width, self.bounds.size.height);
					  
			PLog(@"bounds = %@ frame = %@ img bounds = %@ image frame = %@ img center = %@\n",NSStringFromCGRect(_parentView.bounds),
				  NSStringFromCGRect(rcFrame),NSStringFromCGRect(self.bounds),NSStringFromCGRect(self.frame),NSStringFromCGPoint(self.center));
			
            //self.center = [self convertPoint:self.center toView:_parentView];
			
			//PLog(@"frame = %@ center = %@ image = %@\n",NSStringFromCGRect(self.frame),
			//	  NSStringFromCGPoint(self.center),NSStringFromCGSize(_bannerImage.image.size));
		}
			
			break;
		case CMAdsAlighmentCenter:
			self.center = CGPointMake(rc.size.width/2,rc.size.height/2);
			break;
		case CMAdsAlighmentLeft:
			break;
		case CMAdsAlighmentRight:
			break;
	}
	//_bannerImage.center = CGPointMake(160,_banner.bannerImage.size.height/2);
	//button.center = CGPointMake(320 - image.size.width/2 - 2,image.size.height/2 + 2 );
	
}


-(void) closeButtonClicked:(NSTimer*) timer
{
	
	if(timer)
	{
		[timer invalidate];
	}
	else if (bannerBehaviourTimer && [bannerBehaviourTimer isValid])
	{
		[bannerBehaviourTimer invalidate];
	}
	bannerBehaviourTimer = nil;
	CAAnimation *animOut = [self popOutAnimationFor:self duration:.4 delegate:nil 
									  startSelector:nil stopSelector:nil];

	[self.layer addAnimation:animOut forKey:kFTAnimationPopOut];	
	self.alpha = 0.98;
	[self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.7];
	[bannerDelegate bannerWillDisappear:_banner]; 
}

-(void) closeBanner
{
	[self closeButtonClicked:nil];
	//[bannerDelegate closeButtonTapped:_banner];
}

-(void) triggerTimerWithBehavior:(CMAdsBehavior) behaviour
{
	PLog(@"%s\n",__FUNCTION__);
	if(behaviour!=CMAdsStatic)
	{
		NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
		
		switch (behaviour)
		{
			case CMAdsDissapearsIn10:
				bannerBehaviourTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(closeButtonClicked:) userInfo:nil repeats:NO];
				break;
			case CMAdsDissapearsIn30:
				bannerBehaviourTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(closeButtonClicked:) userInfo:nil repeats:NO];
				break;			
			default:
				break;
		}
		[runLoop addTimer:bannerBehaviourTimer forMode:NSDefaultRunLoopMode];
		[runLoop run];
	}
}

-(id) initWithBanner:(CMLBABanner*) banner inView:(RMMapView*) view
{
	self = [super initWithFrame:CGRectMake(0,0,320,banner.bannerImage.size.height)];
	self.userInteractionEnabled = YES;
	UIImage* img = [UIImage imageNamed:_BI(@"BackLine.png")];// @"BackLine.png"
	self.image = img;
	_bannerImage = [[UIImageView alloc] initWithImage:banner.bannerImage];
	_bannerImage.center = CGPointMake(160,banner.bannerImage.size.height/2);
	[self addSubview:_bannerImage];	
	
	//_button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	//[_button addTarget:self action:@selector(closeBanner) forControlEvents:UIControlEventTouchUpInside];	
	//UIImage* image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"CloseButton.png"]];
	//UIImage* image =  [UIImage imageNamed:_BI(@"CloseButton.png")];
	//[_button setBackgroundImage:image forState:UIControlStateNormal];
	//_button.frame = CGRectMake(0,0,image.size.width,image.size.height);
	//_button.center = CGPointMake(320 - image.size.width/2 - 2,image.size.height/2 + 2 );
	//[self addSubview:_button];
	
	CAAnimation *animIn = [self popInAnimationFor:self duration:.4 delegate:nil 
																startSelector:nil stopSelector:nil];
	
	[self.layer addAnimation:animIn forKey:kFTAnimationPopIn];
	_parentView = view;
	_banner = banner;
	 return self;
}


- (void)didMoveToSuperview
{
	if([self superview] && self.bannerDelegate)
	{
		[bannerDelegate bannerDidAppear:_banner];
		[self triggerTimerWithBehavior:_banner.behavior];
	}
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(bannerDelegate)
		[bannerDelegate bannerDidTap:_banner];
	[self closeBanner];
}


- (void)dealloc {
    [super dealloc];
}


@end
