
//  Created by TTLock on 2017/8/9.
//  Copyright © 2017年 TTLock. All rights reserved.
//  version:3.0.1

#import <Foundation/Foundation.h>
#import "TTDFUMacros.h"
#import "TTGatewayDFU.h"

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

@end
