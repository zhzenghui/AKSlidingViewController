//
//  AKSplitViewController.m
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 23.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import "AKSplitViewController.h"
#import "AKAppDelegate.h"

@interface AKSplitViewController ()

@end

@implementation AKSplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.slidingViewController shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.slidingViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    AKAppDelegate *appDelegate = (AKAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.slidingViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
