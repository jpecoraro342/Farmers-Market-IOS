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
+(void)getEmptyStalls;
+(void)getAllStalls;
+(void)getPostFromBeaconID:(NSString*)beaconID;
+(void)getAllPosts;
+(void)getAllBeaconPosts;
+(void)unassign:(NSString*)beaconID;
+(void)unassignAll;

@end
