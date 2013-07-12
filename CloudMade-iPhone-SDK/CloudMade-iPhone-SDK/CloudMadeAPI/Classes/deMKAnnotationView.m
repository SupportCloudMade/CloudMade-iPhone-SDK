//
//  deMKAnnotationView.m
//  SponsoredPOIs
//
//  Created by user on 8/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "deMKAnnotationView.h"
#import <QuartzCore/QuartzCore.h>


//
//  deCartaAnnotationView.m
//  iWalkRunBike
//
//  Created by Patrick Murphy on 9/25/09.
//  Copyright 2010 Fitamatic, LLC. All rights reserved.
//

//#import "deCartaAnnotationView.h"
//#import "iWalkRunBikeAppDelegate.h"
//#import "UIImageResize.h"



#define CALLOUT_PICTURE_WIDTH 33
#define LEFT_CALLOUT_MARGIN     10
#define LEFT_ICON_MARGIN      10


@implementation deCartaAnnotationView

@synthesize delegate;
@synthesize annRect;
@synthesize annotationOffset; 
//@synthesize position; 
@synthesize picture; 
@synthesize pinMessageLabel;
@synthesize pinPlacemarkLabel;
@synthesize detailedViewButton;
//@synthesize icon;
//@synthesize poi;
@synthesize title;
//@synthesize placemark;
@synthesize userData;
@synthesize annSize;
@synthesize highlightTimer;
@synthesize subTitle;

+(CGRect) frameForTitle:(NSString*) title subtitle:(NSString*) subTitle picture:(UIImage*) picture
{
	CGSize theTitleSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(270,25) lineBreakMode:UILineBreakModeTailTruncation];
	CGSize theSubtitleSize = [subTitle sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(270,25) lineBreakMode:UILineBreakModeTailTruncation];
	int theAnnotationWidth = MAX(theTitleSize.width,theSubtitleSize.width);
    int calloutMargins =  LEFT_CALLOUT_MARGIN*3 + ((picture)?(CALLOUT_PICTURE_WIDTH):0)+25 /* disclosere btn*/;
	int calloutWidth = (theAnnotationWidth + calloutMargins);
	CGRect neededFrame = CGRectIntegral(CGRectMake(0,0,calloutWidth + CALLOUT_PICTURE_WIDTH,55));	
	return neededFrame;
}

- (id) init
{
    annRect = CGRectMake(0, 0, 300, 55);
    if (self = [self initWithFrame:annRect]) {
        self.opaque = NO;  //needs to be opaque or no rounded corners
//        self.poi = [[deCartaPOI alloc] init];
//        self.icon = [[deCartaIcon alloc] init];
        //Need to rescale the pictures 
//        self.picture = [self.icon.pinImage scaleToSize:CGSizeMake(annRect.size.height-10,annRect.size.height-10)];
        annSize = YES;
	}
    
	return self;
}

//-(void) setFrame:(CGRect) frame
//{
//	CGRect newFrame = frame;
//	if(frame.origin.x<0)
//	{
//		newFrame = CGRectOffset(frame,frame.origin.x,0);
//	}
//	[super setFrame:newFrame];
//}

//Init for a Pin with Big annotation window
//- (id)initBigWithId:(id) inId andIcon:(deCartaIcon *) inIcon {
- (id)initWithFrame:(CGRect)frame title:(NSString*) _title subtitle:(NSString*) subtitle picture:(UIImage*) image 
{
    annRect = frame;//CGRectMake(0, 0, 300, 55);
    if (self = [self initWithFrame:annRect]) {
        self.opaque = NO;
        //assign the inId for pushMapAnnotationDetailedViewControllerDelegate

//        self.icon = inIcon;
//        self.poi = inIcon.poi;
        //Need to rescale the pictures 
//        self.picture = [inIcon.pinImage scaleToSize:CGSizeMake(annRect.size.height-10,annRect.size.height-10)];
		//[self changePosition:position];		
		self.title =_title;
		self.subTitle = subtitle; 
		//picture =    [UIImage imageNamed:@"Icon.png"];
		
//		- (UIImage *)imageScaledToFitSize:(CGSize)size; // 
		self.picture = image;//[picture imageScaledToFitSize:CGSizeMake(35,35)];
		[picture retain];
        annSize = YES;
		
		trianglePoint.x = 0;
		trianglePoint.y = 0;
		
		detailedViewButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[detailedViewButton addTarget:self action:@selector(annotationButtonPressed:)
					 forControlEvents:UIControlEventTouchDown];
		if (annSize) 
			detailedViewButton.frame = CGRectMake(annRect.size.width-32, 6.5, 32.0, 32.0);
		else 
			detailedViewButton.frame = CGRectMake(annRect.size.width-32, 1.5, 32.0, 32.0);
		[self addSubview:detailedViewButton];
		moveTriangle = NO;
    }
	return self;
}

-(void) moveTriangleToPoint:(CGPoint) point
{
	moveTriangle = YES;
	trianglePoint = point;
}


/*
//Init for a Pin with Small annoation window
- (id)initSmallWithId:(id) inId andIcon:(deCartaIcon *) inIcon 
{
    CGSize textsize = [inIcon.message sizeWithFont:[UIFont systemFontOfSize:16]];
    CGFloat rectWidth = textsize.width+50+32; //add picture and button size widths
    if (rectWidth > 300) {
        //if text is larger than this the text size will be scaled down below
        rectWidth = 300;
    }
    annRect = CGRectMake(0, 0, rectWidth, 45);
    if (self = [self initWithFrame:annRect]) {
        self.opaque = NO;
        //assign the inId for pushMapAnnotationDetailedViewControllerDelegate
        self.delegate = inId;
        self.icon = inIcon;
        self.poi = inIcon.poi;
        //Need to rescale the pictures 
        self.picture = [inIcon.pinImage scaleToSize:CGSizeMake(annRect.size.height-10,annRect.size.height-10)];
		[self changePosition:inIcon.poi.position];		
		self.title = inIcon.poi.name; 
        annSize = NO;
	}
	return self;
}


//Init for a Route
- (id)initRouteWithPosition:(deCartaPosition*)_position title:(NSString*)_title {
	if (self = [super init]) {
		[self changePosition:_position];		
        self.title = [_title retain];  
	}
	return self;
}
*/

- (void)runHighlightTimer
{
    // reset the timer
    [highlightTimer invalidate];
	[highlightTimer release];
	highlightTimer = nil;
    
    highlightTimer = [[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(highlightTimerFired:) userInfo:nil repeats:NO] retain];
    [[NSRunLoop currentRunLoop] addTimer:highlightTimer forMode:NSDefaultRunLoopMode];
}

- (void)highlightTimerFired:(NSTimer *)timer
{
	// time has passed, turn off highlightLabel's
    pinMessageLabel.highlighted = NO;
    pinPlacemarkLabel.highlighted = NO;
}

- (IBAction) annotationButtonPressed:(id)sender
{
    //pinMessageLabel.highlighted = YES;
    //pinPlacemarkLabel.highlighted = YES;
    //[self runHighlightTimer];
	
    // A UIView can't push a View Controller so the delegate does this for us
	if (([(id)self.delegate respondsToSelector:@selector(pushMapAnnotationDetailedViewControllerDelegate:)]))
	{
		[self.delegate pushMapAnnotationDetailedViewControllerDelegate:self];
	}
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context
{
    float radius = 8.0f; 
    float triSize = 10.0f;
    //First Create the rounded rectangular Pin Annoation box
    CGContextBeginPath(context);
    //color of the annotation box, color=black=0.0;white=1.0 , alpha
	CGContextSetGrayFillColor(context, 0.0, 0.80);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y-triSize + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y-triSize + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y-triSize + rect.size.height - radius, 
                    radius, M_PI / 4, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, 
                            rect.origin.y-triSize + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, 
                    rect.origin.y-triSize + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, (int)(rect.origin.x + radius), (int)(rect.origin.y + radius), radius, 
                    -M_PI / 2, M_PI, 1);
    //triangle pointer above Pin
	if (moveTriangle)
	{
		CGContextMoveToPoint(context, (int)(trianglePoint.x), (int)(rect.size.height-triSize));
		CGContextAddLineToPoint(context, (int)(trianglePoint.x+triSize), rect.size.height);
		CGContextAddLineToPoint(context, (int)(trianglePoint.x+triSize*2), (int)(rect.size.height-triSize));
		CGContextAddLineToPoint(context, (int)(trianglePoint.x-triSize*2), (int)(rect.size.height-triSize));
	}
	else
	{
		CGContextMoveToPoint(context, (int)(rect.size.width/2-triSize), (int)(rect.size.height-triSize));
		CGContextAddLineToPoint(context, (int)(rect.size.width/2), rect.size.height);
		CGContextAddLineToPoint(context, (int)(rect.size.width/2+triSize), (int)(rect.size.height-triSize));
		CGContextAddLineToPoint(context, (int)(rect.size.width/2-triSize), (int)(rect.size.height-triSize));
	}
    
    CGContextClosePath(context);
    CGContextFillPath(context);
	
    CGContextClip(context);


 
	size_t num_locations = 2;	
	CGFloat locations[2] = { 0.0, 0.1 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
		1.0, 1.0, 1.0, 0.06 }; // End color
	
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);	
	
	
	//CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(rect), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect) - triSize/2);
    CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);	
	
	
	


 
	
    //Now add the picture, labels, and button over the rectangle
    //Place the picture in the left corner
    [picture drawAtPoint:CGPointMake(9.0, 5.0)];
	

    //Create the Message Label programmatically
    CGRect labelFrame;
    if (annSize) 
        labelFrame = CGRectIntegral(CGRectMake((int)picture.size.width+5 + 7 + 5, 3, (int)(rect.size.width-picture.size.width-32-5), 20));
    else 
        labelFrame = CGRectIntegral(CGRectMake(picture.size.width+5 +7 + 5, 8, (int)(rect.size.width-picture.size.width-32-5), 20));
	if (!pinMessageLabel)
	{
		pinMessageLabel = [[UILabel alloc] initWithFrame:labelFrame];
	}
    pinMessageLabel.adjustsFontSizeToFitWidth = YES;
    pinMessageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    pinMessageLabel.font = [UIFont boldSystemFontOfSize:18.0];
    pinMessageLabel.textAlignment = UITextAlignmentLeft;
    pinMessageLabel.textColor = [UIColor whiteColor];
    //highlightedTextColor controlled by highlightTimer
    pinMessageLabel.highlighted = NO;
    pinMessageLabel.highlightedTextColor = [UIColor redColor];
    pinMessageLabel.backgroundColor = [UIColor clearColor]; 
    [pinMessageLabel setText: self.title];
	pinMessageLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	pinMessageLabel.shadowOffset = CGSizeMake(-1,0); 
	
    [self addSubview:pinMessageLabel];
    
    //Create the Placemark Label programmatically
    if (annSize) {
        //Placemark for large rectangle ONLY
        labelFrame = CGRectMake((int)picture.size.width+5+7+5, 22, 218, 20);
		if (!pinPlacemarkLabel)
			pinPlacemarkLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(labelFrame)];
        pinPlacemarkLabel.adjustsFontSizeToFitWidth = YES;
        pinPlacemarkLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        pinPlacemarkLabel.font = [UIFont boldSystemFontOfSize:13.0];
        pinPlacemarkLabel.textAlignment = UITextAlignmentLeft;
        pinPlacemarkLabel.textColor = [UIColor whiteColor];
        //highlightedTextColor controlled by highlightTimer
        pinPlacemarkLabel.highlighted = NO;
        pinPlacemarkLabel.highlightedTextColor = [UIColor redColor]; 
        pinPlacemarkLabel.backgroundColor = [UIColor clearColor]; 
        [pinPlacemarkLabel setText:self.subTitle];
		pinPlacemarkLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		pinPlacemarkLabel.shadowOffset = CGSizeMake(-1,0); 
		
        [self addSubview:pinPlacemarkLabel];
    }
    //Create the UIButton programmatically
	//CAGradientLayer* grlayer = [self shadowAsInverse:TRUE];
	//[self.layer insertSublayer:grlayer below:pinPlacemarkLabel.layer]; 
	CGGradientRelease(glossGradient);
}

- (void)drawRect:(CGRect)rect
{
	
    CGContextRef ctxt = UIGraphicsGetCurrentContext();	
    [self fillRoundedRect:annRect inContext:ctxt];	
}

#pragma mark -
#pragma mark MKAnnotation Methods

- (NSString *)subtitle {
	NSString* subtitle = nil;
/*	
	//TODO : Debug this isn't doing anything right now
	if (self.placemark) {
        //This is the info we display on a Pin
        subtitle = [NSString stringWithFormat:@"%@ %@, %@, %@, %@ ", self.placemark.buildingNumber,self.placemark.street,self.placemark.municipality,self.placemark.countrySecondarySubdivision,self.placemark.countrySubdivision];
        //NSLog(@"deCartaAnnotationView : subtitle = %@",subtitle);
		
	} else {
        //If we fail reverse geocoding we just deliver lat / lon, some locations have no address
		subtitle = [NSString stringWithFormat:@"%lf, %lf", self.position.getLat, self.position.getLon];
	}
*/ 
	return subtitle;
}

#pragma mark -
#pragma mark Change position

- (void)changePosition:(CLLocationCoordinate2D)_position {
    //NSLog(@"changePosition : DEBUG");
    //[self.position release];
	//self.position = [_position retain];
    
    //self.position = [_position retain];
	// Try to reverse geocode here
/*	
    iWalkRunBikeAppDelegate *AppDelegate = (iWalkRunBikeAppDelegate *)[[UIApplication sharedApplication] delegate];
	deCartaGeocoder *geoCoder = [[deCartaGeocoder alloc] init];
	geoCoder.config = AppDelegate.config;
    /*
	 if (position == nil)
	 {
	 //default it with something
	 position = [[deCartaPosition alloc] initWithString:@"37.336723 -121.889555"];
	 }
	 * /
	//deCartaStructuredAddress *address = [geoCoder reverseGeocode:position];
    //deCartaStructuredAddress *address = [geoCoder reverseGeocode:self.icon.poi.position];
    deCartaStructuredAddress *address = [geoCoder reverseGeocode:_position];
	
	if (address)
	{
        //[self.placemark release];
		self.placemark = [NSString stringWithFormat:@"%@", address];
        //Update the icon POI position for MapAnnotationDetailedViewController
        //[self.icon setPoiNewPosition:position];
        //self.icon.poi.address = placemark.description;
        //[self.icon.poi.address release];
        
        //debug added autorelease 3-21-10
        self.icon.poi.address = [[[deCartaFreeFormAddress alloc] initWithFreeFormAddress:placemark.description] autorelease];
		
        //Update pinPlacemarkLabel so new location is shown
        [pinPlacemarkLabel setText:self.placemark.description];
	}
	//[pos release];
	[geoCoder release];
    //NSLog(@"deCartaAnnotationView : changePosition : position = %@",position.description);
    //NSLog(@"deCartaAnnotationView : changePosition : placemark = %@",placemark.description);
*/	
}

#pragma mark -
#pragma mark MKAnnotationView Notification
/*
- (void)notifyCalloutInfo:(deCartaStructuredAddress *)_placemark {
	[self willChangeValueForKey:@"subtitle"]; 
	self.placemark = _placemark;
	[self didChangeValueForKey:@"subtitle"]; 
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"deCartaAnnotationViewCalloutInfoDidChangeNotification" object:self]];
}

- (void) setNewIconInfo:(deCartaIcon *) inIcon
{
    NSLog(@"deCartaAnnotationView : setNewIconInfo : icon = %@",inIcon);
    self.icon = inIcon;
    self.poi = inIcon.poi;
    //Update the pinMessageLabel and picture since these are the only things that change
    [pinMessageLabel setText:self.icon.poi.name];
    //Need to rescale the pictures and redraw the annotationView
    self.picture = [self.icon.pinImage scaleToSize:CGSizeMake(self.annRect.size.height-10,self.annRect.size.height-10)];
    [self setNeedsDisplay];
}
*/
- (BOOL) isEqualTo:(id) inObj
{
	if (inObj == nil)
	{
		return NO;
	}
	
	if (![inObj isKindOfClass:[self class]])
	{
		return NO;
	}
/*	
	deCartaAnnotationView *obj = inObj;
	
	if ( CGRectEqualToRect(obj.annRect,self.annRect) && CGPointEqualToPoint(obj.annotationOffset,self.annotationOffset)
        && [obj.detailedViewButton isEqual:self.detailedViewButton] && [obj.icon isEqual:self.icon]
        && [obj.poi isEqualTo:self.poi] && [UIImagePNGRepresentation(obj.picture) isEqualToData:UIImagePNGRepresentation(self.picture)]
        && [obj.position isEqualTo:self.position] && [obj.title isEqualToString:self.title]
        && [obj.placemark isEqualTo:self.placemark] && [obj.userData isEqualToString:self.userData]
        && (obj.annSize == self.annSize) )
	{
		return YES;
	}
*/	
	return NO;
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


- (void)dealloc {
    [pinMessageLabel release];
    [pinPlacemarkLabel release];
    [detailedViewButton release];
    [picture release];
    [highlightTimer release];
    //NSStringRelease
    [userData release];
    [title release];
    [super dealloc];
}

@end
