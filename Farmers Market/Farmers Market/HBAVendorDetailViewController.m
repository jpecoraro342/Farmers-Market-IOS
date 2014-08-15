//
//  HBAVenderDetailViewController.m
//  Farmers Market
//
//  Created by Joseph Pecoraro on 8/14/14.
//  Copyright (c) 2014 Hatchery Lab, LLC. All rights reserved.
//

#import "HBAVendorDetailViewController.h"

@interface HBAVendorDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *aboutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productsImageView;

@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet UITextView *productsTextView;
@property (weak, nonatomic) IBOutlet UITextView *otherTextView;


@end

@implementation HBAVendorDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.navigationItem.title = @"Vendor Name Here";
    
    self.scrollView.contentSize = self.contentView.frame.size;
    
    UIBezierPath *aboutPath = [UIBezierPath bezierPathWithRect:[self.aboutTextView convertRect:self.aboutImageView.frame fromView:self.contentView]];
    UIBezierPath *productsPath = [UIBezierPath bezierPathWithRect:[self.productsTextView convertRect:self.productsImageView.frame fromView:self.contentView]];
    self.aboutTextView.textContainer.exclusionPaths = @[aboutPath];
    self.productsTextView.textContainer.exclusionPaths = @[productsPath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
