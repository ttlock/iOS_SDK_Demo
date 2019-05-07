//
//  TTCenterManager+SceneV2.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager+SceneV2.h"
#import "TTDebugLog.h"
#import "TTHandleResponse.h"
#import "TTDateHelper.h"
#import "TTMacros.h"
#import "TTCommandUtils.h"
#import "TTCenterManager+Common.h"
#import "TTDataTransformUtil.h"

#define DEFAULT_VAILD_NUMBER   0

@implementation TTCenterManager (SceneV2)

Byte timePsBytes[1614] = {0x00};
Byte bytes4Send[28] = {0x00};

-(void)sceneV2HandleCommand:(TTCommand*)command{
    switch ([command getCommand]) {
        case COMM_FETCH_AES_KEY:{
            //读取aes加密字
            [TTDebugLog log:@"TTLockLog#####0x19 successfully#####"];
            Byte *data =  [command getDataAes_pwdKey:(Byte *)[TTCommand getDefaultAesKey].bytes];
            if (data[1] == 0x01) {
                //成功，包含了aes加密字
                Byte aeskey[16]={0x00, 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
                [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:aeskey dstPos:0 length:16];
                
                self.lockDataModel.aesKeyStr = [NSData dataWithBytes:aeskey length:16];
                 self.lockDataModel.adminPwd = [TTDataTransformUtil generateDynamicPassword:10];
               self.lockDataModel.lockKey = [TTDataTransformUtil generateDynamicPassword:10];
                
                //发送添加管理员指令
                if (command ->protocolVersion == 0x03) {
                    //添加管理员指令
                    [TTCommandUtils v3_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                }else if (command ->protocolVersion == 0x04){
                    [TTCommandUtils v2_aes_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                }
                
            }
            else{
                [self onTTErrorWithData:data version:command->version];
            }
        } break;
        case COMM_RESPONSE:{
            
            //lock在无法解密app传输的数据的时候（app和lock的aes加密字不同），返回的数据为空，也就是解密之前就是空，这是lock那边直接返回的
            Byte* data = [command getDataAes_pwdKey:(Byte*)self.lockDataModel.aesKeyStr.bytes];// lock传递给app的command中存储的data
            
            Byte * aesKeyBytes = (Byte *)self.lockDataModel.aesKeyStr.bytes;
            if (aesKeyBytes == NULL) {
                [self onTTError:TTErrorAesKey command:[TTDataTransformUtil intFromHexBytes:&data[0] length:1]];
                return;
            }
            if (data == NULL) {
                if (self.m_currentOperatorState == Current_Operator_State_Restore_factory_settings) {
                    if ((command->dataLength == 0 )&& [self.delegate respondsToSelector:@selector(onResetLock)]) {
                        [self.delegate onResetLock];
                    }
                    self.isFirstCommand = NO;
                    return;
                }
                
                [self onTTError:TTErrorHadReseted command:0];
                
                self.isFirstCommand = NO;
                return;
            }
            
            //锁可能被他人重置
            if (data[0] != 'E' && data[1] != 1 && data[1] !=0 && self.isFirstCommand == YES&& command->mIsChecksumValid&&self.m_currentOperatorState != Current_Operator_State_Add_Admin) {
                //写个E指令 做参考 与上边的可能重置区分
                [self onTTError:TTErrorHadReseted command:'E'];
                self.isFirstCommand = NO;
                return;
            }
            //CRC校验不通过
            if (command->mIsChecksumValid == NO) {
                [self onTTError:TTErrorCRCError command:[TTDataTransformUtil intFromHexBytes:&data[0] length:1]];
                self.isFirstCommand = NO;
                return;
            }
            self.isFirstCommand = NO;
            
            //发生错误的处理
            if (data[1] != 1){
                
                if (data[0] == 'U' && self.m_currentOperatorState == Current_Operator_State_Calibation_Time ) {
                    
                    [TTCommandUtils v2_aes_calibation_time_with_version:command->version
                                                          referenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                    key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                    
                }
                [self onTTErrorWithData:data version:command->version];
                return;
            }
            
            if (data[1] == 1){
                //获取到电压
                [TTHandleResponse setPowerWithCommand:command data:data];
                
                switch (data[0]) {
                    case 'E':               //COMM_INITIALIZATION
                    {
                        [TTDebugLog log:@"TTLockLog#####Instruction success#####"];
                        switch (self.m_currentOperatorState) {
                            case Current_Operator_State_Init_900_ps:
                            case Current_Operator_State_Add_Onepsw:
                            case  Current_Operator_state_Set_Lock_BongKey:
                            case Current_Operator_State_Set_Keyboard_password:
                            case Current_Operator_State_Set_Admin_delete_ps:
                            case Current_Operator_state_reset_ekey:
                            case Current_Operator_State_Unlock_Admin:
                            case Current_Operator_State_Set_Keyboard_password_user:
                            case Current_Operator_State_del_keyboard_password:
                            case Current_Operator_State_clear_Keyboard_password:
                            case Current_Operator_state_AT_COMMADN:
                            {
                                //A指令 检验是否是管理员
                                
                                [TTCommandUtils v2_aes_check_admin_with_ps: self.lockDataModel.adminPwd flag:self.lockDataModel.lockFlagPos version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                                break;
                            }
                                
                            case Current_Operator_State_Add_Admin:
                            {
                                //添加管理员
                                 self.lockDataModel.adminPwd = [TTDataTransformUtil generateDynamicPassword:10];
                               self.lockDataModel.lockKey = [TTDataTransformUtil generateDynamicPassword:10];
                                [TTCommandUtils v2_aes_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                                break;
                            }
                                
                            case Current_Operator_State_Unlock_EKey:
                            {
                                //ekey开门
                                
                                [TTCommandUtils v2_aes_check_user_with_startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] flag:self.lockDataModel.lockFlagPos version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                                
                                break;
                            }
                            case Current_Operator_State_Calibation_Time:
                           
                            {
                                //U指令
                                [TTCommandUtils v2_aes_check_user_with_startDate:@"00-01-01-00-00" endDate:@"99-12-31-23-59" flag:self.lockDataModel.lockFlagPos version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                                break;
                            }
                                
                            default:
                                break;
                        }
                        
                        break;
                    }
                    case 'V':
                    {
                        [TTDebugLog log:@"TTLockLog#####V2 AES add administrator successfully#####"];
                        
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            [TTCommandUtils v2_aes_set_admin_nokey_ps:self.m_keyboard_password_admin version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        
                        break;
                    }
                        //检验是管理员成功后
                    case 'A':
                    {
                        [TTDebugLog log:@"TTLockLog#####V2 AES Administrator landing success#####"];
                        if (self.m_currentOperatorState ==  Current_Operator_state_reset_ekey){
                            if ([self.delegate respondsToSelector:@selector(onResetEkey)]) {
                                [self.delegate onResetEkey];
                            }
                            
                            break;
                        }else if (self.m_currentOperatorState == Current_Operator_state_AT_COMMADN){
                            
                            [TTCommandUtils setOrQuery_Para:self.ATCommand version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        else{
                            Byte bytes[4];//lock发送过来的开锁密码
                            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                            long long passwordFromLock = [TTDataTransformUtil longFromHexBytes:bytes length:4];
                            NSData *kdata = [self.lockDataModel.lockKey dataUsingEncoding:NSUTF8StringEncoding];
                            long long passwordLocal = [TTDataTransformUtil getLongForBytes:(Byte*)[kdata bytes]];
                            [TTCommandUtils v2_aes_unlock_with_psFromLock:passwordFromLock psLocal:passwordLocal flag:@"1" version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        
                        break;
                        
                    }
                    case COMM_LOCK_TIME_CALIBRATION:
                    {
                        [TTDebugLog log:@"TTLockLog#####V2 AES Calibration time success#####"];
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            
                            
                            self.validPsNumber = DEFAULT_VAILD_NUMBER;
                            
                            [self generatePs300WithCommand:command];
                            
                            [TTCommandUtils v2_aes_init_ps_pool_bytes:bytes4Send length:28 pos:self.timePsBytesSended version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                        }
                        //只有专门的校准时钟的接口才会回调 校准成功
                        if (self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                            if ([self.delegate respondsToSelector:@selector(onSetLockTime)]) {
                                [self.delegate onSetLockTime];
                            }
                        }
                        
                        break;
                    }
                    case 'G':
                    {
                        
                        [TTDebugLog log:@"TTLockLog#####V2 AES unlocking success#####"];
                        
                        switch (self.m_currentOperatorState) {
                                
                            case Current_Operator_State_del_keyboard_password:
                            {
                                
                                //删除键盘密码
                                [TTCommandUtils v3_del_kbpwd:self.m_keyboardPs psType:self.m_psType version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                                break;
                            }
                            case Current_Operator_State_clear_Keyboard_password:
                            {
                                
                                //清空键盘密码
                                [TTCommandUtils v3_clear_kbpwd_WithVersion:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                                
                                break;
                            }
                                
                            case Current_Operator_State_Unlock_Admin:
                            {
                                
                                
                                if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                                    [self.delegate onControlLockWithLockTime:0 electricQuantity:[self getPower] uniqueId:self.uniqueid];
                                }
                                
                                break;
                            }
                            case Current_Operator_state_Set_Lock_BongKey:
                            case Current_Operator_State_Set_Keyboard_password:
                            {
                                //设置管理员密码
                                [TTCommandUtils v2_aes_set_admin_nokey_ps:self.m_keyboard_password_admin version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                                
                                break;
                            }
                            case Current_Operator_State_Set_Admin_delete_ps:
                            {
                                
                                [TTCommandUtils v2_aes_del_kbpwd:self.m_keyboard_delete_admin version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                                break;
                            }
                                
                            case Current_Operator_State_Unlock_EKey:
                            {
                                //电子钥匙开门
                                if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                                    [self.delegate onControlLockWithLockTime:0 electricQuantity:[self getPower] uniqueId:self.uniqueid];
                                }
                                
                                break;
                            }
                            case Current_Operator_State_Init_900_ps:
                            {
                                
                                [self generatePs300WithCommand:command];
                                [TTCommandUtils v2_aes_init_ps_pool_bytes:bytes4Send length:28 pos:self.timePsBytesSended version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                                break;
                            }
                                
                            default:
                                break;
                        }
                        break;
                    }
                    case 'D':
                    {
                        [TTDebugLog log:@"TTLockLog#####V2AES Setting the password to delete the current valid password is successful#####"];
                        
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            
                            [TTCommandUtils v2_aes_calibation_time_with_version:command->version referenceTime:[TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm" timezoneRawOffset:-1] key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                            
                        }else{
                            if ([self.delegate respondsToSelector:@selector(onSetAdminErasePasscode)]) {
                                [self.delegate onSetAdminErasePasscode];
                            }
                            
                        }
                        
                        break;
                        
                    }
                    case 'S':
                    {
                        [TTDebugLog log:@"TTLockLog#####V2 AES Setting admin passcode success#####"];
                        
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin){
                            [TTCommandUtils v2_aes_del_kbpwd:self.m_keyboard_delete_admin version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }else{
                            if ([self.delegate respondsToSelector:@selector(onModifyAdminPasscode)]) {
                                [self.delegate onModifyAdminPasscode];
                            }
                        }
                        
                        break;
                        
                    }
                    case 'U':
                    {
                        
                        [TTDebugLog log:@"TTLockLog#####V2 AES Common user landing success#####"];
                        Byte bytes[4];//lock发送过来的开锁密码
                        [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                        long long passwordFromLock = [TTDataTransformUtil longFromHexBytes:bytes length:4];
                        if (self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                            [TTCommandUtils v2_aes_calibation_time_with_version:command->version referenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        else {
                            [TTCommandUtils v2_aes_unlock_with_psFromLock:passwordFromLock psLocal:self.lockDataModel.lockKey.longLongValue flag:@"0" version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        break;
                    }
                    case 'I':
                    {
                        
                        
                        if (self.timePsBytesSended < 1614) {
                            if (self.timePsBytesSended < 588) {
                                if (!self.kpstimeArr || self.kpstimeArr.count < 1000) {
                                    [NSThread sleepForTimeInterval:0.8];
                                }
                                
                                int count = 0;
                                for (NSString * ps  in self.timepsArr) {
                                    NSData * data = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%04x",ps.intValue]];
                                    
                                    Byte * dataByte = (Byte *)data.bytes;
                                    
                                    //高地位反的
                                    timePsBytes[count+1] = dataByte[0];
                                    timePsBytes[count] = dataByte[1];
                                    count += 2;
                                    
                                }
                            }
                            else if (self.timePsBytesSended >=588 && self.timePsBytesSended < 1596)
                            {
                                while (!(self.kpstimeArr && (self.kpstimeArr.count >=1000))) {
                                    [NSThread sleepForTimeInterval:0.8];
                                }
                                int count = 600;
                                for (NSString * type  in self.kpstimeArr) {
                                    NSData *data = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",type.intValue]];
                                    Byte * dataByte = (Byte *)data.bytes;
                                    timePsBytes[count] = dataByte[0];
                                    count += 1;
                                    
                                }
                                
                            }
                            else {
                                
                                while (!(self.kpschecknumbersArr && self.kpschecknumbersArr.count>=10)) {
                                    
                                }
                                int count = 1600;
                                {
                                    NSArray *arr = [self.posString componentsSeparatedByString:@"["];
                                    NSArray *posArray =  [arr[1] componentsSeparatedByString:@","];
                                    timePsBytes[count] = [posArray[0] intValue];
                                    
                                    timePsBytes[count+1] = [posArray[1] intValue];
                                    timePsBytes[count+2] = [posArray[2] intValue];
                                    count += 3;
                                }
                                
                                {
                                    for (NSString * result in self.kpschecknumbersArr) {
                                        NSData * data = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",result.intValue]];
                                        Byte * dataByte = (Byte *)data.bytes;
                                        //高地位没变
                                        timePsBytes[count] = dataByte[0];
                                        count += 1;
                                        
                                    }
                                }
                                //5. 有效密码数量（1个字节，0为设备默认）
                                {
                                    NSData * data = [TTDataTransformUtil DataFromHexStr:[NSString stringWithFormat:@"%02x",self.validPsNumber]];
                                    Byte * dataByte = (Byte *)data.bytes;
                                    //高地位没变
                                    timePsBytes[count] = dataByte[0];
                                }
                                
                            }
                            if ((1614-self.timePsBytesSended)>28) {//一共1614个字节的密码数据
                                [TTDataTransformUtil arrayCopyWithSrc:timePsBytes srcPos:self.timePsBytesSended dst:bytes4Send dstPos:0 length:28];
                            }else{
                                [TTDataTransformUtil arrayCopyWithSrc:timePsBytes srcPos:self.timePsBytesSended dst:bytes4Send dstPos:0 length:1614-self.timePsBytesSended];
                            }
                            
                            [TTCommandUtils v2_aes_init_ps_pool_bytes:bytes4Send length:28 pos:self.timePsBytesSended version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
                            self.timePsBytesSended += 28;
                        }
                        else {
                            
                            //数据传输完毕
                            
                            NSString *string = [NSString stringWithFormat:@"{\"position\":\"%@\",\"currentIndex\":\"%d\",\"timeControlTb\":\"%@\",\"fourKeyboardPwdList\":\"%@\",\"checkDigit\":\"%@\"}",self.posString,-1,self.timeControlString,self.psListString,self.checkString];
                            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                            NSTimeInterval timeInterval=[dat timeIntervalSince1970]*1000;
                            NSString *timeString = [NSString stringWithFormat:@"%.0f000", timeInterval];
                            
                            NSData *strData = [string dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *keyData = [timeString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            NSData * dataEncrypted = [TTSecurityUtil encryptAESData:strData keyBytes:(Byte *)keyData.bytes];
                            
                            NSString *str  = [TTSecurityUtil encodeBase64Data:dataEncrypted];
                            
                            if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                                
                                [self onAddAdminWithCommand:command timestamp:timeString.longLongValue pwdInfo:str Characteristic:-1 deviceInfoDic:nil];
                            }else{
                                if ([self.delegate respondsToSelector:@selector(onResetPasscodeWithTimestamp:pwdInfo:)]) {
                                    [self.delegate onResetPasscodeWithTimestamp:timeString.longLongValue pwdInfo:str];
                                }
                            }
                            
                            return;
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
        }
            
    }
    
}

- (void)generatePs300WithCommand:(TTCommand*)command{
    
    self.timePsBytesSended = 0;
    //初始化300个密码
    //时间对照
    NSMutableArray * Ps300Array = [NSMutableArray array];
    int count = 0;
    do {
        int random = [TTDataTransformUtil RandomNumber0To9_length:4];
        
        if ([Ps300Array containsObject:[NSString stringWithFormat:@"%04i",random]]) {
            
            continue;
            
        }
        [Ps300Array addObject:[NSString stringWithFormat:@"%04i",random]];
        count++;
    } while (count < 300);
    self.timepsArr = [NSMutableArray array];
    for (int i = 0 ; i < Ps300Array.count; i ++) {
        
        [self.timepsArr addObject:[Ps300Array objectAtIndex:i]];
    }
    //300个密码
    self.psListString = [NSMutableString stringWithString:@"["];
    for (NSString  * ps in Ps300Array) {
        [self.psListString appendString:[NSString stringWithFormat:@"%@,",ps]];
    }
    if (self.psListString.length>0) {
        [self.psListString deleteCharactersInRange:NSMakeRange(self.psListString.length-1, 1)];
        [self.psListString appendString:@"]"];
    }
    
    //初始化键盘密码的实效对照表
    //先初始化时间段类型表数组
    self.kpstimeArr = [NSMutableArray array];
    
    NSMutableArray *typeArr = [NSMutableArray array];
    
    if (command->applyCatagory == 1) {
        for (int i = 0; i < 218; i++) {
            if (i < 10) {
                [typeArr addObject:[NSNumber numberWithInt:0]];
            }
            else {
                [typeArr addObject:[NSNumber numberWithInt:i - 9]];
            }
        }
    }else if (command->applyCatagory == 2) {
        for (int i = 0; i < 163; i++) {
            if (i < 10) {
                
                [typeArr addObject:[NSNumber numberWithInt:0]];
                
            }else if (i < 138) {
                
                [typeArr addObject:[NSNumber numberWithInt:i - 9]];
                
            }else if (i < 162) {
                
                [typeArr addObject:[NSNumber numberWithInt:i + 71]];
                
            }else if (i == 162) {
                
                [typeArr addObject:[NSNumber numberWithInt:254]];
                
            }
        }
    }
    for (int i = 0; i < 218; i++) {
        if (i < 10) {
            [typeArr addObject:[NSNumber numberWithInt:0]];
        }
        else {
            [typeArr addObject:[NSNumber numberWithInt:i - 9]];
        }
    }
    
    
    //初始化 1000个数字的数组
    NSMutableArray *digitArr = [NSMutableArray array];
    for (int i = 0; i < 1000; i++) {
        [digitArr addObject:[NSNumber numberWithInt:i]];
    }
    //初始化时间有效性数字对照表
    NSMutableArray *FFArr = [NSMutableArray array];
    for (int i = 0; i < 1000; i++) {
        [FFArr addObject:[NSNumber numberWithInt:0xFF]];
    }
    
    if (command->applyCatagory == 1) {
        for (int i = 0; i < 218; i++) {
            int index = arc4random() % [digitArr count];
            [FFArr replaceObjectAtIndex:[[digitArr objectAtIndex:index] intValue] withObject:[typeArr objectAtIndex:i]];
            [digitArr removeObjectAtIndex:index];
            
        }
    }else if (command->applyCatagory == 2) {
        for (int i = 0; i < 163; i++) {
            int index = arc4random() % [digitArr count];
            [FFArr replaceObjectAtIndex:[[digitArr objectAtIndex:index] intValue] withObject:[typeArr objectAtIndex:i]];
            [digitArr removeObjectAtIndex:index];
            
        }
    }
    
    self.kpstimeArr = FFArr;
    
    //时间对照表
    NSMutableDictionary * timeControlDict = [[NSMutableDictionary alloc]init];
    NSMutableString * timeControl0String = [NSMutableString stringWithString:@"["];
    NSMutableArray *timecontrolArr = [NSMutableArray array];
    
    for (int i = 0; i < 1000; i++) {
        //类型为0的时间  共10个 如：[11,12,13,14,15,16,17,18,19,20]
        if ([[FFArr objectAtIndex:i] intValue] == 0) {
            if (i < 10) {
                [timecontrolArr addObject:[NSString stringWithFormat:@"00%d", i]];
            }else if (i < 100){
                [timecontrolArr addObject:[NSString stringWithFormat:@"0%d", i]];
            }else{
                [timecontrolArr addObject:[NSString stringWithFormat:@"%d", i]];
            }
            
            
        }else if ([[FFArr objectAtIndex:i] intValue] == 0xFF){
            
        }else{
            if (i < 10) {
                [timeControlDict setValue:[NSString stringWithFormat:@"00%d", i] forKey:[NSString stringWithFormat:@"%i",[[FFArr objectAtIndex:i] intValue]]];
                
            }else if (i < 100){
                [timeControlDict setValue:[NSString stringWithFormat:@"0%d", i] forKey:[NSString stringWithFormat:@"%i",[[FFArr objectAtIndex:i] intValue]]];
            }else{
                [timeControlDict setValue:[NSString stringWithFormat:@"%d", i] forKey:[NSString stringWithFormat:@"%i",[[FFArr objectAtIndex:i] intValue]]];
            }
        }
    }
    
    if (timeControl0String.length>0) {
        
        [timeControl0String deleteCharactersInRange:NSMakeRange(timeControl0String.length-1, 1)];
        [timeControl0String appendString:@"]"];
    }
    [timeControlDict setValue:timecontrolArr forKey:@"0"];
    
    NSError * error0 = nil;
    NSData * result = [NSJSONSerialization dataWithJSONObject:timeControlDict
                                                      options:kNilOptions
                                                        error:&error0];
    NSString * timeControlStringtmp = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
    NSMutableString *str1 = [NSMutableString stringWithString:timeControlStringtmp];
    for (int i = 0; i < str1.length; i++) {
        unichar c = [str1 characterAtIndex:i];
        NSRange range = NSMakeRange(i, 1);
        if ( c == '"') {
            //此处可以是任何字符
            [str1 deleteCharactersInRange:range];
            --i;
        }
    }
    self.timeControlString = [NSString stringWithString:str1];
    
    
    
    //初始化键盘密码的时间位置表, 1,2,3,4,5,6,7这些位置随机生成
    int pos1 = arc4random()%4+1;//1~5
    int pos2;
    int pos3;
    
    do {
        
        pos2 = arc4random()%(6-pos1)+pos1;//pos1~6
        
    } while (pos1>=pos2);
    
    do {
        
        pos3 = arc4random()%(7-pos2)+pos2;//pos2~7
        
    } while (pos2>=pos3 || pos1>=pos3);
    
    
    //时间位置
    self.posString = [NSString stringWithFormat:@"[%i,%i,%i]",pos1,pos2,pos3];
    
    //初始化键盘密码的校验表
    
    self.kpschecknumbersArr = [NSMutableArray array];
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    //校验码
    self.checkString = [NSMutableString stringWithString:@""];
    for (int i = 0 ; i < 10; i ++) {
        int index = arc4random()% [arr count]; //0~9
        int value = [[arr objectAtIndex:index] intValue];
        [self.checkString appendString:[NSString stringWithFormat:@"%i",value]];
        [self.kpschecknumbersArr addObject:[NSString stringWithFormat:@"%i",value]];
        [arr removeObjectAtIndex:index];
        
    }
    
}


@end
