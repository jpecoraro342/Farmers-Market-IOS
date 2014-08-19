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

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *stallName;
@property (nonatomic, copy) NSString *stallInfo;
@property (nonatomic, copy) NSString *thumbURL;
@property (nonatomic, copy) NSString *coverPhotoURL;

@property (nonatomic, strong) UIImage *stallThumb;

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary;

@end
