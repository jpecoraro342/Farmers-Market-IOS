//
//  HBAConnectionTester.m
//  iAssign + iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAConnectionTester.h"
#import "HBADatabaseConnector.h"

@implementation HBAConnectionTester

+(void)assign:(NSString*)beaconID userID:(NSString *)userID
{
    NSString *method = @"assign";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@&params[]=%@", method, beaconID, userID];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)getEmptyStalls
{
    NSString *method = @"getEmptyStalls";
    NSString *postData = [NSString stringWithFormat:@"method=%@", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)getAllStalls
{
    NSString *method = @"getAllStalls";
    NSString *postData = [NSString stringWithFormat:@"method=%@", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)getPostFromBeaconID:(NSString*)beaconID
{
    NSString *method = @"getPostFromBeaconID";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@", method, beaconID];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)getAllPosts
{
    NSString *method = @"getAllPosts";
    NSString *postData = [NSString stringWithFormat:@"method=%@", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)getAllBeaconPosts
{
    NSString *method = @"getAllBeaconPosts";
    NSString *postData = [NSString stringWithFormat:@"method=%@", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)unassign:(NSString*)beaconID
{
    NSString *method = @"unassign";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@", method, beaconID];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)unassignAll
{
    NSString *method = @"unassignAll";
    NSString *postData = [NSString stringWithFormat:@"method=%@", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            
        }
        else {
            [self alertUserOfErrorWithError:error];
        }
    }];
    [databaseConnector startConnection];
}

+(void)alertUserOfErrorWithError:(NSError*)error {
    NSLog(@"An Error Occurred: %@\n\n", error);
    [self createAlertViewWithMessage:error.localizedDescription];
}

+(void)createAlertViewWithMessage:(NSString*)message {
    [[[UIAlertView alloc] initWithTitle:@"Could Not Complete Request" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
