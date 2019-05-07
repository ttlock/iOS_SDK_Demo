//
//  TTLockApiManager.m
//  PublicHouse
//
//  Created by Jinbo Lu on 2018/7/11.
//  Copyright © 2018年 HangZhouSciener. All rights reserved.
//

#import "TTLockApiManager.h"


#define NSLog(...) NSLog(__VA_ARGS__)



typedef void(^TTPopCommandBlock)(id block);

@interface NSArray (Helper)
- (id)objectAtIndexSafe:(NSInteger)index;
@end

typedef NS_ENUM(NSInteger,BLECommand) {
    BLECommandNone,
    BLECommandScan,
    BLECommandScanMac,
    BLECommandConnect,
    
    BLECommandGetRecord,//锁内存存储的记录
    BLECommandSetTime,
    BLECommandGetTime,
    BLECommandInitLock,
    BLECommandResetLock,//恢复出厂设置
    BLECommandGetElectricQuantity,
    BLECommandGetSpecialValue,//读取特征值
    BLECommandGetSystem,//系统的固件版本
    BLECommandGetProtocolVersion,
    BLECommandGetLockSwitchState,
    BLECommandSetPasscodeVisible,
    BLECommandGetPasscodeVisible,
    BLECommandDoorSensorLocking,//修改、查询 门磁上锁
    BLECommandGetSensorDoorState,//门磁是否处于打开状态
    
    BLECommandSetAutomaticLockingPeriodicTime,
    BLECommandGetAutomaticLockingPeriodicTime,
    
    BLECommandSetRemoteUnlockSwitch,
    BLECommandGetRemoteUnlockSwitch,
    BLECommandSetAudioSwitch,
    BLECommandGetAudioSwitch,
    BLECommandGetPassageMode,
    BLECommandSetPassageMode,
    BLECommandDeletePassageMode,
    BLECommandClearPassageMode,
    
    BLECommandSetNB,
    
    BLECommandLockControl,
    BLECommandResetEkey,
    
    BLECommandAddIC,//添加指纹
    BLECommandDeleteIC,
    BLECommandClearIC,
    BLECommandModifyIC,
    BLECommandGetIC,
    BLECommandRecoverIC,
    
    BLECommandAddFingerprint,//添加 指纹
    BLECommandDeleteFingerprint,
    BLECommandClearFingerprint,
    BLECommandModifyFingerprint,
    BLECommandGetFingerprint,
    BLECommandRecoverFingerprint,
    BLECommandWriteFingerprintData,
    
    BLECommandGetPasswords,
    BLECommandRecoverPassword,//恢复密码
    BLECommandGetPasscodeData,//锁内存储的密码方案
    BLECommandSetAdminPasscode,
    BLECommandGetAdminPasscode,
    BLECommandSetAdminErasePasscode,
    BLECommandResetPasscode,
    BLECommandDeletePasscode,
    BLECommandModifyPasscode,
    BLECommandAddPasscode,
    
    
    BLECommandEnterUpgrade,//锁激活升级
    BLECommandUpgradeProgress,//锁升级进度
    BLECommandUpgrade,//锁升级
    
    BLECommandAddWristband,
    BLECommandSetWristband,
    BLECommandSetWristbandRssi,
};


@interface BLECommandModel : NSObject
@property (nonatomic, assign) BLECommand command;
@property (nonatomic, strong) TTLockModel *lockModel;
@property (nonatomic, strong) id progressBlock;
@property (nonatomic, strong) id succeedBlock;
@property (nonatomic, strong) TTFailedBlock failedBlock;

+ (BLECommandModel *)modelCommand:(BLECommand)command lockModel:(TTLockModel *)lockModel progress:(id)progressBlock succeedBlock:(id)succeedBlock failedBlock:(TTFailedBlock)failedBlock;
@end

@implementation BLECommandModel
+ (BLECommandModel *)modelCommand:(BLECommand)command lockModel:(TTLockModel *)lockModel progress:(id)progressBlock succeedBlock:(id)succeedBlock failedBlock:(TTFailedBlock)failedBlock{
    BLECommandModel *model = [BLECommandModel new];
    model.command = command;
    model.lockModel = lockModel;
    model.succeedBlock =   succeedBlock;
    model.progressBlock = progressBlock;
    model.failedBlock = failedBlock;
    return model;
}
@end

@interface TTLockApiManager ()<TTSDKDelegate>
@property (nonatomic, strong) TTLockApi *ttlockApi;
@property (atomic, strong) NSMutableArray<BLECommandModel *> *commandQueue;
@property (nonatomic, strong) TTScanBlock scanBlock;
@property (nonatomic, strong) TTBluetoothStateBlock bluetoothStateBlock;
@end

@implementation TTLockApiManager


+ (instancetype)shareInstance {
    static TTLockApiManager* s_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[TTLockApiManager alloc] init];
    });
    return s_instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _commandQueue = @[].mutableCopy;
        _ttlockApi = [[TTLockApi alloc] initWithDelegate:self];
        
    }
    return self;
}

- (void)addObserveBluetoothState:(TTBluetoothStateBlock)stateBlock{
    _bluetoothStateBlock = stateBlock;
}

- (TTBluetoothState)bluetoothState{
    return _ttlockApi.state;
}

- (BOOL)isScanning{
    return _ttlockApi.isScanning;
}

- (BOOL)isPrintLog{
    return _ttlockApi.isPrintLog;
}

- (void)setPrintLog:(BOOL)printLog{
    _ttlockApi.isPrintLog = printLog;
}

- (void)startScan:(TTScanBlock)scanBlock{
    _scanBlock = scanBlock;
    [_ttlockApi startScanLock:YES];
}

- (void)stopScan {
    [_ttlockApi stopScanLock];
    _scanBlock = nil;
}

- (void)initLockWithDict:(NSDictionary *)dict success:(TTInitLockSucceedBlock)success failure:(TTFailedBlock)failure {
    TTLockModel *lockModel = [TTLockModel new];
    lockModel.addLockDict = dict;
   [self queueAppendCommand:BLECommandInitLock lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setNBServerAddress:(NSString *)serverAddress portNumber:(NSString *)portNumber lockData:(NSString *)lockData success:(TTGetElectricQuantitySucceedBlock)success failure:(TTFailedBlock)failure{
    
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.serverAddress = serverAddress;
    lockModel.portNumber = portNumber;
    [self queueAppendCommand:BLECommandSetNB lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)controlLockWithControlAction:(TTControlAction)controlAction lockData:(NSString *)lockData success:(TTControlLockSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.controlAction = controlAction;
    [self queueAppendCommand:BLECommandLockControl lockModel:lockModel progress:nil success:success failure:failure];
}


- (void)resetEkeyWithLockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandResetEkey lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getElectricQuantityWithLockData:(NSString *)lockData success:(TTGetElectricQuantitySucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetElectricQuantity lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getOperationLogWithType:(TTOperateLogType)type lockData:(NSString *)lockData success:(TTGetLockOperateRecordSucceedBlock)success failure:(TTFailedBlock)failure {
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.operateLogType = type;
    [self queueAppendCommand:BLECommandGetRecord lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getLockVersionWithLockData:(NSString *)lockData success:(TTGetLockVersionSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetProtocolVersion lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setLockTimeWithTimestamp:(long long)timestamp lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure {
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.timestamp = timestamp;
    [self queueAppendCommand:BLECommandSetTime lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getLockTimeWithLockData:(NSString *)lockData success:(TTGetLockTimeSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetTime lockModel:lockModel progress:nil success:success failure:failure];
    
}

- (void)getLockSpecialValueWithLockData:(NSString *)lockData success:(TTGetSpecialValueSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetSpecialValue lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getLockSystemInfoWithLockData:(NSString*)lockData success:(TTGetLockSystemSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetSystem lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getLockSwitchStateWithLockData:(NSString *)lockData success:(TTGetLockStatusSuccessBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetLockSwitchState lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setPasscodeVisibleSwitchOn:(BOOL)on lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.isOn = on;
    [self queueAppendCommand:BLECommandSetPasscodeVisible lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getPasscodeVisibleSwitchWithLockData:(NSString *)lockData success:(TTGetSwitchStateSuccessBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetPasscodeVisible lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)doorSensorOpration:(TTOprationType)opration isOn:(BOOL)isOn lock:(TTLockModel *)lock success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    lock.isOn = isOn;
    lock.oprationType = opration;
    [self queueAppendCommand:BLECommandDoorSensorLocking lockModel:lock progress:nil success:success failure:failure];
}

- (void)sensorDoor:(TTLockModel *)lockModel success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    [self queueAppendCommand:BLECommandGetSensorDoorState lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setAutomaticLockingPeriodicTime:(int)time lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.timestamp = time;
    [self queueAppendCommand:BLECommandSetAutomaticLockingPeriodicTime lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getAutomaticLockingPeriodicTimeWithLockData:(NSString *)lockData success:(TTGetAutomaticLockingPeriodicTimeSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetAutomaticLockingPeriodicTime lockModel:lockModel progress:nil success:success failure:failure];
}


- (void)setRemoteUnlockSwitchOn:(BOOL)on lockData:(NSString *)lockData success:(TTGetSpecialValueSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.isOn = on;
    [self queueAppendCommand:BLECommandSetRemoteUnlockSwitch lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getRemoteUnlockSwitchWithLockData:(NSString *)lockData success:(TTGetSwitchStateSuccessBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetRemoteUnlockSwitch lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setAudioSwitchOn:(BOOL)on lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.isOn = on;
    [self queueAppendCommand:BLECommandSetAudioSwitch lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getAudioSwitchWithLockData:(NSString *)lockData success:(TTGetSwitchStateSuccessBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetAudioSwitch lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getPassagModeWithLockData:(NSString *)lockData success:(TTGetPassageModelSuccessBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetPassageMode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)configPassageModeWithType:(TTPassageModeType)type weekdays:(NSArray *)weekdays month:(int)month startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    lockModel.passageModeType = type;
    lockModel.month = month;
    lockModel.weekdays = weekdays;
    [self queueAppendCommand:BLECommandSetPassageMode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)deletePassageModeWithType:(TTPassageModeType)type weekdays:(NSArray *)weekdays day:(int)day month:(int)month lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.day = day;
    lockModel.passageModeType = type;
    lockModel.month = month;
    lockModel.weekdays = weekdays;
    [self queueAppendCommand:BLECommandDeletePassageMode lockModel:lockModel progress:nil success:success failure:failure];
}


- (void)clearPassageModeWithLockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandClearPassageMode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)enterUpgradeModeWithLockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandEnterUpgrade lockModel:lockModel progress:nil success:success failure:failure];
}


#pragma mark - 指纹、 IC
- (void)addICCardStartDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                  progress:(TTAddICProgressBlock)progress
                   success:(TTAddICSucceedBlock)success
                   failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandAddIC lockModel:lockModel progress:progress success:success failure:failure];
}

- (void)recoverICCardNumber:(NSString *)cardNumber
                  startDate:(long long)startDate
                    endDate:(long long)endDate
                   lockData:(NSString *)lockData
                    success:(TTAddICSucceedBlock)success
                    failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    lockModel.cardNumber = cardNumber;
    [self queueAppendCommand:BLECommandRecoverIC lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)modifyICCardValidityPeriodWithCardNumber:(NSString *)cardNumber startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.cardNumber = cardNumber;
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandModifyIC lockModel:lockModel progress:nil success:success failure:failure];
    
}

- (void)deleteICCardNumber:(NSString *)cardNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.cardNumber = cardNumber;
    [self queueAppendCommand:BLECommandDeleteIC lockModel:lockModel progress:nil success:success failure:failure];
    
}

- (void)clearAllICCardsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandClearIC lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getAllValidICCardsWithLockData:(NSString *)lockData
                               success:(TTGetAllICCardsSucceedBlock)success
                               failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetIC lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)addFingerprintStartDate:(long long)startDate
                        endDate:(long long)endDate
                       lockData:(NSString *)lockData
                       progress:(TTAddFingerprintProgressBlock)progress
                        success:(TTAddFingerprintSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandAddFingerprint lockModel:lockModel progress:progress success:success failure:failure];
}

- (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString *)tempFingerprintNumber
                   startDate:(long long)startDate
                     endData:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTAddFingerprintSucceedBlock)success
                     failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    lockModel.fingerprintData = fingerprintData;
    lockModel.tempFingerprintNumber = tempFingerprintNumber;
    [self queueAppendCommand:BLECommandWriteFingerprintData lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData
                                success:(TTAddFingerprintSucceedBlock)success
                                failure:(TTFailedBlock)failure{
    
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    lockModel.fingerprintNumber = fingerprintNum;
    [self queueAppendCommand:BLECommandRecoverFingerprint lockModel:lockModel progress:nil success:success failure:failure];
    
}

- (void)modifyFingerprintValidityPeriodWithFingerprintNumber:(NSString *)fingerprintNumber startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.fingerprintNumber = fingerprintNumber;
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandModifyFingerprint lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)deleteFingerprintNumber:(NSString *)fingerprintNumber
                       lockData:(NSString *)lockData
                        success:(TTSucceedBlock)success
                        failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.fingerprintNumber = fingerprintNumber;
    [self queueAppendCommand:BLECommandDeleteFingerprint lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)clearAllFingerprintsWithLockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure{
    
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandClearFingerprint lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getAllValidFingerprintsWithLockData:(NSString *)lockData
                                    success:(TTGetAllFingerprintsSucceedBlock)success
                                    failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetFingerprint lockModel:lockModel progress:nil success:success failure:failure];
}



#pragma mark - 密码

- (void)getAllValidPasscodesWithLockData:(NSString *)lockData success:(TTGetLockAllPasscodeSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetPasswords lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)deletePasscode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    [self queueAppendCommand:BLECommandDeletePasscode lockModel:lockModel progress:nil success:success failure:failure];
}



- (void)modifyPasscode:(NSString *)passcode newPasscode:(NSString *)newPasscode startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    lockModel.currentPasscode = newPasscode;
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandModifyPasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)resetLockWithLockData:(NSString*)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandResetLock lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)modifyAdminPasscode:(NSString *)adminPasscode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.adminPasscode = adminPasscode;
    [self queueAppendCommand:BLECommandSetAdminPasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getAdminPasscodeWithLockData:(NSString *)lockData success:(TTGetAdminPasscodeSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetAdminPasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)createCustomPasscode:(NSString *)passcode startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandAddPasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setAdminErasePasscode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    [self queueAppendCommand:BLECommandSetAdminErasePasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)resetPasscodesWithLockData:(NSString *)lockData success:(TTResetPasscodesSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandResetPasscode lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData success:(TTResetPasscodesSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    [self queueAppendCommand:BLECommandGetPasscodeData lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)recoverPasscode:(NSString *)passcode newPasscode:(NSString *)newPasscode passcodeType:(TTPasscodeType)passcodeType startDate:(long long)startDate endDate:(long long)endDate cycleType:(int)cycleType lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    lockModel.currentPasscode = newPasscode;
    lockModel.passcodeType = passcodeType;
    lockModel.passcodeCycleType = cycleType;
    lockModel.startDate = startDate;
    lockModel.endDate = endDate;
    [self queueAppendCommand:BLECommandRecoverPassword lockModel:lockModel progress:nil success:success failure:failure];
}

#pragma mark - 手环

- (void)setWristbandKey:(NSString *)wristbandKey passcode:(NSString *)passcode lockData:(NSString *)lockData success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel modelWithLockData:lockData];
    lockModel.passcode = passcode;
    lockModel.wristbandKey = wristbandKey;
    [self queueAppendCommand:BLECommandAddWristband lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setWristbandKey:(NSString *)wristbandKey isOpen:(BOOL)isOpen success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel new];
    lockModel.wristbandKey = wristbandKey;
    [self queueAppendCommand:BLECommandSetWristband lockModel:lockModel progress:nil success:success failure:failure];
}

- (void)setWristbandRssi:(int)rssi success:(TTSucceedBlock)success failure:(TTFailedBlock)failure{
    TTLockModel *lockModel = [TTLockModel new];
    lockModel.rssi = rssi;
    [self queueAppendCommand:BLECommandSetWristbandRssi lockModel:lockModel progress:nil success:success failure:failure];
}

/*********************************   锁升级    *********************************/

/*
- (void)activeUpgradeKey:(TTLockModel *)key success:(TTSucceedBlock)success failure:(TTFailedBlock)failure {
    _commandDict[@(BLECommandActiveUpgrade)] = completion;
    _currentKey = key;
    [_ttlock upgradeFirmware_adminPS:key.adminPassword lockKey:key.lockKey aesKey:key.aesKeyStr unlockFlag:key.lockFlagPos.intValue];
}

- (void)upgradeFile:(NSString *)file peripheral:(CBPeripheral*)peripheral progress:(BLECompletion)progress success:(TTSucceedBlock)success failure:(TTFailedBlock)failure {
    _commandDict[@(BLECommandUpgradeProgress)] = progress;
    _commandDict[@(BLECommandUpgrade)] = completion;
    _currentPeripheral = nil;
    _dfuMaxRepeat = 4;

    DFUServiceInitiator *dfu = [[DFUServiceInitiator alloc]initWithCentralManager:_ttlock.manager target:peripheral];
    dfu.delegate = self;
    dfu.progressDelegate = self;
    dfu.logger = self;
    dfu.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true;

    //获取升级包的本地地址
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc]initWithUrlToZipFile:[NSURL URLWithString:file]];
    id obj = [dfu withFirmware:selectedFirmware];
    NSLog(@"%@", obj);
    _dfuServiceController = [dfu start];

    // DFUFirmware SDK 会把蓝牙使用权夺走，必须重新初始化蓝牙实例
    [_ttlock setupBlueTooth];
}

- (BOOL)stopUpgrade{
    NSLog(@"%@",@"取消升级");
    [self disconnect];
    return [_dfuServiceController abort];
}

- (void)restartUpgrade{
    NSLog(@"重新升级");
    [_dfuServiceController resume];
}

- (void)pauseUpgrade{
    NSLog(@"暂停升级");
    [_dfuServiceController pause];
}
*/
#pragma mark - TTSDKDelegate
#pragma mark -

- (void)TTBluetoothDidUpdateState:(TTBluetoothState)state {
    
    if (_bluetoothStateBlock) {
        _bluetoothStateBlock(state);
    }
    
    if (state == TTBluetoothStatePoweredOff) {
        _currentPeripheral = nil;
        _currentLockMacOrName = nil;
        _scanBlock = nil;
        
        BLECommandModel *commandModel = [_commandQueue objectAtIndexSafe:0];
        if ( commandModel) {
            [_commandQueue removeAllObjects];
            if (commandModel.failedBlock) {
                commandModel.failedBlock(TTErrorBluetoothPoweredOff,TTErrorMessageBluetoothPoweredOff);
            }
        }
    }
}

- (void)TTError:(TTError)error command:(int)command errorMsg:(NSString *)errorMsg{
    NSLog(@"蓝牙失败回调:%lx command:%lx msg:%@",(long)error,(long)command,errorMsg);
    
    BLECommandModel *commandModel = [_commandQueue objectAtIndexSafe:0];
    if (error == TTErrorConnectionTimeout) {
        _currentPeripheral = nil;
        _currentLockMacOrName = nil;
        if ( commandModel.failedBlock) {
            commandModel.failedBlock(error, errorMsg);
        }
        [_commandQueue removeAllObjects];
    }else{
        if (commandModel) {
            [_commandQueue removeObject:commandModel];
            if (commandModel.failedBlock) commandModel.failedBlock(error, errorMsg);
            [self performQueueCommand];
        }
    }
}

- (void)onScanLockWithModel:(TTScanModel *)model{
    if (_currentPeripheral || _scanBlock == nil || model.lockName.length == 0) return;
    _scanBlock(model);
}

- (void)onBTConnectSuccessWithPeripheral:(CBPeripheral *)peripheral lockName:(NSString *)lockName {
    if (_currentPeripheral) return;
    _currentPeripheral = peripheral;
    NSLog(@"蓝牙连接成功");
    //停止扫描
    [_ttlockApi stopScanLock];
    //设置用户id
    
    BLECommandModel *commandModel = [_commandQueue objectAtIndexSafe:0];
    if ( commandModel.command == BLECommandConnect) {
        [_commandQueue removeObject:commandModel];
        [self performQueueCommand];
    }else{
        NSLog(@"蓝牙连接异常 当前指令：%ld",(long)commandModel.command);
    }
}

- (void)onBTDisconnectWithPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"蓝牙断开连接");
    _currentPeripheral = nil;
    _currentLockMacOrName = nil;
    
    BLECommandModel *commandModel = [_commandQueue objectAtIndexSafe:0];
    if ( commandModel.failedBlock) {
        commandModel.failedBlock(TTErrorDisconnection, TTErrorMessageDisconnection);
    }
    [_commandQueue removeAllObjects];
    
    if (_scanBlock) [self.ttlockApi startScanLock:YES];
}

- (void)onInitLockWithLockData:(NSString *)lockData{
    NSLog(@"初始化锁成功 %@",lockData);
    [self popQueueCommand:BLECommandInitLock success:^(id block) {
        TTInitLockSucceedBlock initLockSucceedBlock = block;
        initLockSucceedBlock(lockData,);
    }];
}

- (void)onSetNbServerInfo{
    NSLog(@"设置NB锁地址 端口 成功");
    [self popQueueCommand:BLECommandSetNB success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onControlLockWithLockTime:(long long)lockTimestamp electricQuantity:(int)electricQuantity uniqueId:(long long)uniqueId{
    NSLog(@"闭锁成功 :%lld",lockTimestamp);
    
    [self popQueueCommand:BLECommandLockControl success:^(id block) {
        TTControlLockSucceedBlock succeedBlock = block;
        succeedBlock(lockTimestamp,electricQuantity,uniqueId);
    }];
}


- (void)onResetEkey{
    NSLog(@"重置电子钥匙成功");
    [self popQueueCommand:BLECommandResetEkey success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}


//读取操作记录
- (void)onGetLog:(NSString *)log {
    NSLog(@"读取操作记录 :%@",log);
    [self popQueueCommand:BLECommandGetRecord success:^(id block) {
        TTGetLockOperateRecordSucceedBlock succeedBlock = block;
        succeedBlock(log);
    }];
}

- (void)onGetAllValidPasscodes:(NSString *)passcodeStr{
    NSLog(@"获取锁内所有使用中的密码 :%@",passcodeStr);
    [self popQueueCommand:BLECommandGetPasswords success:^(id block) {
        TTGetLockAllPasscodeSucceedBlock succeedBlock = block;
        succeedBlock(passcodeStr);
    }];
}


- (void)onGetElectricQuantity:(int)electricQuantity{
    NSLog(@"获取电量成功 :%d",electricQuantity);
    [self popQueueCommand:BLECommandGetElectricQuantity success:^(id block) {
        TTGetElectricQuantitySucceedBlock succeedBlock = block;
        succeedBlock(electricQuantity);
    }];
}

//设置锁时间
- (void)onSetLockTime {
    NSLog(@"设置锁时间成功");
    [self popQueueCommand:BLECommandSetTime success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onResetLock{
    NSLog(@"恢复出厂设置成功");
    [self popQueueCommand:BLECommandResetLock success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetLockTime:(long long)lockTimestamp{
    NSLog(@"获取锁时间成功 %lld",lockTimestamp);
    [self popQueueCommand:BLECommandGetTime success:^(id block) {
        TTGetLockTimeSucceedBlock succeedBlock = block;
        succeedBlock(lockTimestamp);
    }];
}

- (void)onGetLockSpecialValue:(long long)characteristic{
    NSLog(@"读取锁特征值：%lld",characteristic);
    [self popQueueCommand:BLECommandGetSpecialValue success:^(id block) {
        TTGetSpecialValueSucceedBlock succeedBlock = block;
        succeedBlock(characteristic);
    }];
}

- (void)onGetLockSystemInfo:(TTSystemInfoModel *)model{
    NSLog(@"读取锁固件信息：%@",model);
    [self popQueueCommand:BLECommandGetSystem success:^(id block) {
        TTGetLockSystemSucceedBlock succeedBlock = block;
        succeedBlock(model);
    }];
}

- (void)onGetLockVersion:(NSDictionary *)lockVersion{
    NSLog(@"获取锁协议版本成功");
    [self popQueueCommand:BLECommandGetProtocolVersion success:^(id block) {
        TTGetLockVersionSucceedBlock succeedBlock = block;
        succeedBlock(lockVersion);
    }];
}

- (void)onGetLockStatus:(TTLockSwitchState)state{
    NSLog(@"获取锁开关状态成功 %ld",(long)state);
    
    [self popQueueCommand:BLECommandGetLockSwitchState success:^(id block) {
        TTGetLockStatusSuccessBlock succeedBlock = block;
        succeedBlock(state);
    }];
}

- (void)onSetPasscodeVisible{
    NSLog(@"设置屏幕密码显示成功");
    [self popQueueCommand:BLECommandSetPasscodeVisible success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetPasscodeVisibleState:(BOOL)visible{
    NSLog(@"设置锁键盘屏幕密码是否显示成功 %d",visible);
    [self popQueueCommand:BLECommandGetPasscodeVisible success:^(id block) {
        TTGetSwitchStateSuccessBlock succeedBlock = block;
        succeedBlock(visible);
    }];
}

- (void)onQueryDoorSensorLocking:(BOOL)isOn{
    NSLog(@"查询门磁是否上锁成功 锁状态 %d",isOn);
    [self popQueueCommand:BLECommandDoorSensorLocking success:^(id block) {
        TTGetSwitchStateSuccessBlock succeedBlock = block;
        succeedBlock(isOn);
    }];
}

- (void)onModifyDoorSensorLocking{
    NSLog(@"修改门传感器是否上锁成功");
    [self popQueueCommand:BLECommandDoorSensorLocking success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetDoorSensorState:(TTDoorSensorState)state{
    NSLog(@"查询门磁是否关门 门状态 %ld",(long)state);
    [self popQueueCommand:BLECommandGetSensorDoorState success:^(id block) {
        TTGetSwitchStateSuccessBlock succeedBlock = block;
        succeedBlock(state);
    }];
}

- (void)onGetRemoteUnlockSwitchState:(BOOL)enabled{
    NSLog(@"远程开锁设置 状态 %d",enabled);
    
    [self popQueueCommand:BLECommandGetRemoteUnlockSwitch success:^(id block) {
        TTGetSwitchStateSuccessBlock succeedBlock = block;
        succeedBlock(enabled);
    }];
}

- (void)onSetAutomaticLockingPeriod{
    NSLog(@"自动闭锁设置成功");
    [self popQueueCommand:BLECommandSetAutomaticLockingPeriodicTime success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetAutomaticLockingPeriodWithCurrentTime:(int)currentTime minTime:(int)minTime maxTime:(int)maxTime{
    NSLog(@"获取自动闭锁 minTime:%d   maxTime:%d",minTime,maxTime);
    [self popQueueCommand:BLECommandGetAutomaticLockingPeriodicTime success:^(id block) {
        TTGetAutomaticLockingPeriodicTimeSucceedBlock succeedBlock = block;
        succeedBlock(minTime,maxTime);
    }];
}


- (void)onSetRemoteUnlockSwitchWithSpecialValue:(long long)specialValue{
    NSLog(@"远程开锁设置");
    [self popQueueCommand:BLECommandSetRemoteUnlockSwitch success:^(id block) {
        TTGetSpecialValueSucceedBlock succeedBlock = block;
        succeedBlock(specialValue);
    }];
}

- (void)onGetAudioSwitchState:(BOOL)enabled{
    NSLog(@"查询开锁声音提示成功 播放音频状态 %d",enabled);
    [self popQueueCommand:BLECommandGetAudioSwitch success:^(id block) {
        TTGetSwitchStateSuccessBlock succeedBlock = block;
        succeedBlock(enabled);
    }];
}

- (void)onSetAudioSwitch{
    NSLog(@"修改开锁声音提示成功 ");
    [self popQueueCommand:BLECommandSetAudioSwitch success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}


- (void)onQueryPassageModeWithRecord:(NSString *)record{
    NSLog(@"查询走廊模式成功 ");
    [self popQueueCommand:BLECommandGetPassageMode success:^(id block) {
        TTGetPassageModelSuccessBlock succeedBlock = block;
        succeedBlock(record);
    }];
}

- (void)onConfigPassageMode{
    NSLog(@"设置走廊模式成功 ");
    [self popQueueCommand:BLECommandSetPassageMode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onDeletePassageMode{
    NSLog(@"删除走廊模式成功 ");
    [self popQueueCommand:BLECommandDeletePassageMode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onClearPassageMode{
    NSLog(@"清空走廊模式成功 ");
    [self popQueueCommand:BLECommandClearPassageMode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}



- (void)onGetInfoWithTimestamp:(long long)timestamp pwdInfo:(NSString *)pwdInfo{
    NSLog(@"获取密码方案成功");
    [self popQueueCommand:BLECommandGetPasscodeData success:^(id block) {
        TTResetPasscodesSucceedBlock succeedBlock = block;
        succeedBlock(timestamp,pwdInfo);
    }];
}

#pragma mark - 密码

- (void)onGetAdminKeyBoardPassword:(NSString *)adminPasscode{
    NSLog(@"获取管理员密码成功");
    [self popQueueCommand:BLECommandGetAdminPasscode success:^(id block) {
        TTGetAdminPasscodeSucceedBlock succeedBlock = block;
        succeedBlock(adminPasscode);
    }];
}

- (void)onModifyAdminPasscode{
    NSLog(@"设置管理员密码成功");
    [self popQueueCommand:BLECommandSetAdminPasscode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onSetAdminErasePasscode{
    NSLog(@"设置管理员删除密码成功");
    [self popQueueCommand:BLECommandSetAdminErasePasscode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onResetPasscodeWithTimestamp:(long long)timestamp pwdInfo:(NSString *)pwdInfo{
    NSLog(@"重置键盘密码成功");
    [self popQueueCommand:BLECommandResetPasscode success:^(id block) {
        TTResetPasscodesSucceedBlock succeedBlock = block;
        succeedBlock(timestamp,pwdInfo);
    }];
}

- (void)onDeletePasscodeSuccess{
    NSLog(@"删除单个键盘密码成功");
    [self popQueueCommand:BLECommandDeletePasscode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onModifyPasscode{
    NSLog(@"修改键盘密码成功");
    [self popQueueCommand:BLECommandModifyPasscode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onCreateCustomPasscode{
    NSLog(@"添加键盘密码成功");
    [self popQueueCommand:BLECommandAddPasscode success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onRecoverPasscode{
    NSLog(@"恢复密码成功");
    [self popQueueCommand:BLECommandRecoverPassword success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}



#pragma mark IC卡

- (void)onAddICCardWithState:(TTAddICState)state cardNum:(NSString *)cardNum{
    NSLog(@"添加回调IC卡 状态：%ld  number:%@",(long)state,cardNum);
    BLECommandModel *commandModel = [_commandQueue objectAtIndex:0];
    if (commandModel.command == BLECommandAddIC){
        if (state == TTAddICStateCanAdd) {
            if (commandModel.progressBlock) {
                TTAddICProgressBlock progressBlock = commandModel.progressBlock;
                progressBlock(state);
            }
        }else{
            if (commandModel.succeedBlock) {
                TTAddICSucceedBlock successBlock = commandModel.succeedBlock;
                successBlock(cardNum);
            }
            [self.commandQueue removeObject:commandModel];
            [self performQueueCommand];
        }
    }else{
        NSLog(@"添加IC卡回调异常，当前回调指令:%ld",(long)commandModel.command);
    }
}

- (void)onRecoverICCardWithCardNum:(NSString *)cardNum{
    NSLog(@"恢复IC卡 ");
    [self popQueueCommand:BLECommandRecoverIC success:^(id block) {
        TTAddICSucceedBlock succeedBlock = block;
        succeedBlock(cardNum);
    }];
}

- (void)onClearICCard{
    NSLog(@"清空IC卡 ");
    [self popQueueCommand:BLECommandClearIC success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onDeleteICCard{
    NSLog(@"删除IC卡 成功");

    [self popQueueCommand:BLECommandDeleteIC success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetAllValidICCards:(NSString *)cardDataStr{
    [self popQueueCommand:BLECommandGetIC success:^(id block) {
        TTGetAllICCardsSucceedBlock succeedBlock = block;
        succeedBlock(cardDataStr);
    }];
}

- (void)onModifyICCard{
    NSLog(@"修改IC卡 ");

    [self popQueueCommand:BLECommandModifyIC success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

#pragma mark 指纹
- (void)onAddFingerprintWithState:(TTAddFingerprintState)state fingerprintNum:(NSString *)fingerprintNum currentCount:(int)currentCount totalCount:(int)totalCount{

    NSLog(@"添加指纹回调 状态：%ld  number:%@",(long)state,fingerprintNum);
     BLECommandModel *commandModel = [_commandQueue objectAtIndex:0];
    if (commandModel.command == BLECommandAddFingerprint){
            if (state == TTAddFingerprintCollectSuccess) {
                if (commandModel.succeedBlock) {
                    TTAddFingerprintSucceedBlock successBlock = commandModel.succeedBlock;
                    successBlock(fingerprintNum);
                }
                [self.commandQueue removeObject:commandModel];
                [self performQueueCommand];
            }else{
                if (commandModel.progressBlock) {
                    TTAddFingerprintProgressBlock progressBlock = commandModel.progressBlock;
                    progressBlock(state, totalCount - currentCount);
                }
            }
    }else{
        NSLog(@"添加指纹回调异常");
    }
}

- (void)onWriteFingerprintDataWithFingerprintNum:(NSString *)fingerprintNum{
    NSLog(@"直接写入指纹数据成功");
    [self popQueueCommand:BLECommandWriteFingerprintData success:^(id block) {
        TTAddFingerprintSucceedBlock succeedBlock = block;
        succeedBlock(fingerprintNum);
    }];
}

- (void)onRecoverFingerprintWithFingerprintNum:(NSString *)fingerprintNum{
    NSLog(@"恢复指纹成功");
    [self popQueueCommand:BLECommandRecoverFingerprint success:^(id block) {
        TTAddFingerprintSucceedBlock succeedBlock = block;
        succeedBlock(fingerprintNum);
    }];
}


- (void)onClearAllFingerprints{
    NSLog(@"清空指纹成功");
    
    [self popQueueCommand:BLECommandClearFingerprint success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onDeleteFingerprint{
    NSLog(@"删除指纹成功");
    [self popQueueCommand:BLECommandDeleteFingerprint success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onModifyFingerprintValidityPeriod{
    NSLog(@"修改指纹成功");
    [self popQueueCommand:BLECommandModifyFingerprint success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onGetAllValidFingerprints:(NSString *)fingerprintStr{
    NSLog(@"获取指纹成功");
    [self popQueueCommand:BLECommandGetFingerprint success:^(id block) {
        TTGetAllFingerprintsSucceedBlock succeedBlock = block;
        succeedBlock(fingerprintStr);
    }];
}

#pragma mark - 手环

- (void)onSetLockWristbandKey{
    NSLog(@"添加手环成功");
    [self popQueueCommand:BLECommandAddWristband success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onSetWristbandKey{
    NSLog(@"设置手环成功");
    [self popQueueCommand:BLECommandSetWristband success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

- (void)onSetWristbandRssi{
    NSLog(@"设置手环信号rssi成功");
    [self popQueueCommand:BLECommandSetWristbandRssi success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}

#pragma mark - DFU 升级

- (void)onEnterFirmwareUpgradeMode{
    NSLog(@"锁进入升级模式成功 ");
    [self popQueueCommand:BLECommandEnterUpgrade success:^(id block) {
        TTSucceedBlock succeedBlock = block;
        succeedBlock();
    }];
}
/*
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message {
    NSLog(@"dfuError %@",message);

    BLECompletion block = _commandDict[@(BLECommandUpgrade)];
    if (block) {
        [_commandDict removeObjectForKey:@(BLECommandUpgrade)];
        [_commandDict removeObjectForKey:@(BLECommandUpgradeProgress)];
        block(false,nil);
    }
}

- (void)dfuStateDidChangeTo:(enum DFUState)state {
    NSLog(@"dfuStateDidChangeTo%ld",(long)state);

    if (state == DFUStateEnablingDfuMode) {
        _dfuMaxRepeat--;
    }else if (state == DFUStateCompleted){
        BLECompletion updateWareBLock = _commandDict[@(BLECommandUpgrade)];
        [_commandDict removeObjectForKey:@(BLECommandUpgrade)];
        if (updateWareBLock) {
            dispatch_main_async(^{
                updateWareBLock(true,nil);
            });
        }
    }
    if (_dfuMaxRepeat == 0) {
        BLECompletion updateWareBLock = _commandDict[@(BLECommandUpgrade)];
        [_commandDict removeObjectForKey:@(BLECommandUpgrade)];
        if (updateWareBLock) {
            updateWareBLock(false,nil);
        }
    }
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    NSLog(@"%ld", (long)progress);
    BLECompletion block = _commandDict[@(BLECommandUpgradeProgress)];
    if (block) {
        dispatch_main_async(^{
            block(true,@(progress));
        });
    }
    if (progress == 100) {
        [_commandDict removeObjectForKey:@(BLECommandUpgradeProgress)];
    }
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message {
    NSLog(@"%@", message);
}
*/


#pragma mark - Private

- (void)queueAppendCommand:(BLECommand)command lockModel:(TTLockModel *)lockModel progress:(id)progress success:(id)success failure:(TTFailedBlock)failure{
    
    if (lockModel.lockMacOrName == nil) {
        if (failure) {
            failure(TTErrorWrongLockData,TTErrorMessageWrongLockData);
        }
        return;
    }
    
    if ([_ttlockApi state] != TTBluetoothStatePoweredOn) {
        if (failure) {
            failure(TTErrorBluetoothPoweredOff,TTErrorMessageBluetoothPoweredOff);
        }
        return;
    }
    
    if (_currentLockMacOrName == nil) {
        _currentLockMacOrName = lockModel.lockMacOrName;
        BLECommandModel *commandModel = [BLECommandModel modelCommand:BLECommandConnect lockModel:lockModel progress:progress succeedBlock:success failedBlock:failure];
        [_commandQueue addObject:commandModel];
        [self performQueueCommand];
    }
    
    if (_currentPeripheral == nil || [lockModel.lockMacOrName isEqualToString:_currentLockMacOrName]) {
        NSLog(@"添加蓝牙指令:%lx",(long)command);
        BLECommandModel *commandModel = [BLECommandModel modelCommand:command lockModel:lockModel progress:progress succeedBlock:success failedBlock:failure];
        [_commandQueue addObject:commandModel];
    }else{
        //当前蓝牙正在与其它锁通信中 禁止与其它锁发起通信
        if (failure) failure(TTErrorLockIsBusy,TTErrorMessageLockIsBusy);
    }
}

- (void)performQueueCommand{
    BLECommandModel *commandModel = [_commandQueue objectAtIndexSafe:0];
    TTLockModel *lockModel = commandModel.lockModel;
    if (commandModel == nil) {
        [_ttlockApi cancelConnectPeripheralWithLockMac:_currentLockMacOrName];
        return;
    }
    
    [_ttlockApi startScanLock:YES];
    
    switch (commandModel.command) {
        case BLECommandConnect:
        {
            [_ttlockApi connectPeripheralWithLockMac:_currentLockMacOrName];
        }
            
            break;
        case BLECommandLockControl:
        {
            [_ttlockApi controlLockWithControlAction:lockModel.controlAction lockData:lockModel.lockData];
        }
            break;
       
        case BLECommandResetEkey:
        {
            [_ttlockApi resetEkeyWithLockData:lockModel.lockData];
        }
            break;
        case BLECommandGetElectricQuantity:
            [_ttlockApi getElectricQuantityWithLockData:lockModel.lockData];
            break;
            
        case BLECommandGetRecord:
            [_ttlockApi getOperationLogWithType:lockModel.operateLogType lockData:lockModel.lockData];
            break;
            
        case BLECommandSetTime:
            [_ttlockApi setLockTimeWithTimestamp:lockModel.timestamp lockData:lockModel.lockData];
            break;
            
        case BLECommandGetTime:
            [_ttlockApi getLockTimeWithLockData:lockModel.lockData];
            
            break;
        case BLECommandInitLock:
        {
            [_ttlockApi initLockWithInfoDic:lockModel.addLockDict];
        }
            break;
            
        case BLECommandSetNB:
            [_ttlockApi setNbServerInfoWithPortNumber:lockModel.portNumber
                                     serverAddress:lockModel.serverAddress
                                          lockData:lockModel.lockData];
            break;
            
        case BLECommandWriteFingerprintData:
            [_ttlockApi writeFingerprintData:lockModel.fingerprintData
                    tempFingerprintNumber:lockModel.tempFingerprintNumber
                                startDate:lockModel.startDate
                                  endDate:lockModel.endDate
                                 lockData:lockModel.lockData];
            break;
            
        case BLECommandAddFingerprint:
            [_ttlockApi addFingerprintWithStartDate:lockModel.startDate endDate:lockModel.endDate lockData:lockModel.lockData];
            break;
        case BLECommandDeleteFingerprint:
            [_ttlockApi deleteFingerprintWithFingerprintNum:lockModel.fingerprintNumber lockData:lockModel.lockData];
            break;
        case BLECommandClearFingerprint:
            [_ttlockApi clearAllFingerprintsWithLockData:lockModel.lockData];
            break;
        case BLECommandModifyFingerprint:
            [_ttlockApi modifyFingerprintValidityPeriodWithStartDate:lockModel.startDate endDate:lockModel.endDate fingerprintNum:lockModel.fingerprintNumber lockData:lockModel.lockData];
            break;
        case BLECommandGetFingerprint:
            [_ttlockApi getAllValidFingerprintsWithLockData:lockModel.lockData];

            break;
        case BLECommandRecoverFingerprint:
            [_ttlockApi recoverFingerprintWithStartDate:lockModel.startDate
                                             endDate:lockModel.endDate
                                      fingerprintNum:lockModel.fingerprintNumber
                                            lockData:lockModel.lockData];
            break;
            
        case BLECommandAddIC:
            [_ttlockApi addICCardWithStartDate:lockModel.startDate endDate:lockModel.endDate lockData:lockModel.lockData];
            break;
        case BLECommandRecoverIC:
            [_ttlockApi recoverICCardWithStartDate:lockModel.startDate
                                        endDate:lockModel.endDate
                                        cardNum:lockModel.cardNumber
                                       lockData:lockModel.lockData];
            break;
        case BLECommandDeleteIC:
            [_ttlockApi deleteICCardWithCardNum:lockModel.cardNumber lockData:lockModel.lockData];
            break;
        case BLECommandClearIC:
            [_ttlockApi clearAllICCardsWithLockData:lockModel.lockData];
            break;
        case BLECommandModifyIC:
            [_ttlockApi modifyICCardValidityPeriodWithStartDate:lockModel.startDate
                                                     endDate:lockModel.endDate
                                                     cardNum:lockModel.cardNumber
                                                    lockData:lockModel.lockData];
            break;
        case BLECommandGetIC:
            [_ttlockApi getAllValidICCardsWithLockData:lockModel.lockData];
            break;
            
        case BLECommandResetLock:
            [_ttlockApi resetLockWithLockData:lockModel.lockData];
            break;
        case BLECommandRecoverPassword:
        {
            [_ttlockApi recoverPasscodeWithPasscodeType:lockModel.passcodeType
                                           cycleType:lockModel.passcodeCycleType
                                         currentCode:lockModel.currentPasscode
                                        originalCode:lockModel.passcode
                                           startDate:lockModel.startDate
                                             endDate:lockModel.endDate
                                            lockData:lockModel.lockData];
        }
            
            break;
        case BLECommandGetSpecialValue:
            [_ttlockApi getLockSpecialValueWithLockData:lockModel.lockData];
            break;
        case BLECommandGetSystem:
            [_ttlockApi getLockSystemInfoWithLockData:lockModel.lockData];
            break;
        case BLECommandGetLockSwitchState:
            [_ttlockApi getLockStatusWithLockData:lockModel.lockData];
            break;
            
        case BLECommandSetAutomaticLockingPeriodicTime:
            [_ttlockApi setAutomaticLockingPeriodWithTime:(int)lockModel.timestamp lockData:lockModel.lockData];
            break;
            
        case BLECommandGetAutomaticLockingPeriodicTime:
            [_ttlockApi getAutomaticLockingPeriodWithLockData:lockModel.lockData];
            break;
            
        case BLECommandSetRemoteUnlockSwitch:
            [_ttlockApi setRemoteUnlockSwitchState:lockModel.isOn lockData:lockModel.lockData];
            break;
        case BLECommandGetRemoteUnlockSwitch:
            [_ttlockApi getRemoteUnlockSwitchStateWithLockData:lockModel.lockData];
            break;
            
        case BLECommandSetAudioSwitch:
            [_ttlockApi setAudioSwitchState:lockModel.isOn lockData:lockModel.lockData];
            break;
        case BLECommandGetAudioSwitch:
            [_ttlockApi getAudioSwitchStateWithLockData:lockModel.lockData];
            break;
        case BLECommandSetPasscodeVisible:
            [_ttlockApi setPasscodeVisibleSwitchState:lockModel.isOn lockData:lockModel.lockData];
            break;
        case BLECommandGetPasscodeVisible:
            [_ttlockApi getPasscodeVisibleSwithStateWithLockData:lockModel.lockData];
            break;

        case BLECommandGetPasswords:
            [_ttlockApi getAllValidPasscodesWithLockData:lockModel.lockData];
            break;
        case BLECommandGetPasscodeData:
            [_ttlockApi getPasscodeVerificationParamsWithLockData:lockModel.lockData];
            break;
        case BLECommandDoorSensorLocking:
            [_ttlockApi operateDoorSensorLockingWithType:lockModel.oprationType isOn:lockModel.isOn lockData:lockModel.lockData];
        case BLECommandGetSensorDoorState:
            [_ttlockApi getDoorSensorStateWithLockData:lockModel.lockData];
            break;
            
        case BLECommandGetAdminPasscode:
            [_ttlockApi getAdminPasscodeWithLockData:lockModel.lockData];
            break;
        case BLECommandSetAdminPasscode:
            [_ttlockApi modifyAdminPasscode:lockModel.adminPasscode lockData:lockModel.lockData];
            break;
        case BLECommandSetAdminErasePasscode:
            [_ttlockApi setAdminErasePasscode:lockModel.passcode lockData:lockModel.lockData];
            break;
        case BLECommandResetPasscode:
            [_ttlockApi resetPasscodeWithLockData:lockModel.lockData];
            break;
        case BLECommandDeletePasscode:
            [_ttlockApi deletePasscode:lockModel.passcode lockData:lockModel.lockData];
            break;
        case BLECommandModifyPasscode:
            [_ttlockApi modifyPasscodeWithCurrentCode:lockModel.currentPasscode
                                      originalCode:lockModel.passcode
                                         startDate:lockModel.startDate
                                           endDate:lockModel.endDate
                                          lockData:lockModel.lockData];
            break;
        case BLECommandAddPasscode:
            [_ttlockApi createCustomPasscode:lockModel.passcode startDate:lockModel.startDate endDate:lockModel.endDate lockData:lockModel.lockData];
            break;
            
        case BLECommandAddWristband:
            [_ttlockApi setLockWristbandKey:lockModel.wristbandKey keyboardPassword:lockModel.passcode lockData:lockModel.lockData];
            break;
        case BLECommandSetPassageMode:
            [_ttlockApi configPassageModeWithType:lockModel.passageModeType
                                      weekDays:lockModel.weekdays
                                         month:lockModel.month
                                     startDate:(int)lockModel.startDate
                                       endDate:(int)lockModel.endDate
                                      lockData:lockModel.lockData];
            break;
        case BLECommandDeletePassageMode:
            [_ttlockApi deletePassageModeWithType:lockModel.passageModeType
                                      weekDays:lockModel.weekdays
                                           day:lockModel.day
                                         month:lockModel.month
                                      lockData:lockModel.lockData];
            break;
        case BLECommandGetPassageMode:
//            [_ttlock passagemodel];
            break;
            
        case BLECommandClearPassageMode:
            [_ttlockApi clearPassageModeWithLockData:lockModel.lockData];
            break;
        case BLECommandSetWristband:
            [_ttlockApi setWristbandKey:lockModel.wristbandKey isOpen:lockModel.isOpen];
            break;
            
        case BLECommandSetWristbandRssi:
            [_ttlockApi setWristbandRssi:lockModel.rssi];
            break;
        case BLECommandGetProtocolVersion:
            [_ttlockApi getLockVersion];
            break;
            
        case BLECommandEnterUpgrade:
            [_ttlockApi enterUpgradeModeWithLockData:lockModel.lockData];
            break;
        case BLECommandUpgradeProgress:
            
            break;
        case BLECommandUpgrade:
            
            break;
            
        default:
            break;
    }
}

- (void)popQueueCommand:(BLECommand)command success:(TTPopCommandBlock)success{
    BLECommandModel *commandModel = [_commandQueue objectAtIndex:0];
    [_commandQueue removeObject:commandModel];
    if (commandModel.command == command){
    }else{
        NSLog(@"回调异常，当前回调指令:%ld",(long)commandModel.command);
    }
    if (success && commandModel.succeedBlock) success(commandModel.succeedBlock);
    [self performQueueCommand];
}


@end



@implementation NSArray (Helper)
- (id)objectAtIndexSafe:(NSInteger)index {
    if (index < self.count && index >= 0) {
        return [self objectAtIndex:index];
    }else{
        return nil;
    }
}
@end
