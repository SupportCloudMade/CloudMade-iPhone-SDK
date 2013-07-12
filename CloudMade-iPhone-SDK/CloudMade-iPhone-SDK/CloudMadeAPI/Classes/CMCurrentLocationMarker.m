//
//  CMCurrentLocationMarker.m
//  Routing
//
//  Created by user on 12/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RMMapView.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"
#import "RMMapContents.h"
#import "CMCurrentLocationMarker.h"
#import "RMFoundation.h"

#import "RMGlobalConstants.h"
#import "RMPixel.h"
#import "RMProjection.h"
#import "locationCenter.h"
#import "RMMarkerManager.h"



#define kbullsEyeSm_crosshair   5.0
#define kbullsEyeSm_radius      20.0 
#define kbullsEyeSm_radius3      8.0
#define kbullsEyeWidthMax		60.0
#define kbullsEyeAccuracy1		60.0
#define kbullsEyeAccuracy2		101.0
#define kbullsEyeAccuracy3		150.0
#define kbullsEyeWidthMin		10.0
#define kbullsEyeBaseFrameSize  100.0       //
#define kbullsEyeVelocity		3.0         // i.e. 30 pxl per sec for base frame size 100x100  
#define kbullsEyeTimer          1.0/10.0    //
#define kbullsEyeOpacity        1.0/7.0


typedef struct _CurrentLocationProperties
{
    CGPoint	position;
    CGPoint	position1;
    CGPoint	position2;
    CGPoint	position3;
    CGPoint	radius;
    CGFloat opacity;
} CurrentLocationProperties;


static int g_defaultImgWidth;

static inline float radians(double deegrees)
{
	return deegrees * M_PI/180;
}


static inline float deegrees(double radians)
{
	return 180*radians/M_PI;
}

 
@interface CMBuld : CALayer
{
}

@end

@implementation CMBuld
- (id<CAAction>)actionForKey:(NSString *)key
{
	return nil;
}

@end

@interface CMCurrentLocationMarker (Private)
- (CGFloat) relevantVelocity;
- (CGFloat) relevantUpdatingTime;
- (void)forwardChangeBounds;
@end

@implementation CMCurrentLocationMarker

@synthesize projectedLocation;
@synthesize enableDragging;
@synthesize enableRotation;


- (id) initWithContents: (RMMapContents*)aContents accurancy:(float) accurancy
{
	self = [super init];
	_contents = aContents;
//	_heading = CGPathCreateMutable();
    _accurancy = accurancy;
	self.delegate = self;
	currentLocationProperties = malloc(sizeof(CurrentLocationProperties));
	radius = (_accurancy / _contents.metersPerPixel) < kbullsEyeWidthMin ? kbullsEyeWidthMin : (_accurancy / _contents.metersPerPixel);
	
    [self forwardChangeBounds];
    
    //_path = CGPathCreateMutable();
    self.anchorPoint =  CGPointMake(0.5, 0.5);
	
	
	NSData *pngData = [NSData dataWithBytesNoCopy:location_center2_png length:location_center2_png_len];
	centerImage = [[UIImage imageWithData:pngData] retain];
	
	
	g_defaultImgWidth = [centerImage size].width;
	
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:[self relevantUpdatingTime] target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    enableDragging = YES;
    enableRotation = YES;
    
    [_contents.mercatorToScreenProjection addObserver:self
     
              forKeyPath:@"metersPerPixel"
     
                 options:(NSKeyValueObservingOptionNew |                  
                          NSKeyValueObservingOptionOld)
     
                 context:NULL];
    
    
    
	return self;
}

-(void) dealloc
{
	[updateTimer invalidate];
	[centerImage release];
	free(currentLocationProperties);
	[super dealloc];
}

#pragma mark -

- (void)forwardChangeBounds {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.bounds = CGRectMake(0, 0, radius,radius);
    [CATransaction commit];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath

                      ofObject:(id)object

                        change:(NSDictionary *)change

                       context:(void *)context

{
    
     
    if ([keyPath isEqual:@"metersPerPixel"]) {
        
//        CORRECT RELEVANT RADIUS
        radius = (_accurancy/_contents.metersPerPixel)<kbullsEyeWidthMin?kbullsEyeWidthMin:(_accurancy/_contents.metersPerPixel);
        [self forwardChangeBounds];
        [updateTimer invalidate];
        
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:[self relevantUpdatingTime]
                                                       target:self selector:@selector(redraw)
                                                     userInfo:nil
                                                      repeats:YES];
//        NSLog(@"############CORRECTING RADIUS#############");
 
        
    }
} 



- (CGFloat) relevantVelocity
{
	return kbullsEyeVelocity;
}	

- (CGFloat) relevantUpdatingTime
{
	//NSLog(@"size: %f,relevant time: %f",self.bounds.size.height, kbullsEyeBaseFrameSize/self.bounds.size.height*kbullsEyeTimer);
    if (radius > [[UIScreen mainScreen] applicationFrame].size.height) return kbullsEyeBaseFrameSize/([[UIScreen mainScreen] applicationFrame].size.height-kbullsEyeSm_radius3*2-kbullsEyeWidthMin)*kbullsEyeTimer; 
		return kbullsEyeBaseFrameSize/(self.frame.size.height-kbullsEyeSm_radius3*2-kbullsEyeWidthMin)*kbullsEyeTimer; 
}

- (void) updatePosition:(CLLocationCoordinate2D) markerPosition withAccurnacy:(float) accurancy
{
	_accurancy = accurancy;
	[_contents.markerManager removeMarker:self];  //[_sign removeFromMap];
	PLog(@"remove marker\n");
	
	[_contents.markerManager addMarker:self AtLatLong:markerPosition];	
    PLog(@"marker added");
    
    self.zPosition = -1;
	radius = (_accurancy/_contents.metersPerPixel)<50?50:(_accurancy/_contents.metersPerPixel);
	
    [self forwardChangeBounds];
    //_path = CGPathCreateMutable();
    self.anchorPoint =  CGPointMake(0.5, 0.5);
	
	[updateTimer invalidate];
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:[self relevantUpdatingTime] target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    
    [self setNeedsDisplay];	
}


- (void) removeFromMap
{
	[_contents.markerManager removeMarker:self];  //[_sign removeFromMap];
}

-(float) bearing:(CLLocationCoordinate2D) theCurrentPosition
{
	CLLocationCoordinate2D northPole = {90.0,0};
    float dx = northPole.latitude - theCurrentPosition.latitude;
	float dy = northPole.longitude - theCurrentPosition.longitude;
	float angleRadians = atan2(dx,dy);
	return deegrees(angleRadians);
}

- (CGGradientRef) CreateGradient:(CGColorRef) inColor1
				  andColor1Start:(CGFloat) inColor1Start
					   andColor2:(CGColorRef) inColor2
				  andColor2Start:(CGFloat) inColor2Start
					   andColor3:(CGColorRef) inColor3
				  andColor3Start:(CGFloat) inColor3Start
{
	// Setup a CFArray with our CGColorRefs
	const void *colorRefs[3] = {inColor1, inColor2, inColor3};
	CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, colorRefs, 3, &kCFTypeArrayCallBacks);
	// Setup a parallel array that contains the start locations of those colors
	CGFloat locations[3] = {inColor1Start, inColor2Start, inColor3Start};
	// Create the gradient
	CGGradientRef gradients = CGGradientCreateWithColors(NULL, colorArray, locations);
	// clean up the color array (the gradient will retain it if necessary)
	CFRelease(colorArray);
	
	return gradients;
}

-(CGColorRef)CreateDeviceRGBColor:(CGFloat) r
								G:(CGFloat) g 
								B:(CGFloat) b 
								A:(CGFloat) a
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat comps[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, comps);
	CGColorSpaceRelease(rgb);
	return color;
}


-(void)updateBullsEye 
{
    //Bulls Eye View Center Initialization
    currentLocationProperties->position.x = self.frame.size.width/2;
    currentLocationProperties->position.y = self.frame.size.height/2;
    int count;
    
	
    if(currentLocationProperties->radius.x + [self relevantVelocity] >= /*kbullsEyeWidthMax*/(self.frame.size.height-kbullsEyeSm_radius3*2)) {
        currentLocationProperties->opacity = 1.0;
        currentLocationProperties->radius.x = kbullsEyeWidthMin;
        currentLocationProperties->radius.y = kbullsEyeWidthMin; ;
        currentLocationProperties->position1.x = kbullsEyeWidthMin;
        currentLocationProperties->position1.y = kbullsEyeWidthMin;
        currentLocationProperties->position2.x = kbullsEyeWidthMin;
        currentLocationProperties->position2.y = kbullsEyeWidthMin;
        currentLocationProperties->position3.x = kbullsEyeWidthMin;
        currentLocationProperties->position3.y = kbullsEyeWidthMin;
        count = 0;
    }
    count++;
    currentLocationProperties->opacity -= kbullsEyeOpacity;
    currentLocationProperties->radius.x  += [self relevantVelocity];
    currentLocationProperties->radius.y  += [self relevantVelocity];
    //Bulls Eye center circle
    currentLocationProperties->position1.x = currentLocationProperties->position.x-kbullsEyeSm_radius/2;
    currentLocationProperties->position1.y = currentLocationProperties->position.y-kbullsEyeSm_radius/2;
    //Expanding circle
    currentLocationProperties->position2.x = currentLocationProperties->position.x-currentLocationProperties->radius.x/2;
    currentLocationProperties->position2.y = currentLocationProperties->position.y-currentLocationProperties->radius.y/2;
    //Bigger expanding circle
    currentLocationProperties->position3.x = currentLocationProperties->position.x-(currentLocationProperties->radius.x+kbullsEyeSm_radius3)/2;
    currentLocationProperties->position3.y = currentLocationProperties->position.y-(currentLocationProperties->radius.y+kbullsEyeSm_radius3)/2;
    
}

- (void)drawBullsEyeGradient:(CGRect)rect_ inContext:(CGContextRef)context
{
	[self updateBullsEye];
	BOOL extendStart = YES;
	BOOL extendEnd = NO;
	
	CGColorRef blue = [self CreateDeviceRGBColor:0.0 G:0.0 B:1.0 A:1.0];
	CGColorRef red = [self CreateDeviceRGBColor:1.0 G:0.0 B:0.0 A:1.0];
	CGColorRef red_opacity = [self CreateDeviceRGBColor:1.0 G:0.0 B:0.0 A:1];
	CGColorRef yellow = [self CreateDeviceRGBColor:1.0 G:1.0 B:0.0 A:1.0];
	CGColorRef yellow_opacity = [self CreateDeviceRGBColor:1.0 G:1.0 B:0.0 A:1];
	CGColorRef green = [self CreateDeviceRGBColor:0.0 G:1.0 B:0.0 A:1.0];
	CGColorRef green_opacity = [self CreateDeviceRGBColor:0.0 G:1.0 B:0.0 A:1];
	CGColorRef black = [self CreateDeviceRGBColor:0.0 G:0.0 B:0.0 A:1.0];
	
	CGFloat colorStart1 = 1;
	CGFloat colorStart2 = 0.3;
	CGFloat colorStart3 = 0.2;
	CGGradientRef gradient;
	
	float bullsEyeAccuracy = _accurancy;
	
	
	
	if (bullsEyeAccuracy < kbullsEyeAccuracy1)
		gradient = [self CreateGradient:green_opacity andColor1Start:colorStart1 andColor2:green andColor2Start:colorStart2 andColor3:blue andColor3Start:colorStart3];
	else if (bullsEyeAccuracy < kbullsEyeAccuracy2)
		gradient = [self CreateGradient:yellow_opacity andColor1Start:colorStart1 andColor2:yellow andColor2Start:colorStart2 andColor3:blue andColor3Start:colorStart3];
	else if (bullsEyeAccuracy < kbullsEyeAccuracy3)
		gradient = [self CreateGradient:red_opacity andColor1Start:colorStart1 andColor2:red andColor2Start:colorStart2 andColor3:yellow andColor3Start:colorStart3];
	else 
		gradient = [self CreateGradient:red_opacity andColor1Start:colorStart1 andColor2:red andColor2Start:colorStart2 andColor3:black andColor3Start:colorStart3];
	
	CGColorRelease(blue);
	CGColorRelease(red);
	CGColorRelease(red_opacity);
	CGColorRelease(yellow);
	CGColorRelease(yellow_opacity);
	CGColorRelease(green);
	CGColorRelease(green_opacity);
	CGColorRelease(black);
	
	//center of rectangle
	CGPoint startPoint = CGPointMake(self.position.x,self.position.y);
	CGPoint endPoint = CGPointMake(self.position.x,self.position.y);
	
    CGFloat startRadius = kbullsEyeSm_radius/2*0.10;
    CGFloat endRadius = kbullsEyeSm_radius/2*0.75;	
	
	
	//radius from center of rectangle, max is radius/2
	if(self.bounds.size.height >= centerImage.size.height*3)
	{
		
/*		
		
        //Create the gradient circles path
        CGMutablePathRef circle = CGPathCreateMutable();
        //Add the context to the path 
        CGContextAddPath(context, circle);
        //Draw the inner circle with Radial Gradient
        CGPathAddEllipseInRect(circle, NULL, CGRectMake(bullsEye.position1.x, bullsEye.position1.y,kbullsEyeSm_radius,kbullsEyeSm_radius));
        //CGContextClip(context);
        CGContextDrawRadialGradient(context, gradient, startPoint, startRadius, endPoint, endRadius,
                                    (extendStart ? kCGGradientDrawsBeforeStartLocation : 0) | (extendEnd ? kCGGradientDrawsAfterEndLocation : 0));
        CGPathRelease(circle);
        
	*/	
		//NSLog(@"context rect %@\n",NSStringFromCGRect(rect_));
		
		//Set up the colors for the expanding bullsEye circles
        //CGFloat sky_blue_fade[] = {0.3, 0.5, 0.871, bullsEye.opacity};
		
		
		CGFloat sky_blue_fade[] = {0.0, 0.5, 1.0, currentLocationProperties->opacity};
		
        //Start a new expanding context path
        CGContextBeginPath(context);
        // Next expanding circles with fading opacity
        CGContextSetLineWidth(context, 3.0);
        //CGContextSetStrokeColor(context,sky_blue_fade);
		
		//CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:1 alpha:0.5] CGColor]);
		
		CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0.55 blue:1 alpha:0.55] CGColor]);
		
		CGRect fadingOpacity = CGRectMake(currentLocationProperties->position3.x, currentLocationProperties->position3.y, currentLocationProperties->radius.x+kbullsEyeSm_radius3, currentLocationProperties->radius.y+kbullsEyeSm_radius3);
		

		
		
		//NSLog(@"fadingOpacity rect %@\n",NSStringFromCGRect(fadingOpacity));
        CGContextAddEllipseInRect(context,fadingOpacity);
        //draw the outer expanding circle context
        CGContextStrokePath(context);
		CGRect expandCircle = CGRectMake(currentLocationProperties->position2.x, currentLocationProperties->position2.y, currentLocationProperties->radius.x, currentLocationProperties->radius.y);
		//NSLog(@"expandCircle rect %@\n",NSStringFromCGRect(expandCircle));
		CGContextSetLineWidth(context, 2.0);
        CGContextAddEllipseInRect(context,expandCircle);
        //draw the inner expanding dashed circle context
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddEllipseInRect(path,NULL,CGRectInset(self.bounds,2,2));
		
		CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0.55 blue:1 alpha:0.14] CGColor]);
		CGContextAddPath(context,path);
		CGContextFillPath(context); 
		
		CGContextAddEllipseInRect(context,CGRectInset(self.bounds,2,2));
		
        CGContextStrokePath(context);
        //NSLog(@"#####PATH RETAIN COUNT IS####:%@", CFGetRetainCount(path));
        CGPathRelease(path); 
 
    }
/*

	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0.55 blue:1 alpha:0.55] CGColor]);	
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddEllipseInRect(path,NULL,CGRectInset(self.bounds,2,2));
	
	CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0.55 blue:1 alpha:0.14] CGColor]);
	CGContextAddPath(context,path);
	CGContextFillPath(context); 
	
	CGContextAddEllipseInRect(context,CGRectInset(self.bounds,2,2));
*/ 
	
	CGContextStrokePath(context);	
	
	CGContextDrawImage(context,CGRectMake(self.frame.size.width/2 - centerImage.size.width/2,
										  self.frame.size.height/2- centerImage.size.height/2,centerImage.size.width,centerImage.size.height),centerImage.CGImage);
    CGGradientRelease(gradient);
    
	//self.borderWidth = 1;
	//self.borderColor = [UIColor greenColor].CGColor;
    
	
}


- (void) redraw
{
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)theContext
{
	[self drawBullsEyeGradient:CGRectZero inContext:theContext];
}


- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
    radius = (_accurancy / _contents.metersPerPixel) < kbullsEyeWidthMin ? kbullsEyeWidthMin : (_accurancy / _contents.metersPerPixel);
    
	[updateTimer invalidate];
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:[self relevantUpdatingTime]
												   target:self selector:@selector(redraw)
												 userInfo:nil
												  repeats:YES];

    [super zoomByFactor:zoomFactor near:pivot];	
 //   NSLog(@"radius: %f, ac: %f, mpp: %f", radius, _accurancy, _contents.metersPerPixel);    
    [self forwardChangeBounds];

//    NSLog(@"bounds h: %f, w: %f", self.bounds.size.height, self.bounds.size.width);

//	NSLog(@"%f\n",zoomFactor);
//	if (self.bounds.size.height > g_defaultImgWidth*2)
//	{
//		[super zoomByFactor:zoomFactor near:pivot];	
//        NSLog(@"First case");
//	}
//	else if(zoomFactor > 1)
//	{
//		[super zoomByFactor:zoomFactor near:pivot];
//         NSLog(@"Second case");
//	}
//	else
//	{
//		self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, pivot);
//         NSLog(@"Third case");
//	}


}

- (id<CAAction>)actionForLayer:(CALayer*)layer
						forKey:(NSString*)key
{
	return nil;
}

@end
