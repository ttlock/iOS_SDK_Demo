//
//  TTSmartLinkLock.m
//  TTLockDemo
//
//  Created by wjjxx on 17/3/23.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import "TTLockGateway.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "TTSmartLinkDeal.h"
#import "TTGatewayDeal.h"

@implementation TTLockGateway

#pragma mark --- G2
+ (void)startScanGatewayWithBlock:(TTGatewayScanBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
#warning todo 这里要有蓝牙状态才能用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [deal startScanGatewayWithBlock:block];
    });
   
}
+ (void)stopScanGateway{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal stopScanGateway];
}
+ (void)connectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayConnectBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal connectGatewayWithGatewayMac:gatewayMac block:block];
}
+ (void)disconnectGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal disconnectGatewayWithGatewayMac:gatewayMac block:block];
}
+ (void)scanWiFiByGatewayWithBlock:(TTGatewayScanWiFiBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal scanWiFiByGatewayWithBlock:block];
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
+ (void)initializeGatewayWithInfoDic:(NSDictionary *)infoDic block:(TTInitializeGatewayBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal initializeGatewayWithInfoDic:infoDic block:block];
}
+ (void)upgradeGatewayWithGatewayMac:(NSString *)gatewayMac block:(TTGatewayBlock)block{
    TTGatewayDeal * deal = [TTGatewayDeal shareInstance];
    [deal upgradeGatewayWithGatewayMac:gatewayMac block:block];
}
#pragma mark --- G1
+(void)startWithSSID:(NSString *)SSID  wifiPwd:(NSString *)wifiPwd uid:(int)uid userPwd:(NSString *)userPwd processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock{
    
    TTSmartLinkDeal *deal = [TTSmartLinkDeal new];
    [deal setupWifiBoxWithUid:uid userPwd:userPwd  wifiPwd:wifiPwd SSID:SSID companyId:0 branchId:0  processblock:pblock successBlock:sblock failBlock:fblock];
    
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
+(void)startWithInfoDic:(NSDictionary*)infoDic processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock{
    TTSmartLinkDeal *deal = [TTSmartLinkDeal new];
    deal.debugMode = infoDic[@"debugMode"];
    deal.plugName = infoDic[@"plugName"];
    deal.ishoneywell = infoDic[@"ishoneywell"];
    [deal setupWifiBoxWithUid:[infoDic[@"uid"] intValue] userPwd:infoDic[@"userPwd"]  wifiPwd:infoDic[@"wifiPwd"] SSID:infoDic[@"SSID"] companyId:[infoDic[@"companyId"] longLongValue] branchId:[infoDic[@"branchId"]longLongValue]  processblock:pblock successBlock:sblock failBlock:fblock];
    
}
#pragma mark ----- 获取到ssid
+ (NSString *)getSSID
{
    NSDictionary *ifs = [TTLockGateway fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    return ssid;
}
+ (id)fetchSSIDInfo {
    NSArray *ifs   = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}
@end
