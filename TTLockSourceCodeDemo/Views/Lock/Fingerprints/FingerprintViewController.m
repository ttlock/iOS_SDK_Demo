//
//  FingerprintViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "FingerprintViewController.h"
#import "KMDatePicker.h"

@interface FingerprintViewController ()
@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) LockModel *lockModel;
@property (nonatomic, strong) FingerprintModel *fingerprintModel;
@property (nonatomic, assign) BOOL permanentDate;
@end

@implementation FingerprintViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
        _fingerprintModel = [FingerprintModel new];
        _permanentDate = YES;
    }
    return self;
}


- (instancetype)initWithLockModel:(LockModel *)lockModel fingerprintModel:(FingerprintModel *)fingerprintModel{
    if (self = [super init]) {
        _lockModel = lockModel;
        _fingerprintModel = fingerprintModel;
        _permanentDate = fingerprintModel.endDate == 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupData];
}

- (void)setupData{
    _dataArray = @[LS(@"Permanent date"),LS(@"Start date"),LS(@"End date")];
}

- (void)setupView{
    self.title = _fingerprintModel.fingerprintId ? _fingerprintModel.fingerprintName : LS(@"Add fingerprint");
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    line.backgroundColor = RGB(200, 200, 200);
    [tableFooterView addSubview:line];
    
    UIButton *footButton = [UIButton new];
    footButton.layer.borderColor = UIColor.blackColor.CGColor;
    footButton.layer.borderWidth = 0.5;
    footButton.layer.cornerRadius = 4;
    footButton.layer.masksToBounds = YES;
    [footButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    NSString *title = _fingerprintModel.fingerprintId ? LS(@"Sure"):LS(@"Add");
    [footButton setTitle:title forState:UIControlStateNormal];
    SEL selector = _fingerprintModel.fingerprintId ? @selector(modifyFingerprintClick) : @selector(addFingerprintClick);
    [footButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:footButton];
    self.tableView.tableFooterView = tableFooterView;
    self.tableView.rowHeight = 50;
    
    [footButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(tableFooterView).inset(20);
        make.height.mas_equalTo(50);
    }];
}

- (void)addFingerprintClick{
    if (_fingerprintModel.startDate >= _fingerprintModel.endDate && _permanentDate == NO){
        if (_fingerprintModel.startDate == 0) {
            [self.view showToast:LS(@"Please set start date")];
        }else{
            [self.view showToast:LS(@"End date must be greater than start date")];
        }
        return;
    }
    long long startDate = _permanentDate ? 0 : _fingerprintModel.startDate;
    long long endDate = _permanentDate ? 0 : _fingerprintModel.endDate;
    [self.view showToastLoading];
    [TTLock addFingerprintStartDate:startDate endDate:endDate lockData:_lockModel.lockData progress:^(TTAddFingerprintState state, NSInteger remanentPressTimes) {
        NSString *text = [NSString stringWithFormat:LS(@"Remaining compressions: %ld"),(long)remanentPressTimes];
        [self.view showToast:text];
    } success:^(NSString *fingerprintNumber) {
        [NetUtil addFingerprintNumber:fingerprintNumber name:fingerprintNumber startDate:startDate endDate:endDate byGateway:NO lockId:self.lockModel.lockId completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            NOTIF_POST(RELOAD_FINGERPRINT_TABLE_NOTIFICATION, nil);
            [self.view showToast:fingerprintNumber completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

- (void)modifyFingerprintClick{
    if (_fingerprintModel.startDate >= _fingerprintModel.endDate && _permanentDate == NO){
        if (_fingerprintModel.startDate == 0) {
            [self.view showToast:LS(@"Please set start date")];
        }else{
            [self.view showToast:LS(@"End date must be greater than start date")];
        }
        return;
    }
    long long startDate = _permanentDate ? 0 : _fingerprintModel.startDate;
    long long endDate = _permanentDate ? 0 : _fingerprintModel.endDate;
    [self.view showToastLoading];
    [TTLock modifyFingerprintValidityPeriodWithFingerprintNumber:_fingerprintModel.fingerprintNumber startDate:startDate endDate:endDate lockData:_lockModel.lockData success:^{
        [NetUtil modifyFingerprintId:self.fingerprintModel.fingerprintId startDate:startDate endDate:endDate byGateway:NO completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            NOTIF_POST(RELOAD_FINGERPRINT_TABLE_NOTIFICATION, nil);
            [self.view showToast:LS(@"Success") completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self.view showToast:errorMsg];
    }];
}

- (void)switchDateAction:(UISwitch *)switchButton{
    _permanentDate = switchButton.isOn;
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _permanentDate ? 1 : _dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = _dataArray[indexPath.row];
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(indexPath.row == 0){
        UISwitch *switchButton = [UISwitch new] ;
        [switchButton addTarget:self action:@selector(switchDateAction:) forControlEvents:UIControlEventAllEvents];
        switchButton.on = _permanentDate;
        cell.accessoryView = switchButton;
        
    }else if (indexPath.row == 1 && _permanentDate == NO && _fingerprintModel.startDate) {
        NSString *startDateString = [NSDate stringWithTimevalue:_fingerprintModel.startDate/1000 dateFormatter:YYYY_MM_DD_HH_MM_SS];
        cell.detailTextLabel.text = startDateString;
        
    }else if(indexPath.row == 2 && _permanentDate == NO && _fingerprintModel.endDate){
        NSString *endDateString = [NSDate stringWithTimevalue:_fingerprintModel.endDate/1000 dateFormatter:YYYY_MM_DD_HH_MM_SS];
        cell.detailTextLabel.text = endDateString;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1 || indexPath.row == 2) {
        __weak FingerprintViewController *weakSelf = self;
        KMDatePicker *datePicker = [[KMDatePicker alloc] initWithFrame:self.view.bounds datePickerStyle:KMDatePickerStyleYearMonthDayHourMinute complete:^(KMDatePicker *datePicker, KMDatePickerDateModel *dateModel) {
            if (indexPath.row == 1) {
                weakSelf.fingerprintModel.startDate = [[dateModel toDate] timeIntervalSince1970] * 1000;
            }else{
                weakSelf.fingerprintModel.endDate = [[dateModel toDate] timeIntervalSince1970] * 1000;
            }
            [weakSelf.tableView reloadData];
        }];
        
        [self.view addSubview:datePicker];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _fingerprintModel.fingerprintName;
}



@end
