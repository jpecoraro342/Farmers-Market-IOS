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
        self.name = [attributeDictionary objectForKey:@"name"];
        self.identifier = [attributeDictionary objectForKey:@"userID"];
    }
    return self;
}

-(NSUInteger)hash {
    return [self.identifier hash];
}

@end
