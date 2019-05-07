//
//  TTDFUMros.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/27.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTDFUMacros : NSObject

typedef NS_ENUM( NSInteger, UpgradeOpration) {
    UpgradeOprationPreparing  = 1,
    UpgradeOprationUpgrading,
    UpgradeOprationRecovering,
    UpgradeOprationSuccess,
};

typedef NS_ENUM( NSInteger, UpgradeErrorCode) {
    UpgradeErrorCodePeripheralPoweredOff  = 1,
    UpgradeErrorCodeConnectTimeout ,
    UpgradeErrorCodeNetFail ,
    UpgradeErrorNONeedUpgrade,
    UpgradeErrorUnknownUpgradeVersion,
    UpgradeErrorCodeEnterUpgradeState,
    UpgradeErrorCodeUpgradeLockFail ,
    UpgradeOprationPreparingError,
    UpgradeOprationGetSpecialValueError
};

typedef void(^TTLockDFUSuccessBlock)(UpgradeOpration type ,NSInteger process);
typedef void(^TTLockDFUFailBlock)(UpgradeOpration type, UpgradeErrorCode code);


@end

NS_ASSUME_NONNULL_END
