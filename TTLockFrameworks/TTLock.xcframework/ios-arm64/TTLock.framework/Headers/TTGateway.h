//
//  TTSmartLinkLock.h
//  TTLockDemo
//
//  Created by wjjxx on 17/3/23.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TTSystemInfoModel.h"

typedef NS_ENUM(NSInteger,TTGatewayType) {
    TTGateWayTypeG2 = 2,
    TTGateWayTypeG3,
    TTGateWayTypeG4,
    TTGateWayTypeG5,
    TTGateWayTypeG6,
};

@interface TTGatewayScanModel : NSObject

@property (nonatomic, strong) NSString *gatewayName;
@property (nonatomic, strong) NSString *gatewayMac;
@property (nonatomic, assign) BOOL isDfuMode;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) TTGatewayType type;

@end

@interface TTGatewayMacro : NSObject

#pragma mark --- G2
typedef NS_ENUM(NSInteger, TTGatewayConnectStatus){
    TTGatewayConnectTimeout,
    TTGatewayConnectSuccess,
    TTGatewayConnectFail,
};

typedef NS_ENUM(NSInteger, TTGatewayStatus){
    TTGatewaySuccess = 0,
    TTGatewayFail = 1,
    TTGatewayWrongSSID = 3,
    TTGatewayWrongWifiPassword = 4,
    TTGatewayInvalidCommand = 6,
    TTGatewayTimeout = 7,
    TTGatewayNoSIM = 8,
    TTGatewayNoPlugCable = 9,
    TTGatewayWrongCRC = -1,
    TTGatewayWrongAeskey = -2,
    TTGatewayNotConnect = -3,
    TTGatewayDisconnect = -4,
    TTGatewayFailConfigRouter = -5,
    TTGatewayFailConfigServer = -6,
    TTGatewayFailConfigAccount = -7,
    TTGatewayFailConfigIP = -8,
    TTGatewayFailInvaildIP = -9,
};

typedef void(^TTGatewayScanBlock)(TTGatewayScanModel *model);
typedef void(^TTGatewayConnectBlock)(TTGatewayConnectStatus connectStatus);
//wifiArr: [{"SSID":"ssid"}]
typedef void(^TTGatewayScanWiFiBlock)(BOOL isFinished, NSArray *WiFiArr,TTGatewayStatus status);
typedef void(^TTGatewayBlock)(TTGatewayStatus status);
typedef void(^TTInitializeGatewayBlock)(TTSystemInfoModel *systemInfoModel,TTGatewayStatus status);

@end

@interface TTGateway : NSObject
/**
 *  Get the name of the wireless network SSID for the current connection.
    If returned nil, the current mobile phone is not connected to the wireless network
 *  (Need to open location permissions After iOS13).
 */
+ (NSString *)getSSID;

/**
 start Scan Gateway
 */
+ (void)startScanGatewayWithBlock:(TTGatewayScanBlock)block;

/**
 Stop Scan
 */
+ (void)stopScanGateway;

/**
 Connect gateway
 */
+ (void)connectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayConnectBlock)block;

/**
 Cancel connect with gateway
 */
+ (void)disconnectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;

/**
 Get wifi nearby gateway
 */
+ (void)scanWiFiByGatewayWithBlock:(TTGatewayScanWiFiBlock)block;

/**
 initialize Gateway

 @param infoDic  @{@"SSID": xxx, @"wifiPwd": xxx, @"uid": xxx ,@"userPwd": xxx, @"gatewayName": xxx, @"gatewayVersion": @2, @"serverAddress":xxx, @"portNumber":xxx}
                 SSID  G2 G5 require, G3 G4 not require
                 wifiPwd  G2 G5 require, G3 G4 not require
                 gatewayName  Cannot exceed 48 bytes, exceeding will be truncated
				 gatewayVersion @2 means G2,@3 means G3,@4 means G4,@5 means G5
                 option  @"serverAddress",@"portNumber"
 */
+ (void)initializeGatewayWithInfoDic:(NSDictionary *)infoDic block:(TTInitializeGatewayBlock)block;

/**
 * Config IP
 *  @param info @{@"type":@(x), @"ipAddress": xxx, @"subnetMask": xxx, @"router": xxx, @"preferredDns": xxx, @"alternateDns": xxx}
                 type  @(0) means manual, @(1) means automatic
                 ipAddress (option)  such as 0.0.0.0
                 subnetMask (option)  such as 255.255.0.0
                 router (option)  such as 0.0.0.0
                 preferredDns (option)  such as 0.0.0.0
                 alternateDns (option)  such as 0.0.0.0
 */
+ (void)configIpWithInfo:(NSDictionary *)info block:(TTGatewayBlock)block;

/**
 Config Apn
 */
+ (void)configApn:(NSString *)apn block:(TTGatewayBlock)block;

/**
 Enter gateway into upgrade mode
 */
+ (void)upgradeGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block;

/**
 Call tihis after connect gateway successfully
 */
+ (NSString *)getNetworkMac;

@end
