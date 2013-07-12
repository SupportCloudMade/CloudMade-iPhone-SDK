//
//  RMMarkerAnimationManager.h
//  SponsoredPOIs
//
//  Created by user on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RMMarkerAnimationManager : NSObject
{
	BOOL _markersAppearForFirstTime;
	int  _markerCounter; // is used for animation
	id data; 
}



@property (nonatomic,assign) id data;
@property (readwrite) BOOL markersAppearForFirstTime;

@end