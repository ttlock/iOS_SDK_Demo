
//  Created by TTLock on 2017/8/9.
//  Copyright © 2017年 TTLock. All rights reserved.
//  version:3.1.8

#import <Foundation/Foundation.h>
#import <TTLockDFU/TTDFUMacros.h>
#import <TTLockDFU/TTGatewayDFU.h>

@interface TTLockDFU : NSObject

+ (instancetype _Nonnull  )shareInstance;

- (void)startDfuWithClientId:(NSString *_Nonnull)clientId
                 accessToken:(NSString *_Nonnull)accessToken
                      lockId:(NSNumber *_Nonnull)lockId
                    lockData:(NSString *_Nonnull)lockData
                successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                   failBlock:(TTLockDFUFailBlock _Nullable )fblock;
/**
 When you receive a failBlock, you can call this method to retry
 */
- (void)retry;
/**
 Do not support instructions to enter the upgrade, enter the password, upgrade again.
 */
- (void)upgradeLockWithEnterPassword;
- (void)pauseUpgrade; 
- (void)restartUpgrade;
- (BOOL)stopUpgrade;
- (BOOL)paused;

//only do dfu operation
- (void)startDfuWithFirmwarePackage:(NSString *_Nonnull)firmwarePackage
                           lockData:(NSString *_Nonnull)lockData
                       successBlock:(TTLockDFUSuccessBlock _Nullable )sblock
                          failBlock:(TTLockDFUFailBlock _Nullable )fblock;
@end
