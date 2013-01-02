//
//  AKAppDelegate.h
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKSlidingViewController;
@class AKSplitViewController;

@interface AKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AKSplitViewController *splitViewController;
@property (strong, nonatomic) AKSlidingViewController *slidingViewController;

@end
