//
//  HBAVendorDetailAccordianViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/18/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorDetailAccordianViewController.h"
#import "HBAVendorDetailTableViewCell.h"
#import "HBAVendorDetailSection.h"
#import "HBAVendor.h"

@interface HBAVendorDetailAccordianViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) HBAVendor *vendor;

@end

@implementation HBAVendorDetailAccordianViewController {
    NSMutableArray *_cellIsSelected;
}

-(instancetype)initWithVendor:(HBAVendor *)vendor {
    self = [super init];
    if (self) {
        self.vendor = vendor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_vendor.detailSections) {
        [_vendor loadDetailSections:^{
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i = 0; i < [_vendor.detailSections count]; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView beginUpdates];
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            
            [self.tableView endUpdates];
        }];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _cellIsSelected = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];
    
    self.navigationItem.title = self.vendor.stallName;
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorDetailTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"detailCell"];
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cellIsSelected[indexPath.row] boolValue]) {
        return 182;
    }
    return 66;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.vendor.detailSections.count;
}

-(HBAVendorDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorDetailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    
    HBAVendorDetailSection *sectionDetails = [[self.vendor detailSections] objectAtIndex:indexPath.row];
    cell.titleLabel.text = sectionDetails.title;
    cell.detailTextView.text = sectionDetails.content;
    
    [cell.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f]];
    
    [cell.headerView.layer setCornerRadius:3];
    [cell.headerView.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:cell.headerView.layer.bounds cornerRadius:3] CGPath]];
    [cell.headerView.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [cell.headerView.layer setShadowOpacity:.7];
    [cell.headerView.layer setShadowRadius:2];
    [cell.headerView.layer setShadowOffset:CGSizeMake(0, -1)];
    
    cell.upArrowImageView.hidden = ![[_cellIsSelected objectAtIndex:indexPath.row] boolValue];
    cell.downArrowImageView.hidden = [[_cellIsSelected objectAtIndex:indexPath.row] boolValue];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _cellIsSelected[indexPath.row] = [NSNumber numberWithBool:![_cellIsSelected[indexPath.row] boolValue]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView beginUpdates];
    
    HBAVendorDetailTableViewCell *cell = (HBAVendorDetailTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.upArrowImageView.hidden = ![[_cellIsSelected objectAtIndex:indexPath.row] boolValue];
    cell.downArrowImageView.hidden = [[_cellIsSelected objectAtIndex:indexPath.row] boolValue];
    
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
