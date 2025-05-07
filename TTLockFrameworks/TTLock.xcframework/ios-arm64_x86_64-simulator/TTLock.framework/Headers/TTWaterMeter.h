//
//  TTWaterMeter.h
//  TTLock
//
//  Created by Juanny on 2025/4/16.
//  Copyright © 2025 TTLock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTWaterMeterModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) BOOL isInited;
@property (nonatomic, assign) long long scanTime; // Unit: millisecond

@property (nonatomic, assign) NSInteger onOff; // 0: water off, 1: water on
@property (nonatomic, assign) NSInteger payMode; // 0: Postpaid, 1: Prepaid
@property (nonatomic, strong) NSString *totalM3;
@property (nonatomic, strong) NSString *remainderM3;
@property (nonatomic, assign) NSInteger magneticInterference;
@property (nonatomic, assign) NSInteger waterValveFailure;
@property (nonatomic, assign) NSInteger electricQuantity;

@end

@interface TTWaterMeter : NSObject

typedef NS_ENUM (NSInteger, TTWaterMeterError) {
    TTWaterMeterBluetoothPowerOff,
    TTWaterMeterConnectTimeout,
    TTWaterMeterDisconnect,
    TTWaterMeterNetError,
    TTWaterMeterRequestServerError,
    TTWaterMeterExistedInServer,
};

typedef void(^TTWaterMeterScanBlock)(TTWaterMeterModel *model);
typedef void(^TTWaterMeterSuccessBlock)(void);
typedef void(^TTWaterMeterFailBlock)(TTWaterMeterError error, NSString *errorMsg);

+ (void)setClientParamWithUrl:(NSString *)url
                     clientId:(NSString *)clientId
                  accessToken:(NSString *)accessToken;

+ (void)startScanWithSuccess:(TTWaterMeterScanBlock)success
                     failure:(TTWaterMeterFailBlock)failure;
+ (void)stopScan;

// After success, the device status light will flash alternately
+ (void)connectWithMac:(NSString *)mac
               success:(TTWaterMeterSuccessBlock)success
               failure:(TTWaterMeterFailBlock)failure;

+ (void)cancelConnectWithMac:(NSString *)mac;

/*
 @param info @{@"mac": @"xxx", @"number": @"xxx", @"payMode": @"xxx", @"price": @"xxx"}
 mac The mac of the water meter
 number The name of the water meter
 payMode  0: Postpaid, 1: Prepaid
 price water price
 */
+ (void)addWithInfo:(NSDictionary *)info
           success:(TTWaterMeterSuccessBlock)success
           failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 */
+ (void)deleteWithMac:(NSString *)mac
              success:(TTWaterMeterSuccessBlock)success
              failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 @param onOff 0: water off, 1: water on
 */
+ (void)setWaterOnOffWithMac:(NSString *)mac
                       onOff:(NSInteger)onOff
                     success:(TTWaterMeterSuccessBlock)success
                     failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 @param remainderM3 remaining water
 */
+ (void)setRemainingWaterWithMac:(NSString *)mac
                     remainderM3:(NSString *)remainderM3
                         success:(TTWaterMeterSuccessBlock)success
                         failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 */
+ (void)clearRemainingWaterWithMac:(NSString *)mac
                                 success:(TTWaterMeterSuccessBlock)success
                                 failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 */
+ (void)readDataWithMac:(NSString *)mac
                success:(TTWaterMeterSuccessBlock)success
                failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 @param payMode 0: Postpaid, 1: Prepaid
 @param price water price
 */
+ (void)setPayModeWithMac:(NSString *)mac
                  payMode:(NSInteger)payMode
                    price:(NSString *)price
                  success:(TTWaterMeterSuccessBlock)success
                  failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 @param rechargeAmount recharge amount
 @param rechargeM3 degree of recharged water
 */
+ (void)rechargeWithMac:(NSString *)mac
         rechargeAmount:(NSString *)rechargeAmount
             rechargeM3:(NSString *)rechargeM3
                success:(TTWaterMeterSuccessBlock)success
                failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 @param totalM3 total water
 */
+ (void)setTotalUsageWithMac:(NSString *)mac
                    totalM3:(NSString *)totalM3
                    success:(TTWaterMeterSuccessBlock)success
                    failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 */
+ (void)getFeatureValueWithMac:(NSString *)mac
                       success:(TTWaterMeterSuccessBlock)success
                       failure:(TTWaterMeterFailBlock)failure;

/*
 @param mac The mac of the water meter
 */
+ (void)enterUpgradeModeWithMac:(NSString *)mac
                        success:(TTWaterMeterSuccessBlock)success
                        failure:(TTWaterMeterFailBlock)failure;


@end

NS_ASSUME_NONNULL_END
