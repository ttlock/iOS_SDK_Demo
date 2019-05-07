//
//  TTGatewayCommandUtils.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/7.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCommand.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TTMacros.h"
#import "TTLockApi.h"
#import "TTCenterManager.h"


#define KKGATEWAYBLE_SCAN  @"ble_scan"//搜索
#define KKGATEWAYBLE_CONNECT  @"ble_connect"//连接
#define KKGATEWAYBLE_DISCONNECT  @"ble_disconnect"//断开连接
#define KKGATEWAYBLE_GET_SSID  @"ble_ssid"//连接
#define KKGATEWAYBLE_CONFIG_GATEWAY  @"ble_initialize"
#define KKGATEWAYBLE_UPGRADE_GATEWAY  @"ble_upgrade"

#define GATEWAY_COMM_SCAN_NEARBY_WIFI            0x01
#define GATEWAY_COMM_CONFIG_WIFI                 0x02
#define GATEWAY_COMM_CONFIG_SERVER               0x03
#define GATEWAY_COMM_CONFIG_ACCOUNT              0x04
#define GATEWAY_COMM_UPGRADE                     0x05
#define GATEWAY_COMM_ECHO                        0x45

@interface TTGatewayCommandUtils : NSObject
+ (void)gatewayEchoWithLockMac:(NSString *)lockMac;
+ (void)scanWiFiByGatewayWithLockMac:(NSString *)lockMac;
+ (void)configSSID:(NSString *)SSID pwd:(NSString *)pwd lockMac:(NSString *)lockMac;
+ (void)configServer:(NSString *)server port:(NSString *)port lockMac:(NSString *)lockMac;
+ (void)configAccountWithUid:(long long)uid password:(NSString *)password companyId:(long long)companyId branchId:(long long)branchId plugName:(NSString*)plugName lockMac:(NSString *)lockMac;
+(void)upgradeWithLockMac:(NSString *)lockMac;

+ (Byte *)getDefaultAesKeyWithMac:(NSString *)mac;

@end
