//
//  TTHumanPresenceSensor.h
//  TTLock
//
//  Created by Juanny on 2026/6/17.
//  Copyright © 2026 TTLock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBlocks.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, TTHumanPresenceSensorError) {
    TTHumanPresenceSensorBluetoothPowerOff = -1,
    TTHumanPresenceSensorConnectTimeout = -2 ,
    TTHumanPresenceSensorDisconnect = -3,
    TTHumanPresenceSensorWrongCRC = 1,
    TTHumanPresenceSensorDecryptFail = 2,
    TTHumanPresenceSensorFail = 3,
};

typedef NS_ENUM(int, TTSensorSensitivityValue) {
    TTSensorSensitivityValueOff = 0,
    TTSensorSensitivityValueLow = 1,
    TTSensorSensitivityValueMediumLow = 2,
    TTSensorSensitivityValueMedium = 3,
    TTSensorSensitivityValueMediumHigh = 4,
    TTSensorSensitivityValueHigh = 5,
};

typedef NS_ENUM(int, TTLedLightValue) {
    TTLedLightValueOff = 0,
    TTLedLightValueOn = 1,
    TTLedLightValueQuickFlashing = 2,
};



@interface TTHumanPresenceSensorScanModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) BOOL hasHumanPresence;
@property (nonatomic, assign) long long scanTime; //millisecond

@end

@interface TTHumanPresenceSensorAddResult : NSObject

@property (nonatomic, assign) TTSensorSensitivityValue sensitivityValue;
@property (nonatomic, strong) NSString *modelNum;
@property (nonatomic, strong) NSString *hardwareRevision;
@property (nonatomic, strong) NSString *firmwareRevision;

@end

@interface TTHumanPresenceSensor : NSObject

typedef void(^TTHumanPresenceSensorScanBlock)(TTHumanPresenceSensorScanModel *model);
typedef void(^TTHumanPresenceSensorSuccessBlock)(void);
typedef void(^TTHumanPresenceSensorAddSuccessBlock)(TTHumanPresenceSensorAddResult *result);
typedef void(^TTGetSensorSensitivitySuccessBlock)(TTSensorSensitivityValue value);
typedef void(^TTHumanPresenceSensorFailBlock)(TTHumanPresenceSensorError error, NSString *errorMsg);

+ (void)startScanWithSuccess:(TTHumanPresenceSensorScanBlock)success
                     failure:(TTHumanPresenceSensorFailBlock)failure;
+ (void)stopScan;
/**
 Add  Human Presence Sensor  (The lock and human presence sensor must be nearby )
 @param sensorMac  sensor Mac
 @param lockData  lockData of the lock
 @param success  A block invoked when the operation is successful
 @param lockFailure  By lock,  block invoked when the operation fails
 @param sensorFailure  By sensor, a block invoked when the operation fails
 */
+ (void)addWithSensorMac:(NSString *)sensorMac
                lockData:(NSString *)lockData
                 success:(TTHumanPresenceSensorAddSuccessBlock)success
             lockFailure:(TTFailedBlock)lockFailure
           sensorFailure:(TTHumanPresenceSensorFailBlock)sensorFailure;

/**
 Set Sensitivity  ( Only human presence sensor must be nearby )
 @param sensorMac  sensor Mac
 @param sensitivityValue  ENUM: TTSensorSensitivityValue
 @param success  A block invoked when the operation is successful
 @param sensorFailure  By sensor, a block invoked when the operation fails
 */
+ (void)setSensitivityWithSensorMac:(NSString *)sensorMac
                   sensitivityValue:(TTSensorSensitivityValue)sensitivityValue
                         success:(TTHumanPresenceSensorSuccessBlock)success
                   sensorFailure:(TTHumanPresenceSensorFailBlock)sensorFailure;

/**
 Get Sensitivity  ( Only human presence sensor must be nearby )
 @param sensorMac  sensor Mac
 @param success  A block invoked when the operation is successful
 @param sensorFailure  By sensor, a block invoked when the operation fails
 */
+ (void)getSensitivityWithSensorMac:(NSString *)sensorMac
                         success:(TTGetSensorSensitivitySuccessBlock)success
                   sensorFailure:(TTHumanPresenceSensorFailBlock)sensorFailure;

/**
 Set Led Light  ( Only human presence sensor must be nearby )
 @param sensorMac  sensor Mac
 @param value  ENUM: TTLedLightValue
 @param success  A block invoked when the operation is successful
 @param sensorFailure  By sensor, a block invoked when the operation fails
 */
+ (void)setLedLightWithSensorMac:(NSString *)sensorMac
                           value:(TTLedLightValue)value
                         success:(TTHumanPresenceSensorSuccessBlock)success
                   sensorFailure:(TTHumanPresenceSensorFailBlock)sensorFailure;

/**
 Enter Upgrade Mode  ( Only human presence sensor must be nearby )
 @param sensorMac  sensor Mac
 @param success  A block invoked when the operation is successful
 @param sensorFailure  By sensor, a block invoked when the operation fails
 */
+ (void)enterUpgradeModeWitSensorMac:(NSString *)sensorMac
                        success:(TTHumanPresenceSensorSuccessBlock)success
                       sensorFailure:(TTHumanPresenceSensorFailBlock)sensorFailure;

/**
 Delete  ( Only lock must be nearby )
 @param sensorMac  sensor Mac
 @param lockData  lockData of the lock
 @param success  A block invoked when the operation is successful
 @param lockFailure  By lock,  block invoked when the operation fails
 */
+ (void)deleteWithSensorMac:(NSString *)sensorMac
                lockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
                lockFailure:(TTFailedBlock)lockFailure;

/**
 Clear  ( Only lock must be nearby )
 @param lockData  lockData of the lock
 @param success  A block invoked when the operation is successful
 @param lockFailure  By lock,  block invoked when the operation fails
 */
+ (void)clearWithLockData:(NSString *)lockData
                 success:(TTSucceedBlock)success
              lockFailure:(TTFailedBlock)lockFailure;

@end

NS_ASSUME_NONNULL_END
