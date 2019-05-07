//
//  KeyTableViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeyTableViewController.h"
#import "KeyViewController.h"


@interface KeyTableViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) LockModel *lockModel;
@end

@implementation KeyTableViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self loadData];
}

- (void)loadData{
    [self.view showToastLoading];
    [NetUtil keyListWithLockId:_lockModel.lockId pageIndex:1 completion:^(id info, NSError *error) {
        if (error){
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        self.dataArray = [KeyModel mj_objectArrayWithKeyValuesArray:info];
        [self.tableView reloadData];
    }];
}

- (void)setupView{
    self.title = LS(@"Ekey List");

    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Reset Ekey") style:UIBarButtonItemStylePlain target:self action:@selector(resetEkeyClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
   
}

- (void)resetEkeyClick{
    [self.view showToastLoading];
    [TTLock resetEkeyWithLockData:_lockModel.lockData success:^{
        [NetUtil resetEKeyWithLockId:self.lockModel.lockId completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            [self loadData];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KeyModel *keyModel = self.dataArray[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = keyModel.lockAlias;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    KeyViewController *vc = [[KeyViewController alloc] initWithKeyModel:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
