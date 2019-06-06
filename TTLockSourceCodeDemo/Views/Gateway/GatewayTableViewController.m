//
//  GatewayTableViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "GatewayTableViewController.h"
#import "GatewayTypeTableViewController.h"
#import "GatewayModel.h"
#import "GateWayDetailViewController.h"

@interface GatewayTableViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation GatewayTableViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [self setupData];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view showToastLoading];
    [self setupData];
    [self setupView];
  
}

- (void)setupView{
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    
    UIButton *rightItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightItemButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightItemButton setTitle:@"+" forState:UIControlStateNormal];
    rightItemButton.titleLabel.font = [UIFont systemFontOfSize:35];
    [rightItemButton addTarget:self action:@selector(addGatewayClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupData{
    
    [NetUtil getGatewayListWithPageNo:1 completion:^(id info, NSError *error) {
        if (error) {
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        self.dataArray = [GatewayModel mj_objectArrayWithKeyValuesArray:info];
        [self.tableView reloadData];
    }];
}

- (void)addGatewayClick{
    [self.navigationController pushViewController:[GatewayTypeTableViewController new] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GatewayModel *gatewayModel = _dataArray[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    NSString *imageName = gatewayModel.gatewayVersion == GatewayG2 ? @"G2" : @"G1";
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.textLabel.text = gatewayModel.gatewayName;
    cell.detailTextLabel.text = gatewayModel.isOnline ? LS(@"Online") : LS(@"Offline");
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GateWayDetailViewController *vc = [GateWayDetailViewController new];
     GatewayModel *gatewayModel = _dataArray[indexPath.row];
    vc.gatewayModel = gatewayModel;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
