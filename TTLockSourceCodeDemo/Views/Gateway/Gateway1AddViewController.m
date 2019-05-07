//
//  Gateway1AddViewController.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/26.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "Gateway1AddViewController.h"
#import "TTLockGateway.h"
#import "UserModel.h"

@interface Gateway1AddViewController ()

@end

@implementation Gateway1AddViewController

- (void)gatewayConfigWiFi:(NSString *)wifi wifiPassword:(NSString *)wifiPasscord gatewayName:(NSString *)gatewayName{
    MBProgressHUD *hud = [self.view showProgress:@"0%%"];
    NSDictionary *dict = @{@"SSID":wifi,@"wifiPwd":wifiPasscord,@"uid":UserModel.userModel.uid,@"plugName":gatewayName};
    
    [TTLockGateway startWithInfoDic:dict processblock:^(NSInteger process) {
        hud.progress = process/100.0;
    } successBlock:^(NSString *ip, NSString *mac) {
        [self.view showToast:LS(@"成功") completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failBlock:^{
        [self.view showToast:LS(@"失败")];
    }];
}

@end
