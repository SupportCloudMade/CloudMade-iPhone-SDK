//
//  CMMarkerWithControlLayer.m
//  SponsoredPOIs
//
//  Created by user on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CMMarkerWithControlLayer.h"
#import "deMKAnnotationView.h"
#import "RMMapView.h"


@interface CMMarkerWithControlLayer (ExtendedDelegate) <CMAnnotationViewDelegate>
@end


@implementation CMMarkerWithControlLayer

@synthesize controlLayers,annotationDelegate;

- (id)init
{
    if (self = [super init]) {
		controlLayers = nil;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_discloseButtondidTapped:) name:RMMarkerDisclosureButtonDidTap object:nil];
    }
    return self;
}


-(void) _discloseButtondidTapped:(NSNotification*) notification
{
	CMMarkerWithControlLayer* marker = nil;
	CALayer* layer = nil;
	
	NSSet* args = (NSSet*)notification.object;
	for (id obj in args)
	{
		if ([obj isKindOfClass:[CMMarkerWithControlLayer class]])
		{
			marker = (CMMarkerWithControlLayer*)obj;
		}
		else 
		{
			layer = (CALayer*)obj;
		}
	}
	if (marker != self)
	{
		return;
	}
    //NSLog(@"tapOnLabelForMarker..."); 
	
	NSAssert(marker,@"marker can't be nil");
	NSAssert(layer,@"controlLayer can't be nil");
	
	//[controlLayer sendActionsForControlEvents:UIControlEventTouchDown];
	
	for (UIView *controlLayer in [marker controlLayers]) { 
		if (controlLayer.layer == layer)
		{ 
			[(UIControl*)controlLayer sendActionsForControlEvents:UIControlEventTouchDown];
		}
	}
//	}	
}

/*
- (id) initWithUIImage: (UIImage*) image anchorPoint: (CGPoint) _anchorPoint
{
	if (![self initWithUIImage:image anchorPoint:_anchorPoint])
		return nil;
	return self;
}
*/

- (void) setLabel:(UIView*)aView
{
	if (label == aView) {
		return;
	}
	
	if (label != nil)
	{
		[[label layer] removeFromSuperlayer];
		[label release];
		label = nil;
	}
    // fix for UIControl layers	
	NSArray* subviews = [aView subviews];
	for (UIView *subView in subviews) { 
		if ([subView isKindOfClass:[UIControl class]]) { 
			if (!controlLayers) { 
				controlLayers = [NSMutableArray new]; 
			} 
			[controlLayers addObject:subView]; 
			//NSLog(@"%@\n",subView.layer);
		} 
	} 	
	
	if (aView != nil)
	{
		label = [aView retain];
		[self addSublayer:[label layer]];
	}
}

- (void) dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self  name:RMMarkerDisclosureButtonDidTap object:nil];
	[controlLayers release];
	[super dealloc];
}

-(void) calculateGeometryForAnnotation:(deCartaAnnotationView*) annotationView view:(RMMapView*) mapView
{
	CGRect screenBounds = mapView.contents.screenBounds;
	CGRect pinBounds = self.frame;
	CGPoint px;
	CGRect rc = annotationView.frame;
	CGRect annView = CGRectMake(pinBounds.origin.x - rc.size.width/2, pinBounds.origin.y - 55/2, rc.size.width,55);	
	
	//NSLog(@"ann rect %@  mapBounds %@ pin frame %@\n",NSStringFromCGRect(annView),NSStringFromCGRect(screenBounds),
	//	  NSStringFromCGRect(pinBounds));
	
	
	if (CGRectContainsRect(screenBounds,annView))
	{
		px =  CGPointMake(self.bounds.size.width/2,-self.frame.size.height/2);
	}
    else
    {
		//check if left border is crossed
		if (annView.origin.x < screenBounds.origin.x)
		{
			px = CGPointMake(fabs(annView.origin.x) + 3,-self.frame.size.height/2);
			float delta = fabs(annView.origin.x);
			CGRect annRect = annotationView.frame;
			int mx = ((int)(annRect.size.width/2-delta+pinBounds.size.width/4)<3)?5:((int)(annRect.size.width/2-delta+pinBounds.size.width/4));
			[annotationView moveTriangleToPoint:CGPointMake(mx,0)];
		}
		else if ((annView.origin.x + annView.size.width) > (screenBounds.origin.x + screenBounds.size.width) ) // right border is crossed
		{
			//NSLog(@"right border crossed");
			float delta = (annView.origin.x + annView.size.width) - (screenBounds.origin.x + screenBounds.size.width);
			px = CGPointMake(-(delta),-self.frame.size.height/2);
			CGRect annRect = annotationView.frame;
			[annotationView moveTriangleToPoint:CGPointMake(annRect.size.width/2+delta+pinBounds.size.width/4,0)];
		}
	}
	annotationView.center = px;
}

-(void) addAnnotationViewWithPicture:(UIImage*) picture title:(NSString *)title subtitle:(NSString*) subtitle inMapView:(RMMapView*) mapView
{
	CGRect rc = [deCartaAnnotationView frameForTitle:title subtitle:subtitle picture:picture];
	deCartaAnnotationView* annotationView = [[deCartaAnnotationView alloc] initWithFrame:rc title:title subtitle:subtitle picture:picture];
	annotationView.delegate = self;	
	[self calculateGeometryForAnnotation:annotationView view:mapView];
	self.label = annotationView;
}

-(void) addAnnotationViewWithTitle:(NSString *)title subtitle:(NSString*) subtitle inMapView:(RMMapView*) mapView
{
	CGRect rc = [deCartaAnnotationView frameForTitle:title subtitle:subtitle picture:nil];
	deCartaAnnotationView* annotationView = [[deCartaAnnotationView alloc] initWithFrame:rc title:title subtitle:subtitle picture:nil];
	annotationView.delegate = self;
	[self calculateGeometryForAnnotation:annotationView view:mapView];
	self.label = annotationView;
}

#pragma mark -
#pragma mark CMMarkerWithControlLayerDelegate delegate


-(void)pushMapAnnotationDetailedViewControllerDelegate:(id) sender
{
	PLog(@"%s\n",__FUNCTION__);
	if ([(id)annotationDelegate respondsToSelector:@selector(pushMapAnnotationDetailedViewControllerDelegate:)])
	{
		[annotationDelegate pushMapAnnotationDetailedViewControllerDelegate:self];
	}
}

@end
