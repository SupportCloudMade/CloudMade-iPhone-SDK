/*
 * Copyright 2009 CloudMade.
 *
 * Licensed under the GNU Lesser General Public License, Version 3.0;
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.gnu.org/licenses/lgpl-3.0.txt
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "PlaceMarker.h"


#define DROPPED_TOUCH_MOVED_EVENTS_RATIO  (0.8)
#define ZOOM_IN_TOUCH_SPACING_RATIO       (0.75)
#define ZOOM_OUT_TOUCH_SPACING_RATIO      (1.5)


@implementation PlaceMarker

@synthesize delegate;
@synthesize location;
@synthesize nID;
@synthesize bDragable;

@synthesize fLongitude;
@synthesize fLatitude;
@synthesize routingPoint;


- (id) init
{
	//UIImage *image = [UIImage imageNamed:@"balloon.png"];
	//UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"p_flag_green.png"]];
	UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"000.png"]];
	
	if(image!=nil)
	{
		[super initWithFrame:CGRectMake(0, 0, [image size].width, [image size].height)];
		//self.image = image;
	    //self.multipleTouchEnabled = YES;
	    self.userInteractionEnabled = YES;
		self.bDragable = TRUE;
		self.routingPoint = UNDEFINED_POINT;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return self;
}


-(void) setMarker:(float)x :(float) y 
{
	[self setCenter:CGPointMake(x,y)];
	PLog(@"%s marker %f,%f\n",__FUNCTION__,self.center.x,self.center.y);	
}

- (void)dealloc {
	[super dealloc];
}


- (void) touchesBeginEvent:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) tochesMovedEvent:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) moveMap:(float) x :(float) y
{
	CGPoint pCenter = self.center;
	pCenter.x-=x;
	pCenter.y-=y;	
	[self setCenter:pCenter];
//	[self setCenter:CGPointMake(x,y)];	
}


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    touchMovedEventCounter = 0;
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) 
	{
        case 1:
		{
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            [self setPanningModeWithLocation:[touch locationInView:self]];
        } break;
	}
           
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	//[super touchesMoved:touches withEvent:event];
	// Tricky procedure which was stolen from another application but it looks like it's working fine
	// Without this trick we have many fake callings of this function  	
	if (++touchMovedEventCounter % (int)(1.0 / (1.0 - DROPPED_TOUCH_MOVED_EVENTS_RATIO)))
        return;
    
	if(!self.bDragable)
		return;
	
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
	{
        case 1: {
            if (! [self isPanning])
			{
                [self reset];
                break;
            }
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint currentLocation = [touch locationInView:self];
            float dX = (currentLocation.x - lastTouchLocation.x);
            float dY = (currentLocation.y - lastTouchLocation.y);
			[self moveMap:-dX :-dY];
        };
	}
            
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	PLog(@"B - %s\n",__FUNCTION__);
	UITouch *touch = [[event allTouches] anyObject];
	id del = delegate;		
	switch (touch.tapCount)
	{
		case 1:
			{
				if(delegate)
				{
					if([del respondsToSelector:@selector(markerWasClicked:)])			
						[delegate markerWasClicked:self]; 
				}
				touchMovedEventCounter = 0;
				PLog(@"\ntouchMovedEventCounter = %d\nClick!!!\n\n", touchMovedEventCounter);
				[self reset];	
			}
			break;
			
		case 2:
			break;
	/*		
		case 2:
			
			if(delegate)
			{
				if([del respondsToSelector:@selector(markerWasDbClicked:)])			
					[delegate markerWasDbClicked:self]; 
			}
			PLog(@"\nMarker was markerWasDbClicked!!!\n\n");					
			[self reset];				
			break;
	*/ 
		default:
	//		if(location.strID)
			{
				if([del respondsToSelector:@selector(markerWasMoved:)])
					[delegate markerWasMoved:self];	
			}
			break;
	}
	PLog(@"E - %s\n",__FUNCTION__);	
/*	
	id del = delegate;	
	if(!touchMovedEventCounter)
	{
		if(delegate)
		{
			if([del respondsToSelector:@selector(markerWasClicked:)])			
				[delegate markerWasClicked:self]; 
		}
	    PLog(@"\ntouchMovedEventCounter = %d\nClick!!!\n\n", touchMovedEventCounter);
		[self reset];	
	}
	else
	{
		if(location.strID)
		{
			if([del respondsToSelector:@selector(markerWasMoved:)])
				[delegate markerWasMoved:self];	
		}
	}
*/ 
}
	
- (void) setPanningModeWithLocation:(CGPoint)_location
{
    lastTouchLocation = _location;
    lastTouchSpacing = -1;
}

- (BOOL) isPanning
{
    return lastTouchLocation.x > 0 ? YES : NO;
}

- (void) reset
{
	lastTouchLocation = CGPointMake(-1, -1);
	lastTouchSpacing = -1;
}

-(void) setMarkerImage:(UIImage*) image
{
	//[super initWithFrame:CGRectMake(0, 0, [image size].width, [image size].height)];
	//self.contentMode = UIViewContentModeRedraw;
	super.bounds = CGRectMake(0, 0, [image size].width, [image size].height);
	PLog(@"image width = %d height = %d\n",[image size].width,[image size].height);
	self.image = image;
}

-(void) setLocation:(Location*) loc
{
	location = loc;
	self.bDragable = (loc.bStaticPlace)?FALSE:TRUE;
}

@end
