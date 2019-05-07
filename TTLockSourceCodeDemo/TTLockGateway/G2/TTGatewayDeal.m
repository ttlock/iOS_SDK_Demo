//
//  TTGatewayDeal.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/5.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTGatewayDeal.h"
#import "TTGatewayCommandUtils.h"
#import "TTCommand.h"
#import "TTDataTransformUtil.h"
#import "TTScanModel.h"
#import "TTGatewayDeal+CenterManager.h"
#import "TTGatewayDeal+HandleResponse.h"

@interface TTGatewayDeal ()<TTSDKDelegate>


@end

@implementation TTGatewayDeal

static  TTGatewayDeal *instace;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[self alloc]createManager];
    });
    return instace;
}
- (instancetype)createManager{
     self.bleBlockDict = [NSMutableDictionary dictionary];
    [self createCentralManager];
    return self;
}
- (void)startScanGatewayWithBlock:(TTGatewayScanBlock)block{
   
    [self startScanLock];
    self.bleBlockDict[KKGATEWAYBLE_SCAN]  = block;
}
- (void)stopScanGateway{
    
    [self stopScanLock];
     [_bleBlockDict removeObjectForKey:KKGATEWAYBLE_SCAN];
    
}

- (void)connectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayConnectBlock)block{
    [self connectPeripheralWithLockMac:gatewayMac];
    self.bleBlockDict[KKGATEWAYBLE_CONNECT]  = block;

}

- (void)scanWiFiByGatewayWithBlock:(TTGatewayScanWiFiBlock)block{
    if (_isConnected == NO) {
        block(NO,nil,TTGatewayNotConnect);
        return;
    }
    self.WiFiArr = [NSMutableArray array];
    self.bleBlockDict[KKGATEWAYBLE_GET_SSID]  = block;
    [TTGatewayCommandUtils scanWiFiByGatewayWithLockMac:_currentLockMac];
  
}
// @param infoDic
//key:SSID      type:NSString
//key:wifiPwd   type:NSString  (不能有中文）
//key:uid       type:NSNumber
//key:userPwd   type:NSString
//key:companyId  type:NSNumber
//key:branchId  type:NSNumber
//key:debugMode type:NSNumber
//key:plugName  type:NSString
//key:ishoneywell  type:NSNumber
- (void)initializeGatewayWithInfoDic:(NSDictionary *)infoDic block:(TTInitializeGatewayBlock)block{
    if (_isConnected == NO) {
        block(nil,TTGatewayNotConnect);
        return;
    }
    TTGatewayInitModel *model =  [TTGatewayInitModel new];
    model.SSID = infoDic[@"SSID"];
    model.wifiPwd = infoDic[@"wifiPwd"];
    model.uid = infoDic[@"uid"];
    model.userPwd = infoDic[@"userPwd"];
    model.companyId = infoDic[@"companyId"];
    model.branchId = infoDic[@"branchId"];
    model.debugMode = [infoDic[@"debugMode"] boolValue];
    model.plugName = [infoDic[@"plugName"] length] > 0 ? infoDic[@"plugName"] : _currentLockMac;
    model.ishoneywell = [infoDic[@"ishoneywell"] boolValue];
    self.gatewayModel = model;
     self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY]  = block;
    [TTGatewayCommandUtils configSSID:infoDic[@"SSID"] pwd:infoDic[@"wifiPwd"] lockMac:_currentLockMac];
}
- (void)upgradeGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block{
    if (_isConnected == NO) {
        block(TTGatewayNotConnect);
        return;
    }
    self.bleBlockDict[KKGATEWAYBLE_UPGRADE_GATEWAY]  = block;
    [TTGatewayCommandUtils upgradeWithLockMac:gatewayMac];
}
- (void)disconnectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block{
   
    [self cancelConnectPeripheralWithLockMac:gatewayMac];
    self.bleBlockDict[KKGATEWAYBLE_DISCONNECT]  = block;
}




@end
