//
//  AKMaster2ViewController.h
//  SlidingOrderbirdTest
//
//  Created by Alexander Koglin on 22.12.12.
//  Copyright (c) 2012 Alexander Koglin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKSlidingViewController.h"

@class AKDetail2ViewController;

@interface AKMaster2ViewController : UITableViewController <AKSlidingViewControllerProtocol>

@property (strong, nonatomic) AKDetail2ViewController *detailViewController;

@end
