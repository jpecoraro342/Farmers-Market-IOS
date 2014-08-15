//
//  WRPMenuViewController.m
//  Warrior Pointe
//
//  Created by Joseph Pecoraro on 8/2/14.
//  Copyright (c) 2014 Warrior Pointe, Inc. All rights reserved.
//

#import "HBAMenuViewController.h"
#import "SWRevealViewController.h"
#import "HBAVendorViewController.h"
#import "HBAPostViewController.h"

@interface HBAMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HBAMenuViewController {
    NSArray *_menuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    _menuItems = [[NSArray alloc] initWithObjects:@"Vendors Near Me", @"Posts Near Me", @"All Vendors For My Market", @"Browse Farmer's Markets", nil];
}

#pragma mark TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row < [_menuItems count]) {
        cell.textLabel.text = [_menuItems objectAtIndex:indexPath.row];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor grayColor];
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
                UINavigationController *currentNavController = (id) [self.revealViewController frontViewController];
                if ([currentNavController.topViewController isKindOfClass:[HBAVendorViewController class]]) {
                    [self.revealViewController revealToggle:self];
                }
                else {
                    [self.revealViewController pushFrontViewController:[[UINavigationController alloc] initWithRootViewController:[[HBAVendorViewController alloc] init]] animated:YES];
                }
            }
            break;
        case 1: {
            UINavigationController *currentNavController = (id) [self.revealViewController frontViewController];
            if ([currentNavController.topViewController isKindOfClass:[HBAPostViewController class]]) {
                [self.revealViewController revealToggle:self];
            }
            else {
                [self.revealViewController pushFrontViewController:[[UINavigationController alloc] initWithRootViewController:[[HBAPostViewController alloc] init]] animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
