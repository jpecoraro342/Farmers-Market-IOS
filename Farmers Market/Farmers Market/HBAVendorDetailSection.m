//
//  HBAPost.m
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorDetailSection.h"

@implementation HBAVendorDetailSection

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary {
    self = [super init];
    if (self) {
        self.title = [attributeDictionary objectForKey:@"sectionTitle"];
        self.content = [attributeDictionary objectForKey:@"sectionContent"];
    }
    return self;
}

@end
