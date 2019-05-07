//
//  HandleResponse.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/15.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTHandleResponse.h"
#import "TTMacros.h"
#import "TTSecurityUtil.h"
#import "TTCommand.h"
#import "TTDateHelper.h"
#import "TTDataTransformUtil.h"

@implementation TTHandleResponse

static Byte dataResponse[256];
static int responseDataSize;

+ (TTCommand *) handleCommandResponse: (NSData *)data
{
   
    Byte *dataResponseTemp = (Byte *)[data bytes];
    [TTDataTransformUtil arrayCopyWithSrc:dataResponseTemp
                       srcPos:0
                          dst:dataResponse
                       dstPos:responseDataSize
                       length:data.length];
    responseDataSize =responseDataSize+(int)data.length;
    //没有结束符10 13
    int startIndex=0;
    for (int i = 0; i < responseDataSize; i++) {
        startIndex = i;
        Byte first = dataResponse[i];
        if (first==127) {
            if (i != responseDataSize-1) {
                Byte second = dataResponse[i+1];
                if (second == 90) {
                    //这里是开始。
                    break;
                }
            }
        }
    }
    //获取数据长度
    int dataLen = 0;
    if (responseDataSize-startIndex >= 2) {
        //获取版本协议，每条指令都必须要携带版本信息，否者这里没法获取数据
        Byte version = dataResponse[startIndex+2];
        if (version == Version_Lock_v1 || version == Version_Lock_v2 || version == Version_Lock_v3) {
            //版本3，2，1
            
            if (responseDataSize-startIndex >= 7) {
                dataLen = dataResponse[startIndex+5];
                
                if ((responseDataSize-startIndex)>=(dataLen+7)) {
                    
                    
                    //说明够一整条数据了
                    Byte dataCommand[dataLen+7];
                    
                    [TTDataTransformUtil arrayCopyWithSrc:dataResponse
                                       srcPos:startIndex
                                          dst:dataCommand
                                       dstPos:0
                                       length:dataLen+7];
                    
                    
                    TTCommand *command = [[TTCommand alloc]init];
                    [command command:dataCommand withLength:dataLen+7];
                    responseDataSize=0;
                    return command;
                    
                }
            }
        }
        else{
            //版本4
            
            if (responseDataSize-startIndex >= 13) {
                
                dataLen = dataResponse[startIndex+11];
                
                if ((responseDataSize-startIndex)>=(dataLen+13)) {
                    
                    //说明够一整条数据了
                    Byte dataCommand[dataLen+13];
                    [TTDataTransformUtil arrayCopyWithSrc:dataResponse
                                       srcPos:startIndex
                                          dst:dataCommand
                                       dstPos:0
                                       length:dataLen+13];
                    
                    TTCommand *command = [[TTCommand alloc]init];
                    [command command:dataCommand withLength:dataLen+13];
                    responseDataSize=0;
                    return command;
                  
                }
            }
            
        }
    }
    return nil;
    
}

//读取开门密码 1-永久密码2-单次密码3-限时密码4-循环密码
+ (void)unlockPasswordWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset{
    
    NSMutableDictionary *recordDic = @{}.mutableCopy;
    
    int  passwordType =[TTDataTransformUtil intFromHexBytes:&data[i+1] length:1];
    
    //锁里的密码类型和文档里的 不一致
    switch (passwordType) {
        case TTPasscodeTypeOnce:
            passwordType = TTPasscodeTypePermanent;
            break;
        case TTPasscodeTypePermanent:
            passwordType = TTPasscodeTypeOnce;
            break;
        default:
            break;
    }
    [recordDic setObject:@(passwordType) forKey:@"keyboardPwdType"];
    //锁里存的先是新密码，再是原密码
    int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+2] length:1];
    int currentLength = [TTDataTransformUtil intFromHexBytes:&data[i+2+1+originalLength] length:1];
    Byte originalPassword[originalLength];
    Byte currentPassword[currentLength];
    for (int j = i+3; j < i+3+originalLength; j++) {
        originalPassword[j-i-3]=data[j];
    }
    for (int j = i+3+originalLength + 1; j < i+3+originalLength + 1 +currentLength; j++) {
        currentPassword[j-i-3-originalLength-1]=data[j];
    }
    NSString * originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
    NSString * currentPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:currentPassword length:currentLength] encoding:NSUTF8StringEncoding];
    [recordDic setObject:originalPasswordStr forKey:@"newKeyboardPwd"];
    [recordDic setObject:currentPasswordStr forKey:@"keyboardPwd"];
    
    //开始时间
    NSString *startDate = [NSString string];
    for (int j = 0; j < 5; j++) {
        startDate = [NSString stringWithFormat:@"%@%02d",startDate,[TTDataTransformUtil intFromHexBytes:&data[i+3+originalLength + 1 +currentLength  +j] length:1]];
    }
    long long startDateLong = [TTDateHelper formateDateFromStringToDate:startDate format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970*1000;
    
    [recordDic setObject:@(startDateLong) forKey:@"startDate"];
    
    switch (passwordType) {
        case TTPasscodeTypePeriod:
        case TTPasscodeTypeOnce:{
            //结束时间
            NSString *endDate = [NSString string];
            for (int j = 0; j < 5; j++) {
                endDate = [NSString stringWithFormat:@"%@%02d",endDate,[TTDataTransformUtil intFromHexBytes:&data[i+3+originalLength+ 1 + currentLength +5+j] length:1]];
            }
            long long endDateLong = [TTDateHelper formateDateFromStringToDate:endDate format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970*1000;
            [recordDic setObject:@(endDateLong) forKey:@"endDate"];
            
        }break;
        case TTPasscodeTypeCycle:{
            //循环类型
            //记录总长度 为第3和第4个字节
            Byte cycleTypeByte[2] = {data[i+3+originalLength+ 1 + currentLength +5],data[i+3+originalLength+ 1 + currentLength +6]};
            int cycleType = [TTDataTransformUtil intFromHexBytes:cycleTypeByte length:2];
            [recordDic setObject:@(cycleType) forKey:@"cycleType"];
            
        }break;
        default:{
            
        } break;
    }
    
    [lockOpenRecordArr addObject:recordDic] ;
    
}
+ (void)operationRecordWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset{
    
    NSMutableDictionary *recordDic = @{}.mutableCopy;
    //这一条记录的长度 但不包含自己
    int recordLengthNum = [TTDataTransformUtil intFromHexBytes:&data[i] length:1];
    int frontFixedLen = 9 - 1;//因为长度本身占一个字节 所以要减去
    //把返回的数据装到数组中
    int  lockOpenType =[TTDataTransformUtil intFromHexBytes:&data[i+1] length:1];
    
    //开门时间
    NSString *recordTime = [NSString string];
    for (int j = i+2; j < i+8; j++) {
        recordTime = [NSString stringWithFormat:@"%@%02d",recordTime,[TTDataTransformUtil intFromHexBytes:&data[j] length:1]];
    }
    long long dateTimeLong = [TTDateHelper formateDateFromStringToDate:recordTime format:@"yyMMddHHmmss" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970;
    
    int  electricQuantity =[TTDataTransformUtil intFromHexBytes:&data[i+8] length:1];
    
    recordDic[@"recordType"] = @(lockOpenType) ;
    recordDic[@"operateDate"] = @(dateTimeLong*1000) ;
    recordDic[@"electricQuantity"] = @(electricQuantity) ;
    
    switch (lockOpenType) {
        case 1:
        case 26:
        case 28:
        case 3:
        case 41:{
            Byte useridbyte[4];
            for (int j = i+9; j < i+9+4; j++) {
                useridbyte[j-i-9]=data[j];
            }
            NSString *userID = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:useridbyte length:4]];
            
            Byte uniqueByte[4];
            for (int j = i+9+4; j < i+9+4+4; j++) {
                uniqueByte[j-i-9-4]=data[j];
                
            }
            NSString * uniqueStr = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:uniqueByte length:4]];
            
            recordDic[@"uid"] = userID;
            recordDic[@"recordId"] =  uniqueStr;
            
        }break;
        case 4:
        case 5:
        case 6:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 34:
        case 38:
        {
            int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+9] length:1];
            int currentLength = [TTDataTransformUtil intFromHexBytes:&data[i+9+1+originalLength] length:1];
            Byte originalPassword[originalLength];
            Byte currentPassword[currentLength];
            for (int j = i+10; j < i+10+originalLength; j++) {
                originalPassword[j-i-10]=data[j];                                                                                        }
            for (int j = i+10+originalLength + 1; j < i+10+originalLength + 1 +currentLength; j++) {
                currentPassword[j-i-10-originalLength-1]=data[j];                                                                                    }
            NSString * originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
            NSString * currentPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:currentPassword length:currentLength] encoding:NSUTF8StringEncoding];
            recordDic[@"password"] = originalPasswordStr;
            recordDic[@"newPassword"] =  currentPasswordStr;
            
            
        }break;
        case 7:{
            int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+9] length:1];
            Byte originalPassword[originalLength];
            for (int j = i+10; j < i+10+originalLength; j++) {
                originalPassword[j-i-10] = data[j];
                
            }
            NSString *originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
            recordDic[@"password"] = originalPasswordStr;
            
            
        }break;
        case 8:{
            
            if (recordLengthNum <= 13) {
                NSString *deleteTime = [NSString string];
                for (int j = i + 9 ; j < i+9 + 5; j++) {
                    
                    deleteTime = [NSString stringWithFormat:@"%@%02d",deleteTime,[TTDataTransformUtil intFromHexBytes:&data[j] length:1]];
                    
                }
                long long dateTimeLong = [TTDateHelper formateDateFromStringToDate:deleteTime format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970;
                recordDic[@"deleteDate"] = @(dateTimeLong*1000);
                
            }else{
                
                NSString *deleteTime = [NSString string];
                for (int j = i + 9 ; j < i+9 + 5; j++) {
                    
                    deleteTime = [NSString stringWithFormat:@"%@%02d",deleteTime,[TTDataTransformUtil intFromHexBytes:&data[j] length:1]];
                    
                }
                long long dateTimeLong = [TTDateHelper formateDateFromStringToDate:deleteTime format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970;
                
                i = i+ 5;
                
                int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+9] length:1];
                Byte originalPassword[originalLength];
                for (int j = i+10; j < i+10+originalLength; j++) {
                    originalPassword[j-i-10] = data[j];
                    
                }
                NSString *originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
                recordDic[@"password"] = originalPasswordStr;
                recordDic[@"deleteDate"] = @(dateTimeLong*1000);
            }
            
        }break;
        case 15:
        case 17:
        case 18:
        case 25:
        case 35:
        case 39:{
            
            //身份证是8个字节的
            if (recordLengthNum == frontFixedLen + 8) {
                Byte uniqueByte[8];
                for (int j = i+9; j < i+9+8; j++) {
                    uniqueByte[j-i-9]=data[j];
                }
                NSString * uniqueStr  = [NSString stringWithFormat:@"%lld", [TTDataTransformUtil longFromHexBytes:uniqueByte length:8]];
                recordDic[@"password"] = uniqueStr;
                
            }else{
                Byte uniqueByte[4];
                for (int j = i+9; j < i+9+4; j++) {
                    uniqueByte[j-i-9]=data[j];
                }
                NSString * uniqueStr  = [NSString stringWithFormat:@"%lld", [TTDataTransformUtil longFromHexBytes:uniqueByte length:4]];
                recordDic[@"password"] = uniqueStr;
                
                
                /* 下面的这种情景被去掉了
                 //密码长度和密码为可选字段，不是所有的锁都有这个字段的，这个字段是用来标识这个卡是哪个密码添加的。使用场景：给客户发了一个期限密码，用户使用这个期限密码添加卡，这张卡也具有相同的使用期限。
                 if (recordLengthNum > frontFixedLen + 4) {
                 i = i+ 4;
                 int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+9] length:1];
                 Byte originalPassword[originalLength];
                 for (int j = i+10; j < i+10+originalLength; j++) {
                 originalPassword[j-i-10] = data[j];
                 
                 }
                 NSString *originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
                 recordDic[@"oldPassword"] = originalPasswordStr;
                 
                 }
                 */
            }
        }break;
        case 19:{
            //计算mac地址
            NSString *macStr;
            Byte macBytes[6];
            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:i+9 dst:macBytes dstPos:0 length:6];
            NSMutableString * macBuffer = [[NSMutableString alloc]init];
            for (int j = 5; j >= 0 ; j --) {
                [macBuffer appendFormat:@"%02x:",macBytes[j]];
            }
            if (macBuffer.length>0) {
                [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
                macStr = [macBuffer uppercaseString];
            }
            recordDic[@"password"] = macStr;
            
        }break;
        case 20:
        case 21:
        case 22:
        case 23:
        case 33:
        case 40:
        {
            Byte uniqueByte[6];
            for (int j = i+9; j < i+9+6; j++) {
                uniqueByte[j-i-9]=data[j];
            }
            NSString * uniqueStr  = [NSString stringWithFormat:@"%lld", [TTDataTransformUtil longFromHexBytes:uniqueByte length:6]];
            recordDic[@"password"] = uniqueStr;
            //密码长度和密码为可选字段，不是所有的锁都有这个字段的，这个字段是用来标识这个指纹是哪个密码添加的。使用场景：给客户发了一个期限密码，用户使用这个期限密码添加指纹，这个指纹也具有相同的使用期限。
            if (recordLengthNum > frontFixedLen + 6) {
                i = i+ 6;
                int originalLength = [TTDataTransformUtil intFromHexBytes:&data[i+9] length:1];
                Byte originalPassword[originalLength];
                for (int j = i+10; j < i+10+originalLength; j++) {
                    originalPassword[j-i-10] = data[j];
                    
                }
                NSString *originalPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:originalPassword length:originalLength] encoding:NSUTF8StringEncoding];
                recordDic[@"oldPassword"] = originalPasswordStr;
                
            }
            
        }break;
        case 37:{
            Byte useridbyte[4];
            for (int j = i+9; j < i+9+4; j++) {
                useridbyte[j-i-9]=data[j];
            }
            NSString *userID = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:useridbyte length:4]];
            
            Byte uniqueByte[4];
            for (int j = i+9+4; j < i+9+4+4; j++) {
                uniqueByte[j-i-9-4]=data[j];
                
            }
            NSString * uniqueStr = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:uniqueByte length:4]];
            
            int keyValue = [TTDataTransformUtil intFromHexBytes:&data[i+9+4+4] length:1];
            recordDic[@"uid"] = userID;
            recordDic[@"recordId"] =  uniqueStr;
            recordDic[@"keyId"] = @(keyValue);
            
        }break;
        default:{
            
        }  break;
    }
    [lockOpenRecordArr addObject:recordDic] ;
    
}
+(void)ICQueryWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr type:(int)type timezoneRawOffset:(long)timezoneRawOffset{
    
    NSMutableDictionary *recordDic = @{}.mutableCopy;
    //    type 0-ic ,1-指纹 , 2-8个字节的指纹
    int  numberLen = 4;
    if (type == 1) {
        numberLen = 6;
    }else if (type == 2){
        numberLen = 8;
    }
    Byte useridbyte[numberLen];
    for (int j = 0; j < numberLen; j++) {
        useridbyte[j]=data[i+j];
    }
    NSString *userID = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:useridbyte length:numberLen]];
    
    //开始时间
    NSString *startDate = [NSString string];
    for (int j = 0; j < 5; j++) {
        startDate = [NSString stringWithFormat:@"%@%02d",startDate,[TTDataTransformUtil intFromHexBytes:&data[i+numberLen+j] length:1]];
    }
    //结束时间
    NSString *endDate = [NSString string];
    for (int j = 0; j < 5; j++) {
        endDate = [NSString stringWithFormat:@"%@%02d",endDate,[TTDataTransformUtil intFromHexBytes:&data[i+numberLen+5+j] length:1]];
    }
    
    if (type == 1) {
        [recordDic setObject:userID forKey:@"fingerprintNum"];
        
    }else{
        [recordDic setObject:userID forKey:@"cardNumber"];
    }
    long long startDateLong = [TTDateHelper formateDateFromStringToDate:startDate format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970*1000;
    long long endDateLong = [TTDateHelper formateDateFromStringToDate:endDate format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970*1000;
    [recordDic setObject:@(startDateLong) forKey:@"startDate"];
    [recordDic setObject:@(endDateLong) forKey:@"endDate"];
    [lockOpenRecordArr addObject:recordDic];
    
}

+(void)passageModeWithByteData:(Byte*)data lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset{
    
    NSMutableDictionary *recordDic = @{}.mutableCopy;
    int type = [TTDataTransformUtil intFromHexBytes:&data[5] length:1];
    int week = [TTDataTransformUtil intFromHexBytes:&data[6] length:1];
    int month = [TTDataTransformUtil intFromHexBytes:&data[7] length:1];
    recordDic[@"type"]  = @(type);
    recordDic[@"weekOrDay"]  = @(week);
    recordDic[@"month"] = @(month);
    
    int startDate = [TTDataTransformUtil intFromHexBytes:&data[8] length:1] * 60 + [TTDataTransformUtil intFromHexBytes:&data[9] length:1] ;
    int endDate = [TTDataTransformUtil intFromHexBytes:&data[10] length:1] * 60 + [TTDataTransformUtil intFromHexBytes:&data[11] length:1] ;
    [recordDic setObject:@(startDate) forKey:@"startDate"];
    [recordDic setObject:@(endDate) forKey:@"endDate"];
    [lockOpenRecordArr addObject:recordDic];
}

+ (NSTimeInterval)convertTime:(Byte*)data index:(int)index length:(int)length timezoneRawOffset:(long)timezoneRawOffset{
    
    NSString *recordTime = [NSString string];
    for (int i = 0; i < length; i++) {
        recordTime = [NSString stringWithFormat:@"%@%02d",recordTime,[TTDataTransformUtil intFromHexBytes:&data[i+index] length:1]];
    }
    //时间
    NSTimeInterval dateTime = 0;
    if (recordTime.longLongValue != 0) {
        if (length ==5) {
            dateTime = [TTDateHelper formateDateFromStringToDate:recordTime format:@"yyMMddHHmm" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970;
        }
        if (length == 6 ) {
            
            dateTime = [TTDateHelper formateDateFromStringToDate:recordTime format:@"yyMMddHHmmss" timezoneRawOffset:timezoneRawOffset].timeIntervalSince1970;
        }
        
    }
    
    return dateTime;
}
+ (NSArray*)generateV3Code{
    
    //生成年份、约定数和映射数
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < 10; i++) {
        NSString *rand = [NSString stringWithFormat:@"%d",arc4random() % 1070 + 1];
        
        [mutArray addObject:rand];
        for (int j = 0; j < i; j++) {
            if (mutArray[i] == mutArray[j]) {
                mutArray[i] = [NSString stringWithFormat:@"%d",arc4random() % 1070 + 1];
            }
        }
    }
    NSArray *code = [NSArray arrayWithArray:mutArray];
    return code;
}
+ (NSArray*)generateSecretKey{
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    for (int j = 0; j < 10; j++) {
        NSMutableArray *startArray=[[NSMutableArray alloc] initWithObjects:@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,nil];
        NSMutableArray *resultArray=[[NSMutableArray alloc] initWithCapacity:0];
        //随机数个数
        NSInteger m=10;
        for (int i=0; i<m; i++) {
            int t=arc4random()%startArray.count;
            resultArray[i]=startArray[t];
            startArray[t]=[startArray lastObject]; //为更好的乱序，故交换下位置
            [startArray removeLastObject];
        }
        NSString *str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@",resultArray[0],resultArray[1],resultArray[2],resultArray[3],resultArray[4],resultArray[5],resultArray[6],resultArray[7],resultArray[8],resultArray[9]];
        if (str.longLongValue < 987654322) {
            j--;
        }else{
            [mutArr addObject:str];
        }
    }
    NSArray *secretKey = [NSArray arrayWithArray:mutArr];
    return secretKey;
}

+ (NSArray*)generateV3Year{
    NSString *year = [TTDateHelper getCurrentYear];
    NSMutableArray * yearMutArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < 10; i++) {
        [yearMutArr addObject:[NSNumber numberWithInt:(year.intValue + i)]];
    }
    NSArray *yearArray = [NSArray arrayWithArray:yearMutArr];
    return yearArray;
}

+ (NSString *)generateV3PasswordWithCodeArray:(NSArray *)code yearArray:(NSArray*)yearArray secretKeyArray:(NSArray *)secretKey timeString:(NSString *)timeString{
    
    NSMutableString *jsonString = [NSMutableString string];
    jsonString = [[NSMutableString alloc] initWithString:@"["];
    for (int i = 0;i < 10; i++) {
        NSString *str = [NSString stringWithFormat:@"{\"year\":\"%@\",\"code\":\"%@\",\"secretKey\":\"%@\"},",yearArray[i],[NSString stringWithFormat:@"%@",code[i]],[NSString stringWithFormat:@"%@",secretKey[i]]];
        [jsonString appendString:str];
    }
    NSUInteger location = [jsonString length]-1;
    NSRange range  = NSMakeRange(location, 1);
    [jsonString replaceCharactersInRange:range withString:@"]"];
    
    NSData *strData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [timeString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * dataEncrypted = [TTSecurityUtil encryptAESData:strData keyBytes:(Byte *)keyData.bytes];
    
    NSString *str  = [TTSecurityUtil encodeBase64Data:dataEncrypted];
    
    return  str;
    
}
+ (NSString *)generateWith900Array:(NSArray*)Ps900Array{
    //2s
    NSMutableString *keyboardPwd = [[NSMutableString alloc]init];
    [keyboardPwd appendFormat:@"{"];
    [keyboardPwd appendFormat:@"\"id\":%i,",0];
    //10m
    {
        [keyboardPwd appendString:@"\"tenMinutes\":\""];
        for(int i = 800;i<900;i++)
        {
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    //1天
    {
        [keyboardPwd appendString:@"\"oneDay\":\""];
        
        for(int i = 0;i<300;i++)
        {
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    //2天
    {
        [keyboardPwd appendString:@"\"twoDays\":\""];
        for(int i = 300;i<450;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    //3天
    {
        
        [keyboardPwd appendString:@"\"threeDays\":\""];
        for(int i = 450;i<550;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    //4天
    {
        
        [keyboardPwd appendString:@"\"fourDays\":\""];
        for(int i = 550;i<650;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
    }
    
    //5天
    {
        
        [keyboardPwd appendString:@"\"fiveDays\":\""];
        for(int i = 650;i<700;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    //6天
    {
        
        [keyboardPwd appendString:@"\"sixDays\":\""];
        for(int i = 700;i<750;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
    }
    
    //7天
    {
        
        [keyboardPwd appendString:@"\"sevenDays\":\""];
        for(int i = 750; i<800;i++)
        {
            
            [keyboardPwd appendFormat:@"%@,",Ps900Array[i]];
        }
        if (keyboardPwd.length>0) {
            
            [keyboardPwd deleteCharactersInRange:NSMakeRange(keyboardPwd.length-1, 1)];
            
        }
        [keyboardPwd appendString:@"\","];
        
    }
    
    [keyboardPwd appendFormat:@"\"oneDaySequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"twoDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"threeDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"fourDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"fiveDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"sixDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"sevenDaysSequence\":%i,",0];
    [keyboardPwd appendFormat:@"\"tenMinutesSequence\":%i",0];
    [keyboardPwd appendFormat:@"}"];
    return keyboardPwd;
    
}

+ (int)gettimezoneRawOffset {
    NSDate *currentDate =  [NSDate date];
    //设置当前日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:currentDate];
    
    //设置UTC的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:currentDate];
    
    NSTimeInterval interval = sourceGMTOffset - destinationGMTOffset ;
    
    int timezoneRawOffset = (int)interval  * 1000;
    return timezoneRawOffset;
    
}

+ (NSString *)getV3PasswordData:(Byte*)data timeString:(NSString *)timeString timezoneRawOffset:(long)timezoneRawOffset{
    
    Byte sumbtye[6];
    for (int i = 0; i < 6 ; i++) {
        sumbtye[i]=data[i+3];
    }
    long long sum = [TTDataTransformUtil longFromHexBytes:sumbtye length:6];
    NSString* code = [TTHandleResponse conventionalNumber:sum] ;
    NSString* secretKey = [TTHandleResponse mappingNumber:sum] ;
    long long dateTimeLong = [TTHandleResponse convertTime:data index:3+6 length:5 timezoneRawOffset:timezoneRawOffset];
    
    NSMutableDictionary *pwdDataDic = @{}.mutableCopy;
    [pwdDataDic setObject:code forKey:@"code"];
    [pwdDataDic setObject:secretKey forKey:@"secretKey"];
    [pwdDataDic setObject:[NSNumber numberWithLongLong:dateTimeLong*1000]  forKey:@"deleteDate"];
    
    //数组转json
    NSData *pwdData=[NSJSONSerialization
                     dataWithJSONObject:pwdDataDic options:0 //NSJSONWritingPrettyPrinted
                     error:nil];
    NSString* jsonString = [[NSString
                             alloc]initWithData:pwdData
                            encoding:NSUTF8StringEncoding];
    
    NSData *strData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [timeString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData * dataEncrypted = [TTSecurityUtil encryptAESData:strData keyBytes:(Byte *)keyData.bytes];
    
    NSString *str  = [TTSecurityUtil encodeBase64Data:dataEncrypted];
    
    return  str;
    
}
+ (NSString*)conventionalNumber:(long long)decimal{
    
    NSString *decimalstr = [self toBinarySystemWithDecimalSystem:decimal];
    if (decimalstr.length <48) {
        //前面补0 满6个字节
        while (true) {
            decimalstr = [NSString stringWithFormat:@"%d%@",0,decimalstr];
            if (decimalstr.length == 48) {
                break;
            }
        }
        
    }
    //前1.5个字节 即前12位
    NSString * conventionalNumberStr = [decimalstr substringWithRange:NSMakeRange(0, 12)];
    
    return [self toDecimalSystemWithBinarySystem:conventionalNumberStr];
    
}
+ (NSString*)mappingNumber:(long long)decimal{
    NSString *decimalstr = [self toBinarySystemWithDecimalSystem:decimal];
    if (decimalstr.length <48) {
        //前面补0 满6个字节
        while (true) {
            decimalstr = [NSString stringWithFormat:@"%d%@",0,decimalstr];
            if (decimalstr.length == 48) {
                break;
            }
        }
        
    }
    //后4.5个字节 即后36位
    NSString *mappingNumberStr = [decimalstr substringWithRange:NSMakeRange(12, 36)];
    
    return [self toDecimalSystemWithBinarySystem:mappingNumberStr] ;
}
//  十进制转二进制
+ (NSString *)toBinarySystemWithDecimalSystem:(long long)decimal
{
    long long num = decimal ;
    long long remainder = 0;      //余数
    long long divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%lld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}
//  二进制转十进制
+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary
{
    long long ll = 0 ;
    long long  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] longLongValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%lld",ll];
    
    return result;
}

+ (NSString *)getDeviceInfoData:(Byte*)data deviceInfoType:(TTDeviceInfoType)deviceInfoType{
    
    NSString *infoStr = [NSString string];
    if (deviceInfoType == TTDeviceInfoTypeOfProductionMac) {
        NSMutableString *macBuffer = [NSMutableString string];
        for (int j = 5; j >= 0 ; j --) {
            [macBuffer appendFormat:@"%02x:",data[j+2]];
        }
        if (macBuffer.length>0) {
            [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
            infoStr = [macBuffer uppercaseString];
        }
    }
    else if (deviceInfoType == TTDeviceInfoTypeOfProductionClock){
        for (int i = 0; i < 6; i++) {
            infoStr = [NSString stringWithFormat:@"%@%02d",infoStr,[TTDataTransformUtil intFromHexBytes:&data[i+2] length:1]];
        }
    }else if (deviceInfoType == TTDeviceInfoTypeOfNbRssi){
        infoStr = [NSString stringWithFormat:@"%d",[TTDataTransformUtil intFromHexBytes:&data[2] length:1]];
    }
    else{
        Byte infobyte[30] = {};
        int i = 0;
        for (; i < 30; i++) {
            if (data[i+2] == '\0') {
                break;
            }
            infobyte[i] = data[i+2];
        }
        infoStr  = [TTDataTransformUtil stringFormBytes:infobyte length:i];
        
    }
    
    return infoStr== nil ? @"" :infoStr;
}



+ (void)setPowerWithCommand:(TTCommand*)command data:(Byte*)data{
    if (command->length>2) {
        Byte byteT[1]={0x00};
        byteT[0] = data[2];
        int dianliang = [TTDataTransformUtil intFromHexBytes:byteT length:1];
        if (dianliang<=127) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", dianliang] forKey:@"dianliang"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"dianliang"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


+ (NSArray*)initErrorMsgArray{
    
    NSArray * errorMsgArray = @[TTErrorMessageHadReseted,TTErrorMessageCRCError,TTErrorMessageNoPermisstion,TTErrorMessageWrongAdminCode,TTErrorMessageLackOfStorageSpace,TTErrorMessageInSettingMode,TTErrorMessageNoAdmin,TTErrorMessageNotInSettingMode,TTErrorMessageWrongDynamicCode,@"",TTErrorMessageIsNoPower,TTErrorMessageResetPasscode,TTErrorMessageUpdatePasscodeIndex,TTErrorMessageInvalidLockFlagPos,TTErrorMessageEkeyExpired,TTErrorMessagePasscodeLengthInvalid,TTErrorMessageSamePasscodes,TTErrorMessageEkeyInactive,TTErrorMessageAesKey,TTErrorMessageFail,TTErrorMessagePasscodeExist,TTErrorMessagePasscodeNotExist,TTErrorMessageLackOfStorageSpaceWhenAddingPasscodes,TTErrorMessageInvalidParaLength,TTErrorMessageCardNotExist,TTErrorMessageFingerprintDuplication,TTErrorMessageFingerprintNotExist,TTErrorMessageInvalidCommand,TTErrorMessageInFreezeMode,TTErrorMessageInvalidClientPara,TTErrorMessageLockIsLocked,TTErrorMessageRecordNotExist];
    return errorMsgArray;
}

+ (TTLockDataModel *)getLockDataModel:(NSString *)lockData{
    
    if (lockData.length == 0) {
        printf("TTLockLog#####error：lockData can not be null #####");
        return nil;
    }
    NSData *decodeData = [TTSecurityUtil decodeBase64WithString:lockData];
    if (decodeData.length <= 6) {
        printf("TTLockLog#####error：lockData is wrong #####");
        return nil;
    }
    Byte *decodebytes = (Byte *)decodeData.bytes;
    NSString *encodeLockMac;
    NSMutableString * macBuffer = [[NSMutableString alloc]init];
    for (NSInteger i = decodeData.length - 6 ;i < decodeData.length; i++) {
        [macBuffer appendFormat:@"%02x:",decodebytes[i]];
    }
    if (macBuffer.length>0) {
        [macBuffer deleteCharactersInRange:NSMakeRange(macBuffer.length-1, 1)];
        [macBuffer deleteCharactersInRange:NSMakeRange(9, 1)];
        encodeLockMac = [macBuffer uppercaseString];
    }
    if (encodeLockMac.length == 0) {
        printf("TTLockLog#####error：lockData is wrong #####");
        return nil;
    }
    NSString *decodeLockData = [TTSecurityUtil decryptAESData:[NSData dataWithBytes:decodebytes length:decodeData.length - 6] key:encodeLockMac];
    NSDictionary *lockDataDic = [NSJSONSerialization JSONObjectWithData:[decodeLockData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return  [[TTLockDataModel alloc]initWithLockData:lockDataDic];

}

@end
