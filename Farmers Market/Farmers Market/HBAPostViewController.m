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
    _listOfPosts = [[NSMutableArray alloc] initWithCapacity:[beacons count]];
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
            [_listOfBeacons addObject:updateBeacon];
            [_beaconDictionary setObject:updateBeacon forKey:updateBeacon.identifier];
            NSLog(@"Beacon Created: %@", updateBeacon.name);
        }
        
        [updateBeacon updateBeaconWithCLBeacon:beacon];
        
        if (![_dictOfPosts objectForKey:updateBeacon.identifier]) {
            NSString *method = @"getPostFromBeaconID";
            NSString *postData = [NSString stringWithFormat:@"method=%@&params[]=%@", method, updateBeacon.identifier];
            HBADatabaseConnector *databaseConnector = [[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
                if (!error) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    HBAPost *post = [[HBAPost alloc] initWithAttributeDictionary:dict];
                    [_listOfPosts addObject:post];
                    [_dictOfPosts setObject:post forKey:updateBeacon.identifier];
                }
                else {
                }
            }];
            [databaseConnector startConnection];
        } else {
            [_listOfPosts addObject:[_dictOfPosts objectForKey:updateBeacon.identifier]];
        }
    }
    [self.collectionView reloadData];
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
