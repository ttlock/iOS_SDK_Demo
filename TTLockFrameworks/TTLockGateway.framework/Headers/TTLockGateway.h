//
//  TTGatewayV1.h
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/29.
//  Copyright © 2019 Sciener. All rights reserved.
//  version:3.0.1

#import <Foundation/Foundation.h>


@interface TTLockGateway : NSObject

typedef void(^TTSmartLinkProcessBlock)(NSInteger process);
typedef void(^TTSmartLinkSuccessBlock)(NSString *ip,NSString *mac);
typedef void(^TTSmartLinkFailBlock)(void);

+ (NSString *)getSSID;
/**
 Start configuration 
 
 @param infoDic @{@"SSID": xxx, @"wifiPwd": xxx, @"uid": xxx ,@"userPwd": xxx}
                wifiPwd   Cannot contain Chinese
 @param pblock    Process Block
 @param sblock    Success Block
 @param fblock    Fail Block
 */
+(void)initializeGatewayWithInfoDic:(NSDictionary*)infoDic processblock:(TTSmartLinkProcessBlock)pblock successBlock:(TTSmartLinkSuccessBlock)sblock failBlock:(TTSmartLinkFailBlock)fblock;


@end


