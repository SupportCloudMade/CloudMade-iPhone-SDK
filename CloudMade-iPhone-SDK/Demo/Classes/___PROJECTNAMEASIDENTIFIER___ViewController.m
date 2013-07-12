//
//  ___PROJECTNAMEASIDENTIFIER___ViewController.m
//  ___PROJECTNAME___
//
//  Created by user on 11/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___ViewController.h"
#import "RMCloudMadeMapSource.h"

@implementation ___PROJECTNAMEASIDENTIFIER___ViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// init CloudMade tilesourse
	id cmTilesource = [[[RMCloudMadeMapSource alloc] initWithAccessKey:@"518f15c781b5484cb89f78925904b783" styleNumber:1] autorelease];
	
	// have to initialize the RMMapContents object explicitly if we want it to use a particular tilesource
	[[[RMMapContents alloc] initWithView:mapView tilesource: cmTilesource] autorelease];
	
	//Set Map For Some initial location (by Default Sydney, Australia - RouteMe author's place)
	CLLocationCoordinate2D initLocation;
	// somewhere in London...
	// Web PermLink: http://maps.cloudmade.com/?lat=51.51383&lng=-0.127523&zoom=16&styleId=1&opened_tab=0
	initLocation.longitude = -0.127523;
	initLocation.latitude  = 51.51383;
	
	// point map to location and set apropriate zoom
	[mapView moveToLatLong: initLocation];
	[mapView.contents setZoom: 16];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end
