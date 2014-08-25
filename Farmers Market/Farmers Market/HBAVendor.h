//
//  HBAVenue.h
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/8/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HBABeacon;

@interface HBAVendor : NSObject <NSCoding>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *stallName;
@property (nonatomic, copy) NSString *stallInfo;
@property (nonatomic, copy) NSString *beaconID;
@property (nonatomic, copy) NSString *thumbURL;
@property (nonatomic, copy) NSString *coverPhotoURL;

@property (nonatomic, copy) NSString *aboutSectionDetails;
@property (nonatomic, copy) NSString *productsSectionDetails;
@property (nonatomic, copy) NSString *contactSectionDetails;

@property (nonatomic, strong) NSMutableArray *detailSections __deprecated;

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary;

-(void)loadDetailSections:(void(^)())completed __deprecated;

@end
