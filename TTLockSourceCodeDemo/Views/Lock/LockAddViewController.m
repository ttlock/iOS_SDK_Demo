//
//  LockAddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/4.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LockAddViewController.h"
#import <MJExtension/MJExtension.h>
#import "NetUtil.h"

@interface LockAddViewController ()
@property (nonatomic, strong) NSMutableArray<TTScanModel *> *dataArray;
@end

@implementation LockAddViewController

MJLogAllIvars;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
}

- (void)setupView{
    self.title = LS(@"Add lock");
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
}

- (void)setupData{
    _dataArray = @[].mutableCopy;
    __block long long interval = 0;
    [TTLock startScan:^(TTScanModel *scanModel) {
        __block BOOL containScanModel = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(TTScanModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.lockMac isEqualToString:scanModel.lockMac]) {
                containScanModel = YES;
                [obj mj_setKeyValues:scanModel];
                *stop = YES;
            }
        }];
        if (!containScanModel) {
            [self.dataArray addObject:scanModel];
        }
        
        interval++;
        if (interval % 20 == 0) {
            [self.dataArray sortUsingComparator:^NSComparisonResult(TTScanModel *obj1, TTScanModel *obj2) {
                return obj1.isInited > obj2.isInited ;
            }];
            [self.tableView reloadData];
        }
    }];
}


- (void)uploadLockData:(NSString *)lockData alias:(NSString *)alias{
    [NetUtil lockInitializeWithlockAlias:alias lockData:lockData completion:^(id info, NSError *error) {
        if (error){
            [self.view showToastError:error];
            return;
        }
        [TTLock stopScan];
        NOTIF_POST(RELOAD_LOCK_TABLE_NOTIFICATION, nil);
        [self.view showToast:LS(@"Success") completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    TTScanModel *scanModel = _dataArray[indexPath.row];
    cell.textLabel.text = scanModel.lockName;
    cell.detailTextLabel.text = scanModel.isInited ? @"" : @"+";
    cell.textLabel.textColor = scanModel.isInited ? UIColor.lightGrayColor : UIColor.redColor;
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:35];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTScanModel *scanModel = self.dataArray[indexPath.row];
    if (scanModel.isInited) return;
    
    [self.view showToastLoading];
    [TTLock initLockWithDict:scanModel.mj_keyValues success:^(NSString *lockData, long long specialValue) {
#warning set the lock's alias
        NSString *alias = scanModel.lockName;
        [self uploadLockData:lockData alias:alias];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
        NSLog(@"%@",errorMsg);
    }];

}


@end
