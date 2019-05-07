//
//  TTLockApiManager.h
//  PublicHouse
//
//  Created by Jinbo Lu on 2018/7/11.
//  Copyright © 2018年 HangZhouSciener. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTLockApi.h"
#import "TTLockModel.h"
#import "TTScanModel.h"
#import "TTBlocks.h"


typedef void(^BLECompletion)(NSDictionary *result,NSError *error);

@interface TTLockApiManager : NSObject
+ (instancetype)shareInstance;

@property (nonatomic, assign, getter=isPrintLog) BOOL printLog;
@property (nonatomic, assign, readonly) BOOL isScanning;
@property (nonatomic, assign, readonly) TTBluetoothState bluetoothState;
@property (atomic, strong) CBPeripheral *currentPeripheral;
@property (atomic, strong) NSString *currentLockMacOrName;

- (void)addObserveBluetoothState:(TTBluetoothStateBlock)stateBlock;

/** 搜索周边所有的蓝牙 并返回*/
- (void)startScan:(TTScanBlock)scanBlock;
/** 停止搜索蓝牙 */
- (void)stopScan;

#pragma mark - 锁基本操作
/** 添加锁 */
- (void)initLockWithDict:(NSDictionary *)dict
                      success:(TTInitLockSucceedBlock)success
                      failure:(TTFailedBlock)failure;
/** 恢复出厂设置*/
- (void)resetLockWithLockData:(NSString*)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;
/** 设置锁的时间*/
- (void)setLockTimeWithTimestamp:(long long)timestamp
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure;
/** 获取锁里面的时间 */
- (void)getLockTimeWithLockData:(NSString *)lockData
                        success:(TTGetLockTimeSucceedBlock)success
                        failure:(TTFailedBlock)failure;
/** 获取蓝牙的操作记录 */
- (void)getOperationLogWithType:(TTOperateLogType)type
                       lockData:(NSString *)lockData
                        success:(TTGetLockOperateRecordSucceedBlock)success
                        failure:(TTFailedBlock)failure;
/** 获取锁电量 */
- (void)getElectricQuantityWithLockData:(NSString *)lockData
                                success:(TTGetElectricQuantitySucceedBlock)success
                                failure:(TTFailedBlock)failure;

/** 获取锁的协议版本 */
- (void)getLockVersionWithLockData:(NSString *)lockData
                           success:(TTGetLockVersionSucceedBlock)success
                           failure:(TTFailedBlock)failure;

/** 获取锁的特征值 */
- (void)getLockSpecialValueWithLockData:(NSString *)lockData
                                success:(TTGetSpecialValueSucceedBlock)success
                                failure:(TTFailedBlock)failure;

/** 获取锁的固件版本号 */
- (void)getLockSystemInfoWithLockData:(NSString*)lockData
                              success:(TTGetLockSystemSucceedBlock)success
                              failure:(TTFailedBlock)failure;

- (void)getLockSwitchStateWithLockData:(NSString *)lockData
                               success:(TTGetLockStatusSuccessBlock)success
                               failure:(TTFailedBlock)failure;



- (void)sensorDoor:(TTLockModel *)lockModel
           success:(TTSucceedBlock)success
           failure:(TTFailedBlock)failure;

- (void)setAutomaticLockingPeriodicTime:(int)time
                               lockData:(NSString *)lockData
                                success:(TTSucceedBlock)success
                                failure:(TTFailedBlock)failure;

- (void)getAutomaticLockingPeriodicTimeWithLockData:(NSString *)lockData
                                            success:(TTGetAutomaticLockingPeriodicTimeSucceedBlock)success
                                            failure:(TTFailedBlock)failure;

- (void)setRemoteUnlockSwitchOn:(BOOL)on
                       lockData:(NSString *)lockData
                        success:(TTGetSpecialValueSucceedBlock)success
                        failure:(TTFailedBlock)failure;

- (void)getRemoteUnlockSwitchWithLockData:(NSString *)lockData
                                  success:(TTGetSwitchStateSuccessBlock)success
                                  failure:(TTFailedBlock)failure;

- (void)setAudioSwitchOn:(BOOL)on
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                 failure:(TTFailedBlock)failure;

- (void)getAudioSwitchWithLockData:(NSString *)lockData
                           success:(TTGetSwitchStateSuccessBlock)success
                           failure:(TTFailedBlock)failure;

- (void)getPassagModeWithLockData:(NSString *)lockData
                          success:(TTGetPassageModelSuccessBlock)success
                          failure:(TTFailedBlock)failure;

- (void)configPassageModeWithType:(TTPassageModeType)type
                         weekdays:(NSArray *)weekdays
                            month:(int)month
                        startDate:(long long)startDate
                          endDate:(long long)endDate
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

- (void)deletePassageModeWithType:(TTPassageModeType)type
                         weekdays:(NSArray *)weekdays
                              day:(int)day month:(int)month
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;

- (void)clearPassageModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;


#pragma mark - 门磁

- (void)operateDoorSensorLockingWithType:(TTOprationType)type
                                    isOn:(BOOL)isOn
                                lockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure;

- (void)doorSensorOpration:(TTOprationType)opration
                      isOn:(BOOL)isOn lock:(TTLockModel *)lock
                   success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

#pragma mark - 锁升级
- (void)enterUpgradeModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;

#pragma mark - NB锁
/** 设置锁的NB地址 和 端口*/
- (void)setNBServerAddress:(NSString *)serverAddress
                portNumber:(NSString *)portNumber
                  lockData:(NSString *)lockData
                   success:(TTGetElectricQuantitySucceedBlock)success
                   failure:(TTFailedBlock)failure;

#pragma mark - 电子钥匙
/** 开锁 */

- (void)controlLockWithControlAction:(TTControlAction)controlAction
                            lockData:(NSString *)lockData
                             success:(TTControlLockSucceedBlock)success
                             failure:(TTFailedBlock)failure;

- (void)resetEkeyWithLockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;

#pragma mark - 密码
- (void)createCustomPasscode:(NSString *)passcode
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure;

- (void)modifyAdminPasscode:(NSString *)adminPasscode
                   lockData:(NSString *)lockData
                    success:(TTSucceedBlock)success
                    failure:(TTFailedBlock)failure;

- (void)getAdminPasscodeWithLockData:(NSString *)lockData
                             success:(TTGetAdminPasscodeSucceedBlock)success
                             failure:(TTFailedBlock)failure;

- (void)setAdminErasePasscode:(NSString *)passcode
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;

- (void)resetPasscodesWithLockData:(NSString *)lockData
                           success:(TTResetPasscodesSucceedBlock)success
                           failure:(TTFailedBlock)failure;

/** 获取锁里面的密码方案 */
- (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData
                                          success:(TTResetPasscodesSucceedBlock)success
                                          failure:(TTFailedBlock)failure;

/** 恢复锁的密码*/
- (void)recoverPasscode:(NSString *)passcode
            newPasscode:(NSString *)newPasscode
           passcodeType:(TTPasscodeType)passcodeType
              startDate:(long long)startDate
                endDate:(long long)endDate
              cycleType:(int)cycleType
               lockData:(NSString *)lockData
                success:(TTSucceedBlock)success
                failure:(TTFailedBlock)failure;

/** 获取锁里面存储的密码 */
- (void)getAllValidPasscodesWithLockData:(NSString *)lockData
                                 success:(TTGetLockAllPasscodeSucceedBlock)success
                                 failure:(TTFailedBlock)failure;

- (void)deletePasscode:(NSString *)passcode
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure;

- (void)modifyPasscode:(NSString *)passcode
           newPasscode:(NSString *)newPasscode
             startDate:(long long)startDate
               endDate:(long long)endDate
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure;

- (void)setPasscodeVisibleSwitchOn:(BOOL)on
                          lockData:(NSString *)lockData
                           success:(TTSucceedBlock)success
                           failure:(TTFailedBlock)failure;

- (void)getPasscodeVisibleSwitchWithLockData:(NSString *)lockData
                                     success:(TTGetSwitchStateSuccessBlock)success
                                     failure:(TTFailedBlock)failure;
#pragma mark - 指纹、IC卡
/**  添加  修改 删除  恢复  IC 指纹 */
- (void)addICCardStartDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                  progress:(TTAddICProgressBlock)progress
                   success:(TTAddICSucceedBlock)success
                   failure:(TTFailedBlock)failure;

- (void)recoverICCardNumber:(NSString *)cardNumber
                 startDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                   success:(TTAddICSucceedBlock)success
                   failure:(TTFailedBlock)failure;

- (void)modifyICCardValidityPeriodWithCardNumber:(NSString *)cardNumber
                 startDate:(long long)startDate
                      endDate:(long long)endDate
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;

- (void)deleteICCardNumber:(NSString *)cardNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;

- (void)clearAllICCardsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;

- (void)getAllValidICCardsWithLockData:(NSString *)lockData
                               success:(TTGetAllICCardsSucceedBlock)success
                               failure:(TTFailedBlock)failure;

- (void)addFingerprintStartDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                  progress:(TTAddFingerprintProgressBlock)progress
                   success:(TTAddFingerprintSucceedBlock)success
                   failure:(TTFailedBlock)failure;


- (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString *)tempFingerprintNumber
                   startDate:(long long)startDate
                     endData:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTAddFingerprintSucceedBlock)success
                     failure:(TTFailedBlock)failure;

- (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData
                                success:(TTAddFingerprintSucceedBlock)success
                                failure:(TTFailedBlock)failure;

- (void)modifyFingerprintValidityPeriodWithFingerprintNumber:(NSString *)fingerprintNumber
                      startDate:(long long)startDate
                      endDate:(long long)endDate
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;

- (void)deleteFingerprintNumber:(NSString *)fingerprintNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;

- (void)clearAllFingerprintsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;

- (void)getAllValidFingerprintsWithLockData:(NSString *)lockData
                               success:(TTGetAllFingerprintsSucceedBlock)success
                               failure:(TTFailedBlock)failure;

#pragma mark - 手环
- (void)setWristbandKey:(NSString *)wristbandKey passcode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

- (void)setWristbandKey:(NSString *)wristbandKey isOpen:(BOOL)isOpen success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;
- (void)setWristbandRssi:(int)rssi success:(TTSucceedBlock)success failure:(TTFailedBlock)failure;

@end
