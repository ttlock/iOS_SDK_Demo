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
@property (nonatomic, strong) NSMutableArray<TTScanModel *> *scanModelArray;
@property (nonatomic, strong) NSArray<TTScanModel *> *dataArray;
@end

@implementation LockAddViewController


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [TTLock stopScan];
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
}

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
    NSMutableArray *scanModelArray = @[].mutableCopy;
    _scanModelArray = scanModelArray;
    [TTLock startScan:^(TTScanModel *scanModel) {
        BOOL dataArrayHasContainScanModel = NO;
        for (TTScanModel *containModel in scanModelArray) {
            if ([containModel.lockMac isEqualToString:scanModel.lockMac]) {
                dataArrayHasContainScanModel = YES;
                [containModel mj_setKeyValues:scanModel];//update model state
                break;
            }
        }
        if (!dataArrayHasContainScanModel) {
            [scanModelArray addObject:scanModel];//add new model
        }
        
        NSMutableArray *disappearDataArray = @[].mutableCopy;
        for (TTScanModel *model in scanModelArray) {
            if (model.date.timeIntervalSinceNow < -5) {
                [disappearDataArray addObject:model];
            }
        }
        [scanModelArray removeObjectsInArray:disappearDataArray];//delete objects that have not been scanned for a long time
    }];
    
    [self resetDataArrayEachSecond];
}

- (void)resetDataArrayEachSecond{
    NSSortDescriptor *sort0 = [NSSortDescriptor sortDescriptorWithKey:@"isInited" ascending:YES];
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"RSSI" ascending:NO];
    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:_scanModelArray];
    [dataArray sortUsingDescriptors:@[sort0,sort1]];
    _dataArray = dataArray;
    [self.tableView reloadData];
    
    [self performSelector:@selector(resetDataArrayEachSecond) withObject:nil afterDelay:1];
}


- (void)uploadLockData:(NSString *)lockData alias:(NSString *)alias{
    [NetUtil lockInitializeWithlockAlias:alias lockData:lockData completion:^(id info, NSError *error) {
        if (error){
#warning You should reset the lock after upload lockData failed, otherwise the lock can't be initialized again
            [TTLock resetLockWithLockData:lockData success:^{
                NSLog(@"reset lock success");
            } failure:^(TTError errorCode, NSString *errorMsg) {
                
            }];
            [self.view showToastError:error];
            return;
        }
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
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"lockMac"] = scanModel.lockMac;
    dict[@"lockName"] = scanModel.lockName;
    dict[@"lockVersion"] = scanModel.lockVersion;
    
/* Only hotel lock need to be set
 
    dict[@"hotelInfo"] = @"xxxx";
    dict[@"buildingNumber"] = @10;
    dict[@"floorNumber"] = @3;
*/

    [self.view showToastLoading];
    [TTLock initLockWithDict:dict success:^(NSString *lockData, long long specialValue) {
#warning set the lock's alias
        NSString *alias = scanModel.lockName;
        [self uploadLockData:lockData alias:alias];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
        NSLog(@"%@",errorMsg);
    }];

}


@end
