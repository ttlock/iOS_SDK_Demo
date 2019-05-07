//
//  TTCenterManager+LOCKV2.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager+LOCKV2.h"
#import "TTDebugLog.h"
#import "TTHandleResponse.h"
#import "TTDateHelper.h"
#import "TTMacros.h"
#import "TTCommandUtils.h"
#import "TTCenterManager+Common.h"
#import "TTDataTransformUtil.h"

#define MAX_POOL_PS_NUMBER 900

@implementation TTCenterManager (LOCKV2)

-(void)LOCKV2HandleCommand:(TTCommand*)command{
    switch ([command getCommand]) {
            
        case 'T': {
            [TTDebugLog log:@"TTLockLog#####T success#####"];
            Byte* data = [command getData];
            if (data[1] == 1) {
                [TTHandleResponse setPowerWithCommand:command data:data];
                
                switch (data[0]) {
                    case 'E':
                    {
                        [TTDebugLog log:@"TTLockLog#####E success#####"];
                        switch (self.m_currentOperatorState) {
                            case Current_Operator_State_Add_Admin:
                            {
                                //添加管理员
                                 self.lockDataModel.adminPwd = [TTDataTransformUtil generateDynamicPassword:10];
                               self.lockDataModel.lockKey =  [TTDataTransformUtil generateDynamicPassword:10];
                                
                                [TTCommandUtils v4_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey];
                                
                                break;
                                
                            }
                            case Current_Operator_State_Set_Admin_delete_ps:
                            case Current_Operator_State_Set_Keyboard_password:
                            case Current_Operator_State_Init_900_ps:
                            case Current_Operator_state_reset_ekey:
                                
                            case Current_Operator_State_Unlock_Admin:
                            {
                                [TTCommandUtils v4_check_admin_with_ps: self.lockDataModel.adminPwd flag:self.lockDataModel.lockFlagPos ];
                                break;
                            }
                                
                            case Current_Operator_State_Calibation_Time:
                          
                            {
                                //校准时间并开门
                                [TTCommandUtils v4_check_user_startDate:@"00-01-01-00-00"  endDate:@"99-12-31-23-59" flag:self.lockDataModel.lockFlagPos ];
                                
                                break;
                            }
                                
                            case Current_Operator_State_Unlock_EKey:
                            {
                                //ekey开门
                                
                                [TTCommandUtils v4_check_user_startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] flag:self.lockDataModel.lockFlagPos ];
                                
                                
                                break;
                                
                            }
                            default:
                                break;
                        }
                        
                        break;
                    }
                    case 'D':
                    {
                        //老的锁没有mac
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            self.Ps900Array = [[NSMutableArray alloc]init];
                            [self generatePs900WithCommand:command];
                            [TTCommandUtils v4_init_ps_pool:self.PSTmp5Arr pos:(int)self.Ps900Array.count-5 ];
                            
                        }else{
                            if ([self.delegate respondsToSelector:@selector(onSetAdminErasePasscode)]) {
                                [self.delegate onSetAdminErasePasscode];
                            }
                            
                        }
                        
                        break;
                        
                    }
                    case 'I':
                    {
                        
                        if (self.Ps900Array && self.Ps900Array.count >= MAX_POOL_PS_NUMBER) {
                            
                            NSString *keyboardPwd = [TTHandleResponse generateWith900Array:self.Ps900Array];
                            [self.Ps900Array removeAllObjects];
                            self.Ps900Array = Nil;
                            
                            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                            NSTimeInterval timeInterval=[dat timeIntervalSince1970]*1000;
                            NSString *timeString = [NSString stringWithFormat:@"%.0f000", timeInterval];
                            NSData *strData = [keyboardPwd dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *keyData = [timeString dataUsingEncoding:NSUTF8StringEncoding];
                            
                            NSData * dataEncrypted = [TTSecurityUtil encryptAESData:strData keyBytes:(Byte *)keyData.bytes];
                            
                            NSString *str  = [TTSecurityUtil encodeBase64Data:dataEncrypted];
                            
                            if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                                
                                [TTCommandUtils v4_calibation_timeWithVersion:command->version referenceTime: [TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm" timezoneRawOffset:-1]];
                                
                                [self  onAddAdminWithCommand:command timestamp:timeString.longLongValue pwdInfo:str Characteristic:-1 deviceInfoDic:nil];
                                
                            }else{
                                if ([self.delegate respondsToSelector:@selector(onResetPasscodeWithTimestamp:pwdInfo:)]) {
                                    [self.delegate onResetPasscodeWithTimestamp:timeString.longLongValue pwdInfo:str];
                                }
                            }
                            return;
                        }
                        [self generatePs900WithCommand:command];
                        [TTCommandUtils v4_init_ps_pool:self.PSTmp5Arr pos:(int)self.Ps900Array.count-5];
                        
                        break;
                    }
                    case 'V':
                    {
                        [TTDebugLog log:@"TTLockLog#####add admin success#####"];
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            [TTCommandUtils v4_set_admin_nokey_ps:self.m_keyboard_password_admin ];
                        }
                        
                        break;
                    }
                    case 'A':
                    {
                        
                        if (self.m_currentOperatorState ==  Current_Operator_state_reset_ekey){
                            
                            if ([self.delegate respondsToSelector:@selector(onResetEkey)]) {
                                [self.delegate onResetEkey];
                            }
                            return;
                        }
                        Byte bytes[4];//lock发送过来的开锁密码
                        [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                        long long passwordFromLock = [TTDataTransformUtil longFromHexBytes:bytes length:4];
                        long long passwordLocal =self.lockDataModel.lockKey.longLongValue;
                        [TTCommandUtils v4_unlock_psFromLock:passwordFromLock psLocal:passwordLocal flag:@"1" ];
                        
                        break;
                    }
                    case COMM_LOCK_TIME_CALIBRATION:
                    {
                        [TTDebugLog log:@"TTLockLog#####Set Lock Time success#####"];
                        if (self.m_currentOperatorState == Current_Operator_State_Add_Admin) {
                            
                            return;
                            
                        }
                        if (self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                            if ([self.delegate respondsToSelector:@selector(onSetLockTime)]) {
                                [self.delegate onSetLockTime];
                            }
                        }
                        break;
                    }
                    case 'G':
                    {
                        //开锁成功，没有低电压（低电压见‘g’失败）
                        [TTDebugLog log:@"TTLockLog#####unlock success#####"];
                        
                        [self LockUnlockSuccessWithCommand:command];
                        
                        break;
                    }
                    case 'S':
                    {
                        
                        //设置管理员无钥匙密码成功
                        [TTDebugLog log:@"TTLockLog#####Set Admin Keyboard Password success#####"];
                        switch (self.m_currentOperatorState) {
                            case Current_Operator_State_Set_Keyboard_password:
                            case Current_Operator_State_Unlock_Admin:{
                                if ([self.delegate respondsToSelector:@selector(onModifyAdminPasscode)]) {
                                    [self.delegate onModifyAdminPasscode];
                                }
                                
                            } break;
                            case Current_Operator_State_Add_Admin:{
                                [TTCommandUtils v4_set_admin_delete_ps:self.m_keyboard_delete_admin ];
                            }break;
                            default:
                                break;
                        }
                        
                        break;
                        
                    }
                    case 'U':
                    {
                        
                        Byte bytes[4];//lock发送过来的开锁密码
                        [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:4];
                        int passwordFromLock = [TTDataTransformUtil intFromHexBytes:bytes length:4];
                        long long passwordLocal =self.lockDataModel.lockKey.longLongValue;
                        if (self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                            
                            [TTCommandUtils v4_calibation_timeWithVersion:command->version referenceTime: [TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]];
                            
                        }else{
                            [TTCommandUtils v4_unlock_psFromLock:passwordFromLock psLocal:passwordLocal flag:@"1"];
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            else {
                [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####error code:%02x#####",data[2]]];
                if (data[0] == 'G' && data[2] == 0x0a) {
                    //开门成功，并伴有低电压，
                    [TTDebugLog log:@"TTLockLog#####Unlocking success with low battery#####"];
                    //开门成功，并伴有低电压， 这个方法只有没有电量 老的锁才会走 所以这里把电量设为-1
                    [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"dianliang"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self LockUnlockSuccessWithCommand:command];
                }
                if (data[0] == 'U' && self.m_currentOperatorState == Current_Operator_State_Calibation_Time) {
                    [TTCommandUtils v4_calibation_timeWithVersion:command->version referenceTime: [TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]];
                }
                [self onTTErrorWithData:data version:command->version];
                
            }
        }
            break;
        default:
            
            break;
    }
    
}

- (void)generatePs900WithCommand:(TTCommand*)command{
    
    self.PSTmp5Arr = [[NSMutableArray alloc] init];
    
    int count = 0;
    do {
        
        int startIndex = 0;
        
        int random = [TTDataTransformUtil RandomNumber0To9_length:5];
        
        int i = (int)self.Ps900Array.count;
        if (i<300) {
            
            startIndex = 0;
            
            random += 100000;
            
        }else if(i < 450){
            
            startIndex = 300;
            
            random += 200000;
            
        }else if(i < 550){
            
            startIndex = 450;
            
            random += 300000;
            
        }else if(i < 650){
            
            startIndex = 550;
            
            random += 400000;
            
        }else if(i < 700){
            
            startIndex = 650;
            
            random += 500000;
            
        }else if(i < 750){
            
            startIndex = 700;
            
            random += 600000;
            
        }else if(i < 800){
            
            startIndex = 750;
            
            random += 700000;
            
        }else if(i < 900){
            
            startIndex = 800;
            
            random += 800000;
            
        }
        
        BOOL isContain = NO;
        
        //是否包含
        
        for (int i = startIndex; i < self.PSTmp5Arr.count; i++) {
            
            NSString * number = [self.PSTmp5Arr objectAtIndex:startIndex];
            if (number.intValue == random) {
                
                isContain = YES;
                break;
            }
        }
        
        //是否包含
        if (isContain) {
            
            continue;
        }
        for (NSString * number in self.Ps900Array) {
            
            if (number.intValue == random) {
                
                isContain = YES;
                break;
            }
            
        }
        
        if (isContain) {
            continue;
        }
        
        [self.PSTmp5Arr addObject:[NSString stringWithFormat:@"%i",random]];
        [self.Ps900Array addObject:[NSString stringWithFormat:@"%i",random]];
        count++;
    } while (count <= 4);
}

//Lock锁 因为低电压和正常电量 要走的流程相同
- (void)LockUnlockSuccessWithCommand:(TTCommand*)command{
    switch (self.m_currentOperatorState) {
            
        case Current_Operator_State_Set_Admin_delete_ps:
        {
            
            [TTCommandUtils v4_set_admin_delete_ps:self.m_keyboard_delete_admin ];
            break;
        }
        case Current_Operator_State_Unlock_Admin:
        {
            
            //回调，开锁成功
            if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                [self.delegate onControlLockWithLockTime:0 electricQuantity:[self getPower] uniqueId:self.uniqueid];
            }
            break;
        }
        case Current_Operator_State_Set_Keyboard_password:
        {
            //设置管理员密码
            [TTCommandUtils v4_set_admin_nokey_ps:self.m_keyboard_password_admin ];
            
            break;
        }
        case Current_Operator_State_Calibation_Time:
        {
            
            //校准时间
            [TTCommandUtils v4_calibation_timeWithVersion:command->version
                                            referenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]];
            
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
            self.Ps900Array = [[NSMutableArray alloc]init];
            [self generatePs900WithCommand:command];
            [TTCommandUtils v4_init_ps_pool:self.PSTmp5Arr pos:(int)self.Ps900Array.count-5 ];
            break;
        }
            
        default:
            break;
    }
}

@end
