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
    UpgradeErrorCodeConnectTimeout = 2,
    UpgradeErrorCodeNetFail = 3,
    UpgradeErrorNONeedUpgrade = 4,
    UpgradeErrorUnknownUpgradeVersion = 5,
    UpgradeErrorCodeEnterUpgradeState = 6,
    UpgradeErrorCodeUpgradeLockFail = 7,
    UpgradeOprationPreparingError = 8,
    UpgradeOprationGetSpecialValueError = 9,
    UpgradeErrorCodeUpgradeFail = 10,
    UpgradeOprationSetLockTimeError = 11,
};

typedef void(^TTLockDFUSuccessBlock)(UpgradeOpration type ,NSInteger process);
typedef void(^TTLockDFUFailBlock)(UpgradeOpration type, UpgradeErrorCode code);


@end

NS_ASSUME_NONNULL_END
