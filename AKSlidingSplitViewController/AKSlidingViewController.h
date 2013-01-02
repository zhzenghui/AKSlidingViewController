//
//  AKSlidingViewController.h
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import "ECSlidingViewController.h"

@class AKMasterViewController;
@class AKDetailViewController;

/**
 Deklaration eines enum (optional)
 */
enum AKViewControllerState {
	AKViewControllerStateSplit = 0, /**< If the SplitViewController is active */
	AKViewControllerStateSlide      /**< If the SlidingViewController is active */
};
typedef NSUInteger AKViewControllerState;

@interface AKSlidingViewController : ECSlidingViewController <UISplitViewControllerDelegate, UINavigationControllerDelegate>

// the main application navigation controllers for left (minor) and right (major)
@property (strong, nonatomic) UINavigationController *mainNavigationController;
@property (strong, nonatomic) UINavigationController *minorNavigationController;

@property (nonatomic, unsafe_unretained) AKViewControllerState currentState;

// is needed for supporting orientation changes
@property (nonatomic, unsafe_unretained) BOOL isRotationAllowed;
@property (nonatomic, unsafe_unretained) BOOL isSlidingAllowed;
@property (nonatomic, unsafe_unretained) BOOL shouldAddPanGestureOnNavigationBar;
@property (nonatomic, unsafe_unretained) BOOL isInterfaceOrientationChangeLocked;
@property (nonatomic, unsafe_unretained) NSUInteger lockedInterfaceOrientation;

- (UIBarButtonItem *)menuButton;

@end

/** UIViewController extension */
@interface UIViewController(SlidingViewExtension)
/** Convience method for getting access to the ECSlidingViewController instance */
- (AKSlidingViewController *)slidingViewController;
@end


/** AKSlidingViewControllerProtocol */
@protocol AKSlidingViewControllerProtocol <NSObject>

@required

@required

/**
 viewController on the mainNavigationController returns yes if rotation is possible (standard is no).
 */
- (BOOL)isRotationAllowed;

/**
 viewController on the mainNavigationController returns yes if sliding is possible (standard is no).
 */
- (BOOL)isSlidingAllowed;

/**
 viewController on the mainNavigationController returns yes if panning gesture should be automatically added.
 */
- (BOOL)shouldAddPanGestureOnNavigationBar;

@optional

/**
 Informs a viewController on the mainNavigationController about state change
 */
- (void)pushedSlidingViewController:(UIViewController *)slidingVC changedState:(AKViewControllerState)state;

@end