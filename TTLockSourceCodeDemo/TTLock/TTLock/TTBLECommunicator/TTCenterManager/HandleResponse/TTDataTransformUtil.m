//
//  TTDataTransformUtil.m
//  TTLockDemo
//
//  Created by wjjxx on 16/11/2.
//  Copyright © 2016年 wjj. All rights reserved.
//

#import "TTDataTransformUtil.h"
#import "TTCRC8.h"
#import "TTCommandUtils.h"
#import "TTDebugLog.h"
#import "TTDateHelper.h"

@implementation TTDataTransformUtil

//3字节及以下 用int
+(int)intFromHexBytes:(Byte*)bytes length:(int)dataLen
{
    if (bytes != NULL) {
        
        NSMutableString * hexStr = [[NSMutableString alloc]init];
        
        for (int i = 0 ; i < dataLen; i++) {
            
            [hexStr appendFormat:@"%02x",bytes[i]];
            
        }
        int o = 0;
        //10.15
        NSUInteger len = hexStr.length;
        for (int i = 0 ; i < len; i ++) {
            
            char c = [hexStr characterAtIndex:i];
            
            if(c >= '0' && c <='9')
                o+= (c-48)*((i == (len-1))?1:pow(16,len-1-i));   //// 0 的Ascll - 48   //阿拉伯数字
            else if(c >= 'A' && c <='F')
                o+= (c-55)*((i == (len-1))?1:pow(16,len-1-i)); //// A 的Ascll - 65     //英文字母
            else
                o+= (c-87)*((i == (len-1))?1:pow(16,len-1-i)); //// a 的Ascll - 97     //英文字母
            
        }
        
        return o;
    }
    return 0;
    
}
//4字节及以上 用long long
+(long long)longFromHexBytes:(Byte*)bytes length:(int)dataLen
{
    if (dataLen == 8) {
        long long value =0;
        
        value = (((long long)bytes[0] <<56&0xFF00000000000000L)|((long long)bytes[1] <<48&0xFF000000000000L)|((long long)bytes[2] <<40&0xFF0000000000L)|((long long)bytes[3] <<32&0xFF00000000L)|((long long)bytes[4] <<24&0xFF000000L)|((long long)bytes[5] <<16&0xFF0000L)|((long long)bytes[6] <<8&0xFF00L)|((long long)bytes[7] &0xFFL));
        
        return value;
        
    }
    
    if (bytes != NULL) {
        
        NSMutableString * hexStr = [[NSMutableString alloc]init];
        
        for (int i = 0 ; i < dataLen; i++) {
            
            [hexStr appendFormat:@"%02x",bytes[i]];
            
        }
        long long o = 0;
        //10.15
        NSUInteger len = hexStr.length;
        for (int i = 0 ; i < len; i ++) {
            
            char c = [hexStr characterAtIndex:i];
            
            if(c >= '0' && c <='9')
                o+= (c-48)*((i == (len-1))?1:pow(16,len-1-i));   //// 0 的Ascll - 48   //阿拉伯数字
            else if(c >= 'A' && c <='F')
                o+= (c-55)*((i == (len-1))?1:pow(16,len-1-i)); //// A 的Ascll - 65     //英文字母
            else
                o+= (c-87)*((i == (len-1))?1:pow(16,len-1-i)); //// a 的Ascll - 97     //英文字母
            
        }
        
        return o;
    }
    return 0;
    
}
+(NSString*)stringFormBytes:(Byte*)bytes length:(int)dataLen{
    NSData *adata = [[NSData alloc] initWithBytes:bytes length:dataLen];
    NSString *infoStr  = [[NSString alloc]initWithData:adata encoding:NSUTF8StringEncoding];
    return infoStr;
}
+(NSData*)DataFromHexStr:(NSString *)hexString{
    //根据实际的大小 给定字节个数
    int length = ((int)hexString.length / 2 + 1) > 128 ?  ((int)hexString.length / 2 + 1): 128;
    Byte bytes[length] ;  ///3ds key的Byte 数组
    int j=0;
    for(int i = (int) hexString.length-1;i>=0;i--)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = hex_char1-55; //// A 的Ascll - 65
        else
            int_ch1 = hex_char1-87; //// a 的Ascll - 97
        
        i--;
        
        if (i<0) {
            
            bytes[j] = int_ch1;
            j++;
            break;
        }
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48)*16;   //// 0 的Ascll - 48   //阿拉伯数字
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = (hex_char2-55)*16; //// A 的Ascll - 65     //英文字母
        else
            int_ch2 = (hex_char2-87)*16; //// a 的Ascll - 97     //英文字母
        
        
        int_ch = int_ch1+int_ch2;
        
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    
    int count = j-1;
    //    Byte bytess[count];
    Byte bytesFinal[length] ;
    for (int i = 0; i <= count; i++) {
        
        bytesFinal[i] = bytes[count-i];
        
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytesFinal length:count+1];
    
    return newData;
    
}

+(BOOL)isString:(NSString*)source contain:(NSString*)subStr
{
    
    
    NSRange range = [source rangeOfString:subStr];//判断字符串是否包含
    
    if (range.location == NSNotFound)//不包含
    {
        
        return NO;
    }
    else//包含
    {
        
        return YES;
    }
    
}

+(long) getLongForBytes:(Byte*)packet{
    
    int i0 = packet[0]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i1 = packet[1]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i2 = packet[2]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i3 = packet[3]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i4 = packet[4]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i5 = packet[5]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i6 = packet[6]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i7 = packet[7]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i8 = packet[8]-'0';
    
    //    lastChar = [psLong characterAtIndex:psLong.length-1];
    int i9 = packet[9]-'0';
    
    //     NSString* psLong = [NSString stringWithFormat:@"密码:%d%d%d%d%d%d%d%d%d%d",i0,i1,i2,i3,i4,i5,i6,i7,i8,i9];
    //    [ScienerLog log:psLong isdebug:DEBUG_UTILS];
    
    return i0*1000000000+i1*100000000+i2*10000000+i3*1000000+i4*100000+i5*10000+i6*1000+i7*100+i8*10+i9;
}

+(Byte)generateRandomByte {
    Byte randomByte = 0;
    
    do {
        randomByte = (Byte)arc4random()%128;
        //        randomByte = (Byte)(arc4random()/0x1000000  * 128);
        
        //        randomByte = (Byte)(arc4random()  * 128);
    } while (randomByte == 0);
    
    return randomByte;
}


+(void) arrayCopyWithSrc:(Byte*)src srcPos:(int)srcPos dst:(Byte*)dst dstPos:(NSUInteger)dstPos length:(NSUInteger)length
{
    
    for (int i = 0; i<length; i++) {
        
        dst[i+dstPos]=src[srcPos+i];
    }
}

// 单片机的原因，生成的10位数，必须小于：20亿。所以，这里我们规定第一位必须小于3(十进制)
// 因为现在只接受数字，所以，
// byte表示：第一位：48-51
// byte表示：其他位：48-57
+(void) generateDynamicPassword:(Byte*)bytes length:(int) length
{
    
    for (int i = 0; i < length; i++) {
        
        Byte random;
        if(i == 0){
            
            random = 48;//第一位为0
        } else {
            
            double r = arc4random()/0x10000000;
            if (r>=10) {
                r = (int)r%10;
                
                // r = 9;
            }
            random = r+48;
        }
        
        
        bytes[i] = (Byte)random;
    }
    
}

+(NSString *) generateDynamicPassword:(int) length
{
    
    Byte bytes[length];
    
    [self generateDynamicPassword:bytes length:length];
    
    
    return [[NSString alloc]initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    
}
+(NSData *)EncodeScienerPS:(NSString *)password{
    
    //加密
    Byte encrypt = [self generateRandomByte];
    NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];
    Byte *sourceBytes = (Byte *)[data bytes];
    
    
    Byte *bytes = [TTCRC8 encodeWithDataToCrc:sourceBytes off:0 len:password.length seed:encrypt];
    Byte finalBytes[password.length+1];
    [self arrayCopyWithSrc:bytes srcPos:0 dst:finalBytes dstPos:0 length:password.length];
    finalBytes[password.length]=encrypt;
    
    return [NSData dataWithBytes:finalBytes length:password.length+1];
    
}

+(NSData *)DecodeScienerPSToData:(NSData *)data{
    
    if (data && data.length>0) {
        
        Byte *sourceBytes = (Byte *)[data bytes];
        
        Byte encrypt = sourceBytes[data.length-1];
        
        Byte finalBytes[data.length-1];
        [self arrayCopyWithSrc:sourceBytes srcPos:0 dst:finalBytes dstPos:0 length:data.length-1];
        
        Byte * bytesDecode = [TTCRC8 encodeWithDataToCrc:finalBytes off:0 len:data.length-1 seed:encrypt];
        
        
        return [NSData dataWithBytes:bytesDecode length:data.length-1];
        
    }else{
        
        return [NSData data];
    }
    
}
+(int)RandomNumber0To9_length:(int)length
{
    
    int number = 0;
    for (int i = 0 ; i < length; i ++) {
        
        number += [self RandomInt0To9]*pow(10, i);
        
    }
    
    return number;
    
}
+(int)RandomInt0To9
{
    
    
    double r = arc4random()/0x10000000;
    if (r>=10) {
        
        r = 9;
    }else if(r==0){
        
        r = 1;
    }
    
    return r;
    
    
}
+ (NSString *)getRandom7Length{
    Byte bytes[7];
    
    for (int i = 0; i < 7; i++) {
        
        Byte random;
        
        double r = arc4random()/0x10000000;
        if (r>=10) {
            
            r = [self getRandomNumber:1 to:9];//9;
        }else if(r==0){
            
            r = [self getRandomNumber:1 to:9];//1;
        }
        random = r+48;
        
        
        bytes[i] = (Byte)random;
        
    }
    NSString * nokeyps = [[NSString alloc]initWithBytes:bytes length:7 encoding:NSUTF8StringEncoding];
    
    return nokeyps;
}

+(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random() % (to - from + 1)));
    
}
+(NSString*)EncodeSharedKeyValue:(NSString*)edate{
    
    NSData * edateData = [self EncodeScienerPS:edate];
    Byte *edateBytes = (Byte *)[edateData bytes];
    
    
    NSUInteger count = edateData.length;
    NSMutableString * edateStr = [NSMutableString stringWithString:@""];
    for (int i = 0; i < count; i++) {
        [edateStr appendFormat:@"%i,",edateBytes[i]];
    }
    if (edateStr.length>0) {
        [edateStr deleteCharactersInRange:NSMakeRange(edateStr.length-1, 1)];
    }
    return edateStr;
}

+(NSString*)DecodeSharedKeyValue:(NSString*)edateStr{
    
    NSArray * locks = [edateStr componentsSeparatedByString:@","];
    Byte values[locks.count];
    for (int i = 0; i < locks.count; i++) {
        
        values[i] = [[locks objectAtIndex:i] intValue];
    }
    
    return [self DecodeScienerPS:[NSData dataWithBytes:values length:locks.count]];
}


+(NSString *)DecodeScienerPS:(NSData *)data{
    if (data && data.length>0) {
        Byte *sourceBytes = (Byte *)[data bytes];
        Byte encrypt = sourceBytes[data.length-1];
        Byte finalBytes[data.length-1];
        [self arrayCopyWithSrc:sourceBytes srcPos:0 dst:finalBytes dstPos:0 length:data.length-1];
        Byte * bytesDecode = [TTCRC8 encodeWithDataToCrc:finalBytes off:0 len:data.length-1 seed:encrypt];
        return [[NSString alloc]initWithBytes:bytesDecode length:data.length-1 encoding:NSUTF8StringEncoding];
    }else{
        return @"";
    }
}

+ (int)convertToByte:(NSString*)str {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [str dataUsingEncoding:enc];
    int byteLength = (int) [da length];
    return byteLength;
    
}
+ (NSString *)convertToJsonData:(id)obj{
    NSData *data=[NSJSONSerialization
                  dataWithJSONObject:obj options:0
                  error:nil];
    return  [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)convertDicFromStr:(NSString*)Str{
    if ([Str isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)Str;
    }
   return  [NSJSONSerialization JSONObjectWithData:[Str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}
@end
