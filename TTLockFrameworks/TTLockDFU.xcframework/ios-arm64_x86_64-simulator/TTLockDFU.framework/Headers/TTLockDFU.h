
//  Created by TTLock on 2017/8/9.
//  Copyright © 2017年 TTLock. All rights reserved.
//  version:3.3.4

#import <Foundation/Foundation.h>
#import "TTDFUMacros.h"
#import "TTGatewayDFU.h"
#import <TTLock/TTLock.h>

@interface TTLockDFU : NSObject

+ (instancetype _Nonnull  )shareInstance;

- (void)startDfuWithClientId:(NSString *_Nonnull)clientId
                 accessToken:(NSString *_Nonnull)accessToken
                      lockId:(NSNumber *_Nonnull)lockId
                    lockData:(NSString *_Nonnull)lockData
                successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                   failBlock:(TTLockDFUFailBlock _Nullable )fblock;

- (void)endUpgrade;

//only do dfu operation
- (void)startDfuWithFirmwarePackage:(NSString *_Nonnull)firmwarePackage
                           lockData:(NSString *_Nonnull)lockData
                       successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                          failBlock:(TTLockDFUFailBlock _Nullable )fblock;

- (void)retry DEPRECATED_MSG_ATTRIBUTE("SDK3.3.4");
- (void)upgradeLockWithEnterPassword DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (void)pauseUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (void)restartUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (BOOL)stopUpgrade DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");
- (BOOL)paused DEPRECATED_MSG_ATTRIBUTE("SDK3.1.9");

@end
