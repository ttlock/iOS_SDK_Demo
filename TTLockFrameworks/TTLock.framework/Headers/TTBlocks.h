
//
//  TTBlocks.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/11.
//  Copyright © 2019 Sciener. All rights reserved.
//



#ifndef TTBlocks_h
#define TTBlocks_h

#import "TTMacros.h"


@class TTScanModel;
@class TTSystemInfoModel;

typedef void(^TTScanBlock)(TTScanModel *scanModel);
typedef void(^TTBluetoothStateBlock)(TTBluetoothState state);

typedef void(^TTFailedBlock)(TTError errorCode, NSString *errorMsg);
typedef void(^TTSucceedBlock)(void);
typedef void(^TTInitLockSucceedBlock)(NSString *lockData, long long specialValue);
typedef void(^TTControlLockSucceedBlock)(long long lockTime, NSInteger electricQuantity, long long uniqueId);
typedef void(^TTGetAdminPasscodeSucceedBlock)(NSString *adminPasscode);
typedef void(^TTResetPasscodesSucceedBlock)(long long timestamp, NSString *passcodeInfo);
typedef void(^TTGetElectricQuantitySucceedBlock)(NSInteger electricQuantity);
typedef void(^TTGetLockOperateRecordSucceedBlock)(NSString *operateRecord);

typedef void(^TTGetSpecialValueSucceedBlock)(long long specialValue);
typedef void(^TTGetLockTimeSucceedBlock)(long long lockTimestamp);
typedef void(^TTGetLockVersionSucceedBlock)(NSDictionary *lockVersion);
typedef void(^TTGetLockSystemSucceedBlock)(TTSystemInfoModel *systemModel);
typedef void(^TTGetLockAllPasscodeSucceedBlock)(NSString *passcodes);
typedef void(^TTGetLockPasscodeDataSucceedBlock)(NSString *passcodeData);
typedef void(^TTGetAutomaticLockingPeriodicTimeSucceedBlock)(int currentTime, int minTime, int maxTime);

typedef void(^TTAddICProgressBlock)(TTAddICState state);
typedef void(^TTAddICSucceedBlock)(NSString *cardNumber);
typedef void(^TTGetAllICCardsSucceedBlock)(NSString *allICCardsJsonString);

typedef void(^TTAddFingerprintProgressBlock)(TTAddFingerprintState state,NSInteger remanentPressTimes);
typedef void(^TTAddFingerprintSucceedBlock)(NSString *fingerprintNumber);
typedef void(^TTGetAllFingerprintsSucceedBlock)(NSString *allFingerprintsJsonString);

typedef void(^TTGetSwitchStateSuccessBlock)(BOOL isOn);
typedef void(^TTGetLockStatusSuccessBlock)(TTLockSwitchState state);

typedef void(^TTGetPassageModelSuccessBlock)(NSString *passageModes);

#endif /* TTBlocks_h */
