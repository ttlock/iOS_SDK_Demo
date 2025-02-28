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

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) BOOL isInited;
@property (nonatomic, assign) long long scanTime; // Unit: millisecond

@property (nonatomic, assign) BOOL onOff; // 0: power off, 1: power on
@property (nonatomic, assign) NSInteger payMode; // 0: Postpaid, 1: Prepaid
@property (nonatomic, strong) NSString *totalKwh;
@property (nonatomic, strong) NSString *remainderKwh;
@property (nonatomic, strong) NSString *voltage;
@property (nonatomic, strong) NSString *electricCurrent;

@end

@interface TTElectricMeter : NSObject

typedef NS_ENUM (NSInteger, TTElectricMeterError) {
    TTElectricMeterBluetoothPowerOff,
    TTElectricMeterConnectTimeout,
    TTElectricMeterDisconnect,
    TTElectricMeterNetError,
};

typedef void(^TTElectricMeterScanBlock)(TTElectricMeterModel *model);
typedef void(^TTElectricMeterSuccessBlock)(void);
typedef void(^TTElectricMeterFailBlock)(TTElectricMeterError error);

+ (void)startScanWithSuccess:(TTElectricMeterScanBlock)success
                     failure:(TTElectricMeterFailBlock)failure;
+ (void)stopScan;

// After success, the device status light will flash alternately
+ (void)connectWithMac:(NSString *)mac
               success:(TTElectricMeterSuccessBlock)success
               failure:(TTElectricMeterFailBlock)failure;

+ (void)cancelConnectWithMac:(NSString *)mac;

/*
 @param mac The mac of the electric meter
 @param name The name of the electric meter
 @param mode work Mode, 0: Postpaid, 1: Prepaid
 @param price electricity price
 @param url such as "https:...v3/executeCommand"
 */
+ (void)addWithMac:(NSString *)mac
              name:(NSString *)name
              mode:(NSInteger)mode
             price:(NSString *)price
               url:(NSString *)url
          clientId:(NSString *)clientId
       accessToken:(NSString *)accessToken
           success:(TTElectricMeterSuccessBlock)success
           failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param url such as "https:...v3/executeCommand"
 */
+ (void)deleteWithMac:(NSString *)mac
                  url:(NSString *)url
             clientId:(NSString *)clientId
          accessToken:(NSString *)accessToken
              success:(TTElectricMeterSuccessBlock)success
              failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param powerOn 0: power off, 1: power on
 @param url such as "https:...v3/executeCommand"
 */
+ (void)setPowerOnOffWithMac:(NSString *)mac
                     powerOn:(BOOL)powerOn
                         url:(NSString *)url
                    clientId:(NSString *)clientId
                 accessToken:(NSString *)accessToken
                     success:(TTElectricMeterSuccessBlock)success
                     failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param remainderKwh remaining electricity
 @param url such as "https:...v3/executeCommand"
 */
+ (void)setRemainingElectricityWithMac:(NSString *)mac
                          remainderKwh:(NSInteger)remainderKwh
                                   url:(NSString *)url
                              clientId:(NSString *)clientId
                           accessToken:(NSString *)accessToken
                               success:(TTElectricMeterSuccessBlock)success
                               failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param url such as "https:...v3/executeCommand"
 */
+ (void)clearRemainingElectricityWithMac:(NSString *)mac
                                     url:(NSString *)url
                                clientId:(NSString *)clientId
                             accessToken:(NSString *)accessToken
                                 success:(TTElectricMeterSuccessBlock)success
                                 failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param url such as "https:...v3/executeCommand"
 */
+ (void)readDataWithMac:(NSString *)mac
                    url:(NSString *)url
               clientId:(NSString *)clientId
            accessToken:(NSString *)accessToken
                success:(TTElectricMeterSuccessBlock)success
                failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param mode work Mode, 0: Postpaid, 1: Prepaid
 @param price electricity price
 @param url such as "https:...v3/executeCommand"
 */
+ (void)setWorkModeWithMac:(NSString *)mac
                      mode:(NSInteger)mode
                     price:(NSString *)price
                       url:(NSString *)url
                  clientId:(NSString *)clientId
               accessToken:(NSString *)accessToken
                   success:(TTElectricMeterSuccessBlock)success
                   failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param chargeAmount recharge amount
 @param chargeKwh degree of recharged electricity
 @param url such as "https:...v3/executeCommand"
 */
+ (void)chargeWithMac:(NSString *)mac
         chargeAmount:(NSString *)chargeAmount
            chargeKwh:(NSString *)chargeKwh
                  url:(NSString *)url
             clientId:(NSString *)clientId
          accessToken:(NSString *)accessToken
              success:(TTElectricMeterSuccessBlock)success
              failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param maxPower max Power
 @param url such as "https:...v3/executeCommand"
 */
+ (void)setMaxPowerWithMac:(NSString *)mac
                  maxPower:(NSInteger)maxPower
                       url:(NSString *)url
                  clientId:(NSString *)clientId
               accessToken:(NSString *)accessToken
                   success:(TTElectricMeterSuccessBlock)success
                   failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param url such as "https:...v3/executeCommand"
 */
+ (void)getFeatureValueWithMac:(NSString *)mac
                           url:(NSString *)url
                      clientId:(NSString *)clientId
                   accessToken:(NSString *)accessToken
                       success:(TTElectricMeterSuccessBlock)success
                       failure:(TTElectricMeterFailBlock)failure;

/*
 @param mac The mac of the electric meter
 @param url such as "https:...v3/executeCommand"
 */
+ (void)enterUpgradeModeWithMac:(NSString *)mac
                            url:(NSString *)url
                       clientId:(NSString *)clientId
                    accessToken:(NSString *)accessToken
                        success:(TTElectricMeterSuccessBlock)success
                        failure:(TTElectricMeterFailBlock)failure;

@end

NS_ASSUME_NONNULL_END
