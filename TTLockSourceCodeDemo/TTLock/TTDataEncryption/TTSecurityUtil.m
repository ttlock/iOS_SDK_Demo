//
//  SecurityUtil.h
//  Smile
//
//  Created by 周 敏 on 12-11-24.
//  Copyright (c) 2012年 BOX. All rights reserved.
//

#import "TTSecurityUtil.h"
#import "TTGTMBase64.h"
#import "NSData+TTAES.h"
#import "TTMacros.h"
#import "TTDataTransformUtil.h"

//#define APP_PUBLIC_PASSWORD     @"3141592653589793"

@implementation TTSecurityUtil

#pragma mark - base64
+ (NSString*)encodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [TTGTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
	return base64String;
}

+ (NSString*)decodeBase64String:(NSString * )input { 
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]; 
    data = [TTGTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
	return base64String;
} 
+ (NSData*)decodeBase64WithString:(NSString * )input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [TTGTMBase64 decodeData:data];
    return data;
}

+ (NSString*)encodeBase64Data:(NSData *)data {
	data = [TTGTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
	return base64String;
}

+ (NSString*)decodeBase64Data:(NSData *)data {
	data = [TTGTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
	return base64String;
}

#pragma mark - AES加密
+(NSData*)encryptAESStr:(NSString*)string keyBytes:(Byte*)key {
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES256EncryptWithKeyBytes:key gIv:key];
    return encryptedData;
}

+(NSData*)encryptAESData:(NSData*)data keyBytes:(Byte*)key {
    

    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES256EncryptWithKeyBytes:key gIv:key];
    return encryptedData;
}

+(NSData*)decryptToDataAESData:(NSData*)data keyBytes:(Byte*)key {
    //使用密码对data进行解密
    NSData *decryData = [data AES256DecryptWithKeyBytes:key gIv:key];
    //将解了密码的nsdata转化为nsstring
    //    NSString *string = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return decryData;
}








//将string转成带密码的data
+(NSData*)encryptAESStr:(NSString*)string key:(NSString*)key {
    //将nsstring转化为nsdata
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES256EncryptWithKey:key gIv:key];
    return encryptedData;
}
//将data转成带密码的data
+(NSData*)encryptAESData:(NSData*)data key:(NSString*)key {
    //将nsstring转化为nsdata
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    //使用密码对nsdata进行加密
    NSData *encryptedData = [data AES256EncryptWithKey:key gIv:key];
    return encryptedData;
}

//将带密码的data转成string
+(NSString*)decryptAESData:(NSData*)data key:(NSString*)key {
    //使用密码对data进行解密
    NSData *decryData = [data AES256DecryptWithKey:key gIv:key];
    //将解了密码的nsdata转化为nsstring
    NSString *string = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return string;
}
//将带密码的data转成data
+(NSData*)decryptToDataAESData:(NSData*)data key:(NSString*)key {
    //使用密码对data进行解密
    NSData *decryData = [data AES256DecryptWithKey:key gIv:key];
    //将解了密码的nsdata转化为nsstring
//    NSString *string = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return decryData;
}

#pragma mark - MD5加密

+ (NSString*)encodeAdminPSString:(NSString *)adminPs{
   
    NSString * adminpsStr=@"";
    if (adminPs != 0) {
        NSString *adminPsSource = adminPs;
        NSMutableString * zeros = [NSMutableString stringWithFormat:@""];
        if (adminPsSource.length<10) {
            //TODO,这里密码小与10位多，前面用"0"填充
            int len = 10-(int)adminPsSource.length;
            for (int i = 0 ; i < len; i++) {
                [zeros appendString:@"0"];
            }
        }
        NSString * adminpsStr10Length = [NSString stringWithFormat:@"%@%@",zeros,adminPsSource];
        adminpsStr = [TTSecurityUtil encodeBase64String:[TTDataTransformUtil EncodeSharedKeyValue:adminpsStr10Length]];
        
    }
    return adminpsStr;
}
+ (NSString*)decodeAdminPSString:(NSString*)string{
    
    NSString * adminpsStr = [TTSecurityUtil decodeBase64String:string];
    NSString * adminPs = [TTDataTransformUtil DecodeSharedKeyValue:adminpsStr];
    NSMutableString * zeros = [NSMutableString stringWithFormat:@""];
    if (adminPs.length<10) {
        
        //TODO,这里密码小与10位多，前面用"0"填充
        //10.10
        int len = 10-(int)adminPs.length;
        
        for (int i = 0 ; i < len; i++) {
            
            [zeros appendString:@"0"];
        }
    }
    return  [NSString stringWithFormat:@"%@%@",zeros,adminPs];
}
+ (NSString*)encodeLockKeyString:(NSString*)string{
    NSString *lockkeystr = [TTDataTransformUtil EncodeSharedKeyValue:string];
    NSData *data = [lockkeystr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [TTGTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    return base64String;
}
+(NSString*)decodeLockKeyString:(NSString*)string{
   NSString * keyStr = [TTSecurityUtil decodeBase64String:string];
   return [TTDataTransformUtil DecodeSharedKeyValue:keyStr];
}

+(NSString*)encodeAeskey:(NSData*)aeskey{
    NSMutableString * strBuffer = [[NSMutableString alloc]init];
    if (aeskey) {
        Byte * aesKeyBytes = (Byte *)aeskey.bytes;
        for (int i = 0 ; i < aeskey.length ; i++) {
            [strBuffer appendFormat:@"%02x,",aesKeyBytes[i]];
        }
        if (strBuffer.length>0) {
            [strBuffer deleteCharactersInRange:NSMakeRange(strBuffer.length-1, 1)];
        }
    }
    else {
        strBuffer = [NSMutableString stringWithString:@""];
    }
    return strBuffer;
}
+(NSData*)decodeAeskey:(NSString*)aeskey{
    
    NSString *aesKeyStr = aeskey;
    if (![aesKeyStr isKindOfClass:[NSNull class]]) {
        
        NSArray * array = [aesKeyStr componentsSeparatedByString:@","];
        NSMutableString * aesHexStr = [[NSMutableString alloc]init];
        for (int i = 0; i < array.count; i ++) {
            
            [aesHexStr appendFormat:@"%@",array[i]];
            
        }
        if (![aesHexStr isKindOfClass:[NSNull class]]) {
           return  [TTDataTransformUtil DataFromHexStr:aesHexStr];
        }
    }
    
    return nil;
}
@end
