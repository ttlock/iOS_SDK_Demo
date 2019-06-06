//
//  Gateway1AddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "Gateway1AddViewController.h"
#import "RoundCornerButton.h"
#import "UserModel.h"
#import <TTLockGateway/TTLockGateway.h>

@interface Gateway1AddViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) BOOL fillInfomation;
@property (nonatomic, strong) UITextField *wifiPasswordTextField;
@property (nonatomic, strong) UITextField *userPwdTextField;
@property (nonatomic, strong) NSString * wifiName;

@end

@implementation Gateway1AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _wifiName = [TTLockGateway getSSID];
    if (_wifiName.length == 0) {
        [self.view showToast:LS(@"Please connect to the wireless network first")];
    }
    
    [self _setupView];
    [self _loadData];
}

- (void)_setupView{
    self.tableView.tableFooterView = [UIView new];
    
}

- (void)_loadData{
    _dataArray = @[@[@{@"WiFi":@""},@{LS(@"WiFi password"):LS(@"Please enter the password for WiFi")},@{LS(@"Account password"):LS(@"Please enter your account password")}]];
}

- (void)nextButtonClick{
    if (_wifiName.length == 0
        || _wifiPasswordTextField.text.length == 0
        || _userPwdTextField.text.length == 0) {
        [self.view showToast:LS(@"Empty data")];
        return;
    }
    
    _fillInfomation = YES;
 
    {//set tableBackgroundView
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.tableView.backgroundView = backgroundView;
        
        NSString *imageName =   @"G1Introduce";
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [imageView sizeToFit];
        [self.view addSubview:imageView];
        
        UILabel *describeLabel = [UILabel new];
        describeLabel.numberOfLines = 0;
        describeLabel.textAlignment = NSTextAlignmentCenter;
        describeLabel.text = LS(@"Press and hold the gateway reset button. When the red and green lights flash alternately, click “Add”");
        [self.view addSubview:describeLabel];
        
        RoundCornerButton *addButton = [RoundCornerButton buttonWithTitle:LS(@"Add") cornerRadius:4 borderWidth:0.5];
        [addButton addTarget:self action:@selector(gatewayAddButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addButton];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(imageView.frame.size);
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).inset(30);
        }];
        [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.view.bounds.size.width - 40);
            make.centerX.equalTo(self.view);
            make.top.equalTo(imageView.mas_bottom).offset(40);
        }];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(describeLabel);
            make.height.mas_equalTo(50);
            make.top.equalTo(describeLabel.mas_bottom).offset(60);
        }];
    }
    
    [self.tableView reloadData];
}

- (void)gatewayAddButtonClick{
 
    WS(weakSelf);
    MBProgressHUD *hud = [self.view showProgress:@"0%"];

    NSMutableDictionary *ginfoDic = [NSMutableDictionary new];
    ginfoDic[@"SSID"] = _wifiName;
    ginfoDic[@"wifiPwd"] = _wifiPasswordTextField.text;
    ginfoDic[@"uid"] = UserModel.userModel.uid;
    ginfoDic[@"userPwd"] = _userPwdTextField.text;
    [TTLockGateway initializeGatewayWithInfoDic:ginfoDic processblock:^(NSInteger process) {
        hud.progress = process/100.0;
        hud.label.text  = [NSString stringWithFormat:@"%ld%%",(long)process];
    } successBlock:^(NSString *ip, NSString *mac) {
        [weakSelf isInitSuccessWithMac:mac];
        
    } failBlock:^{
        [weakSelf.view showToast:LS(@"Failure")];
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _fillInfomation ? 0 : 1;
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
    return (_fillInfomation ) ? 0 : 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_fillInfomation ) return nil;
    
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


- (void)isInitSuccessWithMac:(NSString *)mac{
    
    [self.view showToastLoading];
    [NetUtil isInitSuccessWithGatewayNetMac:mac completion:^(id info, NSError *error) {
        if (error) {
              [self.view showToastError:error];
            return ;
        }
        [NetUtil gatewayuploadDetailWithGatewayId:info[@"gatewayId"] modelNum:nil hardwareRevision:nil firmwareRevision:nil networkName:_wifiName completion:^(id info, NSError *error) {
            if (error) {
                [self.view showToastError:error];
                return ;
            }
            
            [self.view showToast:LS(@"Success")];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[self.navigationController.childViewControllers.count - 3 ] animated:YES];
            
        }];
        
    }];
}

@end
