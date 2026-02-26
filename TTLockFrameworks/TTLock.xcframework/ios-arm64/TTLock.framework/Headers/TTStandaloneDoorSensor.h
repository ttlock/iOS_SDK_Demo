//
//  TTStandaloneDoorSensor.h
//  TTLock
//
//  Created by Juanny on 2025/3/19.
//  Copyright © 2025 TTLock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTStandaloneDoorSensorScanModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) long long scanTime; //millisecond

@end

@interface TTStandaloneDoorSensorInitModel : NSObject

@property (nonatomic, strong) NSString *doorSensorData;
@property (nonatomic, assign) int electricQuantity;
@property (nonatomic, strong) NSString *featureValue;
@property (nonatomic, strong) NSString *wifiMac;
@property (nonatomic, strong) NSString *modelNum;
@property (nonatomic, strong) NSString *hardwareRevision;
@property (nonatomic, strong) NSString *firmwareRevision;

@end

typedef NS_ENUM(NSInteger, TTStandaloneDoorSensorError){
    TTStandaloneDoorSensorBluetoothPowerOff = -1,
    TTStandaloneDoorSensorConnectTimeout = -2 ,
    TTStandaloneDoorSensorDisconnect = -3,
    TTStandaloneDoorSensorFail = 1,
    TTStandaloneDoorSensorWrongCRC = 2,
    TTStandaloneDoorSensorWrongSSID = 3,
    TTStandaloneDoorSensorWrongWifiPassword = 4,
};

typedef NS_ENUM(NSInteger,TTStandaloneDoorSensorFeature) {
    TTStandaloneDoorSensorFeature24GWifi = 0,  // 2.4G Wifi
    TTStandaloneDoorSensorFeature5GWifi = 1,
    TTStandaloneDoorSensorFeatureAuthCode = 2,
};

@interface TTStandaloneDoorSensor : NSObject

typedef void(^TTStandaloneDoorSensorScanBlock)(TTStandaloneDoorSensorScanModel *model);
typedef void(^TTStandaloneDoorSensorFailBlock)(TTStandaloneDoorSensorError error, NSString *errorMsg);
typedef void(^TTStandaloneDoorSensorInitBlock)(TTStandaloneDoorSensorInitModel *initModel);
typedef void(^TTStandaloneDoorSensorGetFeatureValueBlock)(NSString *featureValue);

+ (void)startScanWithSuccess:(TTStandaloneDoorSensorScanBlock)success
                     failure:(TTStandaloneDoorSensorFailBlock)failure;
+ (void)stopScan;

// @param infoDic @{@"SSID": xxx, @"wifiPwd": xxx,@"serverAddress":xxx,@"portNumber":xxx}
+ (void)initWithInfo:(NSDictionary *)info
                 mac:(NSString *)mac
             success:(TTStandaloneDoorSensorInitBlock)success
             failure:(TTStandaloneDoorSensorFailBlock)failure;

+ (void)getFeatureValueWithMac:(NSString *)mac
                       success:(TTStandaloneDoorSensorGetFeatureValueBlock)success
                       failure:(TTStandaloneDoorSensorFailBlock)failure;

+ (BOOL)supportFunction:(TTStandaloneDoorSensorFeature)function featureValue:(NSString *)featureValue;

@end

NS_ASSUME_NONNULL_END
