//
//  Gateway2AddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "Gateway2AddViewController.h"
#import "RoundCornerButton.h"
#import "UserModel.h"
#import "ChooseSSIDView.h"

@interface Gateway2AddViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSString *wifiName;
@property (nonatomic, strong) UITextField *wifiPasswordTextField;
@property (nonatomic, strong) UITextField *gatewayNameTextField;
@property (nonatomic, strong) UITextField *userPwdTextField;
@property (nonatomic, strong) NSString *uid;
@end

@implementation Gateway2AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _wifiName = [TTGateway getSSID];
    [self _setupView];
    [self _loadData];
}

- (void)_setupView{
    self.tableView.tableFooterView = [UIView new];
    
}

- (void)_loadData{
    _dataArray = @[@[@{@"WiFi":@""},@{LS(@"WiFi password"):LS(@"Please enter the password for WiFi")},@{LS(@"gateway Name"):LS(@"Please enter gateway name")},@{LS(@"Account password"):LS(@"Please enter your account password")}]];
}

- (void)nextButtonClick{

    if (_wifiName.length == 0
        || _wifiPasswordTextField.text.length == 0
        || _userPwdTextField.text.length == 0
        || _gatewayNameTextField.text == 0) {
        [self.view showToast:LS(@"Empty data")];
        return;
    }
    [self.view showToastLoading];
    NSMutableDictionary *ginfoDic = [NSMutableDictionary new];
    ginfoDic[@"SSID"] = _wifiName;
    ginfoDic[@"wifiPwd"] = _wifiPasswordTextField.text;
    ginfoDic[@"uid"] = UserModel.userModel.uid;
    ginfoDic[@"userPwd"] = _userPwdTextField.text;
    ginfoDic[@"gatewayName"]= _gatewayNameTextField.text;
    [TTGateway initializeGatewayWithInfoDic:ginfoDic block:^(TTSystemInfoModel *systemInfoModel, TTGatewayStatus status) {
        
        if (status == TTGatewayNotConnect || status == TTGatewayDisconnect) {
            [self notConnect];
            return ;
        }
        if (status == TTGatewaySuccess) {
            [TTGateway disconnectGatewayWithGatewayMac:self.gatewayMac block:nil];
             [self isUploadSuccess:systemInfoModel];
            return;
        }
        if (status == TTGatewayWrongSSID) {
            [self.view showToast:LS(@"WiFi name error")];
            return;
        }
        if (status == TTGatewayWrongSSID) {
            [self.view showToast:LS(@"WiFi password error")];
            return;
        }
         [self.view showToast:LS(@"Failure")];
    }];
  
}
- (void)notConnect{
    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3] animated:YES];
     [self.view showToast:LS(@"Connection timed out, exited add mode")];
}
- (void)isUploadSuccess:(TTSystemInfoModel *)systemInfoModel{
    [self.view showToastLoading];
    [NetUtil isInitSuccessWithGatewayNetMac:self.gatewayMac completion:^(id info, NSError *error) {
        if (error) {
            [self.view showToastError:error];
            return ;
        }
        [NetUtil gatewayuploadDetailWithGatewayId:info[@"gatewayId"] modelNum:systemInfoModel.modelNum hardwareRevision:systemInfoModel.hardwareRevision firmwareRevision:systemInfoModel.firmwareRevision networkName:_wifiName completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            
            [self.view showToast:LS(@"Success")];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count - 5 ] animated:YES];
            
        }];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = [_dataArray[indexPath.section][indexPath.row] allKeys].firstObject;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    if (indexPath.row == 0 && indexPath.row == 0) {
        cell.detailTextLabel.text  = _wifiName;
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (_wifiPasswordTextField == nil) {
            _wifiPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            _wifiPasswordTextField.textAlignment = NSTextAlignmentRight;
            _wifiPasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
            _wifiPasswordTextField.placeholder = [_dataArray[indexPath.section][indexPath.row] allValues].firstObject;
        }
        cell.accessoryView = _wifiPasswordTextField;
    }
    
    if (indexPath.section == 0 && indexPath.row == 2){
        if (_gatewayNameTextField == nil) {
            _gatewayNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            _gatewayNameTextField.textAlignment = NSTextAlignmentRight;
            _gatewayNameTextField.keyboardType = UIKeyboardTypeDefault;
            _gatewayNameTextField.placeholder = [_dataArray[indexPath.section][indexPath.row] allValues].firstObject;
        }
        
        cell.accessoryView = _gatewayNameTextField;
    }
    if (indexPath.section == 0 && indexPath.row == 3){
        if (_userPwdTextField == nil) {
            _userPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            _userPwdTextField.textAlignment = NSTextAlignmentRight;
            _userPwdTextField.keyboardType = UIKeyboardTypeDefault;
            _userPwdTextField.placeholder = [_dataArray[indexPath.section][indexPath.row] allValues].firstObject;
        }
        
        cell.accessoryView = _userPwdTextField;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return  100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
   

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    line.backgroundColor = RGB(200, 200, 200);
    [footerView addSubview:line];
    
    RoundCornerButton *footButton = [RoundCornerButton buttonWithTitle:LS(@"Next") cornerRadius:4 borderWidth:0.5];
    footButton.frame = CGRectMake(20, 50, tableView.frame.size.width - 20 * 2, 50);
    [footButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:footButton];
    
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @" ";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ChooseSSIDView *SSIDview = [[ChooseSSIDView alloc]init];
        [TTGateway  scanWiFiByGatewayWithBlock:^(BOOL isFinished, NSArray *WiFiArr, TTGatewayStatus status) {
            if (status == TTGatewayNotConnect || status == TTGatewayDisconnect ) {
                [self notConnect];
                [SSIDview dismiss];
                return ;
            }
            
            if (WiFiArr.count > 0) {
                NSMutableArray *arr = [NSMutableArray arrayWithArray:WiFiArr];
                if (isFinished == YES) {
                    SSIDview.testActivityIndicator.hidden = YES;
                }
                SSIDview.ssidArr = [NSArray arrayWithArray:arr];
                [SSIDview.ssidTableView reloadData];
                
            }
        }];
        WS(weakSelf);
        SSIDview.chooseSSIDBlock = ^(NSString *SSID) {
            weakSelf.wifiName = SSID;
            [weakSelf.tableView reloadData];
        };
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
