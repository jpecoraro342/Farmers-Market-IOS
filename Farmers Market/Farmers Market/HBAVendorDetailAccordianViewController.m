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

#import <SDWebImage/UIImageView+WebCache.h>

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
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:_vendor.coverPhotoURL] placeholderImage:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _cellIsSelected = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];
    
    self.navigationItem.title = self.vendor.stallName;
    
    UINib *nib = [UINib nibWithNibName:@"HBAVendorDetailTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"detailCell"];
}

#pragma mark Tableview Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cellIsSelected[indexPath.row] boolValue]) {
        NSString *cellText;
        
        switch (indexPath.row) {
            case 0: {
                cellText = _vendor.aboutSectionDetails;
                break;
            }
            case 1: {
                cellText = _vendor.productsSectionDetails;
                break;
            }
            case 2: {
                cellText = _vendor.contactSectionDetails;
                break;
            }
        }
        
        CGSize constraint = CGSizeMake(self.tableView.frame.size.width - 10, MAXFLOAT);
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14.0] forKey:NSFontAttributeName];
        
        CGRect textsize = [cellText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        CGFloat textHeight = textsize.size.height + 20;
        
        textHeight = (textHeight < 50.0) ? 50.0 : textHeight;
        
        return textHeight + 66;
    }
    return 66;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(HBAVendorDetailTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HBAVendorDetailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = @"About";
            cell.detailTextView.text = _vendor.aboutSectionDetails;
            break;
        }
        case 1: {
            cell.titleLabel.text = @"Products";
            cell.detailTextView.text = _vendor.productsSectionDetails;
            break;
        }
        case 2: {
            cell.titleLabel.text = @"Contact";
            cell.detailTextView.text = _vendor.contactSectionDetails;
            break;
        }
    }
    
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
