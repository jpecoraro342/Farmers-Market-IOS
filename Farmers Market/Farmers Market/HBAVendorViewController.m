//
//  HBAVendorViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/14/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorViewController.h"
#import "HBAVendorDetailViewController.h"
#import "HBADatabaseConnector.h"
#import "HBAVendorCell.h"
#import "HBAVendor.h"
#import "SWRevealViewController.h"

@interface HBAVendorViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HBAVendorViewController {
    NSMutableArray *_listOfVendors;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadVendors];
    
    self.navigationItem.title = @"Farmer's Market";
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburgerIcon"] style:UIBarButtonItemStyleBordered target:[self revealViewController] action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorCard" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"vendorCell"];

    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_listOfVendors count];
}

-(HBAVendorCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"vendorCell" forIndexPath:indexPath];
    
    cell.vendorNameLabel.text = [_listOfVendors[indexPath.row] name];
    cell.vendorImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg", indexPath.row+1]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorDetailViewController *detail = [[HBAVendorDetailViewController alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}

-(void)loadVendors {
    NSString *method = @"getAllStalls";
    NSString *postData = [NSString stringWithFormat:@"method=%@&params=\"\"", method];
    [[[HBADatabaseConnector alloc] initWithURLString:kMobileAPI andPostData:postData completionBlock:^(NSMutableData *data, NSError *error) {
        if (!error) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *jsonArray = [response objectForKey:@"stalls"];
            _listOfVendors = [[NSMutableArray alloc] initWithCapacity:[jsonArray count]];
            for (NSDictionary *vendor in jsonArray) {
                [_listOfVendors addObject:[[HBAVendor alloc] initWithAttributeDictionary:vendor]];
            }
            [self.collectionView reloadData];
        }
        else {

        }
    }] startConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
