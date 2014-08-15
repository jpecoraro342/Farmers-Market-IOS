//
//  HBAPost.h
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAPost : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *beaconID;

-(instancetype)initWithAttributeDictionary:(NSDictionary*)attributeDictionary;

@end
