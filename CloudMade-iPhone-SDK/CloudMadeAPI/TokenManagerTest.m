//
//  TokenManagerTest.m
//  CloudMadeApi
//
//  Created by Vitalii Grygoruk on 10/7/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "TokenManagerTest.h"
#import "TokenManager.h"

@implementation TokenManagerTest

- (void) testToken
{
	TokenManager* tokenManager = [[TokenManager alloc] initWithApikey:@"d22e4b4eda4552bdbf627d145c7c90af"];
	[tokenManager requestToken];
	STAssertNotNil(tokenManager.accessToken,@"Token should not be nil");
	STAssertTrue([tokenManager.accessToken length] == 32, @"Token length is invalid"); 
}

@end
