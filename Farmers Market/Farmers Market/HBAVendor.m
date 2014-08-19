//
//  HBAVenue.m
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/8/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendor.h"

@implementation HBAVendor

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary {
    self = [super init];
    if (self) {
        self.userID = [attributeDictionary objectForKey:@"userID"];
        self.stallName = [attributeDictionary objectForKey:@"name"];
        self.stallInfo = [attributeDictionary objectForKey:@"stallInfo"];
        self.thumbURL = [attributeDictionary objectForKey:@"thumbURL"];
    }
    return self;
}

-(NSUInteger)hash {
    return [self.userID hash];
}

@end
