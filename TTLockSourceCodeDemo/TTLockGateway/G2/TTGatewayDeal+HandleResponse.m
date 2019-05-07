//
//  TTGatewayDeal+HandleResponse.m
//  TTLockSourceCodeDemo
//
//  Created by 王娟娟 on 2019/4/28.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "TTGatewayDeal+HandleResponse.h"
#import "TTDataTransformUtil.h"
#import "TTGatewayCommandUtils.h"
#import "TTCRC8.h"

@implementation TTGatewayDeal (HandleResponse)

#pragma mark --- 解析锁返回的数据
- (void)handleCommandResponse:(Byte *)decryptData dataResponse:(Byte *)dataResponse{
    int commandValue = dataResponse[2];
    switch (commandValue) {
        case 0x01:{
            if (decryptData[0] == 5) {
                TTGatewayScanWiFiBlock ssidBlock = self.bleBlockDict[KKGATEWAYBLE_GET_SSID];
                [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_GET_SSID];
                if (ssidBlock){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ssidBlock(YES,self.WiFiArr,TTGatewaySuccess);
                        NSLog(@"WiFiArr %@",self.WiFiArr);
                    });
                }
                return;
            }
            int ssidLen = decryptData[1];
            Byte ssidByte[ssidLen];
            [TTDataTransformUtil arrayCopyWithSrc:decryptData srcPos:2 dst:ssidByte dstPos:0 length:ssidLen];
            NSString *ssidStr =[[NSString alloc]initWithData:[NSData dataWithBytes:ssidByte length:ssidLen] encoding:NSUTF8StringEncoding];
            
            int rssi = [self getDecimalismFromByte:decryptData[2+ssidLen]];
            
            if (ssidStr.length > 0) {
                BOOL isContain = NO;
                BOOL isChangePosition = YES;
                for (int i = 0; i < self.WiFiArr.count; i ++) {
                    NSMutableDictionary *dicObjc = self.WiFiArr[i];
                    if ([dicObjc[@"SSID"] isEqualToString:ssidStr]) {
                        if (rssi > [dicObjc[@"RSSI"] intValue]) {
                            dicObjc[@"RSSI"] = @(rssi);
                            //rssi变了，位置也可能要发生相应的变化
                            for (int j = 0 ; j < i ; j ++) {
                                NSMutableDictionary *sortObjc = self.WiFiArr[j];
                                if (rssi > [sortObjc[@"RSSI"] intValue]) {
                                    [self.WiFiArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                                    break;
                                }
                            }
                        }else{
                            isChangePosition = NO;
                        }
                        isContain = YES;
                        break;
                    }
                }
                //插入排序，因为之前的已经是排好序了
                if (isContain == NO) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"SSID"] = ssidStr;
                    dic[@"RSSI"] = @(rssi);
                    int sortIndex = 0;
                    for (int i = 0 ; i < self.WiFiArr.count ; i ++) {
                        NSMutableDictionary *sortObjc = self.WiFiArr[i];
                        if (rssi > [sortObjc[@"RSSI"] intValue]) {
                            sortIndex = i;
                            break;
                        }
                        sortIndex = i + 1;
                    }
                    
                    [self.WiFiArr insertObject:dic  atIndex:sortIndex];
                }
                if (isChangePosition == YES) {
                    TTGatewayScanWiFiBlock ssidBlock = self.bleBlockDict[KKGATEWAYBLE_GET_SSID];
                    if (ssidBlock){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ssidBlock(NO,self.WiFiArr,TTGatewaySuccess);
                            NSLog(@"_ssidArr %@",self.WiFiArr);
                        });
                    }
                }
                
            }
            
        }break;
        case 0x02:{
            NSLog(@"0x02 decryptData%d %d",decryptData[0],decryptData[1]);
            if (decryptData[0] == 0) {
                BOOL debugMode = self.gatewayModel.debugMode;
                BOOL ishoneywell =self.gatewayModel.ishoneywell;
                NSString *IP_PORT = debugMode ?  @"120.26.119.23" : (ishoneywell ?  @"47.89.184.209": @"plug.sciener.cn");
                [TTGatewayCommandUtils configServer:IP_PORT port:@"9999" lockMac:self.currentLockMac];
                return;
            }else if (decryptData[0] == 2){
                return;
            }
            TTInitializeGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY];
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONFIG_GATEWAY];
            if (initializeBlock){
                dispatch_async(dispatch_get_main_queue(), ^{
                    initializeBlock(nil,decryptData[0]);
                });
            }
        }break;
        case 0x03:{
            NSLog(@"0x03 decryptData %d",decryptData[0]);
            if (decryptData[0] == 0) {
                [TTGatewayCommandUtils configAccountWithUid:[self.gatewayModel.uid longLongValue] password:self.gatewayModel.userPwd companyId:[self.gatewayModel.companyId longLongValue] branchId:[self.gatewayModel.branchId longLongValue] plugName:self.gatewayModel.plugName lockMac:self.currentLockMac];
                return;
            }
            TTInitializeGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY];
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONFIG_GATEWAY];
            if (initializeBlock){
                dispatch_async(dispatch_get_main_queue(), ^{
                    initializeBlock(nil,decryptData[0]);
                });
            }
        }break;
        case 0x04:{
            NSLog(@"0x04 decryptData %d",decryptData[0]);
            TTInitializeGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY];
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONFIG_GATEWAY];
            if (initializeBlock){
                int value1 = decryptData[0];
                int value = [TTDataTransformUtil intFromHexBytes:&decryptData[0] length:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"0x04 value %d  value1 %d",value,value1);
                    initializeBlock(self.gatewayDeviceInfoDic,value);
                });
            }
        }break;
        case 0x05:{
            NSLog(@"decryptData %d",decryptData[0]);
            TTGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_UPGRADE_GATEWAY];
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_UPGRADE_GATEWAY];
            if (initializeBlock){
                dispatch_async(dispatch_get_main_queue(), ^{
                    int value = [TTDataTransformUtil intFromHexBytes:&decryptData[0] length:1];
                    initializeBlock(value);
                });
            }
        }break;
        case 0x45:{
            TTGatewayConnectBlock connectBlock = self.bleBlockDict[KKGATEWAYBLE_CONNECT];
            [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONNECT];
            if (connectBlock){
                dispatch_async(dispatch_get_main_queue(), ^{
                    connectBlock(TTGatewayConnectSuccess);
                });
            }
        }break;
        default:
            break;
    }
}
Byte indataResponse[256];
int inresponseDataSize;
- (void)responseData:(NSData *)data{

    Byte *dataResponseTemp = (Byte *)[data bytes];
    [TTDataTransformUtil arrayCopyWithSrc:dataResponseTemp
                                   srcPos:0
                                      dst:indataResponse
                                   dstPos:inresponseDataSize
                                   length:data.length];
    
    inresponseDataSize =inresponseDataSize+(int)data.length;
    NSData *totalData = [NSData dataWithBytes:indataResponse length:inresponseDataSize];
    
    NSLog(@"#warning %@ \n%@ %d %d %d",data,totalData,indataResponse[3] ,(int)data.length,inresponseDataSize);
    
    if (indataResponse[0] == 0x72 && indataResponse[1] == 0x5B) {
        
        if (indataResponse[3] + 5 <= inresponseDataSize) {
            NSData *totalData = [NSData dataWithBytes:indataResponse length:inresponseDataSize];
            [self totalData:totalData];
            inresponseDataSize = 0;
            return;
        }
        
        return;
    }else{
        inresponseDataSize = 0;
        for (int i = 0; i < data.length; i++) {
            if (dataResponseTemp[i] == 0x72 && dataResponseTemp[i+1] == 0x5B) {
                [TTDataTransformUtil arrayCopyWithSrc:dataResponseTemp
                                               srcPos:i
                                                  dst:indataResponse
                                               dstPos:inresponseDataSize
                                               length:data.length- i];
                if (indataResponse[3] + 5 <= inresponseDataSize) {
                    NSData *totalData = [NSData dataWithBytes:indataResponse length:inresponseDataSize];
                    [self totalData:totalData];
                    inresponseDataSize = 0;
                    break;
                }
                break;
            }
        }
    }
    
}
- (void)totalData:(NSData *)data{
    Byte *dataResponse = (Byte *)[data bytes];
    NSInteger totalLen = data.length;
    //判断对方校验和自己校验到是否相同
    BOOL mIsChecksumValid = [self checksumCrc:dataResponse totalLen:totalLen];
    if (mIsChecksumValid == NO) {
        
        TTGatewayScanWiFiBlock ssidBlock = self.bleBlockDict[KKGATEWAYBLE_GET_SSID];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_GET_SSID];
        if (ssidBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                ssidBlock(YES,self.WiFiArr,TTGatewayWrongCRC);
            });
        }
        
        TTInitializeGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONFIG_GATEWAY];
        if (initializeBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                initializeBlock(nil,TTGatewayWrongCRC);
            });
        }
        
        TTGatewayBlock upgradeBlock = self.bleBlockDict[KKGATEWAYBLE_UPGRADE_GATEWAY];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_UPGRADE_GATEWAY];
        if (upgradeBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                upgradeBlock(TTGatewayWrongCRC);
            });
        }
        return;
    }
    
    int dataLen = dataResponse[3];
    Byte encryptData[dataLen];
    [TTDataTransformUtil arrayCopyWithSrc:dataResponse
                                   srcPos:4
                                      dst:encryptData
                                   dstPos:0
                                   length:dataLen];
    
    Byte *decryptData = [self getDataAes_pwdKey:[TTGatewayCommandUtils getDefaultAesKeyWithMac:self.currentLockMac] encryptData:encryptData dataLen:dataLen];
    
    if (decryptData == NULL) {
        TTGatewayScanWiFiBlock ssidBlock = self.bleBlockDict[KKGATEWAYBLE_GET_SSID];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_GET_SSID];
        if (ssidBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                ssidBlock(YES,self.WiFiArr,TTGatewayWrongAeskey);
            });
        }
        
        TTInitializeGatewayBlock initializeBlock = self.bleBlockDict[KKGATEWAYBLE_CONFIG_GATEWAY];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_CONFIG_GATEWAY];
        if (initializeBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                initializeBlock(nil,TTGatewayWrongAeskey);
            });
        }
        
        TTGatewayBlock upgradeBlock = self.bleBlockDict[KKGATEWAYBLE_UPGRADE_GATEWAY];
        [self.bleBlockDict removeObjectForKey:KKGATEWAYBLE_UPGRADE_GATEWAY];
        if (upgradeBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                upgradeBlock(TTGatewayWrongCRC);
            });
        }
        return;
    }
    NSLog(@"decryptData %@", [[NSData alloc]initWithBytes:decryptData length:dataLen]);
    [self handleCommandResponse:decryptData dataResponse:dataResponse];
}
- (BOOL)checksumCrc:(Byte *)dataResponse totalLen:(NSInteger)totalLen {
    //先校验crc
    Byte checksum = dataResponse[totalLen - 1];
    Byte commandWithoutChecksum[totalLen - 1];
    [TTDataTransformUtil arrayCopyWithSrc:dataResponse srcPos:0 dst:commandWithoutChecksum dstPos:0 length:totalLen-1];
    
    Byte checksumTmp = (Byte)[TTCRC8 computeWithDataToCrc:commandWithoutChecksum len:(int)totalLen-1];
    return checksumTmp == checksum;
}

-(Byte*)getDataAes_pwdKey:(Byte*)pwdKey encryptData:(Byte *)encryptData dataLen:(int)dataLen{
    
    if (!encryptData) {
        return nil;
    }
    NSData *psData = [TTSecurityUtil decryptToDataAESData:[NSData dataWithBytes:encryptData length:dataLen] keyBytes:pwdKey];
    NSLog(@"psData %@",psData);
    Byte *bytes = (Byte *)[psData bytes];
    return bytes;
    
}
- (int)getDecimalismFromByte:(Byte)byte {
    int decimalism = 0;
    
    if ((byte ^ 0x7F) > 127) {
        decimalism = byte - 256;
    } else {
        decimalism = byte;
    }
    
    return decimalism;
}
@end
