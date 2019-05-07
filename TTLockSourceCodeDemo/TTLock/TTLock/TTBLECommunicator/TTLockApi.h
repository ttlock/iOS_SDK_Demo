
//
//  Created by TTLock on 2017/8/11.
//  Copyright © 2017年 TTLock. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TTMacros.h"
#import "TTSecurityUtil.h"
#import "TTGateway.h"
#import "TTSDKDelegate.h"
#import "TTScanModel.h"


@interface TTLockApi : NSObject

/**
 Whether or not print the log in SDK
 isPrintLog The default value is `NO`.
 */
@property(nonatomic, assign) BOOL isPrintLog;

/* An object that will receive the TTLock delegate methods */
@property (nonatomic, weak) id <TTSDKDelegate> delegate;

/** Special string of v3 lock when adding administrator
    There is a default value that can not be set */
@property (nonatomic, strong) NSString *setClientPara;

/**If yes - the ttlock object is created, if the Bluetooth is not turned on, the system will alert the box.
 The default value is `NO` */
@property (nonatomic,assign) BOOL isShowBleAlert;
/*!
 *  @property state
 *
 *  @discussion The current state of the manager, initially set to <code>TTLockSourceCodeDemoStateUnknown</code>.
 *				Updates are provided by required delegate method {@link TTLockSourceCodeDemoDidUpdateState:}.
 *
 */
@property(nonatomic, assign, readonly) TTBluetoothState state;
/*!
 *  @property isScanning
 *
 *  @discussion Whether or not the central is currently scanning.
 *
 */
@property(nonatomic, assign, readonly) BOOL isScanning NS_AVAILABLE(NA, 9_0);

/** Initialize the TTLock class
    @see TTBluetoothDidUpdateState:
 */
-(id)initWithDelegate:(id<TTSDKDelegate>)TTDelegate;

/** Get a single case */
+ (TTLockApi*)sharedInstance;
/**
 Start scanning near specific service Bluetooth.

 @param isScanDuplicates every time the peripheral is seen, which may be many times per second. This can be useful in specific situations.If you only support v3 lock,we recommend this value to be 'NO',otherwise to be 'YES'.
 *
 *  @see onScanLockWithModel:
 */
-(void)startScanLock:(BOOL)isScanDuplicates;

/** Stop scanning
 */
-(void)stopScanLock;

#pragma mark ------- Lock
/**********************************Lock*****************************/
/**
 * Lock initialize (Add administrator, it also applies to Parking Lock)
     Key                    Type       required     Description
 
     lockMac              NSString      YES
     lockVersion          NSString      YES

 *
 *  @see  onInitLockWithLockData:
 *  @see  TTError: command: errorMsg:
 */   
-(void)initLockWithInfoDic:(NSDictionary *)infoDic;
/**
 *  Set NB Server
 *  @see  onSetNbServerInfo
 *  @see  TTError: command: errorMsg:
 */
-(void)setNbServerInfoWithPortNumber:(NSString*)portNumber
                       serverAddress:(NSString*)serverAddress
                            lockData:(NSString *)lockData;

/** Reset Lock （That is delete the lock，Only for the administrator of v3 lock ）
 *  @see  onResetLock
 *  @see  TTError: command: errorMsg:
 */
-(void)resetLockWithLockData:(NSString *)lockData;
/** 所有开锁，闭锁都在这个接口，包括车位锁、卷闸门通过设置
 *  @see  onControlLock:
 *  @see  TTError: command: errorMsg:
 */
- (void)controlLockWithControlAction:(TTControlAction)controlAction lockData:(NSString *)lockData;

/**  set Audio Switch
     @see onSetAudioSwitch
 */
- (void)setAudioSwitchState:(BOOL)enable lockData:(NSString *)lockData;
/**  get Audio Switch
     @see onGetAudioSwitchState:
 */
- (void)getAudioSwitchStateWithLockData:(NSString *)lockData;
/**  @see onSetRemoteUnlockSwitch:
 */
- (void)setRemoteUnlockSwitchState:(BOOL)enable lockData:(NSString *)lockData;
/**  @see onGetRemoteUnlockSwitchState:
 */
- (void)getRemoteUnlockSwitchStateWithLockData:(NSString *)lockData;
/**  @see onSetPasscodeVisible
 */
- (void)setPasscodeVisibleSwitchState:(BOOL)visible lockData:(NSString *)lockData;

/**  @see onGetPasscodeVisibleState:
 */
- (void)getPasscodeVisibleSwithStateWithLockData:(NSString *)lockData;
/**
 *  Add Or Modify Passage Mode
 *  type                 PassageModeType
 *  weekDays        if type == TTPassageModeTypeWeek,  week：1~7,1 means Sunday，2 means  Monday ,...,6 means Saturday,  0 means everyday
 if type != TTPassageModeTypeWeek,  effective value ：1~31
 *  month                   effective value ：1~12， set 0 if type != PassageModeTypeMonthAndDay
 *  startDate               minutes ,0 means all day
 *  endDate                 minutes ,0 means all day
 *  @see  onConfigPassageMode
 *  @see  TTError: command: errorMsg:
 */
- (void)configPassageModeWithType:(TTPassageModeType)type weekDays:(NSArray*)weekDays month:(int)month startDate:(int)startDate endDate:(int)endDate lockData:(NSString *)lockData;
/**
 *  Delete Passage Mode
 
 *
 *  @see  onDeletePassageMode
 *  @see  TTError: command: errorMsg:
 */
- (void)deletePassageModeWithType:(TTPassageModeType)type weekDays:(NSArray*)weekDays day:(int)day month:(int)month lockData:(NSString *)lockData;
/**
 *  Clear Passage Mode
 
 *
 *  @see  onCleanPassageMode
 *  @see  TTError: command: errorMsg:
 */
- (void)clearPassageModeWithLockData:(NSString *)lockData;
/** Calibrate the lock of the clock
 *  @see  onSetLockTime
 *  @see  TTError: command: errorMsg:
 */
-(void)setLockTimeWithTimestamp:(long long)timestamp lockData:(NSString *)lockData;
/**
 *  Get Lock Time
 *  @see  onGetLockTime:
 *  @see  TTError: command: errorMsg:
 */
- (void)getLockTimeWithLockData:(NSString *)lockData;
/**
 *  Get the operation record
 *  type    OperateLogType
 *  @see  onGetLog:
 *  @see  TTError: command: errorMsg:
 */
- (void)getOperationLogWithType:(TTOperateLogType)type lockData:(NSString *)lockData;
/** Get Lock battery（Only for the v3 lock）
 *
 *  @see  onGetElectricQuantity:
 *  @see  TTError: command: errorMsg:
 */
-(void)getElectricQuantityWithLockData:(NSString *)lockData;

/** Get the version of lock
 *
 *  @see  onGetLockVersion:
 *  @see  TTError: command: errorMsg:
 */
-(void)getLockVersion;
/**
 Recover the keyboard passcode
 
 @param passcodeType  Passcode Type
 @param cycleType     Cycle Type , if passwordType != TTPasscodeTypeCycle ,can set any value
 @param currentCode   New Passcode
 @param originalCode   Old Passcode
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired, if passwordType != TTPasscodeTypePeriod ,can set nil
 *
 *  @see  onRecoverPasscode
 *  @see  TTError: command: errorMsg:
 */
- (void)recoverPasscodeWithPasscodeType:(TTPasscodeType)passcodeType
                                   cycleType:(NSInteger)cycleType
                                 currentCode:(NSString *)currentCode
                                 originalCode:(NSString *)originalCode
                                   startDate:(long long)startDate
                                     endDate:(long long)endDate
                                     lockData:(NSString *)lockData;
/**
 *  Get Device Info 
 *  @see onGetLockSystemInfo:
 *  @see  TTError: command: errorMsg:
 */
- (void)getLockSystemInfoWithLockData:(NSString *)lockData;
/**
 *  @see  onGetLockSpecialValue:
 *  @see  TTError: command: errorMsg:
 */
- (void)getLockSpecialValueWithLockData:(NSString *)lockData;
/**  @see onSetAutomaticLockingPeriod */
- (void)setAutomaticLockingPeriodWithTime:(int)time
                                 lockData:(NSString *)lockData;
/**  @see onGetAutomaticLockingPeriodWithCurrentTime: minTime: maxTime:*/
- (void)getAutomaticLockingPeriodWithLockData:(NSString *)lockData;
/** Get Lock Switch State
 *  @see onGetLockStatus:
 *  @see  TTError: command: errorMsg:
 */
- (void)getLockStatusWithLockData:(NSString *)lockData;
/** @see onEnterFirmwareUpgradeMode */
- (void)enterUpgradeModeWithLockData:(NSString *)lockData;

#pragma mark ------- eKey
/**********************************eKey*****************************/
/**
 *  Reset ekey
 *  @see  onResetEkey
 *  @see  TTError: command: errorMsg:
 */
-(void)resetEkeyWithLockData:(NSString *)lockData;

#pragma mark ------- Passcode
/**********************************Passcode*****************************/
/**
 Add keyboard passcode
 
 @param passcode The Passcode to add ,Passcode range : 4 - 9 Digits in length. If you do not need to modify the password, set the nil
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 *
 *  @see  onCreateCustomPasscode
 *  @see  TTError: command: errorMsg:
 
 */
- (void)createCustomPasscode:(NSString *)passcode
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData;
/**
 Modify the keyboard passcode
 
 @param currentCode  new passcode ,Passcode range : 4 - 9 Digits in length. If you do not need to modify the password, set the nil
 @param originalCode  old passcode
 @param startDate The time when it becomes valid .If you do not need to modify the time, set the nil
 @param endDate  The time when it is expired .If you do not need to modify the time, set the nil
 *
 *  @see  onModifyPasscode
 *  @see  TTError: command: errorMsg:
 */
- (void)modifyPasscodeWithCurrentCode:(NSString *)currentCode
                         originalCode:(NSString *)originalCode
                            startDate:(long long)startDate
                              endDate:(long long)endDate
                             lockData:(NSString *)lockData;

/** Set Admin Passcode
 *  keyboardPassword  Admin Passcod, Passcode range ： v2 lock : 7 - 9 Digits in length
                                                      v3 lock : 4 - 9 Digits in length
 *  @see  onModifyAdminPasscode
 *  @see  TTError: command: errorMsg:
 */
-(void)modifyAdminPasscode:(NSString*)passcode
                  lockData:(NSString *)lockData;
/**
 *  Delete a single keyboard passcode （Only for the administrator of v3 lock）
 *  passwordType(can set any value）
 *  @see  onDeletePasscodeSuccess
 *  @see  TTError: command: errorMsg:
 */
-(void)deletePasscode:(NSString *)passcode
             lockData:(NSString *)lockData;
/** Reset keyboard Passcode
 *  @see  onResetPasscodeWithTimestamp:pwdInfo:
 *  @see  TTError: command: errorMsg:
 */
-(void)resetPasscodeWithLockData:(NSString *)lockData;

/** Set Erase Passcode
 *  delKeyboardPassword Erase Passcode, Passcode range ： v2 lock : 7 - 9 Digits in length
                                                          v3 lock : 4 - 9 Digits in length
 *  @see  onSetAdminErasePasscode
 *  @see  TTError: command: errorMsg:
 */
-(void)setAdminErasePasscode:(NSString*)passcode
                    lockData:(NSString *)lockData;

/**
 *  Read the unlocked password list
 *  @see onGetAllValidPasscodes:
 *  @see  TTError: command: errorMsg:
 */
- (void)getAllValidPasscodesWithLockData:(NSString *)lockData;

/**
 Reading new password data
 *
 *  @see onGetInfoWithTimestamp:pwdInfo:
 */
- (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData;
/**
 *  Get Admin Unlock Passcode
 *  @see  onGetAdminKeyBoardPassword:
 *  @see  TTError: command: errorMsg:
 */
-(void)getAdminPasscodeWithLockData:(NSString *)lockData;

#pragma mark ------- 指纹
/**********************************指纹*****************************/
 /**
  @see onAddFingerprintWithState:fingerprintNum:currentCount:totalCount:
   */
- (void)addFingerprintWithStartDate:(long long)startDate
                            endDate:(long long)endDate
                           lockData:(NSString *)lockData;
/**
 @see onModifyFingerprintValidityPeriod
 */
- (void)modifyFingerprintValidityPeriodWithStartDate:(long long)startDate
                                             endDate:(long long)endDate
                                      fingerprintNum:(NSString*)fingerprintNum
                                            lockData:(NSString *)lockData;
//onDeleteFingerprint
- (void)deleteFingerprintWithFingerprintNum:(NSString*)fingerprintNum
                                   lockData:(NSString *)lockData;
//onClearFingerprint
- (void)clearAllFingerprintsWithLockData:(NSString *)lockData;
//onGetAllValidFingerprints
- (void)getAllValidFingerprintsWithLockData:(NSString *)lockData;
//onRecoverFingerprint
- (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData;

/**
 *  write FingerprintData
 *  fingerprintData         fingerprintData
 *  tempFingerprintNumber   temp FingerprintNumber
 *  startDate               millisecond
 *  endDate                 millisecond
 *
 *  @see onWriteFingerprintDataWithFingerprintNum
 *  @see  TTError: command: errorMsg:
 */
- (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString*)tempFingerprintNumber
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData;

#pragma mark ------- IC卡
/**********************************IC卡*****************************/
/**  @see onAddICCardWithState: ICNumber: */
- (void)addICCardWithStartDate:(long long)startDate
                       endDate:(long long)endDate
                      lockData:(NSString *)lockData;
/**  @see onModifyICCard */
- (void)modifyICCardValidityPeriodWithStartDate:(long long)startDate
                                        endDate:(long long)endDate
                                        cardNum:(NSString*)cardNum
                                       lockData:(NSString *)lockData;
/**  @see onDeleteICCard */
- (void)deleteICCardWithCardNum:(NSString*)cardNum
                       lockData:(NSString *)lockData;
/**  @see onClearICCard */
- (void)clearAllICCardsWithLockData:(NSString *)lockData;
/**  @see onGetAllValidICCards: */
- (void)getAllValidICCardsWithLockData:(NSString *)lockData;
//recoverICCard
- (void)recoverICCardWithStartDate:(long long)startDate
                           endDate:(long long)endDate
                           cardNum:(NSString*)cardNum
                          lockData:(NSString *)lockData;


#pragma mark ------- 门磁、手环
/**********************************门磁、手环*****************************/
/**
 *  Operate  Door Sensor Locking
 *  OprationType  only Query and Modify
 *  isOn    Set door sensor locking switch , NO-off  YES-on ,It is useful when the operation type is Modify

 *  @see onQueryDoorSensorLocking:
 *  @see onModifyDoorSensorLocking
 *  @see  TTError: command: errorMsg:
 */
- (void)operateDoorSensorLockingWithType:(TTOprationType)type isOn:(BOOL)isOn lockData:(NSString *)lockData;

/** Get Door Sensor State
 * @see onGetDoorSensorState:
 * @see  TTError: command: errorMsg:
 */
- (void)getDoorSensorStateWithLockData:(NSString *)lockData;
/**
 *  Set Lock's Wristband Key
 *  wristbandKey  set wristband Key
 *  keyboardPassword  the lock's Admin Passcode
 *
 *  @see onSetLockWristbandKey
 *  @see  TTError: command: errorMsg:
 */
- (void)setLockWristbandKey:(NSString*)wristbandKey keyboardPassword:(NSString*)keyboardPassword lockData:(NSString *)lockData;
/**
 * Set Wristband's Key
 * isOpen  Does this function open
 *
 *  @see onSetWristbandKey
 *  @see  TTError: command: errorMsg:
 */
- (void)setWristbandKey:(NSString*)wristbandKey isOpen:(BOOL)isOpen;
/**
 * Set Wristband's Rssi
 * rssi    set rssi
 *
 *  @see onSetWristbandRssi
 *  @see  TTError: command: errorMsg:
 */
- (void)setWristbandRssi:(int)rssi;


/**
 Start scanning all Bluetooth nearby
 If you need to develop wristbands, you can use this method
 @param isScanDuplicates every time the peripheral is seen, which may be many times per second. This can be useful in specific situations.Recommend this value to be NO
 *
 *  @see onScanLockWithModel:
 */
- (void)scanAllBluetoothDeviceNearby:(BOOL)isScanDuplicates;

- (void)scanSpecificServicesBluetoothDeviceWithServicesArray:(NSArray<NSString *>*)servicesArray isScanDuplicates:(BOOL)isScanDuplicates;
/**
 Connecting peripheral
 Connection attempts never time out .Pending attempts are cancelled automatically upon deallocation of <i>peripheral</i>, and explicitly via {@link cancelConnectPeripheralWithLockMac}.
 @param lockMac (If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see  onBTConnectSuccessWithPeripheral:lockName:
 */
- (void)connectPeripheralWithLockMac:(NSString *)lockMac;
/**
 Cancel connection
 @param lockMac （If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see onBTDisconnectWithPeripheral:
 */
- (void)cancelConnectPeripheralWithLockMac:(NSString *)lockMac;

@end


