//
//  HBAVenue.h
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/8/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBABeacon;

@interface HBAVendor : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary;

@end
