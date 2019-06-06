//
//  UpgradeViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/25.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LockUpgradeViewController.h"
#import "FirmwareUpdateModel.h"
#import "UserModel.h"
#import <TTLockDFU/TTLockDFU.h>

@interface LockUpgradeViewController ()
@property (nonatomic, strong) LockModel *lockModel;
@property (nonatomic, strong)FirmwareUpdateModel *updateModel;
@property (nonatomic, strong)UILabel *versionTitleLabel;
@property (nonatomic, strong)UILabel *versionDetailLabel;
@property (nonatomic, strong)UIButton * bottomBtn;
@end

@implementation LockUpgradeViewController

- (instancetype)initWithLockModel:(LockModel *)lockModel{
    if (self = [super init]) {
        _lockModel = lockModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LS(@"Lock upgrade");
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
    
    [NetUtil lockUpgradeCheckWithLockId:self.lockModel.lockId  completion:^(id info, NSError *error) {
        if (error == nil && [info isKindOfClass:[NSDictionary class]]) {
            [self.view hideToast];
            _updateModel =  [FirmwareUpdateModel  mj_objectWithKeyValues:info];
           [self reloadView];
        }
    }];
    
}
#pragma mark ----- Click the bottom button to read the information in the lock
- (void)bottomBtnClick{
    
    [self.view showToastLoading:nil];
    if (self.bottomBtn.tag == 100) {
        WS(weakSelf);
       
            [[TTLockDFU shareInstance]startDfuWithClientId:TTAppkey accessToken:UserModel.userModel.accessToken lockId:self.lockModel.lockId lockData:self.lockModel.lockData successBlock:^(UpgradeOpration type, NSInteger process) {
                if (type == UpgradeOprationSuccess) {
                    weakSelf.bottomBtn.tag = 101;
                    [weakSelf.view showToast:LS(@"Upgrade successed")];
                    [weakSelf.bottomBtn setTitle:LS(@"Check for updates") forState:UIControlStateNormal];
                    return ;
                }
                [weakSelf.view showToastLoading:[NSString stringWithFormat:@"successBlock type%ld process%ld",(long)type,(long)process]];
            } failBlock:^(UpgradeOpration type, UpgradeErrorCode code) {
                weakSelf.bottomBtn.tag = 105;
                [weakSelf.bottomBtn setTitle:LS(@"Retry") forState:UIControlStateNormal];
                [weakSelf.view showToast:[NSString stringWithFormat:@"failBlock UpgradeOpration%ld UpgradeErrorCode%ld ",(long)type,(long)code]];
            }];
     
      
    }
    if (self.bottomBtn.tag == 101) {
        [TTLock getLockSystemInfoWithLockData:self.lockModel.lockData success:^(TTSystemInfoModel *systemModel) {
            NSString * modelNum = systemModel.modelNum;
            NSString * hardwareRevision = systemModel.hardwareRevision;
            NSString * firmwareRevision = systemModel.firmwareRevision;
            [TTLock getLockSpecialValueWithLockData:self.lockModel.lockData success:^(long long specialValue) {
                [self initDataWithModelNum:modelNum hardwareRevision:hardwareRevision firmwareRevision:firmwareRevision specialValue:specialValue];;
            } failure:^(TTError errorCode, NSString *errorMsg) {
                 [self.view showToast:errorMsg];
            }];
        } failure:^(TTError errorCode, NSString *errorMsg) {
            [self.view showToast:errorMsg];
        }];
        
    }

    if (self.bottomBtn.tag == 105) {
        [[TTLockDFU shareInstance] retry];
    }
}

- (void)initDataWithModelNum:(NSString*)modelNum
            hardwareRevision:(NSString*)hardwareRevision
            firmwareRevision:(NSString*)firmwareRevision
              specialValue:(long long)specialValue{
    
    [NetUtil lockUpgradeRecheckWithLockId:self.lockModel.lockId modelNum:modelNum hardwareRevision:hardwareRevision firmwareRevision:firmwareRevision specialValue:specialValue completion:^(id info, NSError *error) {
        if (error == nil && [info isKindOfClass:[NSDictionary class]]) {
            [self.view hideToast];
            
            _updateModel =   [FirmwareUpdateModel  mj_objectWithKeyValues:info];
            [self reloadView];
            
        }
    }];
}

- (void)reloadView{
    // Is upgrading available: 0-No, 1-Yes, 2-Unknown
    if (_updateModel.needUpgrade.intValue == 0) {
        _versionTitleLabel.text = LS(@"Already the latest version");
        _versionDetailLabel.text = [NSString stringWithFormat:@"%@%@",LS(@"Version number:"),_updateModel.firmwareRevision];
        [self.bottomBtn setTitle:LS(@"Check for updates") forState:UIControlStateNormal];
        self.bottomBtn.hidden = NO;
        self.bottomBtn.tag = 101;
    }else if (_updateModel.needUpgrade.intValue == 1){
        
        self.bottomBtn.hidden = NO;
        self.bottomBtn.tag = 100;
        _versionTitleLabel.text = LS(@"New version");
        _versionDetailLabel.text = [NSString stringWithFormat:@"%@%@",LS(@"Version number:"),_updateModel.version];
        [self.bottomBtn setTitle:LS(@"Upgrade") forState:UIControlStateNormal];
    }else {
        
        self.bottomBtn.hidden = NO;
        self.bottomBtn.tag = 101;
        _versionTitleLabel.text = LS(@"Unknown lock version");
        [self.bottomBtn setTitle:LS(@"Check for updates") forState:UIControlStateNormal];
    }
}
@end
