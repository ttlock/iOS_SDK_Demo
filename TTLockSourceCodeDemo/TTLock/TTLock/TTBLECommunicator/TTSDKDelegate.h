//
//  TTSDKDelegate.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2017/10/25.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTScanModel.h"
#import "TTSystemInfoModel.h"

@protocol TTSDKDelegate <NSObject>

@optional

/**
   Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
   <code>TTBluetoothStatePoweredOn</code>. A state below <code>TTBluetoothStatePoweredOn</code>
   implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
   <code>TTBluetoothStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
   manager become invalid and must be retrieved or discovered again.
 */
- (void)TTBluetoothDidUpdateState:(TTBluetoothState)state;

/**
 *  This method is invoked when the lock returns an error
 *
 *  @param error     error code
 *  @param command   command value
 *  @param errorMsg  Error description
 */
-(void)TTError:(TTError)error command:(int)command errorMsg:(NSString*)errorMsg;

/**
 *  This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>.
 *  A dictionary containing scan response data.
 *  peripheral
 *  rssi
 *  lockName
 *  lockMac
 *  isInited      Whether there is an administrator in the lock (that is, whether it is in setting mode)
 *  isAllowUnlock       YES for someone to touch the lock, v2 lock has been YES, parking lock has been NO
 *  oneMeterRSSI        RSSI about one meter away from the lock
 *  protocolType        Protocol type ,  5 is door lock ,  10 is parking lock,  0x3412 is wristband
 *  protocolVersion     Protocol version , 1 is v2 'LOCK' , 4 is v2 lock ,  3 is v3 lock
 *  scene               Scene
 *  lockSwitchState     The switch state of the parking lock (scene = = 7). The value of the lock which does not support this function is TTLockSwitchStateUnknown.
 *  doorSensorState
 *  electricQuantity    Lock battery (a lock that does not get battery, electricQuantity==-1)
 *  isDfuMode           Is it in the upgrade mode
 */
-(void)onScanLockWithModel:(TTScanModel *)model;

/**
 *  This method is invoked when a connection initiated by {@link connect:} or {@link connectPeripheralWithLockMac:} has succeeded.
 *
 *  @param peripheral     The <code>CBPeripheral</code> that has connected.
 *  @param lockName       lock Name
 */

-(void)onBTConnectSuccessWithPeripheral:(CBPeripheral *)peripheral lockName:(NSString*)lockName;

/**
 *  This method is invoked upon the disconnection of a peripheral
 *
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 */
-(void)onBTDisconnectWithPeripheral:(CBPeripheral*)peripheral;

/**
 *  Get Lock Version
 */
-(void)onGetLockVersion:(NSDictionary *)lockVersion;

/**
 *  This method is invoked when {@link lockInitializeWithInfoDic:} has succeeded.
    lockName
    lockMac
    lockKey
    lockFlagPos
    aesKeyStr
    lockVersion {protocolType, protocolVersion, scene, groupId,orgId}
    adminPwd
    noKeyPwd
    deletePwd
    pwdInfo
    timestamp
    pwdInfo
    specialValue
    electricQuantity
    timezoneRawOffset
    modelNum
    hardwareRevision
    firmwareRevision
    nbOperator
    nbNodeId
    nbCardNumber
    nbRssi
 */
-(void)onInitLockWithLockData:(NSString*)lockData specialValue:(long long)specialValue;

-(void)onSetLockTime;


-(void)onControlLockWithLockTime:(long long)lockTimestamp electricQuantity:(int)electricQuantity uniqueId:(long long)uniqueId;

-(void)onModifyAdminPasscode;

-(void)onSetAdminErasePasscode;

-(void)onResetPasscodeWithTimestamp:(long long)timestamp pwdInfo:(NSString *)pwdInfo;
/**
 *  Reset Ekey Successfully
 */
-(void)onResetEkey;

/**
 *  Get Lock Battery Successfully
 */
-(void)onGetElectricQuantity:(int)electricQuantity;

/**
 *  Reset Lock Successfully
 */
-(void)onResetLock;

- (void)onGetLog:(NSString *)log;
/**
 *  Delete User KeyBoard Password Successfully
 */
- (void)onDeletePasscodeSuccess;
/**
    Modify User KeyBoard Password  Successfully
 */
- (void)onModifyPasscode;
/**
  Add User KeyBoard Password  Successfully
 */
- (void)onCreateCustomPasscode;
/**
 *  Get Device Characteristic Successfully
    characteristic  Use "TTSpecialValueUtil.h" to judge
 */
- (void)onGetLockSpecialValue:(long long)characteristic;
/**
 *  Get Lock Time Successfully
 */
- (void)onGetLockTime:(long long)lockTimestamp;
/**
 *  Set Lock WristbandKey Successfully
 */
- (void)onSetLockWristbandKey;
/**
 *  Set WristbandKey Successfully
 */
- (void)onSetWristbandKey;
/**
 *  Set Wristband Rssi Successfully
 */
- (void)onSetWristbandRssi;
/**
 *  Low Power Callback (Only "LOCK" will be a callback)
 */
- (void)onLowPower;
/**
 *  Add IC Card Successfully
 *
 *  @param state     1->Identify IC card and add successfully  2->Successfully start adding IC card mode
 *  @param cardNum  State "1" contains card number, other states have no card number.
 */
- (void)onAddICCardWithState:(TTAddICState)state cardNum:(NSString*)cardNum;
/**
 *  Clear IC Successfully
 */
- (void)onClearICCard;
/**
 *   Delete IC Successfully
 */
- (void)onDeleteICCard;
/**
 *   Modify IC Successfully
 */
- (void)onModifyICCard;

- (void)onGetAllValidICCards:(NSString *)cardDataStr;

- (void)onRecoverICCardWithCardNum:(NSString*)cardNum;
/**
 Add Fingerprint Successfully
 
 @param state                AddFingerprintState
 @param fingerprintNum    state"TTAddFingerprintCollectSuccess"Contains fingerprint number, other states do not have fingerprint number
 @param currentCount         The number of fingerprints currently entered (the number of -1 representations is unknown), the first time to return the number of collection is 0, the last direct return to the state of 1 and the fingerprint number state TTAddFingerprintCollectSuccess do not return.
 @param totalCount   The number of fingerprints required (-1 is unknown) . when the state is TTAddFingerprintCollectSuccess , it is not returned.
 */
- (void)onAddFingerprintWithState:(TTAddFingerprintState)state fingerprintNum:(NSString*)fingerprintNum currentCount:(int)currentCount totalCount:(int)totalCount ;
/**
 *   Clear Fingerprint Successfully
 */
- (void)onClearAllFingerprints;
/**
 *   Delete Fingerprint Successfully
 */
- (void)onDeleteFingerprint;
/**
 *   Modify Fingerprint Successfully
 */
- (void)onModifyFingerprintValidityPeriod;
- (void)onRecoverFingerprintWithFingerprintNum:(NSString*)fingerprintNum;

- (void)onWriteFingerprintDataWithFingerprintNum:(NSString*)fingerprintNum;

- (void)onGetAllValidFingerprints:(NSString *)fingerprintStr;
/**
 Query Locking Time Successfully
 currentTime  Current locking time
 minTime  Minimum locking time
 maxTime  maximum locking time
 */
- (void)onGetAutomaticLockingPeriodWithCurrentTime:(int)currentTime minTime:(int)minTime maxTime:(int)maxTime;
/**
  Modify Locking Time Successfully
 */
- (void)onSetAutomaticLockingPeriod;
/**
  Get Device Info Successfully
 */
- (void)onGetLockSystemInfo:(TTSystemInfoModel*)model;
/**
  Enter Firmware Upgrade Mode Successfully
 */
- (void)onEnterFirmwareUpgradeMode;
/**
 Get Lock Switch State Successfully
 
 @param state  reference:TTLockSwitchState
 */
- (void)onGetLockStatus:(TTLockSwitchState)state;
- (void)onSetPasscodeVisible;
- (void)onGetPasscodeVisibleState:(BOOL)visible;
/**
 Recover User KeyBoard Password Successfully
 */
- (void)onRecoverPasscode;

- (void)onGetAllValidPasscodes:(NSString *)passcodeStr;
/**
 *  Reading new password data Successfully
 */
-(void)onGetInfoWithTimestamp:(long long)timestamp pwdInfo:(NSString *)pwdInfo;
/**
 Query Door Sensor Locking Successfully
 isOn  YES is open, NO is close
 */
- (void)onQueryDoorSensorLocking:(BOOL)isOn;
/**
 Modify Door Sensor Locking Successfully
 */
- (void)onModifyDoorSensorLocking;
/**
 Get Door Sensor State Successfully
 */
- (void)onGetDoorSensorState:(TTDoorSensorState)state;
/**
 Operate Remote Unlock Swicth Successfully
*/
- (void)onSetRemoteUnlockSwitchWithSpecialValue:(long long)specialValue;
- (void)onGetRemoteUnlockSwitchState:(BOOL)enabled;
/**
 Query Audio Switch  Successfully
 enabled  YES is open, NO is close
 */
- (void)onGetAudioSwitchState:(BOOL)enabled;
/**
 Set Audio Switch Successfully
 */
- (void)onSetAudioSwitch;
/**
 Set NB Server Successfully
 */
- (void)onSetNbServerInfo;
/**
  Get Admin Unlock Passcode Successfully
  */
- (void)onGetAdminKeyBoardPassword:(NSString *)adminPasscode;
/**
 Add Or Modify Passage Mode
 */
- (void)onConfigPassageMode;
/**
 Delete Passage Mode Successfully
 */
- (void)onDeletePassageMode;
/**
 Clear Passage Mode Successfully
 */
- (void)onClearPassageMode;


@end
