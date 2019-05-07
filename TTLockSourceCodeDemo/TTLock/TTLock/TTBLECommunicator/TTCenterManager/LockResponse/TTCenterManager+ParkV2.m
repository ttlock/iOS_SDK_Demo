//
//  TTCenterManager+ParkV2.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager+ParkV2.h"
#import "TTDebugLog.h"
#import "TTHandleResponse.h"
#import "TTDateHelper.h"
#import "TTMacros.h"
#import "TTCommandUtils.h"
#import "TTCenterManager+Common.h"
#import "TTDataTransformUtil.h"

@implementation TTCenterManager (ParkV2)

#pragma mark ------- 蓝牙反馈信息处理
-(void)parkV2HandleCommand:(TTCommand*)command{
    
    if ([command getCommand] != COMM_RESPONSE) {
        return;
    }
    // COMM_RESPONSE 反馈指令
    [TTDebugLog log:@"TTLockLog#####park lock ,T instructions#####" ];
    
    Byte* data = [command getData];
    if (data[1] != 1 ) {
        [self onTTErrorWithData:data version:command->version];
        return;
    }
    
    if (data[0] == PARK_LOCK_V1_COMM_LOCK || data[0] == PARK_LOCK_V1_COMM_UNLOCK ) {
        [TTHandleResponse setPowerWithCommand:command data:data];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@"-1" forKey:@"dianliang"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    switch (data[0]) {
        case PARK_LOCK_V1_COMM_WARN_RECORD: //读取警报纪录指令
        {
            [TTDebugLog log:@"TTLockLog#####get WARN RECORD success#####"  ];
            if(command->length>3)
            {
                NSString * dateStr = [NSString stringWithFormat:@"20%02i%02i%02i%02i%02i",data[2],data[3],data[4],data[5],data[6]];
                long long dateTime = [TTDateHelper formateDateFromStringToDate:dateStr format:@"yyyyMMddHHmm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset].timeIntervalSince1970;
                [self.lockOpenRecordArr addObject:@(dateTime*1000)];
                
                if (command->length == 8 && data[7]==1) {
                    //还有
                    [TTCommandUtils park_lock_v1_warn_recordWith];
                }
                
            }else{
                [self onGetOperateLog:YES];
            }
            
            break;
        }
        case COMM_INITIALIZATION:
        {
            [TTDebugLog log:@"TTLockLog#####E success#####"  ];
            switch (self.m_currentOperatorState) {
                    
                case  Current_Operator_State_Unlock_record:{
                    
                    self.lockOpenRecordArr = [NSMutableArray array];
                    [TTCommandUtils park_lock_v1_warn_recordWith];
                    break;
                }
                case Current_Operator_State_Add_Admin:
                {
                    //添加管理员
                     self.lockDataModel.adminPwd = [TTDataTransformUtil generateDynamicPassword:10];
                   self.lockDataModel.lockKey = [TTDataTransformUtil generateDynamicPassword:10];
                    [TTCommandUtils park_lock_v1_add_admin_with_ps: self.lockDataModel.adminPwd number:self.lockDataModel.lockKey ];
                    break;
                    
                }
                case Current_Operator_State_Calibation_ParkLock_Time:
                case Current_Operator_State_Unlock_Admin:
                {
                    //管理员开门
                    [TTCommandUtils park_lock_v1_check_admin_with_ps: self.lockDataModel.adminPwd ];
                    break;
                    
                }
                case Current_Operator_State_Close_lock_Admin_And_EKey:
                case Current_Operator_State_Unlock_EKey:
                {
                    //ekey开门
                    [TTCommandUtils park_lock_v1_check_user_startDate:[TTDateHelper formateDate:self.m_startDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset] endDate:[TTDateHelper formateDate:self.m_endDate format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]];
                    
                    break;
                    
                }
                    
                default:
                    break;
            }
            break;
        }
        case PARK_LOCK_V1_COMM_ADD_ADMIN:
        {
            [TTDebugLog log:@"TTLockLog#####park lock,add admin success#####"  ];
            //添加管理员成功的回调方法

                [self onAddAdminWithCommand:command timestamp:nil pwdInfo:nil Characteristic:-1 deviceInfoDic:nil];
            
            [TTCommandUtils park_lock_v1_calibation_timeWithReferenceTime:[TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm" timezoneRawOffset:-1]];
            break;
        }
        case PARK_LOCK_V1_COMM_CHECK_ADMIN:
        {
            [TTDebugLog log:@"TTLockLog#####park lock,CHECK ADMIN success#####"  ];
            //发送获取锁状态指令，这里要先保存一下随机数
            
            Byte bytes[10];//lock发送过来的开锁密码
            
            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:10];
            
            self.passwordFromLock = [TTDataTransformUtil getLongForBytes:bytes];
            if (self.m_currentOperatorState == Current_Operator_State_Calibation_ParkLock_Time) {
                [TTCommandUtils park_lock_v1_calibation_timeWithReferenceTime:[TTDateHelper formateTimestamp:self.myTime format:@"yy-MM-dd-HH-mm" timezoneRawOffset:self.lockDataModel.timezoneRawOffset]];
            }else{
                [TTCommandUtils park_lock_v1_get_lock_stateWith];//获取锁状态
            }
            
            break;
        }
            
        case PARK_LOCK_V1_COMM_CHECK_USER_TIME:
        {
            [TTDebugLog log:@"TTLockLog#####park lock,CHECK USER success#####"  ];
            
            Byte bytes[10];//lock发送过来的开锁密码
            
            [TTDataTransformUtil arrayCopyWithSrc:data srcPos:2 dst:bytes dstPos:0 length:10];
            self.passwordFromLock = [TTDataTransformUtil getLongForBytes:bytes];
            
            [TTCommandUtils park_lock_v1_get_lock_stateWith];//获取锁状态
            
            break;
        }
        case PARK_LOCK_V1_COMM_GET_STATE:
        {
            [TTDebugLog log:@"TTLockLog#####park lock ,Get the lock up or down#####"  ];
            long long passwordLocal =self.lockDataModel.lockKey.longLongValue;
            if (self.m_currentOperatorState == Current_Operator_State_Close_lock_Admin_And_EKey ) {
                //
                [TTCommandUtils park_lock_v1_unlock_psFromLock:self.passwordFromLock psLocal:passwordLocal flag:@"1" ];
                //
            }
            break;
        }
            //升 和降 是反的  这个没有问题
        case PARK_LOCK_V1_COMM_UNLOCK:
        {
            if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                [self.delegate onControlLockWithLockTime:0 electricQuantity:[self getPower] uniqueId:self.uniqueid];
            }
            
            
            if (self.m_currentOperatorState ==  Current_Operator_State_Unlock_Admin) {
                [TTCommandUtils park_lock_v1_calibation_timeWithReferenceTime:[TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm" timezoneRawOffset:-1]];
            }
            
            
        }break;
        case PARK_LOCK_V1_COMM_LOCK:
        {
            [TTDebugLog log:@"TTLockLog#####park lock, unlock success#####"  ];
            if ([self.delegate respondsToSelector:@selector(onControlLockWithLockTime:electricQuantity:uniqueId:)]) {
                [self.delegate onControlLockWithLockTime:0 electricQuantity:[self getPower] uniqueId:self.uniqueid];
            }
            
            if (self.m_currentOperatorState ==  Current_Operator_State_Unlock_Admin) {
                [TTCommandUtils park_lock_v1_calibation_timeWithReferenceTime:[TTDateHelper formateDate:[NSDate date] format:@"yy-MM-dd-HH-mm" timezoneRawOffset:-1]];
            }
        }  break;
            
        default:
            break;
    }
    
}



@end
