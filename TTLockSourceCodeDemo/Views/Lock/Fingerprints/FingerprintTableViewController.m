//
//  FingerprintTableViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "FingerprintTableViewController.h"
#import "FingerprintViewController.h"

@interface FingerprintTableViewController ()
@property (nonatomic, strong) LockModel *lockModel;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation FingerprintTableViewController

- (void)dealloc{NOTIF_REMV();NSLog(@"%@",NSStringFromClass([self class]));}

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
    NOTIF_ADD(RELOAD_FINGERPRINT_TABLE_NOTIFICATION, setupData);
}

- (void)setupData{
    [self.view showToastLoading];
    [NetUtil fingerprintsListWithLockId:_lockModel.lockId pageIndex:1 completion:^(id info, NSError *error) {
        if (error) {
            [self.view showToastError:error];
            return ;
        }
        [self.view hideToast];
        self.dataArray = [FingerprintModel mj_objectArrayWithKeyValuesArray:info];
        [self.tableView reloadData];
    }];
}

- (void)setupView{
    
    self.tableView.rowHeight = 65;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIButton *rightItemButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightItemButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightItemButton setTitle:@"+" forState:UIControlStateNormal];
    rightItemButton.titleLabel.font = [UIFont systemFontOfSize:35];
    [rightItemButton addTarget:self action:@selector(addFingerprintsClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemButton];
}

- (void)addFingerprintsClick{
    FingerprintViewController *vc = [[FingerprintViewController alloc] initWithLockModel:_lockModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearAllFingerprintsClick{
    [self.view showToastLoading];
    [TTLock clearAllFingerprintsWithLockData:_lockModel.lockData success:^{
        [NetUtil clearAllFingerprintsWithLockId:self.lockModel.lockId completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            
            [self setupData];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
    
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FingerprintModel *fingerprintModel = self.dataArray[indexPath.row];
    NSString *dateString = LS(@"Permanent date");
    if (fingerprintModel.endDate) {
        NSString *start = [NSDate stringWithTimevalue:fingerprintModel.startDate/1000 dateFormatter:YYYY_MM_DD_HH_MM_SS];
        NSString *end = [NSDate stringWithTimevalue:fingerprintModel.endDate/1000 dateFormatter:YYYY_MM_DD_HH_MM_SS];
        dateString = [NSString stringWithFormat:@"Date: %@   %@",start,end];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = fingerprintModel.fingerprintName;
    cell.detailTextLabel.text = dateString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FingerprintViewController *vc = [[FingerprintViewController alloc] initWithLockModel:_lockModel fingerprintModel:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    FingerprintModel *fingerprintModel = self.dataArray[indexPath.row];
    
    [self.view showToastLoading];
    [TTLock deleteFingerprintNumber:fingerprintModel.fingerprintNumber lockData:_lockModel.lockData success:^{
        [NetUtil deleteFingerprintId:fingerprintModel.fingerprintId lockId:self.lockModel.lockId byGateway:NO completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            [self.view showToast:LS(@"Success")];
            [self.dataArray removeObject:fingerprintModel];
            [self.tableView reloadData];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return _dataArray.count ? 100 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_dataArray.count == 0) return nil;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    line.backgroundColor = RGB(200, 200, 200);
    [footerView addSubview:line];
    
    UIButton *footButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, tableView.frame.size.width - 20 * 2, 50)];
    footButton.layer.borderColor = UIColor.blackColor.CGColor;
    footButton.layer.borderWidth = 0.5;
    footButton.layer.cornerRadius = 4;
    footButton.layer.masksToBounds = YES;
    [footButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [footButton setTitle:LS(@"Clear") forState:UIControlStateNormal];
    [footButton addTarget:self action:@selector(clearAllFingerprintsClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:footButton];
    
    return footerView;
}

@end
