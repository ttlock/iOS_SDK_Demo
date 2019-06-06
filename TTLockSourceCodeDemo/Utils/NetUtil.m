//
//  NetUtil.m
//  TTLockDemo
//
//  Created by LXX on 17/2/7.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import "NetUtil.h"

#import "UserModel.h"


static NSString *const AppDomain = @"AppDomain";
@implementation NetUtil

+ (void)lockInitializeWithlockAlias:(NSString *)lockAlias lockData:(NSString*)lockData completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    
    parame[@"lockAlias"] = lockAlias;
    parame[@"lockData"] = lockData;
    
    [NetUtil apiPost:@"lock/initialize" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
    
}

+ (void)loginUsername:(NSString *)username password:(NSString *)password completion:(RequestBlock)completion{
    NSMutableDictionary *parameters = [NetUtil initParame];
    parameters[@"username"] = username;
    parameters[@"password"] = password;
    parameters[@"grant_type"] = @"password";
    parameters[@"client_id"] = TTAppkey;
    parameters[@"client_secret"] = TTAppSecret;
    parameters[@"redirect_uri"] = TTRedirectUri;
    parameters[@"clientId"] = nil;

    NSString *url = [NSString stringWithFormat:@"%@/oauth2/token",TTLockLoginURL];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    AFHTTPSessionManager *manager = [NetUtil apiRequestSeesion:serializer];
    [serializer requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        id valueData = [self apiResponseParse:responseObject error:&error];
        
        [NetUtil logDebugInfoWithResponse:responseObject url:url error:error];
        if (completion)
            completion(valueData,error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [NetUtil logDebugInfoWithResponse:nil url:url error:error];
        
        if (completion)
            completion(nil, error);
    }];
}

+ (void)lockListWithPageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"pageNo"] = @(pageIndex);
    parame[@"pageSize"] = @(20);
    [NetUtil apiPost:@"lock/list" parameters:parame completion:^(id info, NSError *error) {
        completion(info[@"list"],error);
    }];
}

+ (void)adminKeyWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"pageNo"] = @(pageIndex);
    parame[@"pageSize"] = @(20);
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"key/list" parameters:parame completion:^(id info, NSError *error) {
         KeyModel *adminKey = nil;
        if (error == nil) {
            NSArray *keyList = [KeyModel mj_objectArrayWithKeyValuesArray:info[@"list"]];
            for (KeyModel *keyModel in keyList) {
                if (keyModel.lockId.longLongValue == lockId.longLongValue && keyModel.userType == 110301) {
                    adminKey = keyModel;
                }
            }
        }
        completion(adminKey,error);
    }];
}



+ (void)deleteAllKey:(NSInteger)lockId completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    [NetUtil apiPost:@"lock/deleteAllKey" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)keyboardPwdListOfLock:(NSInteger)lockId pageNo:(NSInteger)pageNo completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"pageNo"] = @(pageNo);
    parame[@"pageSize"] = @(20);
    parame[@"lockId"] = @(lockId);
    [NetUtil apiPost:@"lock/listKeyboardPwd" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];

}

+ (void)changeAdminKeyboardPwd:(NSString*)password lockId:(NSInteger)lockId completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    parame[@"password"] = password;
    [NetUtil apiPost:@"lock/changeAdminKeyboardPwd" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];

}

+ (void)changeDeletePwd:(NSString*)password lockId:(NSInteger)lockId completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    
    parame[@"lockId"] = @(lockId);
    parame[@"password"] = password;
    [NetUtil apiPost:@"lock/changeDeletePwd" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)rename:(NSString*)lockAlias lockId:(NSInteger)lockId completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    parame[@"lockAlias"] = lockAlias;
    [NetUtil apiPost:@"lock/rename" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)resetEKeyWithLockId:(NSNumber *)lockId completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"lock/resetKey" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)resetKeyboardPwd:(NSString*)pwdInfo lockId:(NSInteger)lockId timestamp:(NSString*)timestamp completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    parame[@"pwdInfo"] = pwdInfo;
    parame[@"timestamp"] = timestamp;
    [NetUtil apiPost:@"lock/resetKeyboardPwd" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)getKeyboardPwdVersion:(NSInteger)lockId completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    [NetUtil apiPost:@"lock/getKeyboardPwdVersion" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}


+ (void)sendKey:(NSInteger)lockId receiverUsername:(NSString *)receiverUsername startDate:(NSString*)startDate endDate:(NSString*)endDate remarks:(NSString *)remarks completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    parame[@"receiverUsername"] = receiverUsername;
    if (startDate)
        parame[@"startDate"] = startDate;
    if (endDate)
        parame[@"endDate"] = endDate;
    if (remarks)
        parame[@"remarks"] = remarks;
    [NetUtil apiPost:@"key/send" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)syncKeyData:(NSString*)lastUpdateDate completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    
//    parame[@"lastUpdateDate"] = lastUpdateDate;
    
    [NetUtil apiPost:@"key/syncData" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)deleteKeyWithId:(NSNumber *)keyId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"keyId"] = keyId;
    [NetUtil apiPost:@"key/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
};

+ (void)deleteLockWithId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"lock/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
};

+ (void)freezeKey:(NSInteger)keyId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"keyId"] = @(keyId);
    [NetUtil apiPost:@"key/freeze" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];

}

+ (void)unFreezeKey:(NSInteger)keyId completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"keyId"] = @(keyId);
    [NetUtil apiPost:@"key/unfreeze" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];

}

+ (void)changeKeyPeriod:(NSInteger)keyId startDate:(NSString*)startDate endDate:(NSString*)endDate completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"keyId"] = @(keyId);
    parame[@"startDate"] = startDate;
    parame[@"endDate"] = endDate;
    [NetUtil apiPost:@"key/changePeriod" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}


+(void)getKeyboardPwd:(NSInteger)lockId keyboardPwdVersion:(NSInteger)keyboardPwdVersion keyboardPwdType:(NSInteger)keyboardPwdType startDate:(NSString *)startDate endDate:(NSString *)endDate completion:(RequestBlock)completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = @(lockId);
    parame[@"keyboardPwdVersion"] = @(keyboardPwdVersion);
    parame[@"keyboardPwdType"] = @(keyboardPwdType);
    parame[@"startDate"] = startDate;
    parame[@"endDate"] = endDate;
    
    [NetUtil apiPost:@"keyboardPwd/get" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];

}


+ (void)deleteKeyboardPwd:(NSInteger)keyboardPwdId lockId:(NSInteger)lockId deleteType:(NSInteger)deleteType completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"keyboardPwdId"] = @(keyboardPwdId);
    parame[@"lockId"] = @(lockId);
    parame[@"deleteType"] = @(deleteType);
    [NetUtil apiPost:@"keyboardPwd/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)getUidWithCompletion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [NetUtil apiPost:@"user/getUid" parameters:parame completion:completion];
}
+ (void)isInitSuccessWithGatewayNetMac:(NSString*)gatewayNetMac completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:gatewayNetMac forKey:@"gatewayNetMac"];
    [NetUtil apiPost:@"gateway/isInitSuccess" parameters:parame completion:completion];
}
+ (void)getGatewayListWithPageNo:(int)pageNo completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:[NSNumber numberWithInt:pageNo] forKey:@"pageNo"];
    [parame setObject:@20 forKey:@"pageSize"];
    [NetUtil apiPost:@"gateway/list" parameters:parame completion:^(id info, NSError *error) {
        completion(info[@"list"],error);
    }];
    
}
+ (void)getGatewayListLockWithGatewayId:(NSNumber*)gatewayId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:gatewayId forKey:@"gatewayId"];
     [NetUtil apiPost:@"gateway/listLock" parameters:parame completion:completion];
}
+ (void)deleteGatewayWithGatewayId:(NSNumber*)gatewayId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:gatewayId forKey:@"gatewayId"];
    [NetUtil apiPost:@"gateway/delete" parameters:parame completion:completion];
}
+ (void)lockQueryDateWithLockId:(NSNumber*)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:lockId forKey:@"lockId"];
    [NetUtil apiPost:@"lock/queryDate" parameters:parame completion:completion];
}
+ (void)lockDetailWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:lockId forKey:@"lockId"];
    [NetUtil apiPost:@"lock/detail" parameters:parame completion:completion];
}

+ (void)lockUpdateDateWithLockId:(NSNumber*)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    [parame setObject:lockId forKey:@"lockId"];
    [NetUtil apiPost:@"lock/updateDate" parameters:parame completion:completion];
}

+(void)lockUpgradeCheckWithLockId:(NSNumber *)lockId
                 completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
  
      [NetUtil apiPost:@"lock/upgradeCheck" parameters:parame completion:completion];
    
}
+(void)getRecoverDataWithClientId:(NSString*)clientId
                      accessToken:(NSString*)accessToken
                           lockId:(int)lockId
                       completion:(RequestBlock)completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = [NSNumber numberWithInt:lockId] ;
    
    [NetUtil apiPost:@"lock/getRecoverData" parameters:parame completion:completion];

    
}

+ (void)cardsListWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"pageNo"] = @(pageIndex);
    parame[@"pageSize"] = @(20);
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"identityCard/list" parameters:parame completion:^(id info, NSError *error) {
        completion(info[@"list"],error);
    }];
}

+ (void)addCardNumber:(NSString *)number name:(NSString *)name startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway lockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"startDate"] = @(startDate);
    parame[@"endDate"] = @(endDate);
    parame[@"lockId"] = lockId;
    parame[@"cardNumber"] = number;
    parame[@"cardName"] = name;
    parame[@"addType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"identityCard/add" parameters:parame completion:completion];
    
}

+ (void)modifyCardId:(NSNumber *)cardId startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"startDate"] = @(startDate);
    parame[@"endDate"] = @(endDate);
    parame[@"cardId"] = cardId;
    parame[@"changeType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"identityCard/changePeriod" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}
+ (void)deleteCardId:(NSNumber *)cardId lockId:(NSNumber *)lockId byGateway:(BOOL)byGateway completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"cardId"] = cardId;
    parame[@"lockId"] = lockId;
    parame[@"deleteType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"identityCard/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)clearAllCardsWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"identityCard/clear" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}


+ (void)fingerprintsListWithLockId:(NSNumber *)lockId pageIndex:(NSInteger)pageIndex completion:(RequestBlock) completion
{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"pageNo"] = @(pageIndex);
    parame[@"pageSize"] = @(20);
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"fingerprint/list" parameters:parame completion:^(id info, NSError *error) {
        completion(info[@"list"],error);
    }];
}

+ (void)addFingerprintNumber:(NSString *)number name:(NSString *)name startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway lockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"startDate"] = @(startDate);
    parame[@"endDate"] = @(endDate);
    parame[@"lockId"] = lockId;
    parame[@"fingerprintNumber"] = number;
    parame[@"fingerprintName"] = name;
    parame[@"addType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"fingerprint/add" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
    
}

+ (void)modifyFingerprintId:(NSNumber *)fingerprintId startDate:(long long)startDate endDate:(long long)endDate byGateway:(BOOL)byGateway completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"startDate"] = @(startDate);
    parame[@"endDate"] = @(endDate);
    parame[@"cardId"] = fingerprintId;
    parame[@"changeType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"fingerprint/changePeriod" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}
+ (void)deleteFingerprintId:(NSNumber *)fingerprintId lockId:(NSNumber *)lockId byGateway:(BOOL)byGateway completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"fingerprintId"] = fingerprintId;
    parame[@"lockId"] = lockId;
    parame[@"deleteType"] = byGateway ? @2 : @1;
    [NetUtil apiPost:@"fingerprint/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)clearAllFingerprintsWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"fingerprint/clear" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}


+(void)lockUpgradeRecheckWithLockId:(NSNumber*)lockId
                   modelNum:(NSString*)modelNum
           hardwareRevision:(NSString*)hardwareRevision
           firmwareRevision:(NSString*)firmwareRevision
               specialValue:(long long)specialValue
                 completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId ;
    if (specialValue != -1) parame[@"specialValue"] = @(specialValue);
    if (modelNum.length>0) parame[@"modelNum"] = modelNum;
    if (hardwareRevision.length>0) parame[@"hardwareRevision"] = hardwareRevision;
    if (firmwareRevision.length>0) parame[@"firmwareRevision"] =  firmwareRevision;
    [NetUtil apiPost:@"lock/upgradeRecheck" parameters:parame completion:completion];
    
}
+(void)roomUpgradeRecheckWithLockId:(int)lockId
                      specialValue:(int)specialValue
                        completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = [NSNumber numberWithInt:lockId] ;
    parame[@"specialValue"] = [NSNumber numberWithInt:specialValue] ;
    [NetUtil apiPost:@"room/updateSuccess" parameters:parame completion:completion];
  
}
+(void)gatewayUpgradeCheckWithGatewayId:(NSNumber *)gatewayId
                             completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"gatewayId"] = gatewayId;
    [NetUtil apiPost:@"gateway/upgradeCheck" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+(void)gatewayuploadDetailWithGatewayId:(NSNumber *)gatewayId
                               modelNum:(NSString*)modelNum
                       hardwareRevision:(NSString*)hardwareRevision
                       firmwareRevision:(NSString*)firmwareRevision
                            networkName:(NSString *)networkName
                             completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"gatewayId"] = gatewayId;
    parame[@"modelNum"] = modelNum;
    parame[@"hardwareRevision"] = hardwareRevision;
    parame[@"firmwareRevision"] = firmwareRevision;
    parame[@"networkName"] = networkName;
    [NetUtil apiPost:@"gateway/uploadDetail" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}


+(void)addWirelessKeypadName:(NSString *)name
                      number:(NSString *)number
                         mac:(NSString *)mac
                specialValue:(long long)specialValue
                      lockId:(NSNumber *)lockId
                  completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    parame[@"wirelessKeyboardNumber"] = number;
    parame[@"wirelessKeyboardName"] = name;
    parame[@"wirelessKeyboardMac"] = mac;
    parame[@"wirelessKeyboardSpecialValue"] = @(specialValue);
    [NetUtil apiPost:@"wirelessKeyboard/add" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)deleteWirelessKeypadWithID:(NSString *)ID completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"wirelessKeyboardId"] = ID;
    [NetUtil apiPost:@"wirelessKeyboard/delete" parameters:parame completion:^(id info, NSError *error) {
        completion(info,error);
    }];
}

+ (void)getWirelessKeypadListWithLockId:(NSNumber *)lockId completion:(RequestBlock) completion{
    NSMutableDictionary *parame = [NetUtil initParame];
    parame[@"lockId"] = lockId;
    [NetUtil apiPost:@"wirelessKeyboard/listByLock" parameters:parame completion:^(id info, NSError *error) {
        completion(info[@"list"],error);
    }];
}


#pragma mark - parame
+ (NSMutableDictionary*)initParame
{
    NSMutableDictionary *parame = [NSMutableDictionary new];
    parame[@"clientId"] = TTAppkey;
    parame[@"accessToken"] = UserModel.userModel.accessToken;
    parame[@"date"] = @([[NSDate date] timeIntervalSinceReferenceDate] * 1000);
    return parame;
}


#pragma mark - AFNetworking
+ (NSMutableDictionary*)V3_DefaultParam
{
    NSMutableDictionary *parame = [NSMutableDictionary new];
    //    KKUserModel *userModel = [KKUserManager getUserModel];
    //    if ([userModel.accessToken length]) {
    //        parame[@"accessToken"] = userModel.accessToken;
    //    }
//    parame[@"uniqueid"] = [PTHelper uuid];
    long long date =[[NSDate date] timeIntervalSince1970]*1000;
    parame[@"date"] = @(date);
    return parame;
}

+ (void)apiPost:(NSString *)method parameters:(NSMutableDictionary *)parameters completion:(RequestBlock)completion{
    
    NSMutableDictionary* defaultParams = [NetUtil V3_DefaultParam];
    if ([defaultParams count])
        [parameters addEntriesFromDictionary:defaultParams];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",TTLockURL,method];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    AFHTTPSessionManager *manager = [NetUtil apiRequestSeesion:serializer];
    NSURLRequest *request = [serializer requestWithMethod:@"POST" URLString:url parameters:parameters error:nil];
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *error = nil;
        id valueData = [self apiResponseParse:responseObject error:&error];

        [NetUtil logDebugInfoWithResponse:responseObject url:url error:error];
        if (completion)
            completion(valueData,error);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
  
        [NetUtil logDebugInfoWithResponse:nil url:url error:error];
        
        if (completion)
            completion(nil, error);
    }];
    

    
    [NetUtil logDebugInfoWithRequest:request apiName:method requestParams:parameters httpMethod:@"POST"];
}

+ (void)apiGet:(NSString *)method parameters:(NSMutableDictionary *)parameters completion:(RequestBlock)completion{
    
    NSMutableDictionary* defaultParams = [NetUtil V3_DefaultParam];
    if ([defaultParams count])
        [parameters addEntriesFromDictionary:defaultParams];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",TTLockURL,method];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    AFHTTPSessionManager *manager = [NetUtil apiRequestSeesion:serializer];
    NSURLRequest *request = [serializer requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSError *error = nil;
        id valueData = [self apiResponseParse:responseObject error:&error];
     
        [NetUtil logDebugInfoWithResponse:responseObject url:url error:error];
        if (completion)
            completion(valueData,error);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [NetUtil logDebugInfoWithResponse:nil url:url error:error];
        if (completion)
            completion(nil, error);
    }];
    
    [NetUtil logDebugInfoWithRequest:request apiName:method requestParams:parameters httpMethod:@"GET"];
}

- (NSMutableURLRequest*)apiRequestPOST:(NSString*)method withJSONData:(NSDictionary*)dict files:(NSArray*)files {
    NSMutableDictionary* params = [NetUtil V3_DefaultParam];
    if ([dict count]) {
        [params addEntriesFromDictionary:dict];
    }
    AFHTTPRequestSerializer* httpRequestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:TTLockURL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (id filePath in files) {
            if ([filePath isKindOfClass:[NSString class]]) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath isDirectory:NO] name:@"file" fileName:@"file" mimeType:@"image/png" error:nil];
            }
            else if ([filePath isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:filePath name:@"file" fileName:@"file" mimeType:@"application/octet-stream"];
            }
        }
    } error:nil];
    request.timeoutInterval = 20.f;
    NSLog(request.URL.absoluteString, nil);
    return request;
}


+ (AFHTTPSessionManager *)apiRequestSeesion:(AFHTTPRequestSerializer *)serializer{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *accessToken = [SettingHelper getAccessToken];
//    NSString* date = [XYCUtils GetCurrentTimeInMillisecond];
//    [serializer setValue:TTAppkey forHTTPHeaderField:@"clientId"];
//    [serializer setValue:accessToken forHTTPHeaderField:@"accessToken"];
//    [serializer setValue:date forHTTPHeaderField:@"date"];
//    serializer.timeoutInterval = 20.f;
//    manager.requestSerializer = serializer;
    
    return manager;
}


+ (id)apiResponseParse:(id)responseObject error:(NSError **)error
{
    

      NSDictionary *data = responseObject;
      NSString * errorCode = responseObject[@"errcode"];
      NSString * errorMsg  = responseObject[@"errmsg"];

    if (errorCode.intValue < 0) {
 
//         [SSToastHelper showToastWithStatus:errorMsg];
    }
        id valueData = nil;
        BOOL isValid = (errorCode == nil || [errorCode intValue] == 0);
        valueData = data;
        if (!isValid) {
            if (nil != error) {
                *error = [NSError errorWithDomain:AppDomain code:[errorCode integerValue] userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                
                if ([errorCode intValue] == 10004) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"invalid grant" object:nil];
                }
            }
            valueData = nil;
        }
        if ([valueData isKindOfClass:[NSNull class]]) {
            valueData = nil;
        }
        return valueData;
}

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName requestParams:(NSDictionary *)requestParams httpMethod:(NSString *)httpMethod
{
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", TTLockURL];
    [logString appendFormat:@"Method:\t\t%@\n",httpMethod];
    [logString appendFormat:@"URL:\t\t%@\n",request.URL];
    [logString appendFormat:@"Params:\n%@", requestParams];
    
    [logString appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields];
    
    [logString appendFormat:@"\n*********************************\tRequest End\t*********************************\n\n\n\n"];
    NSLog(@"%@", logString);
}

+ (void)logDebugInfoWithResponse:(id)response url:(NSString *)url error:(NSError *)error
{
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n"];
    [logString appendFormat:@"\nHTTP URL:\n\t%@", url];
    [logString appendFormat:@"\nResponseContent:\n\t%@\n\n", response];
    if (shouldLogError) {
        
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
//         [SSToastHelper showToastWithStatus:error.localizedDescription];
        //        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        //        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendFormat:@"\n============================================\tResponse End\t===========================================\n\n\n\n"];
    
    NSLog(@"%@", logString);
}




@end
