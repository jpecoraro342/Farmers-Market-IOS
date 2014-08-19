//
//  HBAVendorDetailTableViewCell.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/18/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorDetailTableViewCell.h"

@implementation HBAVendorDetailTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void)customInit {
    //[self.headerView.layer setCornerRadius:3];
    //[self addHeaderShadow];
}

//this is not working...
-(void)addHeaderShadow {
    [self.headerView.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.headerView.layer.bounds cornerRadius:3] CGPath]];
    [self.headerView.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [self.headerView.layer setShadowOpacity:.7];
    [self.headerView.layer setShadowRadius:3];
    [self.headerView.layer setShadowOffset:CGSizeMake(0, -3)];
}

//update the shadow path (in the case of autolayout resizes, etc..)
-(void)layoutSubviews {
    [super layoutSubviews];
    [self.headerView.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.headerView.layer.bounds cornerRadius:3] CGPath]];
}


@end
