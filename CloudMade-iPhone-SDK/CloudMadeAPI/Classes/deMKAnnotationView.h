#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "deCartaPosition.h"
//#import "deCartaPOI.h"
//#import "deCartaIcon.h"
//#import "deCartaStructuredAddress.h"

// This protocol is used to tell the MapViewController the detailedViewButton has been pressed
// so the MapViewController can then push MapAnnotationDetailedViewController
@protocol  CMAnnotationViewDelegate 
@optional  
-(void)pushMapAnnotationDetailedViewControllerDelegate:(id) sender;
@end

@interface deCartaAnnotationView : UIView {
    id                          delegate;
    CGRect                      annRect;
    CGPoint                     annotationOffset;
    UILabel                     *pinMessageLabel;  
    UILabel                     *pinPlacemarkLabel;  
    UIButton                    *detailedViewButton;
    //deCartaIcon                 *icon;
	//deCartaPOI                  *poi;
    UIImage                     *picture;
    //deCartaPosition             *position;
	NSString                    *title;
	NSString                    *subTitle;
	//deCartaStructuredAddress    *placemark;
	NSString                    *userData;
    BOOL                        annSize;
    NSTimer                     *highlightTimer;
	CGPoint					 	trianglePoint;
	BOOL						moveTriangle;
}


@property(nonatomic,assign) id <CMAnnotationViewDelegate> delegate;
@property(nonatomic, assign) CGRect annRect;
@property(nonatomic, assign) CGPoint annotationOffset;
@property(nonatomic, retain) UILabel *pinMessageLabel;
@property(nonatomic, retain) UILabel *pinPlacemarkLabel;
@property(nonatomic, retain) UIButton *detailedViewButton;
//@property(nonatomic, retain) deCartaIcon *icon;
//@property(nonatomic, retain) deCartaPOI *poi;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) UIImage *picture;
//@property (nonatomic, retain) deCartaStructuredAddress *placemark;
//@property (nonatomic, retain) deCartaPosition *position;
@property (nonatomic, retain) NSString* userData;
@property(nonatomic, assign) BOOL annSize;
@property(nonatomic, retain) NSTimer *highlightTimer;

//- (void)notifyCalloutInfo:(deCartaStructuredAddress *)_placemark;
//- (id)initBigWithId:(id) inId andIcon:(deCartaIcon *) inIcon;
//- (id)initSmallWithId:(id) inId andIcon:(deCartaIcon *) inIcon;
//- (id)initRouteWithPosition:(deCartaPosition*)_position title:(NSString*)_title;
//- (void)changePosition:(deCartaPosition*)_position;
- (IBAction) annotationButtonPressed:(id)sender;
//- (void) setNewIconInfo:(deCartaIcon *) inIcon;
- (BOOL) isEqualTo:(id) inObj;

//- (id)initWithFrame:(CGRect)frame title:(NSString*) title subtitle:(NSString*) subtitle; 
- (id)initWithFrame:(CGRect)frame title:(NSString*) _title subtitle:(NSString*) subtitle picture:(UIImage*) image;
-(void) moveTriangleToPoint:(CGPoint) point;

+(CGRect) frameForTitle:(NSString*) title subtitle:(NSString*) subTitle picture:(UIImage*) picture;

@end
