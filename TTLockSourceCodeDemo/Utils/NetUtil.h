//
//  NetUtil.h
//  TTLockDemo
//
//  Created by LXX on 17/2/7.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>

#define TTLockURL @"https://api.ttlock.com.cn/v3"
#define TTLockLoginURL @"https://api.ttlock.com.cn"
#define TTAppkey  @"7946f0d923934a61baefb3303de4d132"
#define TTAppSecret @"56d9721abbc3d22a58452c24131a5554"

#define TTRedirectUri @"http://www.sciener.cn"

typedef void(^RequestBlock)(id info, NSError* error);

@interface NetUtil : NSObject


+ (void)apiPost:(NSString *)method parameters:(NSMutableDictionary *)parameters completion:(RequestBlock)completion;

+ (void)apiGet:(NSString *)method parameters:(NSMutableDictionary *)parameters completion:(RequestBlock)completion;


+ (void)loginUsername:(NSString *)username password:(NSString *)password completion:(RequestBlock)completion;

+ (void)lockInitializeWithlockAlias:(NSString *)lockAlias lockData:(NSString*)lockData completion:(RequestBlock)completion;

+ (void)deleteLockWithId:(NSNumber *)lockId completion:(RequestBlock) completion;

+ (void)lockListWithPageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion;

+ (void)adminKeyWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion;

+ (void)deleteAllKey:(NSInteger)lockId completion:(RequestBlock) completion;

+ (void)keyboardPwdListOfLock:(NSInteger)lockId pageNo:(NSInteger)pageNo completion:(RequestBlock) completion;

+ (void)changeAdminKeyboardPwd:(NSString*)password lockId:(NSInteger)lockId completion:(RequestBlock)completion;

+ (void)changeDeletePwd:(NSString*)password lockId:(NSInteger)lockId completion:(RequestBlock)completion;

+ (void)rename:(NSString*)lockAlias lockId:(NSInteger)lockId completion:(RequestBlock)completion;

+ (void)resetEKeyWithLockId:(NSNumber *)lockId completion:(RequestBlock)completion;

+ (void)resetKeyboardPwd:(NSString*)pwdInfo lockId:(NSInteger)lockId timestamp:(NSString*)timestamp completion:(RequestBlock)completion;

+ (void)getKeyboardPwdVersion:(NSInteger)lockId completion:(RequestBlock)completion;


+ (void)sendKey:(NSInteger)lockId receiverUsername:(NSString *)receiverUsername startDate:(NSString*)startDate endDate:(NSString*)endDate remarks:(NSString *)remarks completion:(RequestBlock) completion;

+ (void)syncKeyData:(NSString*)lastUpdateDate completion:(RequestBlock) completion;

+ (void)deleteKeyWithId:(NSNumber *)keyId completion:(RequestBlock) completion;

+ (void)freezeKey:(NSInteger)keyId completion:(RequestBlock) completion;

+ (void)unFreezeKey:(NSInteger)keyId completion:(RequestBlock) completion;

+ (void)changeKeyPeriod:(NSInteger)keyId startDate:(NSString*)startDate endDate:(NSString*)endDate completion:(RequestBlock) completion;



+ (void)getKeyboardPwd:(NSInteger)lockId keyboardPwdVersion:(NSInteger)keyboardPwdVersion keyboardPwdType:(NSInteger)keyboardPwdType startDate:(NSString *)startDate endDate:(NSString *)endDate completion:(RequestBlock) completion;

+ (void)deleteKeyboardPwd:(NSInteger)keyboardPwdId lockId:(NSInteger)lockId deleteType:(NSInteger)deleteType completion:(RequestBlock) completion;

+ (void)cardsListWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion;

+ (void)addCardNumber:(NSString *)number name:(NSString *)name startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway lockId:(NSNumber *)lockId completion:(RequestBlock) completion;

+ (void)modifyCardId:(NSNumber *)cardId startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway completion:(RequestBlock) completion;
+ (void)deleteCardId:(NSNumber *)cardId lockId:(NSNumber *)lockId byGateway:(BOOL)byGateway completion:(RequestBlock) completion;
+ (void)clearAllCardsWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion;


+ (void)fingerprintsListWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion;

+ (void)addFingerprintNumber:(NSString *)number name:(NSString *)name startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway lockId:(NSNumber *)lockId completion:(RequestBlock) completion;

+ (void)modifyFingerprintId:(NSNumber *)fingerprintId startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway completion:(RequestBlock) completion;
+ (void)deleteFingerprintId:(NSNumber *)fingerprintId lockId:(NSNumber *)lockId byGateway:(BOOL)byGateway completion:(RequestBlock) completion;

+ (void)clearAllFingerprintsWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion;


+ (void)getUidWithCompletion:(RequestBlock) completion;
+ (void)isInitSuccessWithGatewayNetMac:(NSString*)gatewayNetMac completion:(RequestBlock) completion;
+ (void)getGatewayListWithPageNo:(int)pageNo completion:(RequestBlock) completion;
+ (void)getGatewayListLockWithGatewayId:(NSNumber*)gatewayId completion:(RequestBlock) completion;
+ (void)deleteGatewayWithGatewayId:(NSNumber*)gatewayId completion:(RequestBlock) completion;
+ (void)lockQueryDateWithLockId:(NSNumber*)lockId completion:(RequestBlock) completion;
+ (void)lockDetailWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion;
+ (void)lockUpdateDateWithLockId:(NSNumber*)lockId completion:(RequestBlock) completion;




+(void)lockUpgradeCheckWithLockId:(NSNumber *)lockId
                       completion:(RequestBlock) completion;

+(void)lockUpgradeRecheckWithLockId:(NSNumber*)lockId
                           modelNum:(NSString*)modelNum
                   hardwareRevision:(NSString*)hardwareRevision
                   firmwareRevision:(NSString*)firmwareRevision
                       specialValue:(long long)specialValue
                         completion:(RequestBlock) completion;

+(void)getRecoverDataWithClientId:(NSString*)clientId
                      accessToken:(NSString*)accessToken
                           lockId:(int)lockId
                       completion:(RequestBlock)completion;

+(void)gatewayUpgradeCheckWithGatewayId:(NSNumber *)gatewayId
                             completion:(RequestBlock) completion;

+(void)gatewayuploadDetailWithGatewayId:(NSNumber *)gatewayId
                               modelNum:(NSString*)modelNum
                       hardwareRevision:(NSString*)hardwareRevision
                       firmwareRevision:(NSString*)firmwareRevision
                            networkName:(NSString *)networkName
                             completion:(RequestBlock) completion;

+(void)addWirelessKeypadName:(NSString *)name
                      number:(NSString *)number
                         mac:(NSString *)mac
                specialValue:(long long)specialValue
                      lockId:(NSNumber *)lockId
                  completion:(RequestBlock) completion;

+ (void)deleteWirelessKeypadWithID:(NSString *)ID completion:(RequestBlock) completion;

+ (void)getWirelessKeypadListWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion;
@end
