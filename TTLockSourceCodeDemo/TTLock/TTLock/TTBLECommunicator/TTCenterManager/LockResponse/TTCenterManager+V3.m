//
//  TTCenterManager+V3.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager+V3.h"
#import "TTDebugLog.h"
#import "TTHandleResponse.h"
#import "TTDateHelper.h"
#import "TTMacros.h"
#import "TTCommandUtils.h"
#import "TTCenterManager+Common.h"
#import "TTDataTransformUtil.h"
#import "TTUtil.h"

@implementation TTCenterManager (V3)

-(void)lockV3HandleCommand:(TTCommand*)command{
    
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
                
                [TTCommandUtils v3_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes ];
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
            if (data[0] != 'E'
                && data[1] != 1
                && data[1] !=0
                && self.isFirstCommand == YES
                && command->mIsChecksumValid
                && self.m_currentOperatorState != Current_Operator_State_Add_Admin) {
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
                NSUInteger commomerror = [TTDataTransformUtil intFromHexBytes:&data[2] length:1];
                if (self.m_currentOperatorState == Current_Operator_State_Delete_PassageMode
                    && commomerror == TTErrorRecordNotExist) {
                    
                    [self.m_weekArr removeObjectAtIndex:0];
                    if (self.m_weekArr.count > 0) {
                        [TTCommandUtils threeRequestPara_WithVersion:command->version requestPara:self.m_passageModeType tworequestPara: [self.m_weekArr[0] intValue] threerequestPara:self.m_monthStr Paralength:1 twoParalength:1 threeParalength:1 commandValue:LOCK_V3_COMM_PASSAGEMODE key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                        return;
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(onDeletePassageMode)]) {
                        [self.delegate onDeletePassageMode];
                    }
                    return;
                }
                //挂锁没有时钟
                if (data[0] == 'C') {
                    
                    if (commomerror == TTErrorInvalidCommand) {
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            if (self.hotelICKEY.length > 0) {
                                [TTCommandUtils setHotelICKey:self.hotelICKEY version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                                return;
                            }
                            [TTCommandUtils v3_lock_v1_notify_addAdmin_success_version:command->version key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                            return;
                            
                        }else if(self.m_currentOperatorState == Current_Operator_State_Calibation_Time){
                            if ([self.delegate respondsToSelector:@selector(onSetLockTime)]) {
                                [self.delegate onSetLockTime];
                            }
                            return;
                        }
                        
                    }
                }
                if (data[0] == 'U' && self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                    [TTCommandUtils v3_calibation_time_with_version:command->version
                                                      referenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm-ss" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
                    
                }
                [self onTTErrorWithData:data version:command->version];
                return;
            }
            
            
            //获取到电压
            [TTHandleResponse setPowerWithCommand:command data:data];
            
            switch (data[0]) {
                    
                case COMM_INITIALIZATION:
                {
                    [TTDebugLog log:@"TTLockLog#####E instruction success#####" ];
                    
                    //初始化指令成功，可获取锁信息
                    switch (self.m_currentOperatorState) {
                        case Current_Operator_State_Get_Total_Unlock_record:
                        case Current_Operator_State_Unlock_record:{
                            self.lockOpenRecordArr = [NSMutableArray array];
                            //执行0x25  第一次请求序号 0xFFFF 是从上一次读的地方开始读
                            //                        0    是从头开始读
                            self.m_operatelog_Count = 0;
                            self.m_operatelog_nextNum = 0;
                            [TTCommandUtils lock_fetch_record_num:(self.m_currentOperatorState == Current_Operator_State_Unlock_record ? 0xFFFF :0)
                                                             type:1
                                                          version:command->version
                                                              key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            break;
                        }
                        case Current_Operator_State_get_keyboard_password_list:
                        case Current_Operator_State_Recover_Keyboard_Password:
                        case  Current_Operator_State_Recover_IC:
                        case  Current_Operator_State_Recover_Fingerprint:
                        case  Current_Operator_State_Recover_Fingerprint_Data:
                        case Current_Operator_state_Fetch_IC_Data:
                        case Current_Operator_state_Modify_IC:
                        case Current_Operator_state_delete_IC:
                        case Current_Operator_state_clear_IC:
                        case Current_Operator_state_add_IC:
                        case  Current_Operator_State_Add_Onepsw:
                        case Current_Operator_State_Set_Keyboard_password_user:
                        case Current_Operator_state_Set_Lock_BongKey:
                        case Current_Operator_State_del_keyboard_password:
                        case Current_Operator_State_clear_Keyboard_password:
                        case Current_Operator_State_Set_Keyboard_password:
                        case Current_Operator_state_reset_ekey:
                        case Current_Operator_State_Unlock_Admin:
                        case Current_Operator_State_Init_900_ps:
                        case Current_Operator_State_Restore_factory_settings:
                        case Current_Operator_state_Modify_Keyboard_Password:
                        case Current_Operator_state_set_lock_name:
                        case Current_Operator_state_add_Fingerprint:
                        case Current_Operator_state_delete_Fingerprint:
                        case Current_Operator_state_clear_Fingerprint:
                        case Current_Operator_state_Modify_Fingerprint:
                        case Current_Operator_state_Fetch_lockingTime_Data:
                        case Current_Operator_state_Modify_lockingTime:
                        case Current_Operator_state_Fetch_DoorSensor_locking:
                        case Current_Operator_state_Modify_DoorSensor_locking:
                        case Current_Operator_state_Fetch_Fingerprint_Data:
                        case Current_Operator_state_Upgrade_Firmware:
                        case Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL:
                        case Current_Operator_state_AT_COMMADN:
                        case Current_Operator_state_Fetch_Remote_Unlock:
                        case Current_Operator_state_Modify_Remote_Unlock:
                        case Current_Operator_state_Query_Audio_Switch:
                        case Current_Operator_state_Modify_Audio_Switch:
                        case Current_Operator_state_Set_NB_Server:
                        case Current_Operator_state_get_admin_passcode:
                        case Current_Operator_State_Query_PassageMode:
                        case Current_Operator_State_AddOrModify_PassageMode:
                        case Current_Operator_State_Delete_PassageMode:
                        case Current_Operator_State_Clean_PassageMode:
                        {
                            //校验管理员身份
                            [TTCommandUtils v3_check_admin_with_ps: self.lockDataModel.adminPwd
                                                              flag:self.lockDataModel.lockFlagPos
                                                            userID:self.lockDataModel.uid
                                                           version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                            
                        }
                        case Current_Operator_state_Get_lock_time:
                        {
                            //获取锁时间
                            [TTCommandUtils v3_get_lockTimeWithversion:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                        }
                        case Current_Operator_State_Close_lock_Admin_And_EKey:
                        case Current_Operator_State_Unlock_EKey:
                        case Current_Operator_state_Query_Remote_Control:
                        case Current_Operator_state_Modify_Remote_Control:
                        {
                            //ekey开门
                            [TTCommandUtils v3_check_user_with_startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] flag:self.lockDataModel.lockFlagPos userID:self.lockDataModel.uid version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            break;
                            
                        }
                            
                        case Current_Operator_State_Get_Password_Data:
                        case Current_Operator_State_Calibation_Time:
                        {
                            
                            [TTCommandUtils v3_check_user_with_startDate:@"00-01-01-00-00" endDate:@"99-12-31-23-59" flag:self.lockDataModel.lockFlagPos userID:self.lockDataModel.uid version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                            
                        }
                        case Current_Operator_state_Get_Electric_Quantity:
                        case Current_Operator_state_get_device_characteristic:{
                            [TTCommandUtils v3_get_device_characteristic_WithVersion:command->version];
                            break;
                        }
                        case Current_Operator_state_get_deviceInfo:{
                            [TTCommandUtils v3_get_device_characteristic_WithVersion:command->version];
                            
                        }break;
                        default:
                            break;
                    }
                    break;
                    
                }
                case Lock_V3_COMM_SWITCH_STATE:{
                    if (self.m_currentOperatorState == Current_Operator_State_Get_Door_Sensor_State) {
                        if (command->length  > 4) {
                            if ([self.delegate respondsToSelector:@selector(onGetDoorSensorState:)]) {
                                [self.delegate onGetDoorSensorState:[TTDataTransformUtil intFromHexBytes:&data[4] length:1]];
                            }
                        }else{
                            [self onTTError:TTErrorFail command:0];
                        }
                    }
                    else {
                        if ([self.delegate respondsToSelector:@selector(onGetLockStatus:)]) {
                            [self.delegate onGetLockStatus:[TTDataTransformUtil intFromHexBytes:&data[3] length:1] ];
                        }
                    }
                }break;
                case Lock_V3_COMM_LOCK:{
                    long long dateTime = [TTHandleResponse convertTime :data index:11 length:6  timezoneRawOffset:self.lockDataModel.timezoneRawOffset]*1000;
                    if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                        [self.delegate onControlLockWithLockTime:dateTime electricQuantity:[self getPower] uniqueId:self.uniqueid];
                    }
                    
                }break;
                case COMM_GET_DeviceInfo:{
                    
                    
                    NSString *infoStr = [TTHandleResponse getDeviceInfoData:data deviceInfoType:self.deviceInfoType];
                    [self.deviceInfoDic setObject:infoStr forKey:[NSString stringWithFormat:@"%ld",(long)self.deviceInfoType]];
                    
                    BOOL isSupportNB = [TTUtil lockSpecialValue:self.lockDataModel.specialValue suportFunction:TTLockSpecialFunctionNB];
                    
                    
                    if ((isSupportNB == NO && self.deviceInfoType == TTDeviceInfoTypeOfProductionClock) || (isSupportNB == YES && self.deviceInfoType == TTDeviceInfoTypeOfNbRssi)) {
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            
                            [TTCommandUtils v3_calibation_time_with_version:command->version referenceTime:[TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm-ss" timezoneRawOffset:-1] key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            return;
                        }
                        if ([self.delegate respondsToSelector:@selector(onGetLockSystemInfo:)]) {
                            TTSystemInfoModel *systemInfo = [TTSystemInfoModel new];
                            if (self.deviceInfoDic != nil) {
                                systemInfo.modelNum = self.deviceInfoDic[@"1"];
                                systemInfo.hardwareRevision = self.deviceInfoDic[@"2"];
                                systemInfo.firmwareRevision = self.deviceInfoDic[@"3"];
                                systemInfo.nbOperator = self.deviceInfoDic[@"7"];
                                systemInfo.nbNodeId = self.deviceInfoDic[@"8"];
                                systemInfo.nbCardNumber = self.deviceInfoDic[@"9"];
                                systemInfo.nbRssi = self.deviceInfoDic[@"10"];
                               
                            }
                            [self.delegate onGetLockSystemInfo:systemInfo];
                        }
                        
                        return;
                    }
                    self.deviceInfoType = self.deviceInfoType + 1 ;
                    [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:self.deviceInfoType Paralength:1 commandValue:COMM_GET_DeviceInfo key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                    
                    
                }break;
                case COMM_NBServer_Config:{
                    if ([self.delegate respondsToSelector:@selector(onSetNbServerInfo)]) {
                        [self.delegate onSetNbServerInfo];
                    }
                }break;
                case 'R':{
                    [TTDebugLog log:@"TTLockLog#####v3 Reset Lock successfully#####" ];
                    if ([self.delegate respondsToSelector:@selector(onResetLock)]) {
                        [self.delegate onResetLock];
                    }
                    
                    break;
                }
                case 'V':
                {
                    
                    [TTDebugLog log:@"TTLockLog#####v3 Add administrator success#####" ];
                    //生成年份、约定数和映射数
                    [self generateV3PwdListWithCommand:command];
                    
                    break;
                }
                case COMM_ADD_USER:
                {
                    
                    //管理员身份校验成功
                    
                    [TTDebugLog log:@"TTLockLog#####v3 Administrator landing success#####" ];
                    
                    switch (self.m_currentOperatorState) {
                        case Current_Operator_state_reset_ekey:{
                            
                            if ([self.delegate respondsToSelector:@selector(onResetEkey)]) {
                                [self.delegate onResetEkey];
                            }
                            break;
                            
                        }
                        case Current_Operator_State_Unlock_Admin:
                        {
                            Byte bytes[4];//lock发送过来的开锁密码
                            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                            
                            long long passwordFromLock = [TTDataTransformUtil longFromHexBytes:bytes length:4];
                            
                            NSData *kdata = [self.lockDataModel.lockKey dataUsingEncoding:NSUTF8StringEncoding];
                            long long passwordLocal = [TTDataTransformUtil getLongForBytes:(Byte*)[kdata bytes]];
                            
                            [TTCommandUtils v3_unlock_with_psFromLock:passwordFromLock psLocal:passwordLocal uniqueid:self.uniqueid  version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                        }
                        case Current_Operator_State_get_keyboard_password_list:
                        case Current_Operator_State_Recover_Keyboard_Password:
                        case  Current_Operator_State_Recover_IC:
                        case  Current_Operator_State_Recover_Fingerprint:
                        case  Current_Operator_State_Recover_Fingerprint_Data:
                        case Current_Operator_state_Fetch_IC_Data:
                        case Current_Operator_state_Modify_IC:
                        case Current_Operator_state_delete_IC:
                        case  Current_Operator_state_clear_IC:
                        case Current_Operator_state_Modify_Keyboard_Password:
                        case Current_Operator_state_add_IC:
                        case Current_Operator_State_Init_900_ps:
                        case Current_Operator_State_Restore_factory_settings:
                        case Current_Operator_state_set_lock_name:
                        case Current_Operator_State_Add_Admin:
                        case Current_Operator_State_Add_Onepsw:
                        case Current_Operator_State_Set_Keyboard_password_user:
                        case Current_Operator_State_del_keyboard_password:
                        case Current_Operator_state_Set_Lock_BongKey:
                        case Current_Operator_State_Set_Keyboard_password:
                        case Current_Operator_state_add_Fingerprint:
                        case Current_Operator_state_delete_Fingerprint:
                        case Current_Operator_state_clear_Fingerprint:
                        case Current_Operator_state_Modify_Fingerprint:
                        case Current_Operator_state_Fetch_Fingerprint_Data:
                        case Current_Operator_state_Fetch_lockingTime_Data:
                        case Current_Operator_state_Modify_lockingTime:
                        case Current_Operator_state_Fetch_DoorSensor_locking:
                        case Current_Operator_state_Modify_DoorSensor_locking:
                        case Current_Operator_state_Upgrade_Firmware:
                        case Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL:
                        case Current_Operator_state_AT_COMMADN:
                        case Current_Operator_state_Fetch_Remote_Unlock:
                        case Current_Operator_state_Modify_Remote_Unlock:
                        case Current_Operator_state_Query_Audio_Switch:
                        case Current_Operator_state_Modify_Audio_Switch:
                        case Current_Operator_state_Set_NB_Server:
                        case Current_Operator_state_get_admin_passcode:
                        case Current_Operator_State_Query_PassageMode:
                        case Current_Operator_State_AddOrModify_PassageMode:
                        case Current_Operator_State_Delete_PassageMode:
                        case Current_Operator_State_Clean_PassageMode:
                        {
                            Byte bytes[4];//lock发送过来的开锁密码
                            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                            
                            long long  passwordFromLock = [TTDataTransformUtil longFromHexBytes:bytes length:4];
                            
                            NSData *kdata = [self.lockDataModel.lockKey dataUsingEncoding:NSUTF8StringEncoding];
                            long long passwordLocal = [TTDataTransformUtil getLongForBytes:(Byte*)[kdata bytes]];
                            
                            [TTCommandUtils v3_check_random_with_psFromLock:passwordFromLock psLocal:passwordLocal version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                        }
                        default:
                            break;
                    }
                }break;
                case COMM_LOCK_TIME_CALIBRATION:
                {
                    [TTDebugLog log:@"TTLockLog#####v3 Calibration time success#####" ];
                    if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                        if (self.hotelICKEY.length > 0) {
                            [TTCommandUtils setHotelICKey:self.hotelICKEY version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            return;
                        }
                        [TTCommandUtils v3_lock_v1_notify_addAdmin_success_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        
                    }
                    //只有校准时间接口 才能回调校准时间成功接口
                    if (self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                        
                        if ([self.delegate respondsToSelector:@selector(onSetLockTime)]) {
                            [self.delegate onSetLockTime];
                        }
                    }
                    
                    break;
                }
                case LOCK_V3_COMM_HOTEL_CARD:{
                    if (data[3] == 1) {
                        
                        switch (data[4]) {
                            case 1:{
                                [TTCommandUtils queryHotelICKeyWithType:2 version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            }break;
                            case 2:{
                                [TTCommandUtils queryHotelICKeyWithType:3 version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            }break;
                            case 3:{
                                Byte hotelNumber[3] = {data[6],data[7],data[8]};
                                int hotelNum = [TTDataTransformUtil intFromHexBytes:hotelNumber length:2];
                                int buildingNum = [TTDataTransformUtil intFromHexBytes:&data[9] length:1];
                                int floorNum = [TTDataTransformUtil intFromHexBytes:&data[10] length:1];
                                [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog##### %hhu %hhu ,buildingNum %d buildingNum %d floorNum %d#####",data[3],data[4],hotelNum,buildingNum,floorNum] ];
                                
                            }break;
                            default:
                                break;
                        }
                    }
                    if (data[3] == 2) {
                        switch (data[4]) {
                            case 1:{
                                [TTCommandUtils setHotelAESKey:self.hotelAESKEY version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            }break;
                            case 2:{
                                [TTCommandUtils setHotelNumber:self.hotelNumber buildingNumber:self.hotelBuildingNumber floorNumber:self.hotelFloorNumber version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            }break;
                            case 3:{
                                [TTCommandUtils v3_lock_v1_notify_addAdmin_success_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            }break;
                            default:
                                break;
                        }
                    }
                    
                }break;
                case COMM_USER_PS_SET_DEL:
                {
                    [TTDebugLog log:@"TTLockLog#####v3 operate KeyBoard Password successful#####" ];
                    switch (data[3]) {
                        case 0x01:{
                            //清空
                            
                            //                                    [self.delegate onDeleteAllKeyboardPassword];
                            break;
                        }
                        case 0x02:{
                            //增
                            
                            if ([self.delegate respondsToSelector:@selector(onCreateCustomPasscode)]) {
                                [self.delegate onCreateCustomPasscode];
                            }
                            
                            break;
                        }
                        case 0x03:{
                            //删
                            
                            if ([self.delegate respondsToSelector:@selector(onDeletePasscodeSuccess)]) {
                                [self.delegate onDeletePasscodeSuccess];
                            }
                            break;
                        }
                        case 0x05:{
                            
                            if ([self.delegate respondsToSelector:@selector(onModifyPasscode)]) {
                                [self.delegate onModifyPasscode];
                            }
                            
                        }break;
                        case 0x06:{
                            
                            if ([self.delegate respondsToSelector:@selector(onRecoverPasscode)]) {
                                [self.delegate onRecoverPasscode];
                            }
                            
                        }break;
                        default:
                            break;
                    }
                    
                    break;
                }
                case COMM_LOCK_UNLOCK:
                {
                    //开锁指令
                    
                    [TTDebugLog log:@"TTLockLog#####v3 unlock successfully#####" ];
                    
                    switch (self.m_currentOperatorState) {
                            
                        case Current_Operator_State_Unlock_Admin:
                        case Current_Operator_State_Unlock_EKey:
                        {
                            //获取锁时间
                            long long dateTime = [TTHandleResponse convertTime:data index:11 length:6  timezoneRawOffset:self.lockDataModel.timezoneRawOffset] * 1000;
                            if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                                
                                [self.delegate onControlLockWithLockTime:dateTime electricQuantity:[self getPower] uniqueId:self.uniqueid];
                            }
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                }
                case COMM_LOCK_SET_ADMIN_PS:
                {
                    [TTDebugLog log:@"TTLockLog#####v3 Set Admin Keyboard Password successfully#####" ];
                    if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                        //获取设备信息
                        [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:self.deviceInfoType Paralength:1 commandValue:COMM_GET_DeviceInfo key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                    }else if (self.m_currentOperatorState == Current_Operator_state_Set_Lock_BongKey){
                        
                        [TTCommandUtils v3_set_Bong_Key:self.bongKey version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                    }
                    else{
                        
                        if ([self.delegate respondsToSelector:@selector(onModifyAdminPasscode)]) {
                            [self.delegate onModifyAdminPasscode];
                        }
                        
                    }
                    
                    break;
                    
                }
                case Lock_V3_COMM_SET_Bongkey:{
                    [TTDebugLog log:@"TTLockLog#####Set Lock Wristband Key successfully#####" ];
                    if ([self.delegate respondsToSelector:@selector(onSetLockWristbandKey)]) {
                        [self.delegate onSetLockWristbandKey];
                    }
                }break;
                case COMM_LOCK_CHECK_USER_TIME:
                {
                    
                    [TTDebugLog log:@"TTLockLog#####v3 check user successfully#####" ];
                    //获取lock发送过来的开锁密码
                    Byte bytes[4];  // lock发送过来的开锁密码
                    [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                    long long passwordFromLock = [TTDataTransformUtil longFromHexBytes :bytes length:4];
                    self.passwordFromLock = passwordFromLock;
                    NSData *kdata = [self.lockDataModel.lockKey dataUsingEncoding:NSUTF8StringEncoding];
                    long long passwordLocal = [TTDataTransformUtil getLongForBytes:(Byte*)[kdata bytes]];
                    self.passwordLocal = passwordLocal;
                    switch (self.m_currentOperatorState) {
                            
                        case Current_Operator_State_Get_Password_Data:{
                            [TTCommandUtils v3_check_random_with_psFromLock:passwordFromLock psLocal:passwordLocal version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        } break;
                            
                        case Current_Operator_State_Calibation_Time:
                        {
                            [TTCommandUtils v3_check_random_with_psFromLock:passwordFromLock psLocal:passwordLocal version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        } break;
                        case Current_Operator_State_Close_lock_Admin_And_EKey:{
                            [TTCommandUtils v3_lock_with_psFromLock:passwordFromLock psLocal:passwordLocal uniqueid:self.uniqueid version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        } break;
                        case Current_Operator_state_Query_Remote_Control:{
                            [TTCommandUtils oneRequestPara_WithVersion:command->version
                                                           requestPara:1
                                                            Paralength:1
                                                          commandValue:LOCK_V3_COMM_Remote_Control key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Modify_Remote_Control:{
                            [TTCommandUtils click_Remote_Control_with_psFromLock:passwordFromLock
                                                                         psLocal:passwordLocal
                                                                        uniqueid:self.uniqueid
                                                                     buttonValue:self.lockingTime version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                        default:{
                            //发送开门指令
                            [TTCommandUtils v3_unlock_with_psFromLock:passwordFromLock psLocal:passwordLocal uniqueid:self.uniqueid version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        }
                            break;
                    }
                    break;
                }
                case 0x34:{
                    [TTDebugLog log:@"TTLockLog#####v3 Get Lock Time successfully#####" ];
                    long long dateTime = [TTHandleResponse convertTime:data index:2 length:6  timezoneRawOffset:self.lockDataModel.timezoneRawOffset]*1000;
                    
                    if ( [self.delegate respondsToSelector:@selector(onGetLockTime:)]) {
                        [self.delegate onGetLockTime:dateTime];
                        
                    }
                    break;
                }
                case 0x25:{
                    [TTDebugLog log:@"TTLockLog#####v3 Get operate log successfully#####" ];
                    //记录总长度 为第3和第4个字节
                    Byte totalLength[2] = {data[2],data[3]};
                    int totalLengthNum = [TTDataTransformUtil intFromHexBytes:totalLength length:2];
                    
                    //请求序号为应答参数的第5和第6个字节
                    Byte datasAgain[2] = {data[4],data[5]};
                    int nextNum = [TTDataTransformUtil intFromHexBytes:datasAgain length:2];
                    
                    if (totalLengthNum != 0) {
                        //前面已经固定了6个字节 但不包括本身两个字节
                        for (int i = 6; i < totalLengthNum +2; ) {//totalLengthNum-2
                            Byte recordLength[1] = {data[i]};
                            int recordLengthNum = [TTDataTransformUtil intFromHexBytes:recordLength length:1];
                            
                            [TTHandleResponse operationRecordWithByteData:data i:i lockOpenRecordArr:self.lockOpenRecordArr timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                            
                            i+=recordLengthNum+1;
                        }
                    }
                    //读了一圈之后，防止数据重复读
                    if (self.m_operatelog_Count == 1 && self.m_operatelog_nextNum >= nextNum) {
                        
                        [self onGetOperateLog:YES];
                        return;
                    }
                    if (nextNum != 0) {
                        self.m_operatelog_nextNum = nextNum;
                    }
                    
                    if (totalLengthNum == 0) {
                        if (self.m_currentOperatorState == Current_Operator_State_Get_Total_Unlock_record && self.m_operatelog_Count == 0) {
                            self.m_operatelog_Count = 1;
                            ++self.m_operatelog_nextNum;
                            [TTCommandUtils lock_fetch_record_num:self.m_operatelog_nextNum
                                                             type:1
                                                          version:command->version
                                                              key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            return;
                        }else{
                            [self onGetOperateLog:YES];
                            return;
                        }
                    }
                    
                    if (nextNum == 0xFFF0 ) {
                        [self onGetOperateLog:YES];
                        
                        return;
                    }
                    else{
                        
                        //执行0x25  请求序号为应答参数的第5和第6个字节
                        [TTCommandUtils lock_fetch_record_num:nextNum
                                                         type:1
                                                      version:command->version
                                                          key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        
                        
                    }
                    break;
                }
                case COMM_FETCH_USER_PS_LIST:{
                    [TTDebugLog log:@"TTLockLog#####v3 get unlock passcode list successfully#####" ];
                    
                    //记录总长度 为第3和第4个字节
                    Byte totalLength[2] = {data[2],data[3]};
                    int totalLengthNum = [TTDataTransformUtil intFromHexBytes:totalLength length:2];
                    
                    //请求序号为应答参数的第5和第6个字节
                    Byte datasAgain[2] = {data[4],data[5]};
                    int nextNum = [TTDataTransformUtil intFromHexBytes:datasAgain length:2];
                    //没有记录可以读取了，则长度为0
                    if (totalLengthNum == 0) {
                        [self onGetOperateLog:YES];
                        return;
                    }
                    else{
                        //前面已经固定了6个字节 但不包括本身两个字节
                        for (int i = 6; i < totalLengthNum +2; ) {//totalLengthNum-2
                            Byte recordLength[1] = {data[i]};
                            int recordLengthNum = [TTDataTransformUtil intFromHexBytes:recordLength length:1];
                            
                            [TTHandleResponse unlockPasswordWithByteData:data i:i lockOpenRecordArr:self.lockOpenRecordArr timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                            i+=recordLengthNum+1;
                        }
                    }
                    //这个序号为0xFFFF，则表示记录已经读完了
                    if (nextNum == 0xFFFF ) {
                        [self onGetOperateLog:YES];
                        return;
                    }
                    else{
                        //执行0x04  请求序号为应答参数的第5和第6个字节
                        [TTCommandUtils lock_fetch_record_num:nextNum
                                                         type:4
                                                      version:command->version
                                                          key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        
                        
                    }
                    break;
                    
                    
                }break;
                case 0x31:
                {
                    [TTDebugLog log:@"TTLockLog#####v3 0x31 successfully#####" ];
                    //添加管理员成功的回调方法
                    if (self.m_currentOperatorState == Current_Operator_State_Add_Admin){
                        [TTCommandUtils v3_check_admin_with_ps: self.lockDataModel.adminPwd
                                                          flag:self.lockDataModel.lockFlagPos
                                                        userID:self.lockDataModel.uid
                                                       version:command->version
                                                           key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        
                    }else{
                        if ([self.delegate respondsToSelector:@selector(onResetPasscodeWithTimestamp:pwdInfo:)]) {
                            [self.delegate onResetPasscodeWithTimestamp:self.timestamp pwdInfo:self.pwdInfo];
                        }
                        
                    }
                    
                    break;
                }
                case COMM_LOCK_NOTIFY_ADDADMIN:{
                    [TTDebugLog log:@"TTLockLog#####v3 Administrators confirm the addition of success#####" ];
                    
                    [self onAddAdminWithCommand:command timestamp:self.timestamp pwdInfo:self.pwdInfo Characteristic:self.lockDataModel.specialValue deviceInfoDic:self.deviceInfoDic];
                    
                    break;
                }
                case 0x30:
                {
                    [TTDebugLog log:@"TTLockLog#####v3 0x30 success#####" ];
                    switch (self.m_currentOperatorState) {
                        case Current_Operator_State_Add_Admin:{
                            [TTCommandUtils v3_get_device_characteristic_WithVersion:command->version];
                            
                        }break;
                        case Current_Operator_state_Set_Lock_BongKey:
                        case Current_Operator_State_Set_Keyboard_password:
                        {
                            //设置管理员密码
                            
                            [TTCommandUtils v3_set_admin_nokey_ps:self.m_keyboard_password_admin
                                                          version:command->version
                                                              key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                        }
                        case  Current_Operator_State_Add_Onepsw:{
                            //执行0x03 添加单次密码
                            [TTCommandUtils add_onepassword_oprationType:TTOprationTypeAdd
                                                               limitType:self.m_psType
                                                                password:self.m_keyboardPs
                                                               startDate:(NSString*)[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                 endDate:(NSString*)[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                 version:command->version
                                                                     key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                            
                        case Current_Operator_State_del_keyboard_password:
                        {
                            
                            //删除键盘密码
                            [TTCommandUtils v3_del_kbpwd:self.m_keyboardPs psType:self.m_psType version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            break;
                        }
                            
                        case Current_Operator_State_clear_Keyboard_password:
                        {
                            
                            //清空键盘密码
                            [TTCommandUtils v3_clear_kbpwd_WithVersion:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            
                            break;
                        }
                        case Current_Operator_State_Recover_Keyboard_Password:{
                            [TTCommandUtils v3_modify_Recover_keyboard_password_operateType:TTOprationTypeRecover
                                                                               keyboardType:self.m_psType
                                                                                  cycleType:self.m_cycleType oldPassword:self.m_keyboardPs newPassword:self.m_newKeyboardPs startDate:self.m_startDate endDate:self.m_endDate timezoneRawOffset:self.lockDataModel.timezoneRawOffset version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                            
                        case Current_Operator_state_Modify_Keyboard_Password:{
                            [TTCommandUtils v3_modify_Recover_keyboard_password_operateType:TTOprationTypeModify
                                                                               keyboardType:TTPasscodeTypePeriod
                                                                                  cycleType:1
                                                                                oldPassword:self.m_keyboardPs newPassword:self.m_newKeyboardPs startDate:self.m_startDate endDate:self.m_endDate timezoneRawOffset:self.lockDataModel.timezoneRawOffset version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                            
                        case  Current_Operator_State_Calibation_Time:
                        {
                            [TTCommandUtils v3_calibation_time_with_version:command->version
                                                              referenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm-ss"
                                                                                         timezoneRawOffset:self.lockDataModel.timezoneRawOffset] key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            
                        }break;
                            
                        case Current_Operator_State_Init_900_ps:
                        {
                            [self generateV3PwdListWithCommand:command ];
                            
                            
                            break;
                            
                        }
                        case Current_Operator_State_Restore_factory_settings:
                        {
                            
                            [TTCommandUtils v3_lock_v1_reset_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            break;
                        }
                            
                        case Current_Operator_state_add_IC:{
                            [TTCommandUtils AddIC_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            break;
                        }
                        case Current_Operator_state_clear_IC:{
                            [TTCommandUtils ClearIC_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            break;
                        }
                        case Current_Operator_state_delete_IC:{
                            [TTCommandUtils DeleteIC_ICNumber:self.m_ICNumber version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            break;
                        }
                        case Current_Operator_State_Recover_IC:{
                            [TTCommandUtils ModifyOrRecoverICWithType:2
                                                             ICNumber:self.m_ICNumber
                                                            startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                              endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                              version:command->version
                                                                  key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            break;
                        }
                        case Current_Operator_state_Modify_IC:{
                            [TTCommandUtils ModifyOrRecoverICWithType:5
                                                             ICNumber:self.m_ICNumber
                                                            startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                              endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                              version:command->version
                                                                  key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                            break;
                        }
                        case Current_Operator_state_Fetch_IC_Data:{
                            self.lockOpenRecordArr = [NSMutableArray array];
                            [TTCommandUtils lock_fetch_record_num:0 type:2 version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                            break;
                        }
                        case Current_Operator_state_add_Fingerprint:{
                            [TTCommandUtils AddFingerprint_WithVersion:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                        case Current_Operator_state_delete_Fingerprint:{
                            [TTCommandUtils DeleteFingerprint_FingerprintNumber:self.m_fingerprintNum version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_clear_Fingerprint:{
                            [TTCommandUtils ClearFingerprint_version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_Recover_Fingerprint:{
                            [TTCommandUtils ModifyOrRecoverFingerprintWithType:2
                                                             FingerprintNumber:self.m_fingerprintNum
                                                                     startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                       endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                       version:command->version
                                                                           key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case  Current_Operator_State_Recover_Fingerprint_Data:{
                            
                            [TTCommandUtils recoverFingerprintDataWithTempNumber:self.m_tempFingerprintNumber
                                                             fingernumberDataStr:self.m_fingerprintData
                                                                       startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                         endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                         version:command->version
                                                                             key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Modify_Fingerprint:{
                            [TTCommandUtils ModifyOrRecoverFingerprintWithType:5
                                                             FingerprintNumber:self.m_fingerprintNum
                                                                     startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                       endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                       version:command->version
                                                                           key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                        case Current_Operator_state_Fetch_Fingerprint_Data:{
                            self.lockOpenRecordArr = [NSMutableArray array];
                            [TTCommandUtils lock_fetch_record_num:0 type:3 version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Fetch_DoorSensor_locking:
                        case Current_Operator_state_Fetch_lockingTime_Data:{
                            [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:1 Paralength:1 commandValue:Lock_V3_COMM_lockingTime_Manager key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                            
                        case Current_Operator_state_Modify_lockingTime:{
                            [TTCommandUtils twoRequestPara_WithVersion:command->version requestPara:2 tworequestPara:self.lockingTime Paralength:1 twoParalength:2 commandValue:Lock_V3_COMM_lockingTime_Manager key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Modify_DoorSensor_locking:{
                            [TTCommandUtils threeRequestPara_WithVersion:command->version requestPara:2 tworequestPara:0xFFFF threerequestPara:self.lockingTime Paralength:1 twoParalength:2 threeParalength:1 commandValue:Lock_V3_COMM_lockingTime_Manager key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Upgrade_Firmware:{
                            [TTCommandUtils oneRequestStringPara_WithVersion:command->version requestPara:@"SCIENER" commandValue:Lock_V3_COMM_PREPARE_UPGRADE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL:{
                            [TTCommandUtils twoRequestPara_WithVersion:command->version
                                                           requestPara:self.bongOperateType
                                                        tworequestPara:self.lockingTime
                                                            Paralength:1
                                                         twoParalength:self.bongOperateType==2?1:0 commandValue:LOCK_V3_COMM_PASSWORD_DISPLAY_HIDE_CONTROL key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_AT_COMMADN:{
                            [TTCommandUtils setOrQuery_Para:self.ATCommand version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        }break;
                        case Current_Operator_State_get_keyboard_password_list:{
                            self.lockOpenRecordArr = [NSMutableArray array];
                            //第一次请求序号为0，以后请求时， 填写收到的应答数据中的序号即可
                            //获取键盘密码列表
                            [TTCommandUtils lock_fetch_record_num:0 type:4 version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                        case Current_Operator_State_Get_Password_Data:{
                            [TTCommandUtils noneRequestStringPara_WithVersion:command->version commandValue:LOCK_V3_COMM_GET_PASSWORD_DATA key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Fetch_Remote_Unlock:{
                            [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:1 Paralength:1 commandValue:LOCK_V3_COMM_Remote_Unlock key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Modify_Remote_Unlock:{
                            [TTCommandUtils twoRequestPara_WithVersion:command->version requestPara:2 tworequestPara:self.lockingTime Paralength:1 twoParalength:1 commandValue:LOCK_V3_COMM_Remote_Unlock key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        }break;
                        case Current_Operator_state_Query_Audio_Switch:{
                            [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:1 Paralength:1 commandValue:LOCK_V3_COMM_Audio_Switch key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Modify_Audio_Switch:{
                            [TTCommandUtils twoRequestPara_WithVersion:command->version requestPara:2 tworequestPara:self.lockingTime Paralength:1 twoParalength:1 commandValue:LOCK_V3_COMM_Audio_Switch key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_Set_NB_Server:{
                            [TTCommandUtils setNBServerConfigWithPortNumber:self.portNumber serverAddress:self.serverAddress version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_state_get_admin_passcode:{
                            [TTCommandUtils noneRequestStringPara_WithVersion:command->version commandValue:LOCK_V3_COMM_GET_ADMIN_PASSCODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_Query_PassageMode:{
                            self.m_passageModeTypeRecord = [NSMutableArray array];
                            [TTCommandUtils twoRequestPara_WithVersion:command->version requestPara:1 tworequestPara:0 Paralength:1 twoParalength:1 commandValue:LOCK_V3_COMM_PASSAGEMODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_AddOrModify_PassageMode:{
                            [TTCommandUtils setPassageModeWithType:self.m_passageModeType
                                                         weekOrDay:[self.m_weekArr[0] intValue]
                                                             month:self.m_monthStr
                                                         startDate:self.m_startMinutes
                                                           endDate:self.m_endMinutes
                                                           version:command->version
                                                               key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_Delete_PassageMode:{
                            [TTCommandUtils fourRequestPara_WithVersion:command->version
                                                            requestPara:3
                                                         tworequestPara:self.m_passageModeType
                                                       threerequestPara:[self.m_weekArr[0] intValue]
                                                        fourrequestPara:self.m_monthStr
                                                             Paralength:1
                                                          twoParalength:1
                                                        threeParalength:1
                                                         fourParalength:1
                                                           commandValue:LOCK_V3_COMM_PASSAGEMODE
                                                                    key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case Current_Operator_State_Clean_PassageMode:{
                            [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:4 Paralength:1 commandValue:LOCK_V3_COMM_PASSAGEMODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        default:
                            break;
                    }
                    
                } break;
                case LOCK_V3_COMM_PASSAGEMODE:{
                    //                                1查询 2添加 3删除 4清空
                    switch (data[3]) {
                        case 1:{
                            int nextNum = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                            if (nextNum == 0xFF) {
                                //                                NSString *jsonStr = self.m_passageModeTypeRecord.count == 0 ? nil : [TTDataTransformUtil convertToJsonData:self.m_passageModeTypeRecord];
                                
                                //                                if ([self.delegate respondsToSelector:@selector(onQueryPassageModeWithRecord:)]) {
                                //                                    [self.delegate onQueryPassageModeWithRecord:jsonStr];
                                //                                }
                                break;
                            }
                            [TTHandleResponse passageModeWithByteData:data lockOpenRecordArr:self.m_passageModeTypeRecord
                                                        timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                            
                            [TTCommandUtils twoRequestPara_WithVersion:command->version requestPara:1 tworequestPara:nextNum Paralength:1 twoParalength:1 commandValue:LOCK_V3_COMM_PASSAGEMODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }break;
                        case 2:{
                            
                            [self.m_weekArr removeObjectAtIndex:0];
                            if (self.m_weekArr.count > 0) {
                                [TTCommandUtils setPassageModeWithType:self.m_passageModeType
                                                             weekOrDay:[self.m_weekArr[0] intValue]
                                                                 month:self.m_monthStr
                                                             startDate:self.m_startMinutes
                                                               endDate:self.m_endMinutes
                                                               version:command->version
                                                                   key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                                return;
                            }
                            
                            if ([self.delegate respondsToSelector:@selector(onConfigPassageMode)]) {
                                [self.delegate onConfigPassageMode];
                            }
                        }break;
                        case 3:{
                            
                            [self.m_weekArr removeObjectAtIndex:0];
                            if (self.m_weekArr.count > 0) {
                                [TTCommandUtils threeRequestPara_WithVersion:command->version
                                                                 requestPara:self.m_passageModeType
                                                              tworequestPara: [self.m_weekArr[0] intValue] threerequestPara:self.m_monthStr
                                                                  Paralength:1
                                                               twoParalength:1
                                                             threeParalength:1
                                                                commandValue:LOCK_V3_COMM_PASSAGEMODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                                return;
                            }
                            if ([self.delegate respondsToSelector:@selector(onDeletePassageMode)]) {
                                [self.delegate onDeletePassageMode];
                            }
                        }break;
                        case 4:{
                            if ([self.delegate respondsToSelector:@selector(onClearPassageMode)]) {
                                [self.delegate onClearPassageMode];
                            }
                        }break;
                        default:
                            break;
                    }
                }break;
                case LOCK_V3_COMM_GET_ADMIN_PASSCODE:{
                    int length = [TTDataTransformUtil intFromHexBytes:&data[3] length:1];
                    NSString * currentPasswordStr = nil;
                    if (length != 0) {
                        Byte currentPassword[length];
                        for (int i = 0; i < length; i++) {
                            currentPassword[i]=data[i+4];
                        }
                        currentPasswordStr = [[NSString alloc]initWithData:[NSData dataWithBytes:currentPassword length:length] encoding:NSUTF8StringEncoding];
                    }
                    if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                        if (currentPasswordStr.length > 0) {
                           self.m_keyboard_password_admin = currentPasswordStr;
                        }
                        [TTCommandUtils v3_set_admin_nokey_ps:self.m_keyboard_password_admin version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                    }
                    if (self.m_currentOperatorState == Current_Operator_state_get_admin_passcode) {
                        if ([self.delegate respondsToSelector:@selector(onGetAdminKeyBoardPassword:)]) {
                            [self.delegate onGetAdminKeyBoardPassword:currentPasswordStr];
                        }
                    }
                }break;
                case LOCK_V3_COMM_Remote_Control:{
                    if (data[3] == 1) {
//                        int state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
//                        if ([self.delegate respondsToSelector:@selector(onQueryRemoteControl:)]) {
//                            [self.delegate onQueryRemoteControl:state];
//                        }
                    }
                }break;
                case LOCK_V3_COMM_Audio_Switch:{
                    switch (data[3]) {
                        case 1:{
                            BOOL state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                            if ([self.delegate respondsToSelector:@selector(onGetAudioSwitchState:)]) {
                                [self.delegate onGetAudioSwitchState:state];
                            }
                        } break;
                        case 2:{
                            if ([self.delegate respondsToSelector:@selector(onSetAudioSwitch)]) {
                                [self.delegate onSetAudioSwitch];
                            }
                        } break;
                        default:
                            break;
                    }
                }break;
                case LOCK_V3_COMM_Remote_Unlock:{
                    switch (data[3]) {
                        case 1:{
                            BOOL state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                            
                            if ([self.delegate respondsToSelector:@selector(onGetRemoteUnlockSwitchState:)]) {
                                [self.delegate onGetRemoteUnlockSwitchState:state];
                            }
                            
                        } break;
                        case 2:{
                            
                            [TTCommandUtils v3_get_device_characteristic_WithVersion:command->version];
                            
                        } break;
                        default:
                            break;
                    }
                    
                }break;
                case LOCK_V3_COMM_GET_PASSWORD_DATA:{
                    
                    long long timestamp = [[NSDate date] timeIntervalSince1970]*1000 ;
                    NSString * timeString = [NSString stringWithFormat:@"%lld",timestamp] ;
                    
                    NSString * pwdInfo = [TTHandleResponse getV3PasswordData:data timeString:timeString timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                    if ([self.delegate respondsToSelector:@selector(onGetInfoWithTimestamp:pwdInfo:)]) {
                        [self.delegate onGetInfoWithTimestamp:timestamp pwdInfo:pwdInfo];
                    }
                    
                }break;
                case COMM_LOCK_Device_Parameter_Settings:{
                    //                                if ([self.delegate respondsToSelector:@selector(onSetLockName)]) {
                    //                                    [self.delegate onSetLockName];
                    //                                }
                }break;
                    
                case LOCK_V3_COMM_PASSWORD_DISPLAY_HIDE_CONTROL:{
                    switch (data[3]) {
                        case 1:{
                            if ([self.delegate respondsToSelector:@selector(onGetPasscodeVisibleState:)]) {
                                int state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                                [self.delegate onGetPasscodeVisibleState:state];
                            }
                        }break;
                        case 2:{
                            if ([self.delegate respondsToSelector:@selector(onSetPasscodeVisible)]) {
                                [self.delegate onSetPasscodeVisible];
                            }
                        }break;
                    }
                    
                }break;
                case Lock_V3_COMM_PREPARE_UPGRADE:{
                    if ([self.delegate respondsToSelector:@selector(onEnterFirmwareUpgradeMode)]) {
                        [self.delegate onEnterFirmwareUpgradeMode];
                    }
                    
                }break;
                case Lock_V3_COMM_lockingTime_Manager:{
                    switch (data[3]) {
                        case 0x01: {
                            Byte currentTimedatas[2]= {data[4],data[5]};
                            int currentTime = [TTDataTransformUtil intFromHexBytes:currentTimedatas length:2];
                            Byte minTimedatas[2]= {data[6],data[7]};
                            int minTime = [TTDataTransformUtil intFromHexBytes:minTimedatas length:2];
                            Byte maxdatas[2]= {data[8],data[9]};
                            int maxTime = [TTDataTransformUtil intFromHexBytes:maxdatas length:2];
                            if (self.m_currentOperatorState == Current_Operator_state_Fetch_DoorSensor_locking) {
                                if (command->length > 10) {
                                    int doorSensor = [TTDataTransformUtil intFromHexBytes:&data[10] length:1];
                                    if ([self.delegate respondsToSelector:@selector(onQueryDoorSensorLocking:)]) {
                                        [self.delegate onQueryDoorSensorLocking:doorSensor];
                                    }
                                }else{
                                    [self onTTError:TTErrorFail command:0];
                                }
                                
                            }else{
                                if ([self.delegate respondsToSelector:@selector(onGetAutomaticLockingPeriodWithCurrentTime:minTime:maxTime:)]) {
                                    
                                    [self.delegate onGetAutomaticLockingPeriodWithCurrentTime:currentTime minTime:minTime maxTime:maxTime];
                                }
                            }
                            
                        } break;
                        case 0x02: {
                            if (self.m_currentOperatorState == Current_Operator_state_Modify_DoorSensor_locking) {
                                if ([self.delegate respondsToSelector:@selector(onModifyDoorSensorLocking)]) {
                                    [self.delegate onModifyDoorSensorLocking];
                                }
                            }else{
                                if ([self.delegate respondsToSelector:@selector(onSetAutomaticLockingPeriod)]) {
                                    [self.delegate onSetAutomaticLockingPeriod];
                                }
                            }
                            
                        } break;
                        default:
                            break;
                    }
                    
                }break;
                case Lock_V3_COMM_Fingerprint_Manager:{
                    
                    switch (data[3]){
                            
                        case 0x06:
                        case 0x01:{
                            //1-查询
                            //请求序号为应答参数的第5和第6个字节
                            Byte datasAgain[2]= {data[4],data[5]};
                            int nextNum = [TTDataTransformUtil intFromHexBytes:datasAgain length:2];
                            int totalLength = [TTDataTransformUtil intFromHexBytes:&command->length length:1];
                            
                            if (totalLength > 6) {
                                for (int i = 6; i < totalLength ;) {
                                    [TTHandleResponse ICQueryWithByteData:data i:i lockOpenRecordArr:self.lockOpenRecordArr type:1 timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                                    i = i+16;
                                    
                                }
                            }
                            if (nextNum == 0xFFFF ) {
                                [self onGetOperateLog:YES];
                                return;
                            }
                            else{
                                //执行0x25  请求序号为应答参数的第5和第6个字节
                                [TTCommandUtils lock_fetch_record_num:nextNum
                                                                 type:3
                                                              version:command->version
                                                                  key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                                
                                
                            }
                        }break;
                        case 0x02:{
                            int state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                            int currentCount = -1;
                            int totalCount = -1;
                            NSString *fingerprintNum;
                            switch (state) {
                                case TTAddFingerprintCollectSuccess:{
                                    Byte uniqueByte[6];
                                    for (int i = 0; i < 6 ; i++) {
                                        uniqueByte[i]=data[i+5];
                                    }
                                    fingerprintNum = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:uniqueByte length:6]];
                                } break;
                                case TTAddFingerprintCanCollect:{
                                    if (command->length > 5) {
                                        currentCount = 0;
                                        totalCount = [TTDataTransformUtil intFromHexBytes:&data[5] length:1];
                                    }
                                    
                                }break;
                                case TTAddFingerprintCanCollectAgain:{
                                    if (command->length > 5) {
                                        currentCount = [TTDataTransformUtil intFromHexBytes:&data[5] length:1];
                                        totalCount = [TTDataTransformUtil intFromHexBytes:&data[6] length:1];
                                    }
                                }break;
                                case 4:{
                                    if (command->length > 5) {
                                        Byte indexByte[2] = {data[5],data[6]};
                                        int index = [TTDataTransformUtil intFromHexBytes:indexByte length:2];
                                        Byte maxByte[2] = {data[7],data[8]};
                                        int maxCount = [TTDataTransformUtil intFromHexBytes:maxByte length:2];
                                        self.m_maxCount = maxCount;
                                        [TTCommandUtils recoverFingerprintDataWithFingernumberDataStr:self.m_fingerprintData
                                                                                                index:index
                                                                                             maxCount:self.m_maxCount version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                                    }
                                }break;
                                default:
                                    break;
                            }
                            if (state == 4) {
                                return;
                            }
                            if (self.m_currentOperatorState == Current_Operator_State_Recover_Fingerprint_Data) {
                                if ([self.delegate respondsToSelector:@selector(onWriteFingerprintDataWithFingerprintNum:)]) {
                                    [self.delegate onWriteFingerprintDataWithFingerprintNum:fingerprintNum];
                                }
                                return;
                            }
                            if (self.m_currentOperatorState == Current_Operator_State_Recover_Fingerprint) {
                                if ([self.delegate respondsToSelector:@selector(onRecoverFingerprintWithFingerprintNum:)]) {
                                    [self.delegate onRecoverFingerprintWithFingerprintNum:fingerprintNum];
                                }
                                return;
                            }
                          
                            if (state != TTAddFingerprintCollectSuccess) {
                                if ([self.delegate respondsToSelector:@selector(onAddFingerprintWithState:fingerprintNum:currentCount:totalCount:)]) {
                                    [self.delegate onAddFingerprintWithState:state fingerprintNum:fingerprintNum currentCount:currentCount totalCount:totalCount];
                                }
                                return;
                            }
                            if ([self.m_startDate isEqual:[TTDateHelper getPermanentStartDateWithtimezoneRawOffset:self.lockDataModel.timezoneRawOffset]] && [self.m_endDate isEqual:[TTDateHelper getPermanentEndDateWithtimezoneRawOffset:self.lockDataModel.timezoneRawOffset]]) {
                                if ([self.delegate respondsToSelector:@selector(onAddFingerprintWithState:fingerprintNum:currentCount:totalCount:)]) {
                                    [self.delegate onAddFingerprintWithState:state fingerprintNum:fingerprintNum currentCount:currentCount totalCount:totalCount];
                                }
                                return;
                            }
                            self.m_fingerprintNum = fingerprintNum;
                            self.m_maxCount = totalCount;
                            //要延迟一点，要不然锁里可能还没写入指纹成功
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [TTCommandUtils ModifyOrRecoverFingerprintWithType:5
                                                                 FingerprintNumber:self.m_fingerprintNum
                                                                         startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                           endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                           version:command->version
                                                                               key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            });
                            
                            
                        }break;
                        case 0x03:{
                            if ([self.delegate respondsToSelector:@selector(onDeleteFingerprint)]) {
                                [self.delegate onDeleteFingerprint];
                            }
                        }break;
                        case 0x04:{
                            if ([self.delegate respondsToSelector:@selector(onClearAllFingerprints)]) {
                                [self.delegate onClearAllFingerprints];
                            }
                            //清空
                        }break;
                        case 0x05:{
                            //修改
                            if (self.m_currentOperatorState== Current_Operator_state_add_Fingerprint) {
                                if ([self.delegate respondsToSelector:@selector(onAddFingerprintWithState:fingerprintNum:currentCount:totalCount:)]) {
                                    [self.delegate onAddFingerprintWithState:TTAddFingerprintCollectSuccess fingerprintNum:self.m_fingerprintNum currentCount:self.m_maxCount totalCount:self.m_maxCount];
                                }
                                return;
                            }
                            
                            if ([self.delegate respondsToSelector:@selector(onModifyFingerprintValidityPeriod)]) {
                                [self.delegate onModifyFingerprintValidityPeriod];
                            }
                        } break;
                        case 0x07:{
                            Byte indexByte[2] = {data[4],data[5]};
                            int index = [TTDataTransformUtil intFromHexBytes:indexByte length:2] + 1;
                            
                            [TTCommandUtils recoverFingerprintDataWithFingernumberDataStr:self.m_fingerprintData
                                                                                    index:index
                                                                                 maxCount:self.m_maxCount version:command->version key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                            
                        } break;
                            
                    }
                    
                }break;
                case Lock_V3_COMM_IC_Manager:{
                    [TTDebugLog log:@"TTLockLog#####v3 IC Manager successful#####" ];
                    
                    switch (data[3]) {
                            
                        case 0x01:{
                            //1-查询
                            //请求序号为应答参数的第5和第6个字节
                            Byte datasAgain[2]= {data[4],data[5]};
                            int nextNum = [TTDataTransformUtil intFromHexBytes:datasAgain length:2];
                            int totalLength = [TTDataTransformUtil intFromHexBytes:&command->length length:1];
                            
                            if (totalLength > 6) {
                                for (int i = 6; i < totalLength ;) {
                                    [TTHandleResponse ICQueryWithByteData:data i:i lockOpenRecordArr:self.lockOpenRecordArr type:totalLength > 20 ? 2 : 0 timezoneRawOffset:self.lockDataModel.timezoneRawOffset];
                                    break;
                                    
                                }
                            }
                            if (nextNum == 0xFFFF ) {
                                [self onGetOperateLog:YES];
                                return;
                            }
                            else{
                                //执行0x25  请求序号为应答参数的第5和第6个字节
                                [TTCommandUtils lock_fetch_record_num:nextNum
                                                                 type:2
                                                              version:command->version
                                                                  key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                                
                                
                            }
                            
                            break;
                        }
                        case 0x02:{
                            int state = [TTDataTransformUtil intFromHexBytes:&data[4] length:1];
                            NSString * uniqueStr = @"";
                            if (state == 1) {
                                int iclength = 4;
                                //判断到底是8个字节还是 4个字节
                                if (command->length > 9
                                    && [TTDataTransformUtil intFromHexBytes:&data[9] length:1] != 255
                                    && [TTDataTransformUtil intFromHexBytes:&data[10] length:1] != 255
                                    && [TTDataTransformUtil intFromHexBytes:&data[11] length:1] != 255
                                    && [TTDataTransformUtil intFromHexBytes:&data[12] length:1] != 255) {
                                    iclength = 8;
                                }
                                Byte uniqueByte[iclength];
                                for (int i = 0; i < iclength ; i++) {
                                    uniqueByte[i]=data[i+5];
                                    
                                }
                                uniqueStr = [NSString stringWithFormat:@"%lld",[TTDataTransformUtil longFromHexBytes:uniqueByte length:iclength]];
                                
                            }
                            if (self.m_currentOperatorState== Current_Operator_State_Recover_IC) {
                                if ([self.delegate respondsToSelector:@selector(onRecoverICCardWithCardNum:)]) {
                                    [self.delegate onRecoverICCardWithCardNum:uniqueStr];
                                }
                                return;
                            }
                            
                            if (state == TTAddICStateCanAdd) {
                                if ([self.delegate respondsToSelector:@selector(onAddICCardWithState:cardNum:)]) {
                                    [self.delegate onAddICCardWithState:state cardNum:uniqueStr];
                                }
                                return;
                            }
                            
                            if ([self.m_startDate isEqual:[TTDateHelper getPermanentStartDateWithtimezoneRawOffset:self.lockDataModel.timezoneRawOffset]] && [self.m_endDate isEqual:[TTDateHelper getPermanentEndDateWithtimezoneRawOffset:self.lockDataModel.timezoneRawOffset]]) {
                                if ([self.delegate respondsToSelector:@selector(onAddICCardWithState:cardNum:)]) {
                                    [self.delegate onAddICCardWithState:state cardNum:uniqueStr];
                                }
                                return;
                            }
                            self.m_ICNumber = uniqueStr;
                            //要延迟一点，要不然锁里可能还没写入卡片成功
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [TTCommandUtils ModifyOrRecoverICWithType:5
                                                                 ICNumber:self.m_ICNumber
                                                                startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                  endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]
                                                                  version:command->version
                                                                    key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                             });
                          
                            break;
                        }
                        case 0x03:{
                            //删除
                            if ([self.delegate respondsToSelector:@selector(onDeleteICCard)]) {
                                [self.delegate onDeleteICCard];
                            }
                            break;
                        }
                        case 0x04:{
                            if ([self.delegate respondsToSelector:@selector(onClearICCard)]) {
                                [self.delegate onClearICCard];
                            }
                            //清空
                            break;
                        }
                        case 0x05:{
                            //修改
                            if (self.m_currentOperatorState== Current_Operator_state_add_IC) {
                                if ([self.delegate respondsToSelector:@selector(onAddICCardWithState:cardNum:)]) {
                                    [self.delegate onAddICCardWithState:TTAddICStateHadAdd cardNum:self.m_ICNumber];
                                }
                                return;
                            }
                        
                            if ([self.delegate respondsToSelector:@selector(onModifyICCard)]) {
                                [self.delegate onModifyICCard];
                            }
                            break;
                        }
                        default:
                            break;
                    }
                    
                    break;
                }
                case Lock_V3_COMM_GET_Device_CHARACTERISTIC:{
                    [TTDebugLog log:@"TTLockLog#####v3 GET Device CHARACTERISTIC success#####" ];
                    Byte typebyte[4];
                    for (int i = 0; i < 4; i++) {
                        typebyte[i]=data[i+3];
                    }
                    long long characteristicType = [TTDataTransformUtil longFromHexBytes:typebyte length:4];
                    if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                        
                        self.lockDataModel.specialValue = characteristicType;
                        self.deviceInfoDic = [[NSMutableDictionary alloc]init];
                        self.deviceInfoType = TTDeviceInfoTypeOfProductionModel;
                        
                        
                        
                        if ([TTUtil lockSpecialValue:self.lockDataModel.specialValue suportFunction:TTLockSpecialFunctionGetAdminPasscode]) {
                            [TTCommandUtils noneRequestStringPara_WithVersion:command->version commandValue:LOCK_V3_COMM_GET_ADMIN_PASSCODE key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                        }else{
                            [TTCommandUtils v3_set_admin_nokey_ps:self.m_keyboard_password_admin
                                                          version:command->version
                                                              key:(Byte*)self.lockDataModel.aesKeyStr.bytes ];
                        }
                        
                    }else if (self.m_currentOperatorState == Current_Operator_state_Modify_Remote_Unlock){
                        if ([self.delegate respondsToSelector:@selector(onSetRemoteUnlockSwitchWithSpecialValue:)]) {
                            [self.delegate onSetRemoteUnlockSwitchWithSpecialValue:characteristicType];
                        }
                    }
                    
                    
                    else if (self.m_currentOperatorState == Current_Operator_state_Modify_Keyboard_Password){
                        BOOL isSupportModiftPwd = [TTUtil lockSpecialValue:characteristicType suportFunction:TTLockSpecialFunctionManagePasscode];
                        //是否支持修改密码
                        if (isSupportModiftPwd) {
                            [self onTTError:self.modifyPwdError command:COMM_USER_PS_SET_DEL];
                        }else{
                            [self onTTError:TTErrorNotSupportModifyPasscode command:COMM_USER_PS_SET_DEL];
                        }
                    }else if (self.m_currentOperatorState == Current_Operator_state_Get_Electric_Quantity){
                        if ([self.delegate respondsToSelector:@selector(onGetElectricQuantity:)]) {
                            [self.delegate onGetElectricQuantity:[self getPower]];
                        }
                    }else if (self.m_currentOperatorState == Current_Operator_state_get_deviceInfo){
                        self.lockDataModel.specialValue = characteristicType;
                        [TTCommandUtils oneRequestPara_WithVersion:command->version requestPara:self.deviceInfoType Paralength:1 commandValue:COMM_GET_DeviceInfo key:(Byte*)self.lockDataModel.aesKeyStr.bytes];
                    }
                    else{
                        if ([self.delegate respondsToSelector:@selector(onGetLockSpecialValue:)]) {
                            [self.delegate onGetLockSpecialValue:characteristicType];
                        }
                    }
                    
                    break;
                }
                default:
                    break;
            }
        }
    }
    
}



- (void)generateV3PwdListWithCommand:(TTCommand*)command {
    NSArray *code = [TTHandleResponse generateV3Code];
    NSArray *secretKey = [TTHandleResponse generateSecretKey];
    NSArray *yearArray = [TTHandleResponse generateV3Year];
    NSTimeInterval a=[[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f000", a];
    self.timestamp = timeString.longLongValue;
    self.pwdInfo  = [TTHandleResponse generateV3PasswordWithCodeArray:code yearArray:yearArray secretKeyArray:secretKey timeString:[NSString stringWithFormat:@"%.0f000", a]];
    [TTCommandUtils v4_initializ_password_code:code secretKey:secretKey version:command->version year:[TTDateHelper getCurrentYear] key:(Byte *)self.lockDataModel.aesKeyStr.bytes];
    
}

@end
