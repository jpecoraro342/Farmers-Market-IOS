//
//  HBAVendorCell.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/14/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorCell.h"

#define kBlueColor [UIColor colorWithRed:15/255.0 green:189/255.0 blue:223/255.0 alpha:1.0]
#define kDarkerBlueColor [UIColor colorWithRed:77/255.0 green:183/255.0 blue:214/255.0 alpha:1.0]
#define kDarkestBlueColor [UIColor colorWithRed:60/255.0 green:143/255.0 blue:180/255.0 alpha:1.0]

@implementation HBAVendorCell

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
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setCornerRadius:5];
    [self addShadow];
    [self.layer setBorderColor:[UIColor colorWithRed:15/255.0 green:189/255.0 blue:223/255.0 alpha:.5].CGColor];
}

-(void)addShadow {
    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.layer.bounds cornerRadius:5] CGPath]];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOpacity:.7];
    [self.layer setShadowRadius:5];
    [self.layer setShadowOffset:CGSizeZero];
}

//update the shadow path (in the case of autolayout resizes, etc..)
-(void)layoutSubviews {
    [super layoutSubviews];
    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.layer.bounds cornerRadius:5] CGPath]];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
