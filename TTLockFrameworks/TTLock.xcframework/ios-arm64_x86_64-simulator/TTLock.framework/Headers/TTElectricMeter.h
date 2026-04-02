//
//  TTElectricMeter.h
//  TTLock
//
//  Created by Juanny on 2024/9/6.
//  Copyright © 2024 TTLock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTElectricMeterModel : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) BOOL isInited;
@property (nonatomic, assign) long long scanTime; // Unit: millisecond
@property (nonatomic, strong) NSString *executeResponse;

// Only when type == 1, the following values exist
@property (nonatomic, assign) BOOL onOff; // 0: power off, 1: power on
@property (nonatomic, assign) NSInteger payMode; // 0: Postpaid, 1: Prepaid
@property (nonatomic, strong) NSString *totalKwh;
@property (nonatomic, strong) NSString *remainderKwh;
@property (nonatomic, strong) NSString *voltage;
@property (nonatomic, strong) NSString *electricCurrent;

@end

@interface TTElectricMeterAddResult : NSObject

@property (nonatomic, assign) NSInteger electricMeterId;
@property (nonatomic, strong) NSString *featureValue;

@end

@interface TTElectricDeviceInfoModel : NSObject

@property (nonatomic,strong) NSString *modelNum;
@property (nonatomic,strong) NSString *hardwareRevision;
@property (nonatomic,strong) NSString *firmwareRevision;
// Cat One
@property (nonatomic, copy) NSString *catOneOperator;
@property (nonatomic, copy) NSString *catOneNodeId;
@property (nonatomic, copy) NSString *catOneCardNumber;
@property (nonatomic, copy) NSString *catOneRssi;
@property (nonatomic, copy) NSString *catOneImsi;

@end

@interface TTElectricMeter : NSObject

typedef NS_ENUM (NSInteger, TTElectricMeterError) {
    TTElectricMeterBluetoothPowerOff,
    TTElectricMeterConnectTimeout,
    TTElectricMeterDisconnect,
    TTElectricMeterNetError,
    TTElectricMeterRequestServerError,
    TTElectricMeterExistedInServer,
};

typedef NS_ENUM(NSInteger,TTElectricMeterFeature) {
    TTElectricMeterFeatureCatOne = 0,
    TTElectricMeterFeatureTelink = 1,
};

typedef void(^TTElectricMeterScanBlock)(TTElectricMeterModel *model);
typedef void(^TTElectricMeterSuccessBlock)(void);
typedef void(^TTElectricMeterAddSuccessBlock)(TTElectricMeterAddResult *result);
typedef void(^TTElectricMeterFailBlock)(TTElectricMeterError error, NSString *errorMsg);
typedef void(^TTElectricMeterGetDeviceInfoBlock)(TTElectricDeviceInfoModel *model);

+ (void)setClientParamWithUrl:(NSString *)url
                     clientId:(NSString *)clientId
                  accessToken:(NSString *)accessToken;

+ (void)startScanWithSuccess:(TTElectricMeterScanBlock)success
                     failure:(TTElectricMeterFailBlock)failure;
+ (void)stopScan;

// After success, the device status light will flash alternately
+ (void)connectWithMac:(NSString *)mac
               success:(TTElectricMeterSuccessBlock)success
               failure:(TTElectricMeterFailBlock)failure;

+ (void)cancelConnectWithMac:(NSString *)mac;

/*
 @param info @{@"mac": @"xxx", @"number": @"xxx", @"payMode": @"xxx", @"price": @"xxx"}
 mac The mac of the electric meter
 number The name of the electric meter
 payMode  0: Postpaid, 1: Prepaid
 price electricity price
 */
+ (void)addElectricMeterWithInfo:(NSDictionary *)info
                         success:(TTElectricMeterAddSuccessBlock)success
                         failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 */
+ (void)deleteWithMac:(NSString *)mac
              success:(TTElectricMeterSuccessBlock)success
              failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param powerOn 0: power off, 1: power on
 */
+ (void)setPowerOnOffWithMac:(NSString *)mac
                     powerOn:(BOOL)powerOn
                     success:(TTElectricMeterSuccessBlock)success
                     failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param remainderKwh remaining electricity
 */
+ (void)setRemainingElectricityWithMac:(NSString *)mac
                          remainderKwh:(NSString *)remainderKwh
                               success:(TTElectricMeterSuccessBlock)success
                               failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 */
+ (void)clearRemainingElectricityWithMac:(NSString *)mac
                                 success:(TTElectricMeterSuccessBlock)success
                                 failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 */
+ (void)readDataWithMac:(NSString *)mac
                success:(TTElectricMeterSuccessBlock)success
                failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param payMode 0: Postpaid, 1: Prepaid
 @param price electricity price
 */
+ (void)setPayModeWithMac:(NSString *)mac
                  payMode:(NSInteger)payMode
                    price:(NSString *)price
                  success:(TTElectricMeterSuccessBlock)success
                  failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param rechargeAmount recharge amount
 @param rechargeKwh degree of recharged electricity
 */
+ (void)rechargeWithMac:(NSString *)mac
         rechargeAmount:(NSString *)rechargeAmount
            rechargeKwh:(NSString *)rechargeKwh
                success:(TTElectricMeterSuccessBlock)success
                failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param maxPower max Power
 */
+ (void)setMaxPowerWithMac:(NSString *)mac
                  maxPower:(NSInteger)maxPower
                   success:(TTElectricMeterSuccessBlock)success
                   failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 */
+ (void)getFeatureValueWithMac:(NSString *)mac
                       success:(TTElectricMeterSuccessBlock)success
                       failure:(TTElectricMeterFailBlock)failure;

+ (void)resetWithMac:(NSString *)mac
             success:(TTElectricMeterSuccessBlock)success
             failure:(TTElectricMeterFailBlock)failure;

+ (void)getDeviceInfoWithMac:(NSString *)mac
                     success:(TTElectricMeterGetDeviceInfoBlock)success
                     failure:(TTElectricMeterFailBlock)failure;

+ (void)configApnWithMac:(NSString *)mac
                     apn:(NSString *)apn
                 success:(TTElectricMeterSuccessBlock)success
                 failure:(TTElectricMeterFailBlock)failure;

+ (void)configServerWithMac:(NSString *)mac
              serverAddress:(NSString *)serverAddress
                 portNumber:(NSString *)portNumber
                    success:(TTElectricMeterSuccessBlock)success
                    failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 */
+ (void)enterUpgradeModeWithMac:(NSString *)mac
                        success:(TTElectricMeterSuccessBlock)success
                        failure:(TTElectricMeterFailBlock)failure;

+ (BOOL)supportFunction:(TTElectricMeterFeature)function featureValue:(NSString *)featureValue;


+ (void)addWithInfo:(NSDictionary *)info
           success:(TTElectricMeterSuccessBlock)success
           failure:(TTElectricMeterFailBlock)failure DEPRECATED_MSG_ATTRIBUTE("Use addElectricMeter:success:failure: instead");

@end

NS_ASSUME_NONNULL_END
