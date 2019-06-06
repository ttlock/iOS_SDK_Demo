//
//  KeypadAddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/5/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "KeypadAddViewController.h"
#import "KeypadModel.h"

@interface KeypadAddViewController ()
@property (nonatomic, strong) KeypadModel *keypadModel;
@property (nonatomic, strong) LockModel *lockModel;

@property (nonatomic, strong) NSMutableArray<TTWirelessKeypadScanModel *> *dataArray;
@end

@implementation KeypadAddViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [TTWirelessKeypad stopScanKeypad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LS(@"添加无线键盘");
    self.tableView.tableFooterView = [UIView new];
    
    if ([TTLock bluetoothState] != TTBluetoothStatePoweredOn ) {
        [self.view showToast:TTErrorMessageBluetoothPoweredOff];
        return;
    }
    
    _dataArray = @[].mutableCopy;
    [TTWirelessKeypad startScanKeypadWithBlock:^(TTWirelessKeypadScanModel *model) {
        for (TTWirelessKeypadScanModel *containModel in self.dataArray) {
            if ([containModel.keypadMac isEqualToString:model.keypadMac]) {
                [self.dataArray removeObject:containModel];
                break;
            }
        }
        [self.dataArray addObject:model];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    TTWirelessKeypadScanModel *scanModel = _dataArray[indexPath.row];
    cell.textLabel.text = scanModel.keypadName;
    cell.detailTextLabel.text = @"+";
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:35];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TTWirelessKeypadScanModel *scanModel = _dataArray[indexPath.row];
    [self.view showToastLoading];
    [TTWirelessKeypad initializeKeypadWithMac:scanModel.keypadMac factorydDate:@"" block:^(long long specialValue, TTKeypadStatus status) {
        if (status != TTKeypadSuccess) {
            NSString *error = [NSString stringWithFormat:@"init keypad error ,code:%d",status];
            [self.view showToast:error];
        }else{
            NSString *wirelessKeypadName = [NSString stringWithFormat:@"Keypad-%ld",random()];
            [NetUtil addWirelessKeypadName:wirelessKeypadName number:scanModel.keypadName mac:scanModel.keypadMac specialValue:specialValue lockId:self.lockModel.lockId completion:^(id info, NSError *error) {
                if (error) {
                    [self.view showToastError:error];
                    return ;
                }
                NOTIF_POST(RELOAD_KEYPAD_TABLE_NOTIFICATION, nil);
                [self.view showToast:LS(@"Success") completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            }];
        }
    }];
}

@end
