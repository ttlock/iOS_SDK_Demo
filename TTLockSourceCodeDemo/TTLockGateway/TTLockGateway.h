//
//  TTSmartLinkLock.h
//  TTLockDemo
//
//  Created by wjjxx on 17/3/23.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTGatewayScanModel.h"

typedef enum {
    TTGatewayConnectTimeout,
    TTGatewayConnectSuccess,
    TTGatewayConnectFail,
}TTGatewayConnectStatus;

typedef enum {
    TTGatewaySuccess = 0,
    TTGatewayFail = 1,
    TTGatewayWrongSSID = 3,
    TTGatewayWrongWifiPassword = 4,
    TTGatewayWrongCRC = -1,
    TTGatewayWrongAeskey = -2,
    TTGatewayNotConnect = -3,
    TTGatewayDisconnect = -4,
}TTGatewayStatus;

@interface TTLockGateway : NSObject
/**
 *  Get the name of the wireless network SSID for the current connection. If returned nil, the current mobile phone is not connected to the wireless network.
 */
+ (NSString *)getSSID;

#pragma mark --- G2
typedef void(^TTGatewayScanBlock)(TTGatewayScanModel *model);
typedef void(^TTGatewayConnectBlock)(TTGatewayConnectStatus connectStatus);
typedef void(^TTGatewayScanWiFiBlock)(BOOL isFinished, NSArray *WiFiArr,TTGatewayStatus status);
typedef void(^TTGatewayBlock)(TTGatewayStatus status);
typedef void(^TTInitializeGatewayBlock)(NSDictionary *infoDic,TTGatewayStatus status);

//扫描
+ (void)startScanGatewayWithBlock:(TTGatewayScanBlock)block;
//停止扫描
+ (void)stopScanGateway;
//连接网关
+ (void)connectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayConnectBlock)block;
//取消连接
+ (void)disconnectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;
//获取网关附近WiFi
+ (void)scanWiFiByGatewayWithBlock:(TTGatewayScanWiFiBlock)block;
//初始化（添加）网关
+ (void)initializeGatewayWithInfoDic:(NSDictionary *)infoDic block:(TTInitializeGatewayBlock)block;
+ (void)upgradeGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;

#pragma mark --- G1

typedef void(^TTSmartLinkProcessBlock)(NSInteger process);

typedef void(^TTSmartLinkSuccessBlock)(NSString *ip,NSString *mac);
/**
 *  Fail Block
 *
 *  Connection timeout, please confirm whether the gateway is in the add state.
 */
typedef void(^TTSmartLinkFailBlock)(void);

/**
   Start configuration (method two)

 @param infoDic   key:SSID      type:NSString
                  key:wifiPwd   type:NSString  (no Chinese)
                  key:uid       type:NSNumber
                  key:userPwd   type:NSString
 @param pblock    Process Block
 @param sblock    Success Block
 @param fblock    Fail Block
 */
+(void)startWithInfoDic:(NSDictionary*)infoDic processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock;

@end
