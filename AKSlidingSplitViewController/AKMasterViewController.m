//
//  AKMasterViewController.m
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import "AKMasterViewController.h"

#import "AKDetailViewController.h"
#import "AKSlidingViewController.h"
#import "AKMaster2ViewController.h"
#import "AKDetail2ViewController.h"
#import "AKAppDelegate.h"

@interface AKMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation AKMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@::viewDidAppear",NSStringFromClass([self class]));
}

- (IBAction)revealMenu:(id)sender
{
    [[(AKAppDelegate *)[[UIApplication sharedApplication] delegate] slidingViewController] anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{

    AKMaster2ViewController *mainRootViewController = nil;
    AKDetail2ViewController *detailRootViewController = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        mainRootViewController = [[[AKMaster2ViewController alloc] initWithNibName:@"AKMasterViewController_iPhone" bundle:nil] autorelease];
        detailRootViewController = [[[AKDetail2ViewController alloc] initWithNibName:@"AKDetailViewController_iPhone" bundle:nil] autorelease];
        
    } else {
        
        mainRootViewController = [[[AKMaster2ViewController alloc] initWithNibName:@"AKMasterViewController_iPad" bundle:nil] autorelease];
        detailRootViewController = [[[AKDetail2ViewController alloc] initWithNibName:@"AKDetailViewController_iPad" bundle:nil] autorelease];
        
    }

    AKSlidingViewController *slidingViewController = [(AKAppDelegate *)[[UIApplication sharedApplication] delegate] slidingViewController];
    [slidingViewController.mainNavigationController pushViewController:mainRootViewController animated:YES];
    [slidingViewController.minorNavigationController pushViewController:detailRootViewController animated:YES];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }


    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = _objects[indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[[AKDetailViewController alloc] initWithNibName:@"AKDetailViewController_iPhone" bundle:nil] autorelease];
	    }
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        self.detailViewController.detailItem = object;
    }
}

# pragma mark - AKSlidingViewController delegate

- (BOOL)isRotationAllowed {
    return YES;
}

- (BOOL)isSlidingAllowed {
    return YES;
}

- (void)pushedSlidingViewController:(UIViewController *)slidingVC changedState:(AKViewControllerState)state {
    switch (state) {
        case AKViewControllerStateSplit:
            self.navigationItem.leftBarButtonItem = nil; break;
        default:
            self.navigationItem.leftBarButtonItem = [[(AKAppDelegate *)[[UIApplication sharedApplication] delegate] slidingViewController] menuButton]; /*self.editButtonItem;*/ break;
    }
}

- (BOOL)shouldAddPanGestureOnNavigationBar {
    return YES;
}

@end
