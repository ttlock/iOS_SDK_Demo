//
//  BaseGatewayAddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "BaseGatewayAddViewController.h"
#import "RoundCornerButton.h"
#import "Gateway2AddViewController.h"

@interface BaseGatewayAddViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) GatewayType gatewayType;
@property (nonatomic, assign) BOOL fillInfomation;

@property (nonatomic, strong) NSString *wifi;

@property (nonatomic, strong) UITextField *wifiPasswordTextField;
@property (nonatomic, strong) UITextField *gatewayNameTextField;
@end

@implementation BaseGatewayAddViewController

- (instancetype)initWithGatewayType:(GatewayType)gatewayType{
    if (self = [super init]) {
        _gatewayType = gatewayType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupView];
    [self _loadData];
}

- (void)_setupView{
    self.tableView.tableFooterView = [UIView new];
    
}

- (void)_loadData{
    _dataArray = @[@[@{@"WiFi":@""},@{LS(@"WiFi密码"):LS(@"请输入WiFi的密码")}]];
}

- (void)nextButtonClick{
    _fillInfomation = YES;
    
    {//set tableBackgroundView
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.tableView.backgroundView = backgroundView;
        
        NSString *imageName = _gatewayType == GatewayG1 ? @"G1Introduce" : @"G2Introduce";
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [imageView sizeToFit];
        [self.view addSubview:imageView];
        
        UILabel *describeLabel = [UILabel new];
        describeLabel.numberOfLines = 0;
        describeLabel.textAlignment = NSTextAlignmentCenter;
        describeLabel.text = _gatewayType == GatewayG1 ? LS(@"长按网关重置键，红、绿灯交替闪烁时，点击”添加“") : LS(@"网关重新通电后，点击“添加”");
        [self.view addSubview:describeLabel];
        
        RoundCornerButton *addButton = [RoundCornerButton buttonWithTitle:LS(@"添加") cornerRadius:4 borderWidth:0.5];
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
    NSString *wifi = _wifi;
    NSString *wifiPassword = _wifiPasswordTextField.text;
    NSString *gatewayName = _gatewayNameTextField.text;
    
    if (_gatewayType == GatewayG2) {
        Gateway2AddViewController *vc = [[Gateway2AddViewController alloc] initWithWiFi:wifi wifiPassword:wifiPassword gatewayName:gatewayName];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self gatewayConfigWiFi:wifi wifiPassword:wifiPassword gatewayName:gatewayName];
    }
}

- (void)gatewayConfigWiFi:(NSString *)wifi wifiPassword:(NSString *)wifiPasscord gatewayName:(NSString *)gatewayName{}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _fillInfomation ? 0 : _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = [_dataArray[indexPath.section][indexPath.row] allKeys].firstObject;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (_wifiPasswordTextField == nil) {
            _wifiPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            _wifiPasswordTextField.textAlignment = NSTextAlignmentRight;
            _wifiPasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
            _wifiPasswordTextField.placeholder = [_dataArray[indexPath.section][indexPath.row] allValues].firstObject;
        }
        cell.accessoryView = _wifiPasswordTextField;
    }else if (indexPath.section == 1){
        if (_gatewayNameTextField == nil) {
            _gatewayNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            _gatewayNameTextField.textAlignment = NSTextAlignmentRight;
            _gatewayNameTextField.keyboardType = UIKeyboardTypeDefault;
            _gatewayNameTextField.placeholder = [_dataArray[indexPath.section][indexPath.row] allValues].firstObject;
        }
        
        cell.accessoryView = _gatewayNameTextField;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return (_fillInfomation || section == 0) ? 0 : 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_fillInfomation || section == 0) return nil;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    line.backgroundColor = RGB(200, 200, 200);
    [footerView addSubview:line];
    
    RoundCornerButton *footButton = [RoundCornerButton buttonWithTitle:LS(@"下一步") cornerRadius:4 borderWidth:0.5];
    footButton.frame = CGRectMake(20, 50, tableView.frame.size.width - 20 * 2, 50);
    [footButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:footButton];
    
    return footerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @" ";
}
@end
