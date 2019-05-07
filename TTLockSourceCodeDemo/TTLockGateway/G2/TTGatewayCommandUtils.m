//
//  TTGatewayCommandUtils.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/3/7.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTGatewayCommandUtils.h"
#import "TTCRC8.h"
#import "TTWIfiMD5.h"
#import "TTDataTransformUtil.h"
#import "TTGatewayDeal.h"

#define gatewayServiceString        @"1911"
#define gatewaySubWriteString         @"0002"

@implementation TTGatewayCommandUtils
+ (void)gatewayEchoWithLockMac:(NSString *)lockMac{
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_ECHO];
    NSData *defaultData = [@"SCIENER" dataUsingEncoding:NSUTF8StringEncoding];
    [command setDataAES:(Byte *)[defaultData bytes] withLength:7 key:[self getDefaultAesKeyWithMac:lockMac]];
    [self readyToWriteValueWithComand:command];
}
+ (void)scanWiFiByGatewayWithLockMac:(NSString *)lockMac{
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_SCAN_NEARBY_WIFI];
    NSData *defaultData = [@"SCIENER" dataUsingEncoding:NSUTF8StringEncoding];
    [command setDataAES:(Byte *)[defaultData bytes] withLength:7 key:[self getDefaultAesKeyWithMac:lockMac]];
    [self readyToWriteValueWithComand:command];
}
+(void)upgradeWithLockMac:(NSString *)lockMac{
    
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_UPGRADE];
    NSData *defaultData = [@"SCIENER" dataUsingEncoding:NSUTF8StringEncoding];
    [command setDataAES:(Byte *)[defaultData bytes] withLength:7 key:[self getDefaultAesKeyWithMac:lockMac]];
    [self readyToWriteValueWithComand:command];
    
}
+ (void)configSSID:(NSString *)SSID pwd:(NSString *)pwd lockMac:(NSString *)lockMac{
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_CONFIG_WIFI];
    NSData *ssidData = [SSID dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger ParaLength = ssidData.length + pwd.length + 2;
    Byte datas[ParaLength];
    datas[0] = ssidData.length;
    Byte *ssidByte = (Byte *)[ssidData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:ssidByte srcPos:0 dst:datas dstPos:1 length:ssidData.length];
    datas[1+ssidData.length] = pwd.length;
    NSData *pwdData = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    Byte *pwdByte = (Byte *)[pwdData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:pwdByte srcPos:0 dst:datas dstPos:2+ssidData.length length:pwd.length];
     [command setDataAES:datas withLength:(int)ParaLength key:[self getDefaultAesKeyWithMac:lockMac]];
     [self readyToWriteValueWithComand:command];
}
+ (void)configServer:(NSString *)server port:(NSString *)port lockMac:(NSString *)lockMac{
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_CONFIG_SERVER];
    NSInteger ParaLength = 1 + server.length  + 2;
    Byte datas[ParaLength];
    datas[0] = server.length;
    NSData *serverData = [server dataUsingEncoding:NSUTF8StringEncoding];
    Byte *serverByte = (Byte *)[serverData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:serverByte srcPos:0 dst:datas dstPos:1 length:server.length];
    NSData *portData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",port.intValue]];
    Byte *unlockByte = (Byte *)[portData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:unlockByte  srcPos:0 dst:datas dstPos:1 + server.length length:2];
    [command setDataAES:datas withLength:(int)ParaLength key:[self getDefaultAesKeyWithMac:lockMac]];
    [self readyToWriteValueWithComand:command];
}
+ (void)configAccountWithUid:(long long)uid password:(NSString *)password companyId:(long long)companyId branchId:(long long)branchId plugName:(NSString*)plugName lockMac:(NSString *)lockMac{
    TTCommand *command = [[TTCommand alloc]init];
    [command setCommand:GATEWAY_COMM_CONFIG_ACCOUNT];
    NSInteger ParaLength = 4 + 32  + 4 + 4 + 51;
    Byte datas[ParaLength];
    
    NSString *uidHexStr = [NSString stringWithFormat:@"%08llx",uid];
    NSData *uidData = [TTDataTransformUtil DataFromHexStr:uidHexStr];
    Byte *userIDByte = (Byte *)[uidData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:userIDByte srcPos:0 dst:datas dstPos:0 length:4];
    
    NSString *md5ps = [TTWIfiMD5 md5:password.length > 0 ? password : @"1"];
    NSData *md5psData = [md5ps dataUsingEncoding:NSUTF8StringEncoding];
    Byte *md5psByte = (Byte *)[md5psData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:md5psByte srcPos:0 dst:datas dstPos:4 length:32];
    
    NSString *companyHexStr = [NSString stringWithFormat:@"%08llx",companyId];
    NSData *companyData = [TTDataTransformUtil DataFromHexStr:companyHexStr];
    Byte *companyIDByte = (Byte *)[companyData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:companyIDByte srcPos:0 dst:datas dstPos:4+32 length:4];
    
    NSString *branchHexStr = [NSString stringWithFormat:@"%08llx",branchId];
    NSData *branchData = [TTDataTransformUtil DataFromHexStr:branchHexStr];
    Byte *branchIDByte = (Byte *)[branchData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:branchIDByte srcPos:0 dst:datas dstPos:4+32+4 length:4];
    
    NSString *nameStr = [NSString stringWithFormat:@"%@\n",plugName];
     NSString *nameG2Str = [NSString stringWithFormat:@"%@%d\n",nameStr,2];
    NSData *nameData = [nameG2Str dataUsingEncoding:NSUTF8StringEncoding];
    Byte *nameByte = (Byte *)[nameData bytes];
    [TTDataTransformUtil arrayCopyWithSrc:nameByte srcPos:0 dst:datas dstPos:4+32+4+4 length:51];

    [command setDataAES:datas withLength:(int)ParaLength key:[self getDefaultAesKeyWithMac:lockMac]];
    [self readyToWriteValueWithComand:command];
}
//***************要写进锁里数据准备完整*****************
+ (void)readyToWriteValueWithComand:(TTCommand*)command{
    
    int len = 2 + 1 + 1 + command->length + 1;
    Byte commandWithoutChecksum[len];
    [self buildCommand:commandWithoutChecksum withLength:len Comand:command];
    Byte bytesWithEndChar[len];
    [TTDataTransformUtil arrayCopyWithSrc:commandWithoutChecksum srcPos:0 dst:bytesWithEndChar dstPos:0 length:len];
    
    [self writeValueWithData:[NSData dataWithBytes:bytesWithEndChar length:len]];
}

+(void)buildCommand:(Byte*)commandWithChecksum withLength:(int)setdataLength Comand:(TTCommand*)command{
    
        commandWithChecksum[0] = 0x72;
        commandWithChecksum[1] = 0x5B;
        commandWithChecksum[2] = command->command;
        commandWithChecksum[3] = command->length;
    
        if (command->length > 0)
            [TTDataTransformUtil arrayCopyWithSrc:command->data srcPos:0 dst:commandWithChecksum dstPos:4 length:command->length];

    // Set checksum here
    Byte checksumJava = (Byte)[TTCRC8 computeWithDataToCrc:commandWithChecksum len:setdataLength-1];
    commandWithChecksum[setdataLength-1] = checksumJava;
}

//***************发送数据需要用的东西******************
+(void)writeValueWithData:(NSData *)data {
    
    CBPeripheral *peripheral =  [[TTGatewayDeal shareInstance] activePeripheral];
    
    CBService *service ;
    
    for (CBService *tempservice in peripheral.services) {
        if ([tempservice.UUID.UUIDString isEqualToString: @"1911"]) {
            service = tempservice;
        }
    }
    
    CBCharacteristic *characteristic;
    if (!service) {
        printf("TTLockLog#####Please connect the lock first#####\n");
        return;
    }
    
    for(int i = 0; i < service.characteristics.count; i++){
        
        if ([TTDataTransformUtil isString:service.characteristics[i].UUID.UUIDString contain:gatewaySubWriteString]) {
            characteristic = service.characteristics[i];
        }
    }
    if (!characteristic) {
        printf("TTLockLog#####Could not find characteristic on service on peripheral with UUID %s#####",[self UUIDToString:(__bridge CFUUIDRef)(peripheral.identifier)]);
        return;
    }
    
    Byte bytes[data.length];
    [data getBytes:bytes];
    
    {
        int datalength = (int) data.length;
        int cut = datalength/20;
        if (cut >= 1) {
            
        }
        
        Byte* bytes = (Byte *)data.bytes;
        
        for (int i = 0; i <= cut; i++) {
            
            int singleDatalen = 20;
            if (i == cut) {
                
                singleDatalen = datalength - i*20;
            }
            Byte byte20[singleDatalen];
            [TTDataTransformUtil arrayCopyWithSrc:bytes srcPos:i*20 dst:byte20 dstPos:0 length:singleDatalen];
            
            [peripheral writeValue:[NSData dataWithBytes:byte20 length:singleDatalen] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
        
    }
}
+(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}
+ (Byte *)getDefaultAesKeyWithMac:(NSString *)mac{
  
        Byte datas[6];
        NSArray *macArray = [mac componentsSeparatedByString:@":"];
        for (int i = (int)macArray.count - 1 ; i >= 0 ; i --) {
            NSData *numberData = [TTDataTransformUtil DataFromHexStr:macArray[macArray.count - 1 - i]];
            Byte *numberByte = (Byte *)[numberData bytes];
            datas[i]  = numberByte[0];
        }

    //固定的AES KEY
    Byte aeskey[16]={0x33,0xA0,0x3E,0x78,0x23,0x6A,0x4D,0x53,0x88,062,0x7A,0x32,0xA3,0xBB,0xF2,0xEF};
    NSData * dataEncrypted = [TTSecurityUtil encryptAESData:[NSData dataWithBytes:datas length:6] keyBytes:aeskey];
    return (Byte *)dataEncrypted.bytes;
}
@end
