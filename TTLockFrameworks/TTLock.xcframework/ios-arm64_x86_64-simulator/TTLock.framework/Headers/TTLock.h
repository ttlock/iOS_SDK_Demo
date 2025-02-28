//
//  TTLock.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/23.
//  Copyright © 2019 Sciener. All rights reserved.

//  version:3.4.8

#import <Foundation/Foundation.h>
#import <TTLock/TTBlocks.h>
#import <TTLock/TTGateway.h>
#import <TTLock/TTMacros.h>
#import <TTLock/TTScanModel.h>
#import <TTLock/TTSystemInfoModel.h>
#import <TTLock/TTUtil.h>
#import <TTLock/TTWirelessKeypad.h>
#import <TTLock/TTWirelessKeyFob.h>
#import <TTLock/TTDoorSensor.h>
#import <TTLock/TTElectricMeter.h>

@interface TTLock : NSObject
/**
 Print sdk log
 */
@property (class, nonatomic, assign, getter=isPrintLog) BOOL printLog;

/**
 Current Bluetooth state
 */
@property (class, nonatomic, assign, readonly) TTBluetoothState bluetoothState;

/**
 The current authorization of the manager
 */
@property(class, nonatomic, assign, readonly) TTManagerAuthorization authorization API_AVAILABLE(ios(13.0));

/**
  Whether the Bluetooth is scanning
 */
@property (class, nonatomic, assign, readonly) BOOL isScanning API_AVAILABLE(ios(9.0));

/**
 Setup Bluetooth

 @param bluetoothStateObserver A block invoked when the bluetooth setup finished
 */
+ (void)setupBluetooth:(TTBluetoothStateBlock)bluetoothStateObserver;

/**
 Start Bluetooth  scanning

 @param scanBlock A block invoked when the bluetooth is scanning
 */
+ (void)startScan:(TTScanBlock)scanBlock;

/**
 Stop Bluetooth scanning
 */
+ (void)stopScan;

/**
 Cancel Operations
 Cancel an active or pending connection to peripheral. Note that this is non-blocking, and any CBPeripheral commands that are still pending to peripheral may or may not complete.
 */
+ (void)cancelOperationsWithLockMac:(NSString *)lockMac;

#pragma mark - Lock basic operation
/**
 Initialize the lock
 
 @param dict @{@"lockMac": xxx, @"lockName": xxx, @"lockVersion": xxx}
 @param success A block invoked when the lock is initialize
 @param failure A block invoked when the operation fails
 */
+ (void)initLockWithDict:(NSDictionary *)dict
                 success:(TTInitLockSucceedBlock)success
                 failure:(TTFailedBlock)failure;


/**
 Reset the lock

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetLockWithLockData:(NSString*)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;


/**
 Set the lock time

 @param timestamp A timestamp（millisecond）
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock time is set
 @param failure A block invoked when the operation fails
 */
+ (void)setLockTimeWithTimestamp:(long long)timestamp
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure;

/**
 Get the lock time

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock time is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockTimeWithLockData:(NSString *)lockData
                        success:(TTGetLockTimeSucceedBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Get the lock log

 @param type The log type
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock log is got
 @param failure A block invoked when the operation fails
 */
+ (void)getOperationLogWithType:(TTOperateLogType)type
                       lockData:(NSString *)lockData
                        success:(TTGetLockOperateRecordSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Get the lock electric quantity

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock power is got
 @param failure A block invoked when the operation fails
 */
+ (void)getElectricQuantityWithLockData:(NSString *)lockData
                                success:(TTGetElectricQuantitySucceedBlock)success
                                failure:(TTFailedBlock)failure;


/**
 Get the lock version
 @param lockMac lockMac
 @param success A block invoked when the lock version is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockVersionWithLockMac:(NSString *)lockMac
                              success:(TTGetLockVersionSucceedBlock)success
                              failure:(TTFailedBlock)failure;


/**
 Get the lock feature value

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock feature value is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockFeatureValueWithLockData:(NSString *)lockData
                                success:(TTGetFeatureValueSucceedBlock)success
                                failure:(TTFailedBlock)failure;

/**
 Get the lock system infomation (this method also can get the newest featurevalue)

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock system infomation is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockSystemInfoWithLockData:(NSString*)lockData
                              success:(TTGetLockSystemSucceedBlock)success
                              failure:(TTFailedBlock)failure;


/**
 Get the lock switch state

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock switch state is got
 @param failure A block invoked when the operation fails
 */
+ (void)getLockSwitchStateWithLockData:(NSString *)lockData
                               success:(TTGetLockStatusSuccessBlock)success
                               failure:(TTFailedBlock)failure;


/**
 Set the lock automatic locking periodic time

 @param time The time(second）must between minTime and maxTime
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock automatic locking periodic time is set
 @param failure A block invoked when the operation fails
 */
+ (void)setAutomaticLockingPeriodicTime:(int)time
                               lockData:(NSString *)lockData
                                success:(TTSucceedBlock)success
                                failure:(TTFailedBlock)failure;


/**
 Get the lock automatic locking periodic time

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock automatic locking periodic time is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAutomaticLockingPeriodicTimeWithLockData:(NSString *)lockData
                                            success:(TTGetAutomaticLockingPeriodicTimeSucceedBlock)success
                                            failure:(TTFailedBlock)failure;


/**
 Set the lock remote unlock switch

 @param on Remote unlock switch on or off
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock remote unlock switch is set
 @param failure A block invoked when the operation fails
 */
+ (void)setRemoteUnlockSwitchOn:(BOOL)on
                       lockData:(NSString *)lockData
                        success:(TTSetRemoteUnlockSwitchSuccessBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Get the lock remote unlock switch state

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock remote unlock switch state is got
 @param failure A block invoked when the operation fails
 */
+ (void)getRemoteUnlockSwitchWithLockData:(NSString *)lockData
                                  success:(TTGetSwitchStateSuccessBlock)success
                                  failure:(TTFailedBlock)failure;


/**
 Config the lock passage mode. If config succeed,the lock will always be unlocked

 @param type TTPassageModeType type
 @param weekly Any number from 1 to 7, such as @[@1,@3,@6,@7]. If type == TTPassageModeTypeMonthly, the weekly will not be set
 @param monthly Any number from 1 to 31, such as @[@1,@13,@26,@31]. If type == TTPassageModeTypeWeekly, the monthly will not be set
 @param startDate The time when it becomes valid (minutes from 0 clock)
 @param endDate The time when it is expired (minutes from 0 clock)
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage mode is set
 @param failure A block invoked when the operation fails
 */
+ (void)configPassageModeWithType:(TTPassageModeType)type
                           weekly:(NSArray<NSNumber *> *)weekly
                          monthly:(NSArray<NSNumber *> *)monthly
                        startDate:(int)startDate
                          endDate:(int)endDate
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;

/**
 get all passage modes of the lock
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when all passage modes is got
 @param failure A block invoked when the operation fails
 */
+ (void)getPassageModesWithLockData:(NSString *)lockData
                                   success:(TTGetPassageModelSuccessBlock)success
                                   failure:(TTFailedBlock)failure;

/**
 Delete passage mode

 @param type TTPassageModeType type
 @param weekly Any number from 1 to 7, such as @[@1,@3,@6,@7]. If type == TTPassageModeTypeMonthly, the weekly will not be set
 @param monthly Any number from 1 to 31, such as @[@1,@13,@26,@31]. If type == TTPassageModeTypeWeekly, the monthly will not be set
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage mode is delete
 @param failure A block invoked when the operation fails
 */
+ (void)deletePassageModeWithType:(TTPassageModeType)type
                           weekly:(NSArray<NSNumber *> *)weekly
                          monthly:(NSArray<NSNumber *> *)monthly
                         lockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;


/**
 Clear all passage modes

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passage modes are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearPassageModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;

/**
Set Light Time
@param time      Light Time
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setLightTime:(int)time
            lockData:(NSString *)lockData
             success:(TTSucceedBlock)success
             failure:(TTFailedBlock)failure;
/**
Get Light Time

@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)getLightTimeWithLockData:(NSString *)lockData
                         success:(TTGetLightTimeSuccessBlock)success
                         failure:(TTFailedBlock)failure;
/**
Set Lock Config
 
@param type  TTLockConfigType
@param on  switch on or off
@param lockData The lock data string used to operate lock
@param success A block invoked when when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setLockConfigWithType:(TTLockConfigType)type
                           on:(BOOL)on
                     lockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;
/**
 Get Lock Config
 
 @param type      TTLockConfigType
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)getLockConfigWithType:(TTLockConfigType)type
                     lockData:(NSString *)lockData
                      success:(TTGetLockConfigSuccessBlock)success
                      failure:(TTFailedBlock)failure;

/**
 Set Unlock Direction
 @param direction TTUnlockDirection
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)setUnlockDirection:(TTUnlockDirection)direction
				  lockData:(NSString *)lockData
				   success:(TTSucceedBlock)success
				   failure:(TTFailedBlock)failure;

/**
 Get Unlock Direction
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)getUnlockDirectionWithLockData:(NSString *)lockData
							   success:(TTGetUnlockDirectionSuccessdBlock)success
							   failure:(TTFailedBlock)failure;

/**
 Get Accessory Electric Quantity
 @param type TTAccessoryType
 @param accessoryMac the Mac of  accessory
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)getAccessoryElectricQuantityWithType:(TTAccessoryType)type
								accessoryMac:(NSString *)accessoryMac
									lockData:(NSString *)lockData
									 success:(TTGetAccessoryElectricQuantitySuccessdBlock)success
									 failure:(TTFailedBlock)failure;

/**
 Set Lock Sound
 @param soundVolume TTSoundVolume
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)setLockSoundWithSoundVolume:(TTSoundVolume)soundVolume
						   lockData:(NSString *)lockData
							success:(TTSucceedBlock)success
							failure:(TTFailedBlock)failure;

/**
 Get Lock Sound
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)getLockSoundWithLockData:(NSString *)lockData
						 success:(TTGetLockSoundSuccessdBlock)success
						 failure:(TTFailedBlock)failure;

#pragma mark - Lock upgrade

/**
 Activate the lock into upgrade mode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is activated
 @param failure A block invoked when the operation fails
 */
+ (void)enterUpgradeModeWithLockData:(NSString *)lockData
                             success:(TTSucceedBlock)success
                             failure:(TTFailedBlock)failure;


#pragma mark - Ekey

/**
 Lock or unlock

 @param controlAction The controlAction
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock is unlock or lock
 @param failure A block invoked when the operation fails
 */
+ (void)controlLockWithControlAction:(TTControlAction)controlAction
                            lockData:(NSString *)lockData
                             success:(TTControlLockSucceedBlock)success
                             failure:(TTFailedBlock)failure;


/**
 Reset all eKey but admin eKey

 @param lockData The lock data string used to operate lock
 @param success A block invoked when eKey is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetEkeyWithLockData:(NSString *)lockData
                      success:(TTResetEkeySucceedBlock)success
                      failure:(TTFailedBlock)failure;

#pragma mark - Passcode

/**
 Modify admin passcode

 @param adminPasscode The new admin passcode is limited to 4 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when admin passcode is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyAdminPasscode:(NSString *)adminPasscode
				   lockData:(NSString *)lockData
					success:(TTSucceedBlock)success
					failure:(TTFailedBlock)failure;


/**
 Get admin passcode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when admin passcode is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAdminPasscodeWithLockData:(NSString *)lockData
							 success:(TTGetAdminPasscodeSucceedBlock)success
							 failure:(TTFailedBlock)failure;


/**
 Set admin erase passcode

 @param passcode  The erase passcode can delete all used passcode and it also limited to 7 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when erase passcode is set
 @param failure A block invoked when the operation fails
 */
+ (void)setAdminErasePasscode:(NSString *)passcode
					 lockData:(NSString *)lockData
					  success:(TTSucceedBlock)success
					  failure:(TTFailedBlock)failure;

/**
 Create custom passcode

 @param passcode The passcode is limited to 4 - 9 digits
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is created
 @param failure A block invoked when the operation fails
 */
+ (void)createCustomPasscode:(NSString *)passcode
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure;

/**
 Moddify passcode or passcode valid date

 @param passcode The passcode need to be modified
 @param newPasscode The new passcode is used to replace first passcode. If you just want to modify valid date, the new passcode should be nil. New passcode is limited to 4 - 9 digits
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyPasscode:(NSString *)passcode
		   newPasscode:(NSString *)newPasscode
			 startDate:(long long)startDate
			   endDate:(long long)endDate
			  lockData:(NSString *)lockData
			   success:(TTSucceedBlock)success
			   failure:(TTFailedBlock)failure;


/**
 Delete passcode

 @param passcode The passcode you want to delete it. Passcode is limited to 4 - 9 digits
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deletePasscode:(NSString *)passcode
			  lockData:(NSString *)lockData
			   success:(TTSucceedBlock)success
			   failure:(TTFailedBlock)failure;


/**
 Reset passcode then all passcode will be invalid

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is reseted
 @param failure A block invoked when the operation fails
 */
+ (void)resetPasscodesWithLockData:(NSString *)lockData
                           success:(TTResetPasscodesSucceedBlock)success
                           failure:(TTFailedBlock)failure;

/**
 Get all valid passcode

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid passcode is got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidPasscodesWithLockData:(NSString *)lockData
								 success:(TTGetLockAllPasscodeSucceedBlock)success
								 failure:(TTFailedBlock)failure;

/**
 Recover passcode

 @param passcode Old Passcode
 @param newPasscode New Passcode is limited to 4 - 9 digits
 @param passcodeType Passcode Type
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired. If passwordType != TTPasscodeTypePeriod ,can set 0
 @param cycleType Cycle Type , if passwordType != TTPasscodeTypeCycle ,can set any value
 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverPasscode:(NSString *)passcode
			newPasscode:(NSString *)newPasscode
		   passcodeType:(TTPasscodeType)passcodeType
			  startDate:(long long)startDate
				endDate:(long long)endDate
			  cycleType:(int)cycleType
			   lockData:(NSString *)lockData
				success:(TTSucceedBlock)success
				failure:(TTFailedBlock)failure;

/**
 Get passcode data

 @param lockData The lock data string used to operate lock
 @param success A block invoked when passcode data is got
 @param failure A block invoked when the operation fails
 */
+ (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData
                                          success:(TTGetPasscodeVerificationParamsSucceedBlock)success
                                          failure:(TTFailedBlock)failure;


#pragma mark - IC card

/**
 Add  IC card

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
					 startTime The time when it becomes valid (minutes from 0 clock)
					 endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when  adding
 @param success A block invoked when card is added
 @param failure A block invoked when the operation fails
 */
+ (void)addICCardWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
						startDate:(long long)startDate
						  endDate:(long long)endDate
						 lockData:(NSString *)lockData
						 progress:(TTAddICProgressBlock)progress
						  success:(TTAddICSucceedBlock)success
						  failure:(TTFailedBlock)failure;

/**
 Modify  IC card valid date

 @param cyclicConfig null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
					 startTime The time when it becomes valid (minutes from 0 clock)
					 endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param cardNumber The card number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyICCardValidityPeriodWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
										cardNumber:(NSString *)cardNumber
										 startDate:(long long)startDate
										   endDate:(long long)endDate
										  lockData:(NSString *)lockData
										   success:(TTSucceedBlock)success
										   failure:(TTFailedBlock)failure;

/**
 Delete IC card

 @param cardNumber The card number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deleteICCardNumber:(NSString *)cardNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;

/**
 Clear all IC cards

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all cards are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearAllICCardsWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;


/**
 Get all valid IC cards

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid cards are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidICCardsWithLockData:(NSString *)lockData
                               success:(TTGetAllICCardsSucceedBlock)success
                               failure:(TTFailedBlock)failure;


/**
 Recover IC card

 @param cyclicConfig   null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param cardNumber The card number you want to recover
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverICCardWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                           cardNumber:(NSString *)cardNumber
                            startDate:(long long)startDate
                              endDate:(long long)endDate
                             lockData:(NSString *)lockData
                              success:(TTAddICSucceedBlock)success
                              failure:(TTFailedBlock)failure;


#pragma mark - Fingerprint

/**
 Add  fingerprint by pressing finger on the lock

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
					 startTime The time when it becomes valid (minutes from 0 clock)
					 endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when  adding
  currentCount == -1 || totalCount  == -1 means unknown,continue adding.
 @param success A block invoked when fingerprint is added
 @param failure A block invoked when the operation fails
 */
+ (void)addFingerprintWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
							 startDate:(long long)startDate
							   endDate:(long long)endDate
							  lockData:(NSString *)lockData
							  progress:(TTAddFingerprintProgressBlock)progress
							   success:(TTAddFingerprintSucceedBlock)success
							   failure:(TTFailedBlock)failure;

/**
 Modify  fingerprint valid date

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
					 startTime The time when it becomes valid (minutes from 0 clock)
					 endTime  The time when it is expired (minutes from 0 clock)
					 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param fingerprintNumber The fingerprint number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyFingerprintValidityPeriodWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
									  fingerprintNumber:(NSString *)fingerprintNumber
											  startDate:(long long)startDate
												endDate:(long long)endDate
											   lockData:(NSString *)lockData
												success:(TTSucceedBlock)success
												failure:(TTFailedBlock)failure;

/**
 Delete fingerprint

 @param fingerprintNumber The fingerprint number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is modified
 @param failure A block invoked when the operation fails
 */
+ (void)deleteFingerprintNumber:(NSString *)fingerprintNumber
                       lockData:(NSString *)lockData
                        success:(TTSucceedBlock)success
                        failure:(TTFailedBlock)failure;


/**
 Clear all fingerprints

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all fingerprints are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearAllFingerprintsWithLockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure;


/**
 Get all valid fingerprint numbers

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid fingerprint numbers  are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidFingerprintsWithLockData:(NSString *)lockData
                                    success:(TTGetAllFingerprintsSucceedBlock)success
                                    failure:(TTFailedBlock)failure;

/**
 Recover Fingerprint

 @param cyclicConfig   null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param fingerprintNumber The fingerprint number you want to recover
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is recovered
 @param failure A block invoked when the operation fails
 */
+ (void)recoverFingerprintWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                         fingerprintNumber:(NSString *)fingerprintNumber
                                 startDate:(long long)startDate
                                   endDate:(long long)endDate
                                  lockData:(NSString *)lockData
                                   success:(TTAddFingerprintSucceedBlock)success
                                   failure:(TTFailedBlock)failure;

/**
 Add new fingerprint by  writing fingerprint data to the lock

 @param fingerprintData The fingerprint data is obtained by the fingerprint collector
 @param tempFingerprintNumber tempFingerprintNumber
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when fingerprint is added
 @param failure A block invoked when the operation fails
 */
+ (void)writeFingerprintData:(NSString *)fingerprintData
	   tempFingerprintNumber:(NSString *)tempFingerprintNumber
				   startDate:(long long)startDate
					 endData:(long long)endDate
					lockData:(NSString *)lockData
					 success:(TTAddFingerprintSucceedBlock)success
					 failure:(TTFailedBlock)failure;

#pragma mark - Key Fob

/**
 Add Wireless Key Fob

 @param cyclicConfig          null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param keyFobMac key Fob Mac
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)addWirelessKeyFobWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                                keyFobMac:(NSString *)keyFobMac
                                startDate:(long long)startDate
                                  endDate:(long long)endDate
                                 lockData:(NSString *)lockData
                                  success:(TTSucceedBlock)success
                                  failure:(TTFailedBlock)failure;

/**
 Modify  Wireless Key Fob valid date

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param keyFobMac key Fob Mac
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)modifyWirelessKeyFobValidityPeriodWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                                                 keyFobMac:(NSString *)keyFobMac
                                                 startDate:(long long)startDate
                                                   endDate:(long long)endDate
                                                  lockData:(NSString *)lockData
                                                   success:(TTSucceedBlock)success
                                                   failure:(TTFailedBlock)failure;

/**
 Delete Wireless Key Fob

 @param keyFobMac key Fob Mac
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)deleteWirelessKeyFobWithKeyFobMac:(NSString *)keyFobMac
                                 lockData:(NSString *)lockData
                                  success:(TTSucceedBlock)success
                                  failure:(TTFailedBlock)failure;


/**
 Clear  Wireless Key Fobs

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)clearWirelessKeyFobsWithLockData:(NSString *)lockData
                                 success:(TTSucceedBlock)success
                                 failure:(TTFailedBlock)failure;


#pragma mark - NB-IoT

/**
 Set the lock nb-iot

 @param serverAddress The server ip
 @param portNumber The server port
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the lock nb-iot is set
 @param failure A block invoked when the operation fails
 */
+ (void)setNBServerAddress:(NSString *)serverAddress
				portNumber:(NSString *)portNumber
				  lockData:(NSString *)lockData
				   success:(TTGetElectricQuantitySucceedBlock)success
				   failure:(TTFailedBlock)failure;

/**
Set NB Awake Modes
 
@param awakeModes enum TTNBAwakeMode ,such as @[TTNBAwakeModeKeypad,TTNBAwakeModeCard,TTNBAwakeModeFingerprint]
				  awakeModes.count == 0, means no awake mode
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setNBAwakeModes:(NSArray <NSNumber *> *)awakeModes
			   lockData:(NSString *)lockData
				success:(TTSucceedBlock)success
				failure:(TTFailedBlock)failure;

/**
Get NB Awake Modes
 
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)getNBAwakeModesWithLockData:(NSString *)lockData
							success:(TTGetNBAwakeModesSuccessdBlock)success
							failure:(TTFailedBlock)failure;

/**
Set NB Awake Modes
 
@param awakeTimes awakeTimes.count must <= 10 ,awakeTimes.count == 0 means delete awakeTimes.
				  type enum TTNBAwakeTimeType, minutes means minutes from 0 clock or time interval
				  such as,@[@{@"type":@(TTNBAwakeTimeTypePoint),@"minutes":@100}]
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setNBAwakeTimes:(NSArray<NSDictionary *> *)awakeTimes
			   lockData:(NSString *)lockData
				success:(TTSucceedBlock)success
				failure:(TTFailedBlock)failure;

/**
Get NB Awake Times
 
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)getNBAwakeTimesWithLockData:(NSString *)lockData
							success:(TTGetNBAwakeTimesSuccessdBlock)success
							failure:(TTFailedBlock)failure;


#pragma mark - Hotel

/**
 Set Hotel Card Sector
 @param sector  connect with comma symbol,Such as, sector = @"1,4,16" means First, fourth and sixteenth sectors can use.
 sector = @"" means all sectors can use. The sector value range is 1 - 16.
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)setHotelCardSector:(NSString *)sector
				  lockData:(NSString *)lockData
				   success:(TTSucceedBlock)success
				   failure:(TTFailedBlock)failure;

/**
Set Hotel Data

@param hotelInfo hotel Info
@param buildingNumber building Number
@param floorNumber floor Number
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setHotelDataWithHotelInfo:(NSString *)hotelInfo
				   buildingNumber:(int)buildingNumber
					  floorNumber:(int)floorNumber
						 lockData:(NSString *)lockData
						  success:(TTSucceedBlock)success
						  failure:(TTFailedBlock)failure;

/**
 Report Loss Card

 @param cardNumber The card number you want to report loss
 @param lockData The lock data string used to operate lock
 @param success A block invoked when card is reported loss
 @param failure A block invoked when the operation fails
 */
+ (void)reportLossCard:(NSString *)cardNumber
			  lockData:(NSString *)lockData
			   success:(TTSucceedBlock)success
			   failure:(TTFailedBlock)failure;

/**
Activate Lift Floors
 
@param floors lift floors,connect with comma symbol,such as: @"1,2,3"
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)activateLiftFloors:(NSString *)floors
				  lockData:(NSString *)lockData
				   success:(TTActivateLiftSuccessdBlock)success
				   failure:(TTFailedBlock)failure;

/**
Set Lift Controlable Floors
 
@param floors lift floors,connect with comma symbol,such as: @"1,2,3"
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setLiftControlableFloors:(NSString *)floors
							lockData:(NSString *)lockData
							 success:(TTSucceedBlock)success
							 failure:(TTFailedBlock)failure;

/**
Set Lift Work Mode
 
@param workMode TTLiftWorkMode
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setLiftWorkMode:(TTLiftWorkMode)workMode
				   lockData:(NSString *)lockData
					success:(TTSucceedBlock)success
					failure:(TTFailedBlock)failure;


/**
Set Power Saver Work Mode
 
@param workMode TTPowerSaverWorkMode
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setPowerSaverWorkMode:(TTPowerSaverWorkMode)workMode
					 lockData:(NSString *)lockData
					  success:(TTSucceedBlock)success
					  failure:(TTFailedBlock)failure;

/**
Set Power Saver Controlable Lock
 
@param lockMac the controlable lock mac, @"" or nil means no control Lock
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setPowerSaverControlableLockWithLockMac:(NSString *)lockMac
									   lockData:(NSString *)lockData
										success:(TTSucceedBlock)success
										failure:(TTFailedBlock)failure;

#pragma mark - Wifi Lock

/**
Scan Wifi
 
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)scanWifiWithLockData:(NSString *)lockData
                     success:(TTScanWifiSuccessdBlock)success
                     failure:(TTFailedBlock)failure;

/**
Config Wifi
@param SSID wifi name
@param wifiPassword wifi password
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)configWifiWithSSID:(NSString *)SSID
              wifiPassword:(NSString *)wifiPassword
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;
/**
Config Server
@param serverAddress set @"" if you use our default server @"wifilock.ttlock.com"
@param portNumber set @"" if you use our default server @"4999"
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)configServerWithServerAddress:(NSString *)serverAddress
                           portNumber:(NSString *)portNumber
                             lockData:(NSString *)lockData
                              success:(TTSucceedBlock)success
                              failure:(TTFailedBlock)failure;
/**
Config Ip
@param info @{@"type":@(x), @"ipAddress": xxx, @"subnetMask": xxx, @"router": xxx, @"preferredDns": xxx, @"alternateDns": xxx}
 type  @(0) means manual, @(1) means automatic
 ipAddress (option)  such as 0.0.0.0
 subnetMask (option)  such as 255.255.0.0
 router (option)  such as 0.0.0.0
 preferredDns (option)  such as 0.0.0.0
 alternateDns (option)  such as 0.0.0.0
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)configIpWithInfo:(NSDictionary *)info
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                 failure:(TTFailedBlock)failure;
/**
 Get Wifi Info
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)getWifiInfoWithLockData:(NSString *)lockData
                        success:(TTGetWifiInfoSuccessdBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Add Door Sensor
@param doorSensorMac door Sensor Mac
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)addDoorSensorWithDoorSensorMac:(NSString *)doorSensorMac
                              lockData:(NSString *)lockData
                               success:(TTSucceedBlock)success
                               failure:(TTFailedBlock)failure;

/**
 Clear Door Sensor
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)clearDoorSensorWithLockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;

/**
 Set Door Sensor Alert Time
@param time  Alert Time
@param lockData The lock data string used to operate lock
@param success A block invoked when the operation is successful
@param failure A block invoked when the operation fails
*/
+ (void)setDoorSensorAlertTime:(int)time
                      lockData:(NSString *)lockData
                       success:(TTSucceedBlock)success
                       failure:(TTFailedBlock)failure;

#pragma mark - Face

/**
 Add Face

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when adding
 @param success A block invoked when face is added
 @param failure A block invoked when the operation fails
 */
+ (void)addFaceWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                      startDate:(long long)startDate
                        endDate:(long long)endDate
                       lockData:(NSString *)lockData
                       progress:(TTAddFaceProgressBlock)progress
                        success:(TTAddFaceSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Modify  face valid date

 @param cyclicConfig null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param faceNumber The face number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when face is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyFaceValidityWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                                faceNumber:(NSString *)faceNumber
                                 startDate:(long long)startDate
                                   endDate:(long long)endDate
                                  lockData:(NSString *)lockData
                                   success:(TTSucceedBlock)success
                                   failure:(TTFailedBlock)failure;

/**
 Delete Face

 @param faceNumber The face number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when face is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deleteFaceNumber:(NSString *)faceNumber
                  lockData:(NSString *)lockData
                   success:(TTSucceedBlock)success
                   failure:(TTFailedBlock)failure;

/**
 Clear all faces

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all faces are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearFaceWithLockData:(NSString *)lockData
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;


/**
 Get all valid faces
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid faces are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidFacesWithLockData:(NSString *)lockData
                             success:(TTGetAllValidFacesSucceedBlock)success
                             failure:(TTFailedBlock)failure;


/**
 Add  face feature data

 @param featureData The face feature data you want to add
 @param cyclicConfig   null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param success A block invoked when face is added
 @param failure A block invoked when the operation fails
 */
+ (void)addFaceFeatureData:(NSString *)featureData
              cyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                 startDate:(long long)startDate
                   endDate:(long long)endDate
                  lockData:(NSString *)lockData
                   success:(TTAddFaceSucceedBlock)success
                   failure:(TTFailedBlock)failure;

#pragma mark - Palm Vein

/**
 Add Palm Vein

 @param cyclicConfig  null array @[] , means no cyclic
                     weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
                     startTime The time when it becomes valid (minutes from 0 clock)
                     endTime  The time when it is expired (minutes from 0 clock)
                     such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param startDate The time when it becomes valid, If it's a permanent key, set 0
 @param endDate The time when it is expired, If it's a permanent key, set 0
 @param lockData The lock data string used to operate lock
 @param progress A block invoked when adding
 @param success A block invoked when palm vein is added
 @param failure A block invoked when the operation fails
 */
+ (void)addPalmVeinWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                          startDate:(long long)startDate
                            endDate:(long long)endDate
                           lockData:(NSString *)lockData
                           progress:(TTAddPalmVeinProgressBlock)progress
                            success:(TTAddPalmVeinSucceedBlock)success
                            failure:(TTFailedBlock)failure;

/**
 Modify  Palm Vein valid date
 
 @param cyclicConfig null array @[] , means no cyclic
 weekDay  1~7,1 means Monday，2 means  Tuesday ,...,7 means Sunday
 startTime The time when it becomes valid (minutes from 0 clock)
 endTime  The time when it is expired (minutes from 0 clock)
 such as @[@{@"weekDay":@1,@"startTime":@10,@"endTime":@100},@{@"weekDay":@2,@"startTime":@10,@"endTime":@100}]
 @param palmVeinNumber The palm vein number you want to modify
 @param startDate The time when it becomes valid
 @param endDate The time when it is expired
 @param lockData The lock data string used to operate lock
 @param success A block invoked when palm vein is modified
 @param failure A block invoked when the operation fails
 */
+ (void)modifyPalmVeinValidityWithCyclicConfig:(NSArray <NSDictionary *> *)cyclicConfig
                                palmVeinNumber:(NSString *)palmVeinNumber
                                     startDate:(long long)startDate
                                       endDate:(long long)endDate
                                      lockData:(NSString *)lockData
                                       success:(TTSucceedBlock)success
                                       failure:(TTFailedBlock)failure;

/**
 Delete Palm Vein

 @param palmVeinNumber The palm vein number you want to delete
 @param lockData The lock data string used to operate lock
 @param success A block invoked when palm vein number is deleted
 @param failure A block invoked when the operation fails
 */
+ (void)deletePalmVeinNumber:(NSString *)palmVeinNumber
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure;

/**
 Clear all palm veins

 @param lockData The lock data string used to operate lock
 @param success A block invoked when all palm veins are cleared
 @param failure A block invoked when the operation fails
 */
+ (void)clearPalmVeinWithLockData:(NSString *)lockData
                          success:(TTSucceedBlock)success
                          failure:(TTFailedBlock)failure;


/**
 Get all valid palm veins
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when all valid palm veins are got
 @param failure A block invoked when the operation fails
 */
+ (void)getAllValidPalmVeinsWithLockData:(NSString *)lockData
                                 success:(TTGetAllValidPalmVeinsSucceedBlock)success
                                 failure:(TTFailedBlock)failure;


/**
 Set Sensitivity
 @param value TTSensitivityValue
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)setSensitivityWithValue:(TTSensitivityValue)value
                           lockData:(NSString *)lockData
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;

/**
 Get Sensitivity
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
*/
+ (void)getSensitivityWithLockData:(NSString *)lockData
                         success:(TTGetSensitivitySuccessBlock)success
                         failure:(TTFailedBlock)failure;

/**
 Get the lock log Parallel

 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)getOperationLogParallelWithLockData:(NSString *)lockData
                        success:(TTGetLockOperateRecordSucceedBlock)success
                        failure:(TTFailedBlock)failure;

/**
 Reset lock by code

 @param resetCode Reset Code
 @param lockMac lock Mac
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)resetLockByCodeWithResetCode:(NSString *)resetCode
                           lockMac:(NSString *)lockMac
                            success:(TTSucceedBlock)success
                            failure:(TTFailedBlock)failure;

/**
 Verify Lock,  after the lock send out sound and light, please touch the lock to complete the verification.
 
 @param lockMac lock Mac
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)verifyLockWithLockMac:(NSString *)lockMac
                      success:(TTSucceedBlock)success
                      failure:(TTFailedBlock)failure;

#pragma mark - Stick Lock

/**
 Set Unlock Angle
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful, , angle value -180 到 180
 @param failure A block invoked when the operation fails
 */
+ (void)setUnlockAngleWithLockData:(NSString *)lockData
                           success:(TTAngleSucceedBlock)success
                           failure:(TTFailedBlock)failure;

/**
 Set Lock Angle
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful, , angle value -180 到 180
 @param failure A block invoked when the operation fails
 */
+ (void)setLockAngleWithLockData:(NSString *)lockData
                         success:(TTAngleSucceedBlock)success
                         failure:(TTFailedBlock)failure;

/**
 Set Auto Angle
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful, angle value -180 到 180
 @param failure A block invoked when the operation fails
 */
+ (void)setAutoAngleWithLockData:(NSString *)lockData
                         success:(TTAngleSucceedBlock)success
                         failure:(TTFailedBlock)failure;

/**
 Get Angle
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful, angle value -180 到 180
 @param failure A block invoked when the operation fails
 */
+ (void)getAngleWithLockData:(NSString *)lockData
                     success:(TTAngleSucceedBlock)success
                     failure:(TTFailedBlock)failure;

/**
 Auto Set Unlock Direction
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)autoSetUnlockDirectionWithLockData:(NSString *)lockData
                                   success:(TTAutoUnlockDirectionSucceedBlock)success
                                   failure:(TTFailedBlock)failure;

/**
 Get Motor Drive Time
 
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)getMotorDriveTimeWithLockData:(NSString *)lockData
                              success:(TTGetMotorDriveTimeSuccessBlock)success
                              failure:(TTFailedBlock)failure;

/**
 Set Motor Drive Time
 @param driveTime  value range: 0 - 65535,  unit: millisecond
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful
 @param failure A block invoked when the operation fails
 */
+ (void)setMotorDriveTime:(int)driveTime
                 lockData:(NSString *)lockData
                  success:(TTSucceedBlock)success
                  failure:(TTFailedBlock)failure;

/**
 Modify Lock FeatureValue
 @param types  enum  TTSupportFeature , such as @[TTSupportFeatureFingerprint,TTSupportFeatureCard,TTSupportFeaturePasscode]
  @[] (types.count == 0), means none of them are supported
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful. if you want to get newest lockData, please call method "getLockSystemInfo".
 @param failure A block invoked when the operation fails
 */
+ (void)modifyLockFeatureValueWithTypes:(NSArray <NSNumber *>*)types
                               lockData:(NSString *)lockData
                                success:(TTSucceedBlock)success
                                failure:(TTFailedBlock)failure;

/**
 Modify Lock Name Prefix
 @param lockNamePrefix   prefix
 @param lockData The lock data string used to operate lock
 @param success A block invoked when the operation is successful. if you want to get newest lockData, please call method "getLockSystemInfo".
 @param failure A block invoked when the operation fails
 */
+ (void)modifyLockNamePrefix:(NSString *)lockNamePrefix
                    lockData:(NSString *)lockData
                     success:(TTSucceedBlock)success
                     failure:(TTFailedBlock)failure;

#pragma mark - deprecated
+ (void)getLockSpecialValueWithLockData:(NSString *)lockData
                                success:(TTGetSpecialValueSucceedBlock)success
                                failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,Use getLockFeatureValue");

+ (void)setLockFreezeStateWithOn:(BOOL)on
                        lockData:(NSString *)lockData
                         success:(TTSucceedBlock)success
                         failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,setLockConfig");

+ (void)getLockFreezeStateWithLockData:(NSString *)lockData
                               success:(TTGetLockConfigSuccessBlock)success
                               failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,getLockConfig");

+ (void)setAudioSwitchOn:(BOOL)on
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                 failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,setLockConfig");

+ (void)getAudioSwitchWithLockData:(NSString *)lockData
                           success:(TTGetLockConfigSuccessBlock)success
                           failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,getLockConfig");

+ (void)setPasscodeVisibleSwitchOn:(BOOL)on
                          lockData:(NSString *)lockData
                           success:(TTSucceedBlock)success
                           failure:(TTFailedBlock)failure  DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,setLockConfig");

+ (void)getPasscodeVisibleSwitchWithLockData:(NSString *)lockData
                                     success:(TTGetLockConfigSuccessBlock)success
                                     failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,getLockConfig");

+ (void)setHotelCardSectorWithSectorArr:(NSArray <NSNumber *>*)sectorArr
							   lockData:(NSString *)lockData
								success:(TTSucceedBlock)success
								failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.0,setHotelCardSector");

+ (void)addFingerprintStartDate:(long long)startDate
						endDate:(long long)endDate
					   lockData:(NSString *)lockData
					   progress:(TTAddFingerprintProgressBlock)progress
						success:(TTAddFingerprintSucceedBlock)success
						failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,addFingerprintWithCyclicConfig");

+ (void)modifyFingerprintValidityPeriodWithFingerprintNumber:(NSString *)fingerprintNumber
												   startDate:(long long)startDate
													 endDate:(long long)endDate
													lockData:(NSString *)lockData
													 success:(TTSucceedBlock)success
													 failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,modifyFingerprintValidityPeriodWithCyclicConfig");

+ (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData
                                success:(TTAddFingerprintSucceedBlock)success
                                failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,recoverFingerprintWithCyclicConfig");


+ (void)addICCardStartDate:(long long)startDate
				   endDate:(long long)endDate
				  lockData:(NSString *)lockData
				  progress:(TTAddICProgressBlock)progress
				   success:(TTAddICSucceedBlock)success
				   failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,addICCardWithCyclicConfig");

+ (void)modifyICCardValidityPeriodWithCardNumber:(NSString *)cardNumber
									   startDate:(long long)startDate
										 endDate:(long long)endDate
										lockData:(NSString *)lockData
										 success:(TTSucceedBlock)success
										 failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,modifyICCardValidityPeriodWithCyclicConfig");

+ (void)recoverICCardNumber:(NSString *)cardNumber
                  startDate:(long long)startDate
                    endDate:(long long)endDate
                   lockData:(NSString *)lockData
                    success:(TTAddICSucceedBlock)success
                    failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.2.0,recoverICCardWithCyclicConfig");

+ (void)getLockVersionWithWithLockMac:(NSString *)lockMac
							  success:(TTGetLockVersionSucceedBlock)success
							  failure:(TTFailedBlock)failure DEPRECATED_MSG_ATTRIBUTE("SDK3.1.5,getLockVersion");
@end

