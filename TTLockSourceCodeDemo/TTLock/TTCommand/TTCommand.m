//
//  Command.m
//  BTstackCocoa
//
//  Created by wan on 13-2-22.
//
//

#import "TTCommand.h"
#import "TTCRC8.h"
#import "TTMacros.h"
#import "TTSecurityUtil.h"
#import "TTDataTransformUtil.h"

//Command value definition
Byte VALUE_ON 	= 0x01;
Byte VALUE_OFF 	= 0x00;

@implementation TTCommand

BOOL DEBUG_COMMAND = YES;

//通信协议 格式
-(void)commandWithVersion:(NSString*)lockVersion
{
    header[0] = 0x7F;
    header[1] = 0x5A;
    //APP的固定来源是 0xAA
    encrypt =  0xAA; //[TTDataTransformUtil generateRandomByte];
    length = 0;
    //这里的5个字节应该就是占位符
    if (lockVersion.length == 0) {
        protocolCategory = Version_Lock_v4;
        protocolVersion = 0x01;
        applyCatagory = 0x01;
        applyID[0] = 0x00;
        applyID[1] = 0x01;
        applyID2[0] = 0x00;
        applyID2[1] = 0x01;
    }else{
        NSArray *array = [lockVersion componentsSeparatedByString:@"."];
        protocolCategory = (Byte)[array[0] intValue];
        protocolVersion = (Byte)[array[1] intValue];
        applyCatagory = (Byte)[array[2] intValue];
        //占两个字节
        NSData *numberData = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",[array[3] intValue]]];
        Byte *psByte = (Byte *)[numberData bytes];
        [TTDataTransformUtil arrayCopyWithSrc:psByte  srcPos:0 dst:applyID dstPos:0 length:2];
        
        //占两个字节
        NSData *numberData2 = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",[array[4] intValue]]];
        Byte *psByte2 = (Byte *)[numberData2 bytes];
        [TTDataTransformUtil arrayCopyWithSrc:psByte2  srcPos:0 dst:applyID2 dstPos:0 length:2];

    }
    
}

-(void)command:(Byte*)commandByte withLength:(int)cmdLength{
    
    header[0] = commandByte[0];
    header[1] = commandByte[1];
    
    protocolCategory  = commandByte[2];
    
    if (protocolCategory == Version_Lock_v3_AES || protocolCategory == Version_Lock_v4 || protocolCategory == Version_Lock_v4_1 || protocolCategory == Version_PARK_Lock_v1) {
        
        protocolVersion  = commandByte[3];
        applyCatagory  = commandByte[4];
        applyID[0]  = commandByte[5];
        applyID[1]  = commandByte[6];
        applyID2[0]  = commandByte[7];
        applyID2[1]  = commandByte[8];
        command   = commandByte[9];
        encrypt   = commandByte[10];
        length    = commandByte[11];
        //校验位
        checksum = commandByte[cmdLength - 1];
        
        Byte commandWithoutChecksum[cmdLength - 1];
        [TTDataTransformUtil arrayCopyWithSrc:commandByte srcPos:0 dst:commandWithoutChecksum dstPos:0 length:cmdLength-1];
        
        Byte checksumTmp = (Byte)[TTCRC8 computeWithDataToCrc:commandWithoutChecksum len:cmdLength-1];
        
        //判断对方校验和自己校验到是否相同
        mIsChecksumValid = (checksumTmp == checksum);
        
        [TTDataTransformUtil arrayCopyWithSrc:commandByte srcPos:12 dst:data dstPos:0 length:length];
      
        version = [NSString stringWithFormat:@"%i.%i.%i.%i.%i",protocolCategory,protocolVersion,applyCatagory,[TTDataTransformUtil intFromHexBytes:applyID length:2],[TTDataTransformUtil intFromHexBytes:applyID2 length:2]];
     
    }
    else{
        command = commandByte[3];
        encrypt = commandByte[4];
        length = commandByte[5];
        [TTDataTransformUtil arrayCopyWithSrc:commandByte srcPos:6 dst:data dstPos:0 length:length];
    }
    
}


-(void) setCommand:(Byte)commandToSet {
    
    command = commandToSet;
}

-(Byte)getCommand {
    return command;
}

-(void)setData:(Byte*)dataToSet withLength:(NSInteger)setdataLength{
    
    Byte* tmpData = [TTCRC8 encodeWithDataToCrc:dataToSet off:0 len:setdataLength seed:encrypt];
    [TTDataTransformUtil arrayCopyWithSrc:tmpData srcPos:0 dst:data dstPos:0 length:setdataLength];

    length = setdataLength;
    

}

-(void)setDataAES:(Byte*)dataToSet withLength:(NSInteger)setdataLength key:(Byte*)pwdKey{
    
        NSData * dataEncrypted = [TTSecurityUtil encryptAESData:[NSData dataWithBytes:dataToSet length:setdataLength] keyBytes:pwdKey];
        Byte* tmpData = (Byte*)dataEncrypted.bytes;
        [TTDataTransformUtil arrayCopyWithSrc:tmpData srcPos:0 dst:data dstPos:0 length:(int)dataEncrypted.length];
        length = dataEncrypted.length;
}

-(Byte*)getData {
   
    Byte* bytes = [TTCRC8 encodeWithDataToCrc:data off:0 len:length seed:encrypt];

    return bytes;
    
}

-(Byte*)getDataAes_pwdKey:(Byte*)pwdKey {
    
    if (!data) {
        return nil;
    }
    NSData *psData = [TTSecurityUtil decryptToDataAESData:[NSData dataWithBytes:data length:length] keyBytes:pwdKey];
    dataLength = (int) [NSData dataWithBytes:data length:length].length;
    length = psData.length;
    Byte *bytes = (Byte *)[psData bytes];
    
    
//    NSData *psData = [SecurityUtil decryptToDataAESData:[NSData dataWithBytes:data length:length] key:pwdKey];
//    Byte *bytes = (Byte *)[psData bytes];
    
    return bytes;
    
}

-(Byte*)getDataAes_pwdKeyStr:(NSString*)pwdKey{
    
    
    NSData *psData = [TTSecurityUtil decryptToDataAESData:[NSData dataWithBytes:data length:length] key:pwdKey];
    Byte *bytes = (Byte *)[psData bytes];
    
    return bytes;
    
}
-(void)buildCommand:(Byte*)commandWithChecksum withLength:(int)setdataLength{

    
    commandWithChecksum[0] = header[0];
    commandWithChecksum[1] = header[1];
    commandWithChecksum[2] = protocolCategory;
    
    if (protocolCategory == Version_Lock_v4 || protocolCategory == Version_Lock_v4_1 || protocolCategory == Version_PARK_Lock_v1) {
        
        commandWithChecksum[3] = protocolVersion;
        commandWithChecksum[4] = applyCatagory;
        commandWithChecksum[5] = applyID[0];
        commandWithChecksum[6] = applyID[1];
        commandWithChecksum[7] = applyID2[0];
        commandWithChecksum[8] = applyID2[1];
        commandWithChecksum[9] = command;
        commandWithChecksum[10] = encrypt;
        commandWithChecksum[11] = length;
        //TODO
        if (length > 0)
            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:0 dst:commandWithChecksum dstPos:12 length:length];
    }else{
        commandWithChecksum[3] = command;
        commandWithChecksum[4] = encrypt;
        commandWithChecksum[5] = length;
        //TODO
        if (length > 0)
            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:0 dst:commandWithChecksum dstPos:6 length:length];
    }
// Set checksum here
//  Byte commandWithChecksum[sizeof(commandWithoutChecksum) + 1];
    
    //byte checksum1 = CodecUtils.getCRC8(commandWithoutChecksum);
    Byte checksumJava = (Byte)[TTCRC8 computeWithDataToCrc:commandWithChecksum len:setdataLength-1];
    commandWithChecksum[setdataLength-1] = checksumJava;
}


+ (NSData*)getDefaultAesKey{
    Byte defaultAesKey[16] = {0x98, 0x76, 0x23, 0xE8, 0xA9, 0x23, 0xA1, 0xBB, 0x3D, 0x9E, 0x7D, 0x03, 0x78, 0x12, 0x45, 0x88};
    
   return [NSData dataWithBytes:defaultAesKey length:16];
}
@end
