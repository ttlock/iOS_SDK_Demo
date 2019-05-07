//
//  TTDataTransformUtil.h
//  TTLockDemo
//
//  Created by wjjxx on 16/11/2.
//  Copyright © 2016年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTDataTransformUtil : NSObject

#pragma mark --- 数据类型转换
//3bytes and below
+(int)intFromHexBytes:(Byte*)bytes length:(int)dataLen;
//4 bytes and above
+(long long)longFromHexBytes:(Byte*)bytes length:(int)dataLen;

+(NSString*)stringFormBytes:(Byte*)bytes length:(int)dataLen;

+(NSData*)DataFromHexStr:(NSString *)hexString;

+(BOOL)isString:(NSString*)source contain:(NSString*)subStr;

+(long) getLongForBytes:(Byte*)packet;

+(Byte)generateRandomByte;

+(void) arrayCopyWithSrc:(Byte*)src srcPos:(int)srcPos dst:(Byte*)dst dstPos:(NSUInteger)dstPos length:(NSUInteger)length;

+(void) generateDynamicPassword:(Byte*)bytes length:(int) length;

+(NSString *) generateDynamicPassword:(int) length;

+(NSString *)DecodeScienerPS:(NSData *)data;

+(int)RandomNumber0To9_length:(int)length;
//Random generation of 7 digits
+ (NSString *)getRandom7Length;
+(NSString*)EncodeSharedKeyValue:(NSString*)edate;
+(NSString*)DecodeSharedKeyValue:(NSString*)edateStr;

/**
 The bytes of the string
 @return Bytes
 */
+ (int)convertToByte:(NSString*)str;

//convert To Json
+ (NSString *)convertToJsonData:(id)obj;
+ (NSDictionary *)convertDicFromStr:(NSString*)Str;

@end
