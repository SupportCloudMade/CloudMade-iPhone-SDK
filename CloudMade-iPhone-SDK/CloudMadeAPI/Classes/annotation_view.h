#import "RMMarkerAdditions.h"

- (void) tapOnMarker: (RMMarker*) marker 
{
 NSString* poiName = poi.name?poi.name:poi.synthesizedName;
 [marker addAnnotationViewWithTitle:poiName];
}