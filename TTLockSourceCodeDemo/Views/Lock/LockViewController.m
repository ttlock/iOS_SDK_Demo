//
//  LockViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/4.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LockViewController.h"
#import "KeyViewController.h"
#import "ICCardTableViewController.h"
#import "PasscodeViewController.h"
#import "FingerprintTableViewController.h"
#import "LockUpgradeViewController.h"
#import "KeypadTableViewController.h"

typedef NS_ENUM(NSInteger,LockAction) {
    LockActionEkey,
    LockActionPasscode,
    LockActionICCard,
    LockActionFingerprint,
    LockActionUpgradeSystem,
    LockActionWirelessKeypad,
    LockActionOperationLog,
    LockActionGetElectricQuantity,
    LockActionSetTime,
    LockActionGetTime,
    LockActionSetNB,
    LockActionGetLockSystemInfo,
    LockActionGetSpecialValue,
    LockActionGetLockSwitchSate,
    LockActionSetAutomaticLockingPeriodicTime,
    LockActionGetAutomaticLockingPeriodicTime,
    LockActionSetRemoteUnlcokSwitch,
    LockActionGetRemoteUnlcokSwitch,
    LockActionSetAudio,
    LockActionGetAudio,
    LockActionConfigPassageMode,
    LockActionGetPassageMode,
    LockActionDeletePassageMode,
    LockActionClearPassageMode,
};

@interface LockViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) LockModel *lockModel;

@property (nonatomic, strong) UISwitch *audioSwitch;
@property (nonatomic, strong) UISwitch *remotUnlockSwitch;
@end

@implementation LockViewController

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
}

- (void)setupView{
    self.title = _lockModel.lockAlias;
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Reset lock") style:UIBarButtonItemStyleDone target:self action:@selector(resetLockClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupData{
    NSArray *dataSection0 = @[@{LS(@"Ekey"):@(LockActionEkey)},
                              @{LS(@"Passcode"):@(LockActionPasscode)},
                              @{LS(@"IC card"):@(LockActionICCard)},
                              @{LS(@"Fingerprint"):@(LockActionFingerprint)}];
    
    NSArray *dataSection1 = @[@{LS(@"Wireless Keypad"):@(LockActionWirelessKeypad)}];
    
    NSArray *dataSection2 = @[@{LS(@"Lock upgrade"):@(LockActionUpgradeSystem)}];
    
    NSArray *dataSection3 = @[@{LS(@"Get lock log"):@(LockActionOperationLog)},
                              @{LS(@"Get electric quantity"):@(LockActionGetElectricQuantity)},
                              @{LS(@"Get lock special value"):@(LockActionGetSpecialValue)},
                              @{LS(@"Get lock version"):@(LockActionGetLockSystemInfo)},
                              @{LS(@"Get lock state"):@(LockActionGetLockSwitchSate)}];
    
    NSArray *dataSection4 = @[@{LS(@"Get lock time"):@(LockActionGetTime)},
                              @{LS(@"Set lock time"):@(LockActionSetTime)}];
    
    NSArray *dataSection5 = @[@{LS(@"Set lock NB-IoT"):@(LockActionSetNB)}];
    
    NSArray *dataSection6 = @[@{LS(@"Get remote unlock switch state"):@(LockActionGetRemoteUnlcokSwitch)},
                              @{LS(@"Set remote unlock switch state"):@(LockActionSetRemoteUnlcokSwitch)}
                              ];
    
    NSArray *dataSection7 = @[@{LS(@"Get lock audio switch state"):@(LockActionGetAudio)},
                              @{LS(@"Set lock audio switch state"):@(LockActionSetAudio)}];
    
    NSArray *dataSection8 = @[@{LS(@"Get automatic locking periodic time"):@(LockActionGetAutomaticLockingPeriodicTime)},
                              @{LS(@"Set automatic locking periodic time"):@(LockActionSetAutomaticLockingPeriodicTime)}];
    
    NSArray *dataSection9 = @[@{LS(@"Set passage mode"):@(LockActionConfigPassageMode)},
                              @{LS(@"Get passage mode"):@(LockActionGetPassageMode)},
                              @{LS(@"Delete passage mode"):@(LockActionDeletePassageMode)},
                              @{LS(@"Clear passage mode"):@(LockActionClearPassageMode)}];
    
    
    _dataArray = @[dataSection0,
                   dataSection1,
                   dataSection2,
                   dataSection3,
                   dataSection4,
                   dataSection5,
                   dataSection6,
                   dataSection7,
                   dataSection8,
                   dataSection9];
}

- (void)resetLockClick{
    
    [self.view showToastLoading];
    [TTLock resetLockWithLockData:_lockModel.lockData success:^{
        [NetUtil deleteLockWithId:self.lockModel.lockId completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            NOTIF_POST(RELOAD_LOCK_TABLE_NOTIFICATION, nil);
            [self.view showToast:LS(@"Delete") completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

- (void)audioSwitchAction:(UISwitch *)audioSwitch{
    BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionAudioSwitch];
    if (!suportFunction) {
        [self showToastAndLog:TTErrorMessageInvalidCommand];
        return;
    }
    
    [self.view showToastLoading];
    [TTLock setAudioSwitchOn:audioSwitch.isOn lockData:_lockModel.lockData success:^{
        [self showToastAndLog:LS(@"Success")];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self showToastAndLog:errorMsg];
    }];
}

- (void)remotUnlockSwitchAction:(UISwitch *)remotUnlockSwitch{
    BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionRemoteUnlockSwicth];
    if (!suportFunction) {
        [self showToastAndLog:TTErrorMessageInvalidCommand];
        return;
    }
    
    [self.view showToastLoading];
    [TTLock setRemoteUnlockSwitchOn:YES lockData:_lockModel.lockData success:^(long long specialValue) {
        [self showToastAndLog:[NSString stringWithFormat:@"SpecialValue:%lld", specialValue]];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self showToastAndLog:errorMsg];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = [self.dataArray[indexPath.section][indexPath.row] allKeys].firstObject;
    cell.accessoryView = nil;
    
    LockAction action = [[[_dataArray[indexPath.section][indexPath.row] allValues] firstObject] integerValue];
    if (action <= LockActionWirelessKeypad) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (action == LockActionSetAudio){
        if (_audioSwitch == nil) {
            _audioSwitch = [UISwitch new];
            _audioSwitch.on = YES;
            [_audioSwitch addTarget:self action:@selector(audioSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.accessoryView = _audioSwitch;
    }else if(action == LockActionSetRemoteUnlcokSwitch){
        if (_remotUnlockSwitch == nil) {
            _remotUnlockSwitch = [UISwitch new];
            _remotUnlockSwitch.on = YES;
            [_remotUnlockSwitch addTarget:self action:@selector(remotUnlockSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.accessoryView = _remotUnlockSwitch;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LockAction action = [[[_dataArray[indexPath.section][indexPath.row] allValues] firstObject] integerValue];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        [self.view showToastLoading];
    }
    
    switch (action) {
        case LockActionEkey:
        {
            KeyViewController *vc = [[KeyViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionPasscode:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionPasscode];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            PasscodeViewController *vc = [[PasscodeViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionICCard:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionICCard];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            ICCardTableViewController *vc = [[ICCardTableViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionFingerprint:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionFingerprint];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            FingerprintTableViewController *vc = [[FingerprintTableViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionOperationLog:
        {
            [TTLock  getOperationLogWithType:TTOperateLogTypeLatest lockData:_lockModel.lockData success:^(NSString *operateRecord) {
                [self showToastAndLog:operateRecord];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
        case LockActionUpgradeSystem:
        {
            LockUpgradeViewController *vc = [[LockUpgradeViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionWirelessKeypad:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionWirelessKeypad];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            KeypadTableViewController *vc = [[KeypadTableViewController alloc] initWithLockModel:_lockModel];
            vc.title = cell.textLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LockActionSetTime:
        {
            long long timeValue = [[NSDate date] timeIntervalSince1970] * 1000;
            [TTLock setLockTimeWithTimestamp:timeValue lockData:_lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
          
        case LockActionGetTime:
        {
            [TTLock getLockTimeWithLockData:_lockModel.lockData success:^(long long lockTime) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:lockTime/1000];
                NSString *text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle];
                [self showToastAndLog:text];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
        case LockActionGetElectricQuantity:
        {
            [TTLock getElectricQuantityWithLockData:_lockModel.lockData success:^(NSInteger electricQuantity) {
                NSString *text = [NSString stringWithFormat:@"Success \n 🔋%ld%%",(long)electricQuantity];
                [self showToastAndLog:text];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
        
        case LockActionSetNB:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionNBIoT];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
#warning set serverAddress and port
//            ip = "117.60.157.137";
//            nbOperator = 46011;
//            port = 5683;
//
//            ip = "112.13.167.63";
//            nbOperator = 46000;
//            port = 5683;
            [TTLock setNBServerAddress:@"117.60.157.137" portNumber:@"5683" lockData:_lockModel.lockData success:^(NSInteger electricQuantity) {
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
        case LockActionGetLockSystemInfo:
        {
            [TTLock getLockSystemInfoWithLockData:_lockModel.lockData success:^(TTSystemInfoModel *systemModel) {
                [self showToastAndLog: systemModel.mj_JSONString];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
        case LockActionGetSpecialValue:
        {
            [TTLock getLockSpecialValueWithLockData:_lockModel.lockData success:^(long long specialValue) {
                NSString *text = [NSString stringWithFormat:@"Success\n SpecialValue:%lld",specialValue];
                [self showToastAndLog:text];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionGetLockSwitchSate:
        {
       
            [TTLock getLockSwitchStateWithLockData:_lockModel.lockData success:^(TTLockSwitchState state) {
                [self showToastAndLog:[NSString stringWithFormat:@"Success \n TLockSwitchState: %ld", (long)state]];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionSetAutomaticLockingPeriodicTime:
        {
            
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionAutoLock];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            // 20 sec
            [TTLock setAutomaticLockingPeriodicTime:20 lockData:_lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionGetAutomaticLockingPeriodicTime:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionAutoLock];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            [TTLock getAutomaticLockingPeriodicTimeWithLockData:_lockModel.lockData success:^(int currentTime, int minTime, int maxTime) {
                [self showToastAndLog:[NSString stringWithFormat:@"Success\n currentTime:%d minTime: %d  maxTime:%d", currentTime,minTime,maxTime]];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionSetRemoteUnlcokSwitch:
            [self.view hideToast];
            break;
            
        case LockActionGetRemoteUnlcokSwitch:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionRemoteUnlockSwicth];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            [TTLock getRemoteUnlockSwitchWithLockData:_lockModel.lockData success:^(BOOL isOn) {
                [self showToastAndLog:[NSString stringWithFormat:@"Success\n switch: %@", isOn ? @"open" : @"close"]];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionSetAudio:
            [self.view hideToast];
            break;
            
        case LockActionGetAudio:
        {
            BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionAudioSwitch];
            if (!suportFunction) {
                [self showToastAndLog:TTErrorMessageInvalidCommand];
                return;
            }
            [TTLock getAudioSwitchWithLockData:_lockModel.lockData success:^(BOOL isOn) {
                [self showToastAndLog:[NSString stringWithFormat:@"Success\n switch: %@", isOn ? @"open" : @"close"]];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionConfigPassageMode:
        {
            
            int startMinutes = 8 * 60;  // ☀️ 08:00
            int endMinutes = 17 * 60; // 🌜 17:00
            NSArray *weekly = @[@1,@2,@3,@4,@5,@6,@7];
            NSArray *monthly = @[@1,@2,@20,@31];
           
            [TTLock configPassageModeWithType:TTPassageModeTypeWeekly weekly:weekly monthly:nil startDate:startMinutes endDate:endMinutes lockData:_lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
        case LockActionGetPassageMode:
        {
            [TTLock getPassageModesWithLockData:_lockModel.lockData success:^(NSString *passageModes) {
                [self showToastAndLog:[NSString stringWithFormat:@"%@\n%@",LS(@"Success"),passageModes]];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;

        case LockActionDeletePassageMode:
        {
            [TTLock setPrintLog:YES];
            NSArray *weekly = @[@6,@7];
            NSArray *monthly = @[@20,@31];
            [TTLock deletePassageModeWithType:TTPassageModeTypeWeekly weekly:weekly monthly:nil lockData:_lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;

        case LockActionClearPassageMode:
        {
            [TTLock clearPassageModeWithLockData:_lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }
            break;
            
            
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @" ";
}

#pragma mark - Private
- (void)showToastAndLog:(NSString *)toast {
    [self.view showToast:toast];
    NSLog(@"%@",toast);
}
@end
