//
//  GatewayTypeTableViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "GatewayTypeTableViewController.h"
#import "Gateway1AddViewController.h"
#import "GuideGatewayViewController.h"

@interface GatewayTypeTableViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GatewayTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
}

- (void)setupView{
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
}

- (void)setupData{
    _dataArray = @[@{@"G1":@"G1"},@{@"G2":@"G2"}];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    cell.imageView.image = [UIImage imageNamed:[_dataArray[indexPath.row] allValues].firstObject];
    cell.textLabel.text = [_dataArray[indexPath.row] allKeys].firstObject;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        Gateway1AddViewController *vc = [[Gateway1AddViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        GuideGatewayViewController *vc = [GuideGatewayViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
