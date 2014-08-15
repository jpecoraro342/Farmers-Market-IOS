//
//  HBAPostViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/12/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAPostViewController.h"
#import "HBADatabaseConnector.h"
#import "HBAPostCell.h"
#import "HBAPost.h"
#import "HBABeacon.h"
#import "SWRevealViewController.h"
@import CoreLocation;

@interface HBAPostViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HBAPostViewController {
    NSMutableArray *_beaconUUIDS;
    NSMutableArray *_listOfBeacons;
    NSMutableDictionary *_beaconDictionary;
    NSMutableArray *_listOfPosts;
    NSMutableDictionary *_dictOfPosts;
    NSMutableDictionary *_listOfOldPositions;
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Farmer's Market";
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburgerIcon"] style:UIBarButtonItemStyleBordered target:[self revealViewController] action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self loadBeacons];
    [self loadBeaconUUIDs];
    _dictOfPosts = [[NSMutableDictionary alloc] init];
    _listOfOldPositions = [[NSMutableDictionary alloc] init];
    
    [self startMonitoringRegions];
    
    UINib *nib = [UINib nibWithNibName:@"HBAPostCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"iBeaconCell"];
}

-(void)viewWillAppear:(BOOL)animated {
    //[self startMonitoringRegions];
}

-(void)viewWillDisappear:(BOOL)animated {
    //[self stopMonitoringRegions];
}

#pragma mark Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_listOfPosts count];
}

-(HBAPostCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAPostCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"iBeaconCell" forIndexPath:indexPath];

    cell.nameLabel.text = [_listOfPosts[indexPath.row] title];
    
    HBABeacon *beacon = _listOfBeacons[indexPath.row];
    cell.distanceLabel.text = beacon.distance;
    cell.rssiLabel.text = [NSString stringWithFormat:@"%zddb", beacon.rssi];
    
    return cell;
}

#pragma mark CLLocation Manager

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    //set up the dictionary for the old positions
    for (int i = 0; i < [_listOfBeacons count]; i++) {
        HBABeacon *item = _listOfBeacons[i];
        [_listOfOldPositions setObject:[NSNumber numberWithInt:i] forKey:[item identifier]];
    }
    
    _listOfBeacons = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in beacons) {
        //get hbabeacon for clbeacon or create it if there is none
        NSString *identifier = [NSString stringWithFormat:@"%@:%zd:%zd", [beacon.proximityUUID UUIDString], [beacon.major integerValue], [beacon.minor integerValue]];
        HBABeacon *updateBeacon = [_beaconDictionary objectForKey:identifier];
        if (!updateBeacon) {
            updateBeacon = [[HBABeacon alloc] init];
            updateBeacon.uuid = beacon.proximityUUID;
            updateBeacon.major = [beacon.major integerValue];
            updateBeacon.minor = [beacon.minor integerValue];
            updateBeacon.name = [NSString stringWithFormat:@"Farmers Market %@-%@", beacon.major, beacon.minor];
            [updateBeacon updateIdentifier];
            [_beaconDictionary setObject:updateBeacon forKey:updateBeacon.identifier];
            NSLog(@"Beacon Created: %@", updateBeacon.name);
        }
        [_listOfBeacons addObject:updateBeacon];
        [updateBeacon updateBeaconWithCLBeacon:beacon];
    }
    
    //update the order of the list of beacons
    [_listOfBeacons sortUsingComparator:^NSComparisonResult(HBABeacon *beacon1, HBABeacon *beacon2) {
        if (beacon1.rssi < (beacon2.rssi - 7)) {
            return NSOrderedDescending;
        }
        else if (beacon1.rssi > beacon2.rssi + 7) {
            //if the location is unknown, we want to return descending since it is far away.. (actually, we want to remove it from the list altogether?
            if (beacon1.rssi == 0) {
                return NSOrderedDescending;
            }
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    [self reloadPosts];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@\nError: %@", region, error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

#pragma mark Button Actions



#pragma mark Beacon Monitoring

-(void)startMonitoringRegions {
    //this is hard coded right now;
    
    CLBeaconRegion *beaconRegion = [self beaconRegionForUUID:_beaconUUIDS[0] Identifier:@"Farmer's Market"];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

-(void)stopMonitoringRegions {
    //this is hard coded right now;
    
    CLBeaconRegion *beaconRegion = [self beaconRegionForUUID:_beaconUUIDS[0] Identifier:@"Farmer's Market"];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

-(CLBeaconRegion *)beaconRegionForUUID:(NSUUID *)beaconUUID Identifier:(NSString*)identifier
{
    return [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:identifier];
}

- (CLBeaconRegion *)beaconRegionWithBeacon:(HBABeacon *)item {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                                                           major:item.major
                                                                           minor:item.minor
                                                                      identifier:item.name];
    return beaconRegion;
}

#pragma mark Algorithms, Yo

-(void)reloadPosts {
    _listOfPosts = [[NSMutableArray alloc] initWithCapacity:[_listOfBeacons count]];
    for (int i = 0; i < [_listOfBeacons count]; i++) {
        HBABeacon *updateBeacon = _listOfBeacons[i];
        if (![_dictOfPosts objectForKey:updateBeacon.identifier]) {
            NSString *method = @"getPostFromBeaconID";
            NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@", method, updateBeacon.identifier];
            HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
                if (!error) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HBAPost *post = [[HBAPost alloc] initWithAttributeDictionary:dict];
                    [_listOfPosts addObject:post];
                    [_dictOfPosts setObject:post forKey:updateBeacon.identifier];
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self collectionView:self.collectionView numberOfItemsInSection:0] - 1 inSection:0]]];
                }
                else {
                }
            }];
            [databaseConnector startConnection];
        } else {
            [_listOfPosts addObject:[_dictOfPosts objectForKey:updateBeacon.identifier]];
        }
    }
    
    [self.collectionView performBatchUpdates:^{
        for (int i = 0; i < [_listOfBeacons count]; i++) {
            HBABeacon *item = _listOfBeacons[i];
            NSNumber *prevPos = [_listOfOldPositions objectForKey:[item identifier]];
            if (!prevPos) {
                continue;
            }
            else if ([prevPos intValue] != i) {
                NSIndexPath *from = [NSIndexPath indexPathForItem:prevPos.intValue inSection:0];
                NSIndexPath *to = [NSIndexPath indexPathForItem:i inSection:0];
                [self.collectionView moveItemAtIndexPath:from toIndexPath:to];
            }
        }
    } completion:^(BOOL success) {
        [self.collectionView reloadData];
    }];
}

#pragma mark Set Up

-(void)loadBeaconUUIDs
{
    NSUUID *locationTrackerUUID = [[NSUUID alloc] initWithUUIDString:@"B30071DE-17B6-4B1E-8915-A01B2E1ABA04"];
    _beaconUUIDS = [[NSMutableArray alloc] initWithObjects:locationTrackerUUID, nil];
}

-(void)loadBeacons
{
    _listOfBeacons = [[NSMutableArray alloc] init];
    _beaconDictionary =[[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
