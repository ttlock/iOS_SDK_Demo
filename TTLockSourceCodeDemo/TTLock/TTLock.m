//
//  TTLock.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/23.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "TTLock.h"
#import "TTLockApiManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TTLock()
@end

@implementation TTLock

+ (TTBluetoothState)bluetoothState{
    return [TTLockApiManager shareInstance].bluetoothState;
}

+ (BOOL)isScanning{
    return [TTLockApiManager shareInstance].isScanning;
}

+ (BOOL)isPrintLog{
    return [TTLockApiManager shareInstance].isPrintLog;
}

+ (void)setPrintLog:(BOOL)printLog{
     [TTLockApiManager shareInstance].printLog = printLog;
}

+ (CBPeripheral *)currentPeripheral{
    return [TTLockApiManager shareInstance].currentPeripheral;
}

+ (void)setupBluetooth:(TTBluetoothStateBlock)bluetooth{
    [[TTLockApiManager shareInstance] addObserveBluetoothState:^(TTBluetoothState state) {
        if (bluetooth) {
            bluetooth(state);
        }
    }];
    
}

/** 搜索周边所有的蓝牙 并返回*/
+ (void)startScan:(TTScanBlock)scanBlock{
    [[TTLockApiManager shareInstance] startScan:scanBlock];
}
/** 停止搜索蓝牙 */
+ (void)stopScan{
    [[TTLockApiManager shareInstance] stopScan];
}

#pragma mark - 锁基本操作
/** 添加锁 */
+ (void)initLockWithDict:(NSDictionary *)dict
                 success:(TTInitLockSucceedBlock)success
                 failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] initLockWithDict:dict success:success failure:failure];
}
/** 恢复出厂设置*/
+ (void)resetLockWithLockData:(NSString*)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] resetLockWithLockData:lockData success:success failure:failure];
}
/** 设置锁的时间*/
+ (void)setLockTimeWithTimestamp:(long long)timestamp
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setLockTimeWithTimestamp:timestamp lockData:lockData success:success failure:failure];
}
/** 获取锁里面的时间 */
+ (void)getLockTimeWithLockData:(NSString *)lockData
                        success:(TTGetLockTimeSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getLockTimeWithLockData:lockData success:success failure:failure];
}
/** 获取蓝牙的操作记录 */
+ (void)getOperationLogWithType:(TTOperateLogType)type
                       lockData:(NSString *)lockData
                        success:(TTGetLockOperateRecordSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getOperationLogWithType:type lockData:lockData success:success failure:failure];
}
/** 获取锁电量 */
+ (void)getElectricQuantityWithLockData:(NSString *)lockData
                                success:(TTGetElectricQuantitySucceedBlock)success
                                failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getElectricQuantityWithLockData:lockData success:success failure:failure];
}

/** 获取锁的协议版本 */
+ (void)getLockVersionWithLockData:(NSString *)lockData
                           success:(TTGetLockVersionSucceedBlock)success
                           failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getLockVersionWithLockData:lockData success:success failure:failure];
}

/** 获取锁的特征值 */
+ (void)getLockSpecialValueWithLockData:(NSString *)lockData
                                success:(TTGetSpecialValueSucceedBlock)success
                                failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getLockSpecialValueWithLockData:lockData success:success failure:failure];
}

/** 获取锁的固件版本号 */
+ (void)getLockSystemInfoWithLockData:(NSString*)lockData
                              success:(TTGetLockSystemSucceedBlock)success
                              failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getLockSystemInfoWithLockData:lockData success:success failure:failure];
}

+ (void)getLockSwitchStateWithLockData:(NSString *)lockData
                               success:(TTGetLockStatusSuccessBlock)success
                               failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getLockSwitchStateWithLockData:lockData success:success failure:failure];
}


+ (void)setAutomaticLockingPeriodicTime:(int)time
                               lockData:(NSString *)lockData
                                success:(TTSucceedBlock)success
                                failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setAutomaticLockingPeriodicTime:time lockData:lockData success:success failure:failure];
}

+ (void)getAutomaticLockingPeriodicTimeWithLockData:(NSString *)lockData
                                            success:(TTGetAutomaticLockingPeriodicTimeSucceedBlock)success
                                            failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAutomaticLockingPeriodicTimeWithLockData:lockData success:success failure:failure];
}

+ (void)setRemoteUnlockSwitchOn:(BOOL)on
                       lockData:(NSString *)lockData
                        success:(TTGetSpecialValueSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setRemoteUnlockSwitchOn:on lockData:lockData success:success failure:failure];
}

+ (void)getRemoteUnlockSwitchWithLockData:(NSString *)lockData
                                  success:(TTGetSwitchStateSuccessBlock)success
                                  failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getRemoteUnlockSwitchWithLockData:lockData success:success failure:failure];
}

+ (void)setAudioSwitchOn:(BOOL)on
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                 failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setAudioSwitchOn:on lockData:lockData success:success failure:failure];
}

+ (void)getAudioSwitchWithLockData:(NSString *)lockData
                           success:(TTGetSwitchStateSuccessBlock)success
                           failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAudioSwitchWithLockData:lockData success:success failure:failure];
}

+ (void)getPassagModeWithLockData:(NSString *)lockData
                          success:(TTGetPassageModelSuccessBlock)success
                          failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getPassagModeWithLockData:lockData success:success failure:failure];
}

+ (void)configPassageModeWithType:(TTPassageModeType)type
                         weekdays:(NSArray *)weekdays
                            month:(int)month
                        startDate:(long long)startDate
                          endDate:(long long)endDate
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] configPassageModeWithType:type weekdays:weekdays month:month startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)deletePassageModeWithType:(TTPassageModeType)type
                         weekdays:(NSArray *)weekdays
                              day:(int)day month:(int)month
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] deletePassageModeWithType:type weekdays:weekdays day:day month:month lockData:lockData success:success failure:failure];
}

+ (void)clearPassageModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] clearPassageModeWithLockData:lockData success:success failure:failure];
}


#pragma mark - 门磁

//+ (void)operateDoorSensorLockingWithType:(TTOprationType)type
//                                    isOn:(BOOL)isOn
//                                lockData:(NSString *)lockData
//                                 success:(TTSucceedBlock)success
//                                 failure:(TTFailedBlock)failure{
//    [[TTLockApiManager shareInstance] operateDoorSensorLockingWithType:type isOn:isOn lockData:lockData success:success failure:failure];
//}

//+ (void)doorSensorOpration:(TTOprationType)opration
//                      isOn:(BOOL)isOn lock:(TTLockModel *)lock
//                   success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
//    [TTLockApiManager shareInstance] doorSensorOpration:opration isOn:isOn lock:lock success:<#^(void)success#> failure:<#^(int errorCode, NSString *errorMsg)failure#>
//}

#pragma mark - 锁升级
+ (void)enterUpgradeModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] enterUpgradeModeWithLockData:lockData success:success failure:failure];
}

#pragma mark - NB锁
/** 设置锁的NB地址 和 端口*/
+ (void)setNBServerAddress:(NSString *)serverAddress
                portNumber:(NSString *)portNumber
                  lockData:(NSString *)lockData
                   success:(TTGetElectricQuantitySucceedBlock)success
                   failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setNBServerAddress:serverAddress portNumber:portNumber lockData:lockData success:success failure:failure];
}

#pragma mark - 电子钥匙
/** 开锁 */

+ (void)controlLockWithControlAction:(TTControlAction)controlAction
                            lockData:(NSString *)lockData
                             success:(TTControlLockSucceedBlock)success
                             failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] controlLockWithControlAction:controlAction lockData:lockData success:success failure:failure];
}

+ (void)resetEkeyWithLockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] resetEkeyWithLockData:lockData success:success failure:failure];
}

#pragma mark - 密码
+ (void)createCustomPasscode:(NSString *)passcode
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] createCustomPasscode:passcode startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)modifyAdminPasscode:(NSString *)adminPasscode
                   lockData:(NSString *)lockData
                    success:(TTSucceedBlock)success
                    failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] modifyAdminPasscode:adminPasscode lockData:lockData success:success failure:failure];
}

+ (void)getAdminPasscodeWithLockData:(NSString *)lockData
                             success:(TTGetAdminPasscodeSucceedBlock)success
                             failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAdminPasscodeWithLockData:lockData success:success failure:failure];
}

+ (void)setAdminErasePasscode:(NSString *)passcode
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setAdminErasePasscode:passcode lockData:lockData success:success failure:failure];
}

+ (void)resetPasscodesWithLockData:(NSString *)lockData
                           success:(TTResetPasscodesSucceedBlock)success
                           failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] resetPasscodesWithLockData:lockData success:success failure:failure];
}

/** 获取锁里面的密码方案 */
+ (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData
                                          success:(TTResetPasscodesSucceedBlock)success
                                          failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getPasscodeVerificationParamsWithLockData:lockData success:success failure:failure];
}

/** 恢复锁的密码*/
+ (void)recoverPasscode:(NSString *)passcode
            newPasscode:(NSString *)newPasscode
           passcodeType:(TTPasscodeType)passcodeType
              startDate:(long long)startDate
                endDate:(long long)endDate
              cycleType:(int)cycleType
               lockData:(NSString *)lockData
                success:(TTSucceedBlock)success
                failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] recoverPasscode:passcode newPasscode:newPasscode passcodeType:passcodeType startDate:startDate endDate:endDate cycleType:cycleType lockData:lockData success:success failure:failure];
}

/** 获取锁里面存储的密码 */
+ (void)getAllValidPasscodesWithLockData:(NSString *)lockData
                                 success:(TTGetLockAllPasscodeSucceedBlock)success
                                 failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAllValidPasscodesWithLockData:lockData success:success failure:failure];
}

+ (void)deletePasscode:(NSString *)passcode
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] deletePasscode:passcode lockData:lockData success:success failure:failure];
}

+ (void)modifyPasscode:(NSString *)passcode
           newPasscode:(NSString *)newPasscode
             startDate:(long long)startDate
               endDate:(long long)endDate
              lockData:(NSString *)lockData
               success:(TTSucceedBlock)success
               failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] modifyPasscode:passcode newPasscode:newPasscode startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)setPasscodeVisibleSwitchOn:(BOOL)on
                          lockData:(NSString *)lockData
                           success:(TTSucceedBlock)success
                           failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setPasscodeVisibleSwitchOn:on lockData:lockData success:success failure:failure];
}

+ (void)getPasscodeVisibleSwitchWithLockData:(NSString *)lockData
                                     success:(TTGetSwitchStateSuccessBlock)success
                                     failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getPasscodeVisibleSwitchWithLockData:lockData success:success failure:failure];
}
#pragma mark - 指纹、IC卡
/**  添加  修改 删除  恢复  IC 指纹 */
+ (void)addICCardStartDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                  progress:(TTAddICProgressBlock)progress
                   success:(TTAddICSucceedBlock)success
                   failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] addICCardStartDate:startDate endDate:endDate lockData:lockData progress:progress success:success failure:failure];
}

+ (void)recoverICCardNumber:(NSString *)cardNumber
                  startDate:(long long)startDate
                    endDate:(long long)endDate
                   lockData:(NSString *)lockData
                    success:(TTAddICSucceedBlock)success
                    failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] recoverICCardNumber:cardNumber startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)modifyICCardValidityPeriodWithCardNumber:(NSString *)cardNumber
                 startDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] modifyICCardValidityPeriodWithCardNumber:cardNumber startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)deleteICCardNumber:(NSString *)cardNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] deleteICCardNumber:cardNumber lockData:lockData success:success failure:failure];
}

+ (void)clearAllICCardsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] clearAllICCardsWithLockData:lockData success:success failure:failure];
}

+ (void)getAllValidICCardsWithLockData:(NSString *)lockData
                               success:(TTGetAllICCardsSucceedBlock)success
                               failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAllValidICCardsWithLockData:lockData success:success failure:failure];
}

+ (void)addFingerprintStartDate:(long long)startDate
                        endDate:(long long)endDate
                       lockData:(NSString *)lockData
                       progress:(TTAddFingerprintProgressBlock)progress
                        success:(TTAddFingerprintSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] addFingerprintStartDate:startDate endDate:endDate lockData:lockData progress:progress success:success failure:failure];
}


+ (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString *)tempFingerprintNumber
                   startDate:(long long)startDate
                     endData:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTAddFingerprintSucceedBlock)success
                     failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] writeFingerprintData:fingerprintData tempFingerprintNumber:tempFingerprintNumber startDate:startDate endData:endDate lockData:lockData success:success failure:failure];
}

+ (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData
                                success:(TTAddFingerprintSucceedBlock)success
                                failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] recoverFingerprintWithStartDate:startDate endDate:endDate fingerprintNum:fingerprintNum lockData:lockData success:success failure:failure];
}

+ (void)modifyFingerprintValidityPeriodWithFingerprintNumber:(NSString *)fingerprintNumber
                      startDate:(long long)startDate
                        endDate:(long long)endDate
                       lockData:(NSString *)lockData
                        success:(TTSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] modifyFingerprintValidityPeriodWithFingerprintNumber:fingerprintNumber startDate:startDate endDate:endDate lockData:lockData success:success failure:failure];
}

+ (void)deleteFingerprintNumber:(NSString *)fingerprintNumber
                       lockData:(NSString *)lockData
                        success:(TTSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] deleteFingerprintNumber:fingerprintNumber lockData:lockData success:success failure:failure];
}

+ (void)clearAllFingerprintsWithLockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] clearAllFingerprintsWithLockData:lockData success:success failure:failure];
}

+ (void)getAllValidFingerprintsWithLockData:(NSString *)lockData
                                    success:(TTGetAllFingerprintsSucceedBlock)success
                                    failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] getAllValidFingerprintsWithLockData:lockData success:success failure:failure];
}

#pragma mark - 手环
+ (void)setWristbandKey:(NSString *)wristbandKey passcode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setWristbandKey:wristbandKey passcode:passcode lockData:lockData success:success failure:failure];
}

+ (void)setWristbandKey:(NSString *)wristbandKey isOpen:(BOOL)isOpen success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setWristbandKey:wristbandKey isOpen:isOpen success:success failure:failure];
}

+ (void)setWristbandRssi:(int)rssi success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    [[TTLockApiManager shareInstance] setWristbandRssi:rssi success:success failure:failure];
}

@end
