//
//  FindCityWithNameTest.h
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/7/10.
//  Copyright 2010 CloudMade. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "GeoCodingRequest.h"

@interface FindCityWithNameTest : SenTestCase <ServiceRequestResult>
{
	BOOL resultsDidReceive;
	BOOL shouldFindSomething;
}

- (void) testFindCityWithName;

@end
