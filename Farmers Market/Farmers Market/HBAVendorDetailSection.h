//
//  HBAPost.h
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/11/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBAVendorDetailSection : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *userID;

-(instancetype)initWithAttributeDictionary:(NSDictionary*)attributeDictionary;

@end
