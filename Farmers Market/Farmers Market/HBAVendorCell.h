//
//  HBAVendorCell.h
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/14/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBAVendorCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (weak, nonatomic) IBOutlet UILabel *vendorNameLabel;

@end
