//
//  TTCenterManager+Common.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/16.
//  Copyright © 2019 wjj. All rights reserved.
//

#import "TTCenterManager+Common.h"
#import "TTSecurityUtil.h"
#import "TTHandleResponse.h"
#import "TTDebugLog.h"
#import "TTCommandUtils.h"
#import "TTDataTransformUtil.h"
#import "TTUtil.h"

@implementation TTCenterManager (Common)

- (void)onAddAdminWithCommand:(TTCommand*)command timestamp:(long long)timeStr pwdInfo:(NSString*)pwdInfo  Characteristic:(long long)characteristic deviceInfoDic:(NSMutableDictionary*)deviceInfoDic{
    
    if ([self.delegate respondsToSelector:@selector(onInitLockWithLockData:)]) {
        NSMutableDictionary *adminInfoDic = [[NSMutableDictionary alloc]init];
        adminInfoDic[@"lockName"] = self.m_lockName;
        adminInfoDic[@"lockMac"] = NOTNILSTRING(self.m_add_mac);
        adminInfoDic[@"lockKey"] = NOTNILSTRING( [TTSecurityUtil encodeLockKeyString:self.lockDataModel.lockKey]);
        adminInfoDic[@"lockFlagPos"] = @0;
        adminInfoDic[@"aesKeyStr"] = NOTNILSTRING([TTSecurityUtil encodeAeskey:self.lockDataModel.aesKeyStr]);
        
        NSMutableDictionary *lockVersionDic = [NSMutableDictionary new];
        lockVersionDic[@"protocolType"] = [NSString stringWithFormat:@"%d",command->protocolCategory];
        lockVersionDic[@"protocolVersion"] = [NSString stringWithFormat:@"%d",command->protocolVersion] ;
        lockVersionDic[@"scene"] = [NSString stringWithFormat:@"%d",command->applyCatagory];
        lockVersionDic[@"groupId"] = [NSString stringWithFormat:@"%d",[TTDataTransformUtil intFromHexBytes:command->applyID length:2]];
        lockVersionDic[@"orgId"] = [NSString stringWithFormat:@"%d",[TTDataTransformUtil intFromHexBytes:command->applyID2 length:2]];
        adminInfoDic[@"lockVersion"] = lockVersionDic;
        
        adminInfoDic[@"adminPwd"] = NOTNILSTRING( [TTSecurityUtil encodeAdminPSString: self.lockDataModel.adminPwd]);
        adminInfoDic[@"noKeyPwd"] = NOTNILSTRING(self.m_keyboard_password_admin);
        adminInfoDic[@"deletePwd"] = NOTNILSTRING(self.m_keyboard_delete_admin);
        adminInfoDic[@"pwdInfo"] = NOTNILSTRING(pwdInfo);
        adminInfoDic[@"timestamp"] = @(timeStr);
        adminInfoDic[@"pwdInfo"] = NOTNILSTRING(pwdInfo);
        adminInfoDic[@"specialValue"] = [NSNumber numberWithLongLong:characteristic];
        adminInfoDic[@"electricQuantity"] = [NSNumber numberWithInt:[self getPower]];
        adminInfoDic[@"timezoneRawOffset"] = [NSNumber numberWithInteger:[TTHandleResponse gettimezoneRawOffset]];
        
        if (deviceInfoDic != nil) {
            adminInfoDic[@"modelNum"] = deviceInfoDic[@"1"];
            adminInfoDic[@"hardwareRevision"] = deviceInfoDic[@"2"];
            adminInfoDic[@"firmwareRevision"] = deviceInfoDic[@"3"];
            if ([TTUtil lockSpecialValue:characteristic suportFunction:TTLockSpecialFunctionNB]) {
                adminInfoDic[@"nbOperator"] = deviceInfoDic[@"7"];
                adminInfoDic[@"nbNodeId"] = deviceInfoDic[@"8"];
                adminInfoDic[@"nbCardNumber"] = deviceInfoDic[@"9"];
                adminInfoDic[@"nbRssi"] = deviceInfoDic[@"10"];
            }
            
        }
        if (self.m_add_mac.length != 0) {
            NSString *lockMac = adminInfoDic[@"lockMac"];
            adminInfoDic[@"version"] = @"1.0";
            adminInfoDic[@"factoryDate"] = deviceInfoDic[@"4"];
            if ([adminInfoDic[@"factoryDate"] intValue] == 0 ) {
                adminInfoDic[@"factoryDate"] = @"19700101";
            }
            NSString *refStr = [NSString stringWithFormat:@"%@%@",[lockMac substringFromIndex:lockMac.length - 5],[adminInfoDic[@"factoryDate"] substringToIndex:8]];
            adminInfoDic[@"ref"] = NOTNILSTRING( [TTSecurityUtil encodeAdminPSString:refStr]);
        }
        
        [self.delegate onInitLockWithLockData:[TTDataTransformUtil convertToJsonData:adminInfoDic]];
        
    }
}

- (void)onTTErrorWithData:(Byte*)data version:(NSString *)version{
    
    if (!self.errorMsgArray) {
        self.errorMsgArray = [TTHandleResponse initErrorMsgArray];
    }
    NSUInteger commomerror = [TTDataTransformUtil intFromHexBytes:&data[2] length:1];
    int commomcommand =[TTDataTransformUtil intFromHexBytes:&data[0] length:1];
    if (self.m_currentOperatorState == Current_Operator_state_Modify_Keyboard_Password && commomcommand == 3) {
        self.modifyPwdError = commomerror;
        //如果是修改密码出了错 那就读锁的特征值
        [TTCommandUtils v3_get_device_characteristic_WithVersion:version];
    }else{
        //如果在这里 commomerror ==0  就当TTErrorFail，区分TTErrorHadReseted
        if (commomerror == 0 ) {
            commomerror = TTErrorFail;
        }
        [self onTTError:commomerror command:commomcommand];
    }
    
}
- (void)onTTError:(TTError)error command:(int)command {
    
    
    NSString *errorMsg = (error>=self.errorMsgArray.count?@"unknow error":self.errorMsgArray[error] );
    if (error == TTErrorNotSupportModifyPasscode) {
        errorMsg = TTErrorMessageNotSupportModifyPasscode;
    }
    [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####error: %@#####",errorMsg]   ];
    
    //   与锁交互发生错误，sdk里会重试一次
    if(self.isSendCommandByError == YES &&  self.m_currentOperatorState != Current_Operator_State_Add_Admin && ( error == TTErrorHadReseted || error == TTErrorCRCError)){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isSendCommandByError = NO;
            self.isFirstCommand = YES;
            [TTCommandUtils initialization_fetchLockDetail];
        });
        return;
    }
    if ([self.delegate respondsToSelector:@selector(TTError:command:errorMsg:)]) {
        [self.delegate TTError:error command:command  errorMsg:errorMsg];
    }
    
}


//获取操作记录的返回
- (void)onGetOperateLog:(BOOL)isFinish{
    
    //如果是读取全部操作记录，没读完的话，就当失败
    if (self.m_currentOperatorState == Current_Operator_State_Get_Total_Unlock_record && isFinish == NO) {
        if ([self.delegate respondsToSelector:@selector(TTError:command:errorMsg:)]) {
            [self.delegate TTError:TTErrorDisconnection command:0x25  errorMsg:TTErrorMessageDisconnection];
        }
        return;
    }
    
    NSString *jsonStr;
    if (self.lockOpenRecordArr.count == 0) {
        jsonStr = nil;
    }else{
        //数组转json
        jsonStr = [TTDataTransformUtil convertToJsonData:self.lockOpenRecordArr];
    }
    
    if (self.m_currentOperatorState == Current_Operator_State_get_keyboard_password_list) {
        if ([self.delegate respondsToSelector:@selector(onGetAllValidPasscodes:)]) {
            [self.delegate onGetAllValidPasscodes:jsonStr];
            self.lockOpenRecordArr = nil;
        }
    }
    if (self.m_currentOperatorState == Current_Operator_state_Fetch_IC_Data) {
        if ([self.delegate respondsToSelector:@selector(onGetAllValidICCards:)]) {
            [self.delegate onGetAllValidICCards:jsonStr];
            self.lockOpenRecordArr = nil;
        }
    }
    if (self.m_currentOperatorState == Current_Operator_state_Fetch_Fingerprint_Data) {
        if ([self.delegate respondsToSelector:@selector(onGetAllValidFingerprints:)]) {
            [self.delegate onGetAllValidFingerprints:jsonStr];
            self.lockOpenRecordArr = nil;
        }
    }
    if (self.m_currentOperatorState == Current_Operator_State_Unlock_record
        ||self.m_currentOperatorState == Current_Operator_State_Get_Total_Unlock_record) {
        if ([self.delegate respondsToSelector:@selector(onGetLog:)]) {
            [self.delegate onGetLog:jsonStr];
            self.lockOpenRecordArr = nil;
        }
    }
   
}
-(int)getPower{
    NSString *dianliang = [[NSUserDefaults standardUserDefaults] stringForKey:@"dianliang"];
    
    [TTDebugLog log:[NSString stringWithFormat:@"TTLockLog#####power:%@#####", dianliang]];
    return dianliang.intValue;
}

@end
