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

@import CoreLocation;

@interface HBAVendorViewController () <UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation HBAVendorViewController {
    NSMutableArray *_listOfVendors;
    NSMutableArray *_listOfBeacons;
    NSMutableDictionary *_beaconsDictionary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self loadBeacons];
    [self startMonitoringUUID];
    
    self.navigationItem.title = @"Farmer's Market";
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorCard" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"vendorCell"];

    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_listOfVendors count];
}

-(HBAVendorCard *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorCard *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"vendorCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:222/255.0f green:222/255.0f blue:222/255.0f alpha:1];
    [cell.vendorNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    cell.vendorNameLabel.text = [_listOfVendors[indexPath.row] stallName];
    cell.vendorImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%zd.jpg", indexPath.row+1]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //HBAVendorDetailViewController *detail = [[HBAVendorDetailViewController alloc] init];
    HBAVendorDetailAccordianViewController *detail = [[HBAVendorDetailAccordianViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSString *identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [beacon.proximityUUID UUIDString], [beacon.major integerValue], [beacon.minor integerValue]];
        HBABeacon *updateBeacon = [_beaconsDictionary objectForKey:identifier];
        [updateBeacon updateBeaconWithCLBeacon:beacon];
        NSLog(@"\n%@\n\n", updateBeacon);
    }
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
        
        [_listOfBeacons addObject:beacon];
        [_beaconsDictionary setObject:beacon forKey:beacon.identifier];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
