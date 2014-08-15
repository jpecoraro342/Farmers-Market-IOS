//
//  HBAPost.m
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAPost.h"

@implementation HBAPost

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary {
    self = [super init];
    if (self) {
        self.title = [attributeDictionary objectForKey:@"title"];
        self.content = [attributeDictionary objectForKey:@"content"];
        self.userID = [attributeDictionary objectForKey:@"userID"];
        self.beaconID = [attributeDictionary objectForKey:@"beaconID"];
    }
    return self;
}

-(NSUInteger)hash {
    return [self.beaconID hash];
}

@end
