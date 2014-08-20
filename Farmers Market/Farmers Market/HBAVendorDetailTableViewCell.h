//
//  HBAVendorDetailTableViewCell.h
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/18/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAVendorDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *downArrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *upArrowImageView;

@end
