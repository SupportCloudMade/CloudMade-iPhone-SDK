//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.h
//  ___PROJECTNAME___
//
//  Created by user on 11/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ___PROJECTNAMEASIDENTIFIER___ViewController;

@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ___PROJECTNAMEASIDENTIFIER___ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ___PROJECTNAMEASIDENTIFIER___ViewController *viewController;

@end

