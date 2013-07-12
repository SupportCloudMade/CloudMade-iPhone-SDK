//
//  SponsoredPOIView.m
//  SponsoredPOIs
//
//  Created by Dmytro Golub on 8/20/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import "CMAnnotationView.h"
#import "LibUtils.h"

@implementation CMAnnotationView

#define CALLOUT_SPARC_WIDTH    
#define CALLOUT_PICTURE_WIDTH 16
#define LEFT_CALLOUT_MARGIN     10
#define LEFT_ICON_MARGIN      10

- (id)initWithFrame:(CGRect)frame andTitle:(NSString*) title  withImage:(UIImage*) image
{
	
	
	UIImage* _leftBorderImage = [UIImage imageNamed:_BI(@"callout_left.png")];
	UIImage* _rightBorderImage = [UIImage imageNamed:_BI(@"callout_right.png")];
	UIImage* centerImage = [UIImage imageNamed:_BI(@"callout_center.png")];
	UIImage* sparkImage = [UIImage imageNamed:_BI(@"callout_fill.png")];
	
	CGSize theStringSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(270,25) lineBreakMode:UILineBreakModeTailTruncation];
    int calloutMargins =  image?(LEFT_CALLOUT_MARGIN*3 + CALLOUT_PICTURE_WIDTH):(LEFT_CALLOUT_MARGIN*2);
	int imagesWidth = [_leftBorderImage size].width + [centerImage size].width + 2;
	int calloutWidth = (theStringSize.width + calloutMargins) < (imagesWidth)?imagesWidth:(theStringSize.width + calloutMargins);
	CGRect neededFrame = CGRectIntegral(CGRectMake(0,0,calloutWidth + [_rightBorderImage size].width,[_leftBorderImage size].height));
	
    if (self = [super initWithFrame: neededFrame /*frame*/])
	{
		_frame = neededFrame;
		UIImage* iconImage = image;
		
		CGRect rcLeft = CGRectMake(0,0,(int)_leftBorderImage.size.width,(int)self.frame.size.height);
		_leftBorder = [[UIImageView alloc] initWithFrame:CGRectIntegral(rcLeft)];
		_leftBorder.image = _leftBorderImage;
		
	
		CGRect rcRight = CGRectMake((int)(self.frame.size.width-_rightBorderImage.size.width),0,(int)_rightBorderImage.size.width,(int)self.frame.size.height);
		_rightBorder = [[UIImageView alloc] initWithFrame:CGRectIntegral(rcRight)];
		_rightBorder.image = _rightBorderImage;

		int sparkLenght = (self.frame.size.width-_leftBorderImage.size.width-_rightBorderImage.size.width - centerImage.size.width)/2;
		
		CGRect rcSpark = CGRectMake((int)_leftBorderImage.size.width,0,sparkLenght,(int)self.frame.size.height);
		
		CGRect rcCenter = CGRectMake((int)(_leftBorderImage.size.width + rcSpark.size.width)/*-1*/,0,(int)centerImage.size.width,(int)self.frame.size.height);
		_middleView = [[UIImageView alloc] initWithFrame:CGRectIntegral(rcCenter)];
		_middleView.image = centerImage;
		
		_sparkViewLeft =  [[UIImageView alloc] initWithFrame:CGRectIntegral(rcSpark)];
		_sparkViewLeft.image = sparkImage;
		

		rcSpark = CGRectMake((int)(rcCenter.origin.x + rcCenter.size.width),0,sparkLenght,(int)self.frame.size.height);
		
		_sparkViewRight = [[UIImageView alloc] initWithFrame:CGRectIntegral(rcSpark)];
		_sparkViewRight.image = sparkImage;
		
		_rightBorder.frame = CGRectMake(rcSpark.origin.x + rcSpark.size.width, 0,
										_rightBorder.bounds.size.width,_rightBorder.bounds.size.height);
		[self addSubview:_rightBorder];
		[self addSubview:_leftBorder];
		[self addSubview:_middleView];
		[self addSubview:_sparkViewLeft];
		[self addSubview:_sparkViewRight];
		
		if( iconImage)
		{
			CGRect rcIcon = CGRectMake(LEFT_CALLOUT_MARGIN*2,5,iconImage.size.width,iconImage.size.height);
			_icon = [[UIImageView alloc] initWithFrame:CGRectIntegral(rcIcon)];
			_icon.image = iconImage;
			[self addSubview:_icon];	
		}
		
		int labelMargin = (iconImage)?(LEFT_CALLOUT_MARGIN*2 + CALLOUT_PICTURE_WIDTH):(LEFT_CALLOUT_MARGIN*1.5);
		CGRect  labelFrame = CGRectIntegral(CGRectMake(labelMargin,15,(int)(theStringSize.width+5),theStringSize.height));
		_poiName = [[UILabel alloc] initWithFrame:labelFrame];
		_poiName.textAlignment = UITextAlignmentLeft;
		_poiName.font = [UIFont boldSystemFontOfSize:18];
		_poiName.backgroundColor = [UIColor clearColor];
		_poiName.textColor = [UIColor whiteColor];
		_poiName.lineBreakMode = UILineBreakModeTailTruncation;
		_poiName.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_poiName.shadowOffset = CGSizeMake(-1,0);
		//if(iconImage == nil)
		//	_poiName.center = CGPointMake((neededFrame.size.width - [_rightBorderImage size].width)/2,(neededFrame.size.height)/2);
/*		
		CGSize theStringSize2 = [title sizeWithFont:_poiName.font constrainedToSize:labelFrame.size lineBreakMode:_poiName.lineBreakMode];
		

		CGRect frameRect = CGRectIntegral(CGRectMake(labelFrame.origin.x,
                                     labelFrame.origin.y + (labelFrame.size.height - theStringSize2.height) / 2.0,
                                     theStringSize2.width,
                                     theStringSize2.height));	
		_poiName.frame = frameRect;	
*/ 
		_poiName.text = title;		
		
		
		//[self insertSubview:_poiName aboveSubview:_sparkViewRight];
		[self insertSubview:_poiName atIndex:6];
		//self.alpha = 0;
		//self.transform = CGAffineTransformMakeScale(0.5,0.5);
    }
    return self;
}

-(void) anchorPoint:(CGPoint) point
{
	self.center = CGPointMake(point.x,(point.y - _frame.size.height/2) );
}

- (void)didMoveToSuperview
{
	//[UIView beginAnimations:nil context:NULL];
	//[UIView setAnimationDuration:0.1];
	
	//self.alpha = 1;
	//self.transform = CGAffineTransformMakeScale(1,1);
	//[UIView commitAnimations];
}

- (void)dealloc {
    [super dealloc];
}


@end
