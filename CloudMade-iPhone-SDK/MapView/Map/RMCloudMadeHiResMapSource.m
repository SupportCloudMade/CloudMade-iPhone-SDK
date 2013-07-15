//
//  RMCloudMadeHiResMapSource.m
//  MapView
//
//  Created by CloudMade Inc. on 11/25/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import "RMCloudMadeHiResMapSource.h"

#define kDefaultCloudMadeSize 256

@implementation RMCloudMadeHiResMapSource
@synthesize styleId;

// Method returns TileSide to set up tiles layer
// and Preformats style ID to request hi-res or regular tiles respectively
- (NSInteger) setupTileScale: (NSUInteger) cmStyleId
{
	NSInteger tileSide = kDefaultCloudMadeSize;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		NSInteger screenScale = (NSInteger) [[UIScreen mainScreen] scale];
		if (screenScale == 2) { // hi-res detected
			styleId = [[NSString stringWithFormat: @"%u@2x", cmStyleId] retain];
			tileSide /= screenScale;
			[self setMaxZoom: self.maxZoom + 1.0];
			[tileProjection setMaxZoom: self.maxZoom];
		} else {
			styleId = [[NSString stringWithFormat: @"%u", cmStyleId] retain];
		}
	}
	return tileSide;
}

- (id) initWithAccessKey:(NSString *)developerAccessKey
			 styleNumber:(NSUInteger)styleNumber;
{
	if (self = [super initWithAccessKey: developerAccessKey styleNumber: styleNumber])
	{
		NSInteger tileSide = [self setupTileScale: styleNumber];
		[self setTileSideLength: tileSide];
		return self;
	}
	return nil;

}

- (NSString*) tileURL: (RMTile) tile
{
	NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f", 
			  self, tile.zoom, self.minZoom, self.maxZoom);
	NSAssert(accessToken,@"CloudMade access token must be non-empty");
	return [NSString stringWithFormat:@"http://tile.cloudmade.com/%@/%@/%d/%d/%d/%d.png?token=%@",
			accessKey,
			styleId,
			kDefaultCloudMadeSize, tile.zoom, tile.x, tile.y,accessToken];	
}

-(NSString*) uniqueTilecacheKey
{
	return [NSString stringWithFormat:@"CloudMadeMaps%@", styleId];
}



@end
