//
//  TTGatewayDFU.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/27.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDFUMacros.h"

typedef NS_ENUM(NSInteger,TTGatewayDFUType) {
    TTGatewayDFUTypeByNet,
    TTGatewayDFUTypeByBluetooth,
};

@interface TTGatewayDFU : NSObject

+ (instancetype _Nonnull  )shareInstance;

/**
If the gateway is online,  use TTGatewayDFUTypeByNet.
Re connect the gateway power, use TTGatewayDFUTypeByBluetooth.
 */
- (void)startDfuWithType:(TTGatewayDFUType)type
                clientId:(NSString *_Nonnull)clientId
             accessToken:(NSString *_Nonnull)accessToken
               gatewayId:(NSNumber *_Nonnull)gatewayId
              gatewayMac:(NSString *_Nonnull)gatewayMac
            successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
               failBlock:(TTLockDFUFailBlock _Nullable )fblock;

- (void)endUpgrade;


- (void)startDfuWithClientId:(NSString *_Nonnull)clientId
                 accessToken:(NSString *_Nonnull)accessToken
                   gatewayId:(NSNumber *_Nonnull)gatewayId
                  gatewayMac:(NSString *_Nonnull)gatewayMac
                successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                   failBlock:(TTLockDFUFailBlock _Nullable )fblock  DEPRECATED_MSG_ATTRIBUTE("SDK3.3.4");
- (void)retryEnterUpgradeModebyNet DEPRECATED_MSG_ATTRIBUTE("SDK3.3.4");
- (void)retryEnterUpgradeModebyBluetooth DEPRECATED_MSG_ATTRIBUTE("SDK3.3.4");
- (void)pauseUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (void)restartUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (BOOL)paused DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (BOOL)stopUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");;

@end

