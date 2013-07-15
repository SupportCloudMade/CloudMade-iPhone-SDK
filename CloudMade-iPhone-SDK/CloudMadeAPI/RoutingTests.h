//
//  RoutingTests.h
//  CloudMadeApi
//
//  Created by user on 10/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "GeoCodingRequest.h"
#import "CMRoutingManager.h"

@interface RoutingTests : SenTestCase <CMRoutingManagerDelegate>
{
	BOOL resultsDidReceive;
}

- (void) testRouting;
- (void) testRoutingWithTransitPoints;

@end
