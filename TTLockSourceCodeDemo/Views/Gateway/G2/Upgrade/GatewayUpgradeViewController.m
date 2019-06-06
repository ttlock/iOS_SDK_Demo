//
//  GatewayUpgradeViewController.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/27.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "GatewayUpgradeViewController.h"
#import "FirmwareUpdateModel.h"
#import "UserModel.h"
#import <TTLockDFU/TTLockDFU.h>

@interface GatewayUpgradeViewController ()
@property (nonatomic, strong)FirmwareUpdateModel *updateModel;
@property (nonatomic, strong)UILabel * versionTitleLabel;
@property (nonatomic, strong)UILabel * versionDetailLabel;
@property (nonatomic, strong)UIButton * bottomBtn;
@property (nonatomic,strong)UIButton * retryBtn;
@property (nonatomic,strong)UIButton * offlineBtn;
@end

@implementation GatewayUpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"Gateway upgrade");
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    [self lockUpgradeCheck];
    // Do any additional setup after loading the view.
}
- (void)createView{
    
    _versionTitleLabel = [[UILabel alloc]init];
    CGFloat fontSize = 20;
    _versionTitleLabel.font = [UIFont systemFontOfSize:fontSize];
    _versionTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_versionTitleLabel];
    
    _versionDetailLabel = [[UILabel alloc]init];
    _versionDetailLabel.font = [UIFont systemFontOfSize:15];
    _versionDetailLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_versionDetailLabel];
    
    UIButton *bottomButton = [[UIButton alloc]init];
    bottomButton.layer.borderWidth = 1;
    bottomButton.layer.borderColor = [UIColor blackColor].CGColor;
    [bottomButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:bottomButton];
    [bottomButton addTarget:self action:@selector(bottomBtnClick) forControlEvents:UIControlEventTouchUpInside];
    bottomButton.hidden = YES;
    self.bottomBtn = bottomButton;
    
    [_versionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(50 + 64);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@30);
    }];
    [_versionDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.versionTitleLabel.mas_bottom).offset(20);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(@30);
    }];
    
    [bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.versionDetailLabel.mas_bottom).offset(40);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@40);
    }];
    
}
- (void)lockUpgradeCheck{
    [self.view showToastLoading:nil];
    
    [NetUtil gatewayUpgradeCheckWithGatewayId:self.gatewayModel.gatewayId completion:^(id info, NSError *error) {
        if (error) {
            [self.view showToastError:error];
        }
        if (error == nil && [info isKindOfClass:[NSDictionary class]]) {
            [self.view hideToast];
            _updateModel =  [FirmwareUpdateModel  mj_objectWithKeyValues:info];
            [self reloadView];
        }
    }];
    
}
- (void)reloadView{
    
    // Is upgrading available: 0-No, 1-Yes, 2-Unknown
    if (_updateModel.needUpgrade.intValue == 0) {
        _versionTitleLabel.text = LS(@"Already the latest version");
        _versionDetailLabel.text = [NSString stringWithFormat:@"%@%@",LS(@"Version number:"),_updateModel.firmwareRevision];
        self.bottomBtn.hidden = YES;
    }else if (_updateModel.needUpgrade.intValue == 1){
        self.bottomBtn.hidden = NO;
        _versionTitleLabel.text = LS(@"New version");
        _versionDetailLabel.text = [NSString stringWithFormat:@"%@%@",LS(@"Version number:"),_updateModel.version];
        [self.bottomBtn setTitle:LS(@"Upgrade") forState:UIControlStateNormal];
    }else {
        self.bottomBtn.hidden = YES;
        _versionTitleLabel.text = LS(@"The gateway version is unknown. Re-add the gateway to get the version information");
    }
}
- (void)bottomBtnClick{
    
    [self.view showToastLoading:nil];
    WS(weakSelf);
    [[TTGatewayDFU shareInstance]startDfuWithClientId:TTAppkey accessToken:UserModel.userModel.accessToken gatewayId:self.gatewayModel.gatewayId gatewayMac:self.gatewayModel.gatewayMac successBlock:^(UpgradeOpration type, NSInteger process) {
        if (type == UpgradeOprationSuccess) {
            [weakSelf.view showToast:LS(@"Upgrade successed")];
           weakSelf.versionTitleLabel.text = LS(@"Already the latest version");
           weakSelf.bottomBtn.hidden = YES;
            return ;
        }
        [weakSelf.view showToastLoading:[NSString stringWithFormat:@"successBlock type%ld process%ld",(long)type,(long)process]];
       
    } failBlock:^(UpgradeOpration type, UpgradeErrorCode code) {

        weakSelf.retryBtn.hidden = NO;
        weakSelf.offlineBtn.hidden = NO;
        weakSelf.bottomBtn.hidden = YES;
        
        [weakSelf.view showToast:[NSString stringWithFormat:@"failBlock UpgradeOpration%ld UpgradeErrorCode%ld ",(long)type,(long)code]];
        
    }];
}
- (UIButton*)retryBtn{
    if (!_retryBtn) {
        UIButton *reStartBtn = [UIButton new];
        reStartBtn.layer.cornerRadius = 6;
        [reStartBtn setTitle:LS(@"Retry") forState:UIControlStateNormal];
        [reStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        reStartBtn.layer.borderWidth = 1;
        reStartBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [self.view addSubview:reStartBtn];
        _retryBtn = reStartBtn;
        [_retryBtn addTarget:self action:@selector(retryBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [reStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-40);
            make.height.equalTo(@44);
            make.bottom.equalTo(self.view.mas_bottom).offset(-80);
            make.width.equalTo(@100);
        }];
    }
    return _retryBtn;
}
- (void)retryBtnClick{
    [self.view showToastLoading:nil];
    [[TTGatewayDFU shareInstance]retryEnterUpgradeModebyNet];
    self.retryBtn.hidden = YES;
    self.offlineBtn.hidden = YES;
}
- (UIButton*)offlineBtn{
    if (!_offlineBtn) {
        UIButton *offlineBtn = [UIButton new];
        offlineBtn.layer.cornerRadius = 6;
        [offlineBtn setTitle:LS(@"Offline retry") forState:UIControlStateNormal];
        [offlineBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        offlineBtn.layer.borderWidth = 1;
        offlineBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [self.view addSubview:offlineBtn];
        _offlineBtn = offlineBtn;
         [_offlineBtn addTarget:self action:@selector(offlineBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [offlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(40);
            make.height.equalTo(@44);
            make.bottom.equalTo(self.view.mas_bottom).offset(-80);
            make.width.equalTo(@100);
        }];
    }
    return _offlineBtn;
}
- (void)offlineBtnClick{
    
     if (![[TTGatewayDFU shareInstance]paused]) {
         //如果不在升级中，需将网关重新上电
         [self.view showToastLoading:@"需将网关重新上电"];
     }
  
    [[TTGatewayDFU shareInstance]retryEnterUpgradeModebyBluetooth];
    self.retryBtn.hidden = YES;
    self.offlineBtn.hidden = YES;
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
