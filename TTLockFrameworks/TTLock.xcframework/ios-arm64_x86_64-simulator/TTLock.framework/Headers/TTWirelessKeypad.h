//
//  TTWirelessKeypad.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/5/13.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTLock.h"

@interface TTWirelessKeypadScanModel : NSObject

@property (nonatomic, strong) NSString *keypadName;
@property (nonatomic, strong) NSString *keypadMac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, strong) NSDictionary *advertisementData;
@property (nonatomic, assign) BOOL isMultifunctionalKeypad;

@end

typedef enum {
    TTKeypadSuccess = 0,
    TTKeypadFail = 1,
    TTKeypadWrongCRC = -1,
    TTKeypadConnectTimeout = -2,
    TTKeypadWrongFactorydDate = -3,
    TTKeypadDuplicateFingerprint = -4,
    TTKeypadLackOfStorageSpace = 0x16
}TTKeypadStatus;

@interface TTWirelessKeypad : NSObject

typedef void(^TTKeypadScanBlock)(TTWirelessKeypadScanModel *model);

typedef void(^TTInitializeKeypadBlock)(NSString *wirelessKeypadFeatureValue,TTKeypadStatus status,int electricQuantity);

typedef void(^TTInitializeMultifunctionalKeypadBlock)(NSString *wirelessKeypadFeatureValue,int electricQuantity,int slotNumber,int slotLimit,TTSystemInfoModel *systemInfoModel);

typedef void(^TTGetAllStoredLocksBlock)(NSArray <NSString *> *lockMacs);

typedef void(^TTKeypadSuccessBlock)(void);

typedef void(^TTKeypadFailBlock)(TTKeypadStatus status);

/**
 start Scan Keypad
 */
+ (void)startScanKeypadWithBlock:(TTKeypadScanBlock)block;
/**
 Stop Scan
 */
+ (void)stopScanKeypad;

#pragma mark -- Multifunctional Keypad
/**
 initialize multifunctional keypad  (The lock and keypad must be nearby )
 @param keypadMac  keypad Mac
 @param lockData  lockData of the lock
 @param success  A block invoked when the operation is successful
 @param lockFailure  By lock,  block invoked when the operation fails
 @param keypadFailure  By keypad, a block invoked when the operation fails
 */
+ (void)initializeMultifunctionalKeypadWithKeypadMac:(NSString *)keypadMac
                                            lockData:(NSString *)lockData
                                             success:(TTInitializeMultifunctionalKeypadBlock)success
                                         lockFailure:(TTFailedBlock)lockFailure
                                       keypadFailure:(TTKeypadFailBlock)keypadFailure;

/**
 delete the lock at specified slot
 @param keypadMac  keypad Mac
 @param slotNumber  0: clear all slots, 1: delete first slot, 2: delete second slot, 3: delete third slot
 @param success  A block invoked when the operation is successful
 @param failure  A block invoked when the operation fails
 */
+ (void)deleteLockAtSpecifiedSlotWithKeypadMac:(NSString *)keypadMac
                                    slotNumber:(int)slotNumber
                                       success:(TTKeypadSuccessBlock)success
                                       failure:(TTKeypadFailBlock)failure;

/**
 get stored lock info
 @param keypadMac  keypad Mac
 @param success  slotLimit: maximum number of locks that can be stored
 lockMacs: the data in the array is sorted by slot, "lockMac:00:00:00:00:00:00" means this slot has not lock
 @param failure A block invoked when the operation fails
 */
+ (void)getAllStoredLocksWithKeypadMac:(NSString *)keypadMac
                               success:(TTGetAllStoredLocksBlock)success
                               failure:(TTKeypadFailBlock)failure;

/**
 Add fingerprint (The lock and keypad must be nearby )

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param keypadMac  keypad Mac
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when  adding, When the totalCount = 0, it is not the true total, it just means that you can start pressing your finger
 @param lockFailure  By lock,  block invoked when the operation fails
 @param keypadFailure  By keypad, a block invoked when the operation fails, when status = TTKeypadDuplicateFingerprint, the wireless keypad automatically enters the add state again
 */
+ (void)addFingerprintWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                             startDate:(long long)startDate
                               endDate:(long long)endDate
                             keypadMac:(NSString *)keypadMac
                              lockData:(NSString *)lockData
                              progress:(TTAddFingerprintProgressBlock)progress
                               success:(TTAddFingerprintSucceedBlock)success
                           lockFailure:(TTFailedBlock)lockFailure
                         keypadFailure:(TTKeypadFailBlock)keypadFailure;

/**
 Add card (The lock and keypad must be nearby )

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when  adding
 @param lockFailure  By lock,  block invoked when the operation fails
 */
+ (void)addCardWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData
                    progress:(TTAddICProgressBlock)progress
                     success:(TTAddICSucceedBlock)success
                 lockFailure:(TTFailedBlock)lockFailure;

+ (void)enterUpgradeModeWithKeypadMac:(NSString *)keypadMac
                              success:(TTKeypadSuccessBlock)success
                              failure:(TTKeypadFailBlock)failure;

#pragma mark -- Passcode Keypad
/**
 initialize Passcode Keypad
 */
+ (void)initializeKeypadWithKeypadMac:(NSString *)KeypadMac lockMac:(NSString *)lockMac block:(TTInitializeKeypadBlock)block;

@end


