//
//  TTDeviceDFU.h
//  TTLockSourceCodeDemo
//
//  Created by Juanny on 2025/9/23.
//  Copyright © 2025 Sciener. All rights reserved.
//  version:3.5.6

#import <Foundation/Foundation.h>
#import <TTLock/TTLock.h>
#import "TTDFUMacros.h"
#import "TTLockDFU.h"
#import "TTGatewayDFU.h"

NS_ASSUME_NONNULL_BEGIN

/**
Gateway Device
If the gateway is online,  use TTDeviceTypeGatewayByNet.
Re connect the gateway power, use TTDeviceTypeGatewayByBluetooth.
 */
typedef NS_ENUM(NSInteger,TTDeviceType) {
    TTDeviceTypeLock,
    TTDeviceTypeGatewayByNet,
    TTDeviceTypeGatewayByBluetooth,
    TTDeviceTypeWaterMeter,
    TTDeviceTypeElectricMeter,
    TTDeviceTypeKeypad,
    TTDeviceTypeRemote,
    TTDeviceTypeDoorSensor,
};

@interface TTDeviceDFUModel : NSObject

@property (nonatomic, assign) TTDeviceType type;
@property (nonatomic, assign) NSInteger deviceId;
@property (nonatomic, strong) NSString *deviceMac;

// Lock, Remote and DoorSensor need to set this value, the lockData of lock
@property (nonatomic, strong) NSString *lockData;
// Keypad need to set this value
@property (nonatomic, assign) NSInteger slotNumber;
// Remote need to set this value , if the remote has featureValue
@property (nonatomic, strong) NSString *featureValue;

@end

@interface TTDeviceDFU : NSObject

+ (instancetype)shareInstance;

- (void)startDfuWithClientId:(NSString *)clientId
                 accessToken:(NSString *)accessToken
                 deviceModel:(TTDeviceDFUModel *)deviceModel
                successBlock:(TTLockDFUSuccessBlock )sblock
                   failBlock:(TTLockDFUFailBlock )fblock;

- (void)endUpgrade;

//only do dfu operation, SDK will set the lock to enter upgrade mode and upgrade it,
- (void)startDfuWithFirmwarePackage:(NSString *)firmwarePackage
                        deviceModel:(TTDeviceDFUModel *)deviceModel
                       successBlock:(TTLockDFUSuccessBlock)sblock
                          failBlock:(TTLockDFUFailBlock)fblock;

// This value can be unset, using the default value
@property (nonatomic, strong) NSString *url;

NS_ASSUME_NONNULL_END

@end

