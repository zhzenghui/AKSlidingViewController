//
//  AKSlidingViewController.m
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import "AKSlidingViewController.h"

#import "AKAppDelegate.h"
#import "AKMasterViewController.h"
#import "AKDetailViewController.h"
#import "AKSplitViewController.h"

const BOOL IS_INTERFACE_ORIENTATION_CHANGE_LOCKED_WHILE_MENU_OPEN = NO;

@interface AKSlidingViewController ()

// is only needed for being compatible with UISplitViewController
@property (strong, nonatomic) UIPopoverController *currentPopoverController;

@end

@implementation AKSlidingViewController

- (id)init {
    self = [super init];
    if (self) {
        
        // setting up the left and right navigationcontrollers (and its rootviewcontrollers)

        AKMasterViewController *mainRootViewController = nil;
        AKDetailViewController *detailRootViewController = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            self.currentState = AKViewControllerStateSlide; // default state for phone
            mainRootViewController = [[[AKMasterViewController alloc] initWithNibName:@"AKMasterViewController_iPhone" bundle:nil] autorelease];
            detailRootViewController = [[[AKDetailViewController alloc] initWithNibName:@"AKDetailViewController_iPhone" bundle:nil] autorelease];
            
        } else {
            
            self.currentState = AKViewControllerStateSplit; // default state for pad
            mainRootViewController = [[[AKMasterViewController alloc] initWithNibName:@"AKMasterViewController_iPad" bundle:nil] autorelease];
            detailRootViewController = [[[AKDetailViewController alloc] initWithNibName:@"AKDetailViewController_iPad" bundle:nil] autorelease];

        }

        self.mainNavigationController = [[[UINavigationController alloc] initWithRootViewController:mainRootViewController] autorelease];
        self.minorNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailRootViewController] autorelease];
        
        self.mainNavigationController.delegate = self;
    }

    self.topViewController = self.mainNavigationController;
    
    return self;
}


- (void)dealloc {
    if (IS_INTERFACE_ORIENTATION_CHANGE_LOCKED_WHILE_MENU_OPEN) {
        [self removeObserver:self forKeyPath:@"topViewIsMoved"];
    }
    
    [_minorNavigationController release];
    [_mainNavigationController release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (IS_INTERFACE_ORIENTATION_CHANGE_LOCKED_WHILE_MENU_OPEN) {
        [self addObserver:self forKeyPath:@"topViewIsMoved" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

#pragma mark - Split view

/**
 This is called if the SplitViewController leftpane hides itself.
 If this callback fires the left panning is activated then.
 */
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    // the flag indicates that this was already called. normally this method
    // shouldn't be called multiple times, there seems to be a problem with the splitViewVC !?
    if (self.currentState == AKViewControllerStateSlide) return;
    self.currentState = AKViewControllerStateSlide;
    [self notifyAllViewControllersOfChangedState:self.currentState];
    
    // configure popover controller
    self.currentPopoverController.contentViewController = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *fakeViewController = [[[UIViewController alloc] init] autorelease];
        fakeViewController.view.backgroundColor = [UIColor whiteColor];
        AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.splitViewController.viewControllers =  @[fakeViewController, self];
        
        if (self.isSlidingAllowed) {
            [self activateLeftPanning];
        }
    });
    
    
}

/**
 This is called if the SplitViewController leftpane shows itself.
 If this callback fires the left panning is deactivated then.
 */
- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    // the flag indicates that this was already called. normally this method
    // shouldn't be called multiple times, there seems to be a problem with the splitViewVC !?
    if (self.currentState == AKViewControllerStateSplit) return;
    self.currentState = AKViewControllerStateSplit;
    [self notifyAllViewControllersOfChangedState:AKViewControllerStateSplit];
    
    if (!IS_INTERFACE_ORIENTATION_CHANGE_LOCKED_WHILE_MENU_OPEN) {
        [self resetTopViewWithDuration:0.0f animations:NULL onComplete:NULL];
    }
    
    [self deactivateLeftPanning];
    self.underLeftViewController = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        // configure popover controller
        AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.splitViewController.viewControllers =  @[self.minorNavigationController, self];
    });
}

/**
 This notifies all view controllers on the right pane
 that the viewcontrollerState was changed.
 */
- (void)notifyAllViewControllersOfChangedState:(AKViewControllerState)state {
    for (UIViewController *viewController in [self.mainNavigationController viewControllers]) {
        [self notifyViewController:viewController ofChangedState:state];
    }
}

/**
 This notifies a viewcontroller on the right pane
 that the viewcontrollerState was changed.
 */
- (void)notifyViewController:(UIViewController *)viewController ofChangedState:(AKViewControllerState)state {
    SEL selector = @selector(pushedSlidingViewController:changedState:);
    if ([viewController conformsToProtocol:@protocol(AKSlidingViewControllerProtocol)] &&
        [viewController respondsToSelector:selector]) {
        [viewController performSelector:selector withObject:self withObject:(id)state];
    }
}

/**
 This sets up the left viewcontroller for the splitview.
 */
- (void)activateLeftPanning {
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color (should be done by view controller).
    self.mainNavigationController.view.layer.shadowOpacity = 0.75f;
    self.mainNavigationController.view.layer.shadowRadius = 10.0f;
    self.mainNavigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    // set left view controller and activate panning (should be done by view controller)
    self.underLeftViewController = self.minorNavigationController;
    [self.mainNavigationController.navigationBar addGestureRecognizer:self.panGesture];
    [self setDisableOverPanning:YES];
    [self setAnchorRightRevealAmount:300.0f];
    [self setUnderLeftWidthLayout:ECFixedRevealWidth];
    
    if (self.shouldAddPanGestureOnNavigationBar && [self.panGesture view] == nil) {
        [self.mainNavigationController.navigationBar addGestureRecognizer:self.panGesture];
    }

    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    self.shouldAllowUserInteractionsWhenAnchored = !isIPhone;
    self.shouldAddPanGestureRecognizerToTopViewSnapshot = isIPhone;
}

/**
 Resets shadows and leftPane (if sliding not possible)
 */
- (void)deactivateLeftPanning {
    // reset all shadows
    self.mainNavigationController.view.layer.shadowOpacity = 0.0f;
    self.mainNavigationController.view.layer.shadowRadius = 0.0f;
    
    // reset left view controller
    self.underLeftViewController = nil;
    [self.mainNavigationController.navigationBar removeGestureRecognizer:self.panGesture];
}

- (void)toggleTopView:(id)sender {
    [(UIBarButtonItem *)sender setEnabled:NO];
    if (self.topViewIsMoved) {
        [self resetTopViewWithDuration:0.25f animations:NULL onComplete:^{
            [(UIBarButtonItem *)sender setEnabled:YES];
        }];
    } else {
        [self anchorTopViewTo:ECRight withDuration:0.25f animations:NULL onComplete:^{
            [(UIBarButtonItem *)sender setEnabled:YES];
        }];
    }
}

/**
 This observes the isOffScreen property of the ECSlidingViewController.
 If 'isOffScreen' is enabled the interface orientation is locked then.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"topViewIsMoved"]) {
        BOOL isTopViewOffScreenNow = [[change objectForKey:@"new"] boolValue];
        self.isInterfaceOrientationChangeLocked = isTopViewOffScreenNow;
    }
}

/**
 only prohibit autorotating if 'isRotationAllowed' and 'isInterfaceOrientationChangeLocked'
 */
- (BOOL)shouldAutorotate {
    return !(self.isRotationAllowed && self.isInterfaceOrientationChangeLocked);
}

/**
 This method is called after rotation and remembers the last interface orientation (which can be locked then).
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    self.lockedInterfaceOrientation = toInterfaceOrientation;
}

/**
 This organizes the supported orientations of the application. If the mainVC does not allow
 rotation then portrait (iPhone) or landscape mode (iPad) is enforced. If rotation is supported
 then the current orientation can be locked by setting 'isInterfaceOrientationChangeLocked' to true.
 */
- (NSUInteger)supportedInterfaceOrientations {

    if (self.isRotationAllowed) {
        if (self.isInterfaceOrientationChangeLocked) {
            return self.lockedInterfaceOrientation;
        } else {
            return UIInterfaceOrientationMaskAll;
        }
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            return UIInterfaceOrientationMaskPortrait;
        } else {
            return UIInterfaceOrientationMaskLandscape;
        }
    }
}

/*
 * This switches off the orientation change on iOS 5.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
    (UIInterfaceOrientationIsLandscape(orientation)) :
    (orientation == UIInterfaceOrientationPortrait);
}

/**
 After a new viewController is shown in the mainNavigationController
 this is called to check if the new viewController allows rotation & sliding or not.
 */
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

    [self notifyViewController:viewController ofChangedState:self.currentState];

    // correct rotation for viewcontroller
    BOOL rotationAllowed = NO;
    if ([viewController conformsToProtocol:@protocol(AKSlidingViewControllerProtocol)] &&
        [viewController respondsToSelector:@selector(isRotationAllowed)]) {
        rotationAllowed = (BOOL)[viewController performSelector:@selector(isRotationAllowed)];
    }
    
    if (self.isRotationAllowed != rotationAllowed) {
        self.isRotationAllowed = rotationAllowed;
        
        // this is only possible beginning from ios 6
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f) {
            [self forceReorientation];
        }
    }
    
    if ([viewController conformsToProtocol:@protocol(AKSlidingViewControllerProtocol)]) {
        self.shouldAddPanGestureOnNavigationBar = (BOOL)[viewController performSelector:@selector(shouldAddPanGestureOnNavigationBar)];
    }

    // this must be done asynchronously because otherwise
    // the interface would not be loaded yet
    dispatch_async(dispatch_get_main_queue(), ^{
        // check correct sliding for viewcontroller
        BOOL slidingAllowed = NO;
        if ([viewController conformsToProtocol:@protocol(AKSlidingViewControllerProtocol)]) {
            slidingAllowed = (BOOL)[viewController performSelector:@selector(isSlidingAllowed)];
        }
        
        if (self.shouldAddPanGestureOnNavigationBar && [self.panGesture view] == nil) {
            [self.mainNavigationController.navigationBar addGestureRecognizer:self.panGesture];
        }
        
        if (self.isSlidingAllowed != slidingAllowed) {
            self.isSlidingAllowed = slidingAllowed;
            
            if (self.currentState == AKViewControllerStateSlide) {
                if (slidingAllowed) {
                    [self activateLeftPanning];
                } else {
                    
                    [self deactivateLeftPanning];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                        [self resetTopView];
                        
                    });
                }
            }
        }
        
    });
}

/**
 This is the only elegant way to force reorientation of the layout.
 */
- (void)forceReorientation {

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        // reset rootviewcontroller
        UIViewController *vc = window.rootViewController;
        window.rootViewController = nil;
        window.rootViewController = vc;

        // reset splitviewcontroller
        AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.splitViewController.viewControllers = @[self.minorNavigationController, self];
    } else {
        // reset navcontroller
        UIViewController *vc = window.rootViewController;
        window.rootViewController = nil;
        window.rootViewController = vc;

        // reset view of navcontroller
        UIView *view = [window.subviews objectAtIndex:0];
        [view removeFromSuperview];
        [window addSubview:view];
    }

}

- (UIBarButtonItem *)menuButton {
    return [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mainmenu"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleTopView:)] autorelease];
}

@end
