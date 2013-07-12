//
//  CMAnimationManager.h
//  CloudMadeApi
//
//  Created by pigeon on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


#define kFTAnimationName  @"kFTAnimationName"
#define kFTAnimationType  @"kFTAnimationType"
#define kFTAnimationTypeIn  @"kFTAnimationTypeIn"
#define kFTAnimationTypeOut  @"kFTAnimationTypeOut"

#define kFTAnimationSlideOut  @"kFTAnimationNameSlideOut"
#define kFTAnimationSlideIn  @"kFTAnimationNameSlideIn"
#define kFTAnimationBackOut  @"kFTAnimationNameBackOut"
#define kFTAnimationBackIn  @"kFTAnimationNameBackIn"
#define kFTAnimationFadeOut  @"kFTAnimationFadeOut"
#define kFTAnimationFadeIn  @"kFTAnimationFadeIn"
#define kFTAnimationFadeBackgroundOut  @"kFTAnimationFadeBackgroundOut"
#define kFTAnimationFadeBackgroundIn  @"kFTAnimationFadeBackgroundIn"
#define kFTAnimationPopIn  @"kFTAnimationPopIn"
#define kFTAnimationPopOut  @"kFTAnimationPopOut"
#define kFTAnimationFallIn  @"kFTAnimationFallIn"
#define kFTAnimationFallOut  @"kFTAnimationFallOut"
#define kFTAnimationFlyOut  @"kFTAnimationFlyOut"

#define kFTAnimationCallerDelegateKey  @"kFTAnimationCallerDelegateKey"
#define kFTAnimationCallerStartSelectorKey  @"kFTAnimationCallerStartSelectorKey"
#define kFTAnimationCallerStopSelectorKey  @"kFTAnimationCallerStopSelectorKey"
#define kFTAnimationTargetViewKey  @"kFTAnimationTargetViewKey"
#define kFTAnimationIsChainedKey  @"kFTAnimationIsChainedKey"
#define kFTAnimationNextAnimationKey  @"kFTAnimationNextAnimationKey"
#define kFTAnimationPrevAnimationKey  @"kFTAnimationPrevAnimationKey"
#define kFTAnimationWasInteractionEnabledKey  @"kFTAnimationWasInteractionEnabledKey"

@interface CMAnimationManager : NSObject {
	
}


+ (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;

+ (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate 
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector;


@end