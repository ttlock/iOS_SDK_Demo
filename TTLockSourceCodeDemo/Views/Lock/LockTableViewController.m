//
//  LockTableViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LockTableViewController.h"
#import "LockAddViewController.h"
#import "LockViewController.h"
#import "NetUtil.h"
#import "KeyModel.h"

@interface LockTableViewController ()
@property (nonatomic, weak) LockAddViewController *addVC;
@property (nonatomic, strong) LockModel *lockModel;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation LockTableViewController

- (void)dealloc{NOTIF_REMV();}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
    
    NOTIF_ADD(RELOAD_LOCK_TABLE_NOTIFICATION, setupData);
}

- (void)setupData{
    [self.view showToastLoading];
    [NetUtil lockListWithPageIndex:1 completion:^(id info, NSError *error) {
        if (error){
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        self.dataArray = [LockModel mj_objectArrayWithKeyValuesArray:info];
        [self.tableView reloadData];
    }];
}

- (void)setupView{

    UIButton *rightItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightItemButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightItemButton setTitle:@"+" forState:UIControlStateNormal];
    rightItemButton.titleLabel.font = [UIFont systemFontOfSize:35];
    [rightItemButton addTarget:self action:@selector(addLockClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
}

- (void)addLockClick{
    LockAddViewController *vc = [LockAddViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    _addVC = vc;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KeyModel *keyModel = self.dataArray[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = keyModel.lockAlias;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"🔋%ld%%",(long)keyModel.electricQuantity];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LockViewController *vc = [[LockViewController alloc] initWithLockModel:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
