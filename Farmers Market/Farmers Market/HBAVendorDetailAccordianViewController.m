//
//  HBAVendorDetailAccordianViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/18/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorDetailAccordianViewController.h"
#import "HBAVendorDetailTableViewCell.h"

@interface HBAVendorDetailAccordianViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HBAVendorDetailAccordianViewController {
    NSMutableArray *_cellIsSelected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _cellIsSelected = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorDetailTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"detailCell"];
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cellIsSelected[indexPath.row] boolValue]) {
        return 180;
    }
    return 62;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(HBAVendorDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorDetailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = @"About";
            break;
        }
        case 1: {
            cell.titleLabel.text = @"Products";
            break;
        }
        case 2: {
            cell.titleLabel.text = @"Contact Us";
            break;
        }
        default:
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _cellIsSelected[indexPath.row] = [NSNumber numberWithBool:![_cellIsSelected[indexPath.row] boolValue]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
