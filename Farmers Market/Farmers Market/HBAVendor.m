//
//  HBAVenue.m
//  iAssign - iBeacon Assignment
//
//  Created by Joseph Pecoraro on 8/8/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendor.h"
#import "HBAVendorDetailSection.h"
#import "HBADatabaseConnector.h"

@implementation HBAVendor

-(instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary {
    self = [super init];
    if (self) {
        self.userID = [attributeDictionary objectForKey:@"userID"];
        self.stallName = [attributeDictionary objectForKey:@"stallName"];
        self.stallInfo = [attributeDictionary objectForKey:@"stallInfo"];
        self.beaconID = [attributeDictionary objectForKey:@"beaconID"];
        self.thumbURL = [attributeDictionary objectForKey:@"thumbURL"];
        self.coverPhotoURL = [attributeDictionary objectForKey:@"coverPhotoURL"];
        
        //further customization to detail sections may be added later
        self.aboutSectionDetails = [attributeDictionary objectForKey:@"about"];
        self.productsSectionDetails = [attributeDictionary objectForKey:@"products"];
        self.contactSectionDetails = [attributeDictionary objectForKey:@"contact"];
    }
    return self;
}

-(void)loadDetailSections:(void (^)())completed {
    NSString *method = @"getStallDetails";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@", method, self.beaconID];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.coverPhotoURL = [json objectForKey:@"coverPhotoURL"];
            
            NSArray *jsonArray = [json objectForKey:@"sections"];
            _detailSections = [[NSMutableArray alloc] initWithCapacity:[jsonArray count]];
            for (NSDictionary *dict in jsonArray) {
                [_detailSections addObject:[[HBAVendorDetailSection alloc] initWithAttributeDictionary:dict]];
            }
        }
        else {
            //handle connection error
        }
    }];
    [databaseConnector startConnection];
}

-(NSUInteger)hash {
    return [self.userID hash];
}

@end
