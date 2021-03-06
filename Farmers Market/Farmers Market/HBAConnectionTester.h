//
//  HBAConnectionTester.h
//  iAssign + iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAConnectionTester : NSObject

+(void)assign:(NSString*)beaconID userID:(NSString *)userID;
+(void)unassign:(NSString*)beaconID;
+(void)unassignAll;

+(void)getEmptyStalls;
+(void)getAllStalls;
+(void)getStallFromBeaconID:(NSString*)beaconID;
+(void)getStallDetails:(NSString*)userID __deprecated;
+(void)getPostFromBeaconID:(NSString*)beaconID __deprecated;
+(void)getAllPosts __deprecated;
+(void)getAllBeaconPosts __deprecated;

@end
