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
    NSMutableOrderedSet *_listOfBeacons;
    NSMutableDictionary *_beaconsDictionary;
    
    BOOL _finishedLoading;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self unarchiveVendors];
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
    cell.vendorInfoTextView.text = [vendor stallInfo];
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
    
    NSMutableOrderedSet *newBeacons = [[NSMutableOrderedSet alloc] init];
    NSMutableOrderedSet *itemsDeleted;
    NSMutableOrderedSet *itemsInserted;
    
    //update all the beacons that were found
    for (CLBeacon *beacon in beacons) {
        NSString *identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [beacon.proximityUUID UUIDString], [beacon.major integerValue], [beacon.minor integerValue]];
        HBABeacon *updateBeacon = [_beaconsDictionary objectForKey:identifier];
        NSInteger index = [_listOfBeacons indexOfObject:updateBeacon];
        
        if (index != NSNotFound)
            updateBeacon = [_listOfBeacons objectAtIndex:index];
        
        if (!updateBeacon)
            continue;
        [updateBeacon updateBeaconWithCLBeacon:beacon];
        
        //if there is a post for this beacon, add it to the list
        if ([_vendorDictionary objectForKey:updateBeacon.identifier])
            [newBeacons addObject:updateBeacon];

        //NSLog(@"\n%@\n\n", updateBeacon);
    }
    
    //sort all the beacons
    [newBeacons sortUsingComparator:^NSComparisonResult(HBABeacon *beacon1, HBABeacon *beacon2) {
        if (beacon1.rssi < (beacon2.rssi)) {
            if (beacon2.rssi == 0) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }
        else if (beacon1.rssi > beacon2.rssi) {
            //if the location is unknown, we want to return descending since it is far away.. (actually, we want to remove it from the list altogether?
            if (beacon1.rssi == 0) {
                return NSOrderedDescending;
            }
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    itemsDeleted = [_listOfBeacons mutableCopy];
    itemsInserted = [newBeacons mutableCopy];
    
    [itemsDeleted minusOrderedSet:newBeacons];
    [itemsInserted minusOrderedSet:_listOfBeacons];
    
    NSMutableArray *deleltionIndices = [[NSMutableArray alloc] init];
    NSMutableArray *insertionIndices = [[NSMutableArray alloc] init];
    
    //UI updates (reordering) on collection view
    //[self.collectionView reloadData];
    [self.collectionView performBatchUpdates:^{
        //delete all the items we need to delete
        for (HBABeacon *beacon in itemsDeleted) {
            NSInteger index = [_listOfBeacons indexOfObject:beacon];
            [_listOfBeacons removeObject:beacon];
            [deleltionIndices addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        [self.collectionView deleteItemsAtIndexPaths:deleltionIndices];
        
        for (HBABeacon *beacon in itemsInserted) {
            [_listOfBeacons addObject:beacon];
            NSInteger index = [_listOfBeacons indexOfObject:beacon];
            [insertionIndices addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        [self.collectionView insertItemsAtIndexPaths:insertionIndices];
        
        //figure out if we need to change the first object in our list
        NSInteger newFirstRSSI = [[newBeacons firstObject] rssi];
        NSInteger oldFirstRSSI = [[_listOfBeacons firstObject] rssi];
        
        if (newFirstRSSI > oldFirstRSSI && newFirstRSSI != 0) {
            NSUInteger oldIndex = [_listOfBeacons indexOfObject:[newBeacons firstObject]];
            NSIndexSet *index = [[NSIndexSet alloc] initWithIndex:oldIndex];
            [_listOfBeacons moveObjectsAtIndexes:index toIndex:0];
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
    } completion:^(BOOL finished) {
        //[self.collectionView reloadData];
    }];
    
    NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];
    NSLog(@"Time to execute all of that hunk of junk: %.4fmilliseconds", elapsedTime*-1000);
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
    _listOfBeacons = [[NSMutableOrderedSet alloc] initWithCapacity:kNumberOfBeaconsInQuiver];
    _beaconsDictionary = [[NSMutableDictionary alloc] initWithCapacity:kNumberOfBeaconsInQuiver];
    for (int i = 1; i < kNumberOfBeaconsInQuiver+1; i++) {
        HBABeacon *beacon = [[HBABeacon alloc] init];
        beacon.uuid = [[NSUUID alloc] initWithUUIDString:kFarmersMarketUUID];
        beacon.major = 1;
        beacon.minor = i;
        beacon.name = [NSString stringWithFormat:@"Farmer's Market %zd-%zd", beacon.major, beacon.minor];
        [beacon updateIdentifier];
        
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
            [_vendorDictionary removeObjectForKey:@"-1"];
            [self.collectionView reloadData];
            _finishedLoading = YES;
        }
        else {
            //handle connection error
        }
    }];
    [databaseConnector startConnection];
}

-(void)archiveVendors {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_vendorDictionary];
    [data writeToFile:[kBaseFilePath stringByAppendingPathComponent:@"vendors.archive"] atomically:YES];
}

-(void)unarchiveVendors {
    NSData *data = [NSData dataWithContentsOfFile:[kBaseFilePath stringByAppendingPathComponent:@"vendors.archive"]];
    _vendorDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (_vendorDictionary)
        _finishedLoading = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
