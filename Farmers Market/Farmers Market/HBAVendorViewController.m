//
//  HBAVendorViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/14/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorViewController.h"
#import "HBAVendorDetailAccordianViewController.h"
#import "HBADatabaseConnector.h"
#import "HBAVendor.h"
#import "HBAVendorCard.h"
#import "HBABeacon.h"
#import "HBAConnectionTester.h"

#import <SDWebImage/UIImageView+WebCache.h>

@import CoreLocation;

@interface HBAVendorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation HBAVendorViewController {
    NSMutableDictionary *_vendorDictionary;
    NSMutableArray *_listOfBeacons;
    NSMutableDictionary *_beaconsDictionary;
    NSMutableDictionary *_listOfOldPositions;
    
    BOOL _finishedLoading;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self loadAllVendors];
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self loadBeacons];
    [self startMonitoringUUID];
    
    self.navigationItem.title = @"Farmer's Market";
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorCard" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"vendorCell"];

    self.automaticallyAdjustsScrollViewInsets = NO;
     
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startMonitoringUUID];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopMonitoringUUID];
}

#pragma mark Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_finishedLoading)
        return [_listOfBeacons count];
    return 0;
}

-(HBAVendorCard *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorCard *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"vendorCell" forIndexPath:indexPath];
    
    HBAVendor *vendor = [_vendorDictionary objectForKey:[_listOfBeacons[indexPath.row] identifier]];
    
    cell.backgroundColor = [UIColor colorWithRed:222/255.0f green:222/255.0f blue:222/255.0f alpha:1];
    [cell.vendorNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    cell.vendorNameLabel.text = [vendor stallName];
    [cell.vendorImage sd_setImageWithURL:[NSURL URLWithString:vendor.thumbURL] placeholderImage:nil];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorDetailAccordianViewController *detail = [[HBAVendorDetailAccordianViewController alloc] initWithVendor:[_vendorDictionary objectForKey:[_listOfBeacons[indexPath.row] identifier]]];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //Performance testing, calculate length it takes for this function to run
    NSDate *startTime = [NSDate new];
    
    //If we are still loading the stalls, we don't want to start ranging for beacons yet, this could cause issues
    if (!_finishedLoading) {
        return;
    }
    
    if (!_listOfOldPositions)
        _listOfOldPositions = [NSMutableDictionary dictionaryWithCapacity:[_listOfBeacons count]];
    
    //register all the old positions in the dictionary
    for (int i = 0; i < [_listOfBeacons count]; i++) {
        HBABeacon *beacon = _listOfBeacons[i];
        [_listOfOldPositions setObject:[NSNumber numberWithInt:i] forKey:[beacon identifier]];
    }
    
    [_listOfBeacons removeAllObjects];
    
    //update all the beacons that were found
    for (CLBeacon *beacon in beacons) {
        NSString *identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [beacon.proximityUUID UUIDString], [beacon.major integerValue], [beacon.minor integerValue]];
        HBABeacon *updateBeacon = [_beaconsDictionary objectForKey:identifier];
        if (!updateBeacon)
            break;
        [updateBeacon updateBeaconWithCLBeacon:beacon];
        [_listOfBeacons addObject:updateBeacon];
        NSLog(@"\n%@\n\n", updateBeacon);
    }

    //sort all the beacons
    [_listOfBeacons sortUsingComparator:^NSComparisonResult(HBABeacon *beacon1, HBABeacon *beacon2) {
        if (beacon1.rssi < (beacon2.rssi - 10)) {
            if (beacon2.rssi == 0) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }
        else if (beacon1.rssi > beacon2.rssi + 10) {
            //if the location is unknown, we want to return descending since it is far away.. (actually, we want to remove it from the list altogether?
            if (beacon1.rssi == 0) {
                return NSOrderedDescending;
            }
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    NSDate *collectionViewStart = [NSDate new];
    //UI updates (reordering) on collection view
    [self.collectionView reloadData];
    //this is buggy, just reload data for now
    /*[self.collectionView performBatchUpdates:^{
        //go through the list of current beacons, inserting new ones, and moving the old ones to the proper position
        NSMutableArray *insertionIndices =[[NSMutableArray alloc] init];
        for (int i = 0; i < [_listOfBeacons count]; i++) {
            HBABeacon *beacon = _listOfBeacons[i];
            NSNumber *prevPosition = [_listOfOldPositions objectForKey:[beacon identifier]] ?: nil;
            NSIndexPath *newPosition = [NSIndexPath indexPathForItem:i inSection:0];
            
            if (!prevPosition) {
                //if the previous position does not exist, this is a new item, so we need to insert it
                [insertionIndices addObject:newPosition];
            }
            else if ([prevPosition intValue] != i) {
                //the new position is not equal to the previous position. we need to move from the old position to the new position
                NSIndexPath *from = [NSIndexPath indexPathForItem:prevPosition.intValue inSection:0];
                [self.collectionView moveItemAtIndexPath:from toIndexPath:newPosition];
                
                //remove the object from the dictionary, so we can see the removed items
                [_listOfOldPositions removeObjectForKey:[beacon identifier]];
            }
        }
        //insert all the items that we accumulated in the index paths array
        [self.collectionView insertItemsAtIndexPaths:insertionIndices];
        
        //remove all the objects that are no longer in range (all the items remaining in the old positions dictionary)
        NSMutableArray *deletionIndices = [[NSMutableArray alloc] init];
        
        //remove all the items accumulated in the deletion indices
        [self.collectionView deleteItemsAtIndexPaths:deletionIndices];
        [_listOfOldPositions removeAllObjects];
        
    } completion:^(BOOL finished) {
        //[self.collectionView reloadData];
    }];*/
    
    NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];
    NSTimeInterval colElapsedTime = [collectionViewStart timeIntervalSinceNow];
    NSLog(@"Time to execute all collection view/beacon commands: %.4fmilliseconds", elapsedTime*-1000);
    NSLog(@"Time to execute collection view batch updates: %.4fmilliseconds", colElapsedTime*-1000);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@\nError: %@", region, error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

#pragma mark Private

-(void)startMonitoringUUID {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kFarmersMarketUUID] identifier:@"Farmer's Market"];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

-(void)stopMonitoringUUID {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kFarmersMarketUUID] identifier:@"Farmer's Market"];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

- (CLBeaconRegion *)beaconRegionWithItem:(HBABeacon *)item {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                    //major:item.major
                                    //minor:item.minor
                                                                      identifier:item.name];
    //beaconRegion.notifyEntryStateOnDisplay = YES;
    return beaconRegion;
}

-(void)loadBeacons {
    _listOfBeacons = [[NSMutableArray alloc] initWithCapacity:kNumberOfBeaconsInQuiver];
    _beaconsDictionary = [[NSMutableDictionary alloc] initWithCapacity:kNumberOfBeaconsInQuiver];
    for (int i = 1; i < kNumberOfBeaconsInQuiver+1; i++) {
        HBABeacon *beacon = [[HBABeacon alloc] init];
        beacon.uuid = [[NSUUID alloc] initWithUUIDString:kFarmersMarketUUID];
        beacon.major = 1;
        beacon.minor = i;
        beacon.name = [NSString stringWithFormat:@"Farmer's Market %zd-%zd", beacon.major, beacon.minor];
        [beacon updateIdentifier];
        
        //[_listOfBeacons addObject:beacon];
        [_beaconsDictionary setObject:beacon forKey:beacon.identifier];
    }
}

#pragma mark Database Methods

-(void)loadAllVendors {
    NSString *method = @"getAllStalls";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=\"\"", method];
    HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray *stalls = [response objectForKey:@"stalls"];
            _vendorDictionary = [[NSMutableDictionary alloc] initWithCapacity:[stalls count]];
            for (NSDictionary *dict in stalls) {
                HBAVendor *vendor = [[HBAVendor alloc] initWithAttributeDictionary:dict];
                [_vendorDictionary setObject:vendor forKey:vendor.beaconID];
            }
            _finishedLoading = YES;
        }
        else {
            //handle connection error
        }
    }];
    [databaseConnector startConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
