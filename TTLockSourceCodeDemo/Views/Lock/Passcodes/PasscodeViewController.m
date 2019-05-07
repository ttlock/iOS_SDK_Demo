//
//  PasscodeViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/23.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "PasscodeViewController.h"

typedef NS_ENUM(NSInteger,PasscodeAction) {
    PasscodeActionGetAdminPasscode,
    PasscodeActionModifyAdminPasscode,
    PasscodeActionCustomPasscode,
    PasscodeActionModifyPasscode,
    PasscodeActionDeletePasscode,
    PasscodeActionSetAdminErasePasscode,
    PasscodeActionGetAllValidPasscodes,
    PasscodeActionSetPasscodeVisibleSwitch,
    PasscodeActionGetPasscodeVisibleSwitch,
};

#define TEN_MINUTES 10*60

@interface PasscodeViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) LockModel *lockModel;

@property (nonatomic, strong) NSString *customAdminPasscode;
@property (nonatomic, strong) NSString *customPasscode;
@property (nonatomic, strong) NSString *modifyPasscode;
@property (nonatomic, strong) NSString *erasePasscode;

@end

@implementation PasscodeViewController

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
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Reset passcode") style:UIBarButtonItemStyleDone target:self action:@selector(resetPasscodeClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupData{
    
    NSArray *dataSection0 = @[@{LS(@"Get admin passcode"):@(PasscodeActionGetAdminPasscode)},
                              @{LS(@"Modify admin passcode"):@(PasscodeActionModifyAdminPasscode)}];
    
    NSArray *dataSection1 = @[@{LS(@"Create custom passcode"):@(PasscodeActionCustomPasscode)},
                              @{LS(@"Modify passcode"):@(PasscodeActionModifyPasscode)},
                              @{LS(@"Delete passcode"):@(PasscodeActionDeletePasscode)}];
    
    NSArray *dataSection2 = @[@{LS(@"Get all valid passcode"):@(PasscodeActionGetAllValidPasscodes)}];
    
     NSArray *dataSection3 = @[@{LS(@"Set admin erase passcode"):@(PasscodeActionSetAdminErasePasscode)}];
    
    NSArray *dataSection4 = @[@{LS(@"Get passcode visible state"):@(PasscodeActionGetPasscodeVisibleSwitch)},
                              @{LS(@"Set passcode visible state"):@(PasscodeActionSetPasscodeVisibleSwitch)},];
    
    _dataArray = @[dataSection0,dataSection1,dataSection2,dataSection3,dataSection4];
    
}

- (void)resetPasscodeClick{
    [self.view showToastLoading];
    [TTLock resetPasscodesWithLockData:_lockModel.lockData success:^(long long timestamp, NSString *passcodeInfo) {
        [self showToastAndLog:LS(@"Success")];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self showToastAndLog:errorMsg];
    }];
}

- (void)visiblePasscodeAction:(UISwitch *)visibleSwitch{
    
    BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionPasscodeVisible];
    if (!suportFunction) {
        [self showToastAndLog:TTErrorMessageInvalidCommand];
        return;
    }
    
    [self.view showToastLoading];
    [TTLock setPasscodeVisibleSwitchOn:visibleSwitch.isOn lockData:_lockModel.lockData success:^{
        [self showToastAndLog:[NSString stringWithFormat:@"Set switch %@",visibleSwitch.isOn ?  @"On":@"Close"]];
    } failure:^(TTError errorCode, NSString *errorMsg) {
        [self showToastAndLog:errorMsg];
    }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PasscodeAction action = [[_dataArray[indexPath.section][indexPath.row] allValues].firstObject integerValue];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = [_dataArray[indexPath.section][indexPath.row] allKeys].firstObject ;
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    if (action == PasscodeActionGetAdminPasscode) {
        cell.detailTextLabel.text = _lockModel.noKeyPwd;
    }else if (action == PasscodeActionModifyAdminPasscode){
        cell.detailTextLabel.text = _customAdminPasscode;
    }else if (action == PasscodeActionCustomPasscode){
        cell.detailTextLabel.text = _customPasscode;
    }else if (action == PasscodeActionModifyPasscode){
        cell.detailTextLabel.text = _modifyPasscode;
    }else if (action == PasscodeActionSetAdminErasePasscode){
        cell.detailTextLabel.text = _erasePasscode;
    }else if(action == PasscodeActionSetPasscodeVisibleSwitch){
        UISwitch *visibleSwitch = [UISwitch new];
        [visibleSwitch addTarget:self action:@selector(visiblePasscodeAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = visibleSwitch;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PasscodeAction action = [[_dataArray[indexPath.section][indexPath.row] allValues].firstObject integerValue];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (action == PasscodeActionGetAdminPasscode) {
        BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionGetAdminPasscode];
        if (!suportFunction) {
            [self showToastAndLog:TTErrorMessageInvalidCommand];
            return;
        }
        [self.view showToastLoading];
        [TTLock getAdminPasscodeWithLockData:_lockModel.lockData success:^(NSString *adminPasscode) {
            [self showToastAndLog:LS(@"Success")];
            self.lockModel.noKeyPwd = adminPasscode;
            [self.tableView reloadData];
        } failure:^(TTError errorCode, NSString *errorMsg) {
            [self showToastAndLog:errorMsg];
        }];
    }else if (action == PasscodeActionModifyAdminPasscode){
        NSString *message = [self passcodeLimitMessage];
        [self presentAlertControllerWithTitle:cell.textLabel.text message:message placeholder:LS(@"Please enter new admin passcode") completion:^(NSString *text) {
            [self.view showToastLoading];
            [TTLock modifyAdminPasscode:text lockData:self.lockModel.lockData success:^{
                self.customAdminPasscode = text;
                [self.tableView reloadData];
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }];
       
    }else if (action == PasscodeActionCustomPasscode){
        NSString *message = [self passcodeLimitMessage];
        [self presentAlertControllerWithTitle:cell.textLabel.text message:message placeholder:LS(@"Please enter custom passcode") completion:^(NSString *text) {
            [self.view showToastLoading];
            long long startDate = [[NSDate date] timeIntervalSince1970] * 1000;
            long long endDate = ([[NSDate date] timeIntervalSince1970] + TEN_MINUTES) * 1000;
            [TTLock createCustomPasscode:text startDate:startDate endDate:endDate lockData:self.lockModel.lockData success:^{
                self.customPasscode = text;
                [self showToastAndLog:LS(@"Success")];
                [self.tableView reloadData];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }];
    }else if (action == PasscodeActionModifyPasscode){
        NSString *message = [self passcodeLimitMessage];
        [self presentAlertControllerWithTitle:cell.textLabel.text message:message placeholder1:LS(@"Please enter original passcode") placeholder2:LS(@"Please enter new passcode") completion:^(NSString *oldPasscode,NSString *newPasscode) {
            [self.view showToastLoading];
            long long startDate = [[NSDate date] timeIntervalSince1970] * 1000;
            long long endDate = ([[NSDate date] timeIntervalSince1970] + TEN_MINUTES * 2) * 1000;
            [TTLock modifyPasscode:oldPasscode newPasscode:newPasscode startDate:startDate endDate:endDate lockData:self.lockModel.lockData success:^{
                self.modifyPasscode = newPasscode;
                [self.tableView reloadData];
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }];
    }else if (action == PasscodeActionDeletePasscode){
        NSString *message = [self passcodeLimitMessage];
        [self presentAlertControllerWithTitle:cell.textLabel.text message:message placeholder:LS(@"Please enter the passcode you want to delete") completion:^(NSString *text) {
            [self.view showToastLoading];
            [TTLock deletePasscode:text lockData:self.lockModel.lockData success:^{
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }];
        
    }else if (action == PasscodeActionSetAdminErasePasscode){
        BOOL suportFunction = [TTUtil getLockTypeWithLockVersion:_lockModel.lockVersion] <= TTLockTypeV2Scene2;
        if (!suportFunction) {
            [self showToastAndLog:TTErrorMessageInvalidCommand];
            return;
        }
       NSString *message = [self passcodeLimitMessage];
        [self presentAlertControllerWithTitle:cell.textLabel.text message:message placeholder:LS(@"请输入管理员删除码") completion:^(NSString *text) {
            [self.view showToastLoading];
            [TTLock setAdminErasePasscode:text lockData:self.lockModel.lockData success:^{
                self.erasePasscode = text;
                [self.tableView reloadData];
                [self showToastAndLog:LS(@"Success")];
            } failure:^(TTError errorCode, NSString *errorMsg) {
                [self showToastAndLog:errorMsg];
            }];
        }];
        
        
    }else if (action == PasscodeActionSetPasscodeVisibleSwitch){
        
    }else if (action == PasscodeActionGetPasscodeVisibleSwitch){
        
        BOOL suportFunction = [TTUtil lockSpecialValue:_lockModel.specialValue suportFunction:TTLockSpecialFunctionPasscodeVisible];
        if (!suportFunction) {
            [self showToastAndLog:TTErrorMessageInvalidCommand];
            return;
        }
        
        [self.view showToastLoading];
        [TTLock getPasscodeVisibleSwitchWithLockData:_lockModel.lockData success:^(BOOL isOn) {
            [self showToastAndLog:LS(@"Success")];
        } failure:^(TTError errorCode, NSString *errorMsg) {
            [self showToastAndLog:errorMsg];
        }];
    }else if (action == PasscodeActionGetAllValidPasscodes){
        [self.view showToastLoading];
        [TTLock getAllValidPasscodesWithLockData:_lockModel.lockData success:^(NSString *passcodes) {
            [self showToastAndLog:passcodes];
        } failure:^(TTError errorCode, NSString *errorMsg) {
            [self showToastAndLog:errorMsg];
        }];
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


- (NSString *)passcodeLimitMessage{
    TTLockType lockType = [TTUtil getLockTypeWithLockVersion:_lockModel.lockVersion];
    NSString *message = nil;
    if (lockType < TTLockTypeV3) {
        message = LS(@"Passcode length 7 - 9 digits");
    }else{
        message = LS(@"Passcode length 4 - 9 digits");
    }
    return message;
}


- (void)presentAlertControllerWithTitle:(NSString *)title
                                message:(NSString *)message
                            placeholder:(NSString *)placeholder
                             completion:(void(^)(NSString *text))completion{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak UIAlertController *weakAlertController = alertController;
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:LS(@"Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = weakAlertController.textFields.firstObject;
        completion(textField.text);
    }];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = placeholder;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)presentAlertControllerWithTitle:(NSString *)title
                                message:(NSString *)message
                            placeholder1:(NSString *)placeholder1
                            placeholder2:(NSString *)placeholder2
                             completion:(void(^)(NSString *oldPasscode,NSString *newPasscode))completion{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LS(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    __weak UIAlertController *weakAlertController = alertController;
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:LS(@"Sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField1 = weakAlertController.textFields[0];
        UITextField *textField2 = weakAlertController.textFields[1];
        NSString *text1 = textField1.tag == 1 ? textField1.text : textField2.text;
        NSString *text2 = textField1.tag == 2 ? textField1.text : textField2.text;
        if (text1.length && text2.length &&completion) {
            completion(text1,text2);
        }
    }];
    
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.tag = 1;
        textField.placeholder = placeholder1;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.tag = 2;
        textField.placeholder = placeholder2;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




@end
