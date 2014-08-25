//
//  HBAAppDelegate.h
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/12/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HBAVendorViewController;

@interface HBAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HBAVendorViewController *mainViewController;

@end
