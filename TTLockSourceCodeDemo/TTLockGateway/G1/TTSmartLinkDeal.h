//
//  TTSmartLinkDeal.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/5.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTLockGateway.h"
@interface TTSmartLinkDeal : NSObject

@property (nonatomic, strong) NSNumber *debugMode;
@property (nonatomic, strong) NSString *plugName;
@property (nonatomic, strong) NSNumber *ishoneywell;

- (void)setupWifiBoxWithUid:(int)uid userPwd:(NSString*)userPwd wifiPwd:(NSString*)wifiPwd SSID:(NSString*)SSID companyId:(long long)companyId branchId:(long long)branchId  processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock;

@end

