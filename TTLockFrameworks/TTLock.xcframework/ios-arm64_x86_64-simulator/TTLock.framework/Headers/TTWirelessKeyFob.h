//
//  TTWirelessKeyFob.h
//  TTLock
//
//  Created by 王娟娟 on 2021/1/7.
//  Copyright © 2021 TTLock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSystemInfoModel.h"

@interface TTWirelessKeyFobScanModel : NSObject

@property (nonatomic, assign) int type; // 1 means R1, 2 means R2
@property (nonatomic, strong) NSString *keyFobName;
@property (nonatomic, strong) NSString *keyFobMac;
@property (nonatomic, assign) NSInteger RSSI;

@end

@interface TTKeyFobInitModel : NSObject

@property (nonatomic, assign) int type; // 1 means R1, 2 means R2
@property (nonatomic, assign) int electricQuantity;
@property (nonatomic, strong) NSString *modelNum;
@property (nonatomic, strong) NSString *hardwareRevision;
@property (nonatomic, strong) NSString *firmwareRevision;
// R1 does not have the following values
@property (nonatomic, strong) NSString *featureValue;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *authCode;
@property (nonatomic, strong) NSString *keyFobName;

@end

typedef enum {
	TTKeyFobSuccess = 0,
	TTKeyFobFail = 1,
	TTKeyFobWrongCRC = -1,
	TTKeyFobConnectTimeout = -2,
}TTKeyFobStatus;

typedef NS_ENUM(NSInteger,TTKeyFobFeatureValue) {
    TTKeyFobFeatureValueOnMicro = 0,
    TTKeyFobFeatureValueAuthCode = 1,
};

@interface TTWirelessKeyFob : NSObject

typedef void(^TTKeyFobScanBlock)(TTWirelessKeyFobScanModel *model);
typedef void(^TTKeyFobInitializeBlock)(TTKeyFobStatus status, TTKeyFobInitModel *initModel);
typedef void(^TTEnterUpgradeModeBlock)(TTKeyFobStatus status);

typedef void(^TTGetLockSystemInfoBlock)(TTKeyFobStatus status,TTSystemInfoModel *systemModel);
typedef void(^TTGetFeatureValueBlock)(TTKeyFobStatus status, NSString *featureValue);

typedef void(^TTNewInitializeKeyFobBlock)(TTKeyFobStatus status,int electricQuantity,TTSystemInfoModel *systemModel) DEPRECATED_MSG_ATTRIBUTE("SDK3.7.0,Use TTKeyFobInitializeBlock");
typedef void(^TTInitializeKeyFobBlock)(TTKeyFobStatus status,int electricQuantity) DEPRECATED_MSG_ATTRIBUTE("SDK3.7.0,Use TTKeyFobInitializeBlock");


/**
 Start Scan Key Fob
 */
+ (void)startScanWithBlock:(TTKeyFobScanBlock)block;
/**
 Stop Scan
 */
+ (void)stopScan;
/**
 Initialize key fob (R1/R2). Callback returns TTKeyFobInitModel.
 */
+ (void)initializeKeyFobWithMac:(NSString *)keyFobMac
                       lockData:(NSString *)lockData
                 initModelBlock:(TTKeyFobInitializeBlock)initModelBlock;
/**
 Enter Upgrade Mode
 */
+ (void)enterUpgradeModeWithKeyFobMac:(NSString *)keyFobMac
                             lockData:(NSString*)lockData
                                block:(TTEnterUpgradeModeBlock)block;

+ (void)getLockSystemInfoWithKeyFobMac:(NSString *)keyFobMac
                                 block:(TTGetLockSystemInfoBlock)block;

// Only r2 is supported
+ (void)getFeatureValueWithKeyFobMac:(NSString *)keyFobMac
                               block:(TTGetFeatureValueBlock)block;

+ (BOOL)supportFunction:(TTKeyFobFeatureValue)function featureValue:(NSString *)featureValue;

+ (void)newInitializeWithKeyFobMac:(NSString *)keyFobMac
                        lockData:(NSString *)lockData
                          block:(TTNewInitializeKeyFobBlock)block DEPRECATED_MSG_ATTRIBUTE("SDK3.7.0,Use initializeKeyFobWithMac:lockData:initModelBlock:");

+ (void)initializeWithKeyFobMac:(NSString *)keyFobMac
                        lockData:(NSString *)lockData
                          block:(TTInitializeKeyFobBlock)block DEPRECATED_MSG_ATTRIBUTE("SDK3.7.0,Use initializeKeyFobWithMac:lockData:initModelBlock:");




@end
