//
//  AKMasterViewController.h
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKSlidingViewController.h"

@class AKDetailViewController;

@interface AKMasterViewController : UITableViewController <AKSlidingViewControllerProtocol>

@property (strong, nonatomic) AKDetailViewController *detailViewController;

@end
