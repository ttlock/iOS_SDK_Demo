//
//  Utils.m
//  BTstackCocoa
//
//  Created by wan on 13-1-31.
//
//

#import "TTWifiUtils.h"

#pragma mark MAC

@implementation TTWifiUtils


+(NSData*)DataFromHexStr:(NSString *)hexString{
    
    
    Byte bytes[128]={0x00};  ///3ds key的Byte 数组， 128位
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
    Byte bytesFinal[128] = {0x00};
    for (int i = 0; i <= count; i++) {
        
        bytesFinal[i] = bytes[count-i];
        
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytesFinal length:count+1];
    
    return newData;
    
}





+(void) arrayCopyWithSrc:(Byte*)src srcPos:(int)srcPos dst:(Byte*)dst dstPos:(NSUInteger)dstPos length:(NSUInteger)length
{
    
    for (int i = 0; i<length; i++) {
        
        dst[i+dstPos]=src[srcPos+i];
    }
}



@end
