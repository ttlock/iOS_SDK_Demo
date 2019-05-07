//
//
//  Created by 谢元潮 on 14-4-25.
//  Copyright (c) 2014年 谢元潮. All rights reserved.
//


#import "TTLockApi.h"
#import "TTCommandUtils.h"
#import "TTGTMBase64.h"
#import "TTDebugLog.h"
#import "TTHandleResponse.h"
#import "TTDateHelper.h"
#import "TTGatewayDeal.h"
#import "TTCenterManager.h"
#import "TTDataTransformUtil.h"
#import "TTLockDataModel.h"

@interface TTLockApi ()

@property (nonatomic,strong) NSDictionary *lockVersion;
@property (nonatomic,assign) BOOL isAdmin;
@property (nonatomic,assign) long long userStartDate;
@property (nonatomic,assign) long long userEndDate;

@end

@implementation TTLockApi

-(id)initWithDelegate:(id<TTSDKDelegate>)TTDelegate;
{
    [TTLockApi sharedInstance];
    sciener.delegate = TTDelegate;
    [TTCenterManager sharedInstance] ;
    [TTCenterManager sharedInstance].delegate = TTDelegate;
    return sciener;
}

static TTLockApi *sciener;
+ (TTLockApi*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sciener = [[TTLockApi alloc] init];
        
    });
    return sciener;
}

- (void)setDelegate:(id<TTSDKDelegate>)delegate{
      _delegate = delegate;
     [TTCenterManager sharedInstance].delegate = delegate;
}
- (TTBluetoothState)state{

    return  (TTBluetoothState)[[TTCenterManager sharedInstance] manager].state;
}

- (BOOL)isScanning{
    
   if ([[UIDevice currentDevice]systemVersion].intValue >= 9.0) {
         return [[TTCenterManager sharedInstance] manager].isScanning;
   }
    printf("TTLockLog#####warning isScanning NS_AVAILABLE(NA, 9_0)#####");
    return YES;
  
}
-(void)startScanLock:(BOOL)isScanDuplicates{
    [[TTCenterManager sharedInstance]startScanLock:isScanDuplicates];
}

- (void)scanAllBluetoothDeviceNearby:(BOOL)isScanDuplicates{
      [[TTCenterManager sharedInstance]scanAllBluetoothDeviceNearby:isScanDuplicates];
}

- (void)scanSpecificServicesBluetoothDeviceWithServicesArray:(NSArray<NSString *>*)servicesArray isScanDuplicates:(BOOL)isScanDuplicates{
     [[TTCenterManager sharedInstance]scanSpecificServicesBluetoothDeviceWithServicesArray:servicesArray isScanDuplicates:isScanDuplicates];
}

/** Stop scanning
 */
-(void)stopScanLock{
     [[TTCenterManager sharedInstance]stopScanLock];
}


/**
 Connecting peripheral
 Connection attempts never time out .Pending attempts are cancelled automatically upon deallocation of <i>peripheral</i>, and explicitly via {@link cancelConnectPeripheralWithLockMac}.
 @param lockMac (If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see  onBTConnectSuccessWithPeripheral:lockName:
 */
- (void)connectPeripheralWithLockMac:(NSString *)lockMac{
     [[TTCenterManager sharedInstance]connectPeripheralWithLockMac:lockMac];
}
/**
 Cancel connection
 @param lockMac （If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see onBTDisconnectWithPeripheral:
 */
- (void)cancelConnectPeripheralWithLockMac:(NSString *)lockMac{
    [[TTCenterManager sharedInstance]cancelConnectPeripheralWithLockMac:lockMac];
    
}

-(void)connect:(CBPeripheral *)peripheral{
     [[TTCenterManager sharedInstance]connect:peripheral];
}

/** Cancel connection
 *
 *  @see onBTDisconnectWithPeripheral:
 */
-(void)disconnect:(CBPeripheral *)peripheral{
    [[TTCenterManager sharedInstance]disconnect:peripheral];
}

/****************************** 接口 *******************************/

#pragma mark ------- 锁指令调用接口
- (void)getOperationLogWithType:(TTOperateLogType)type lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = type == TTOperateLogTypeAll ? Current_Operator_State_Get_Total_Unlock_record : Current_Operator_State_Unlock_record;
    [TTCommandUtils initialization_fetchLockDetail];
}


- (void)getAllValidPasscodesWithLockData:(NSString *)lockData{
    
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_get_keyboard_password_list;
    [TTCommandUtils initialization_fetchLockDetail];
    
}
- (void)getPasscodeVerificationParamsWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Get_Password_Data;
    [TTCommandUtils initialization_fetchLockDetail];
}
/**获取锁版本
 */
-(void)getLockVersion
{
    TTLockDataModel *dataModel = [TTLockDataModel new];
    [TTCenterManager sharedInstance].lockDataModel = dataModel;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Get_Lock_Version;//设置流程状态---获取锁版本
    [TTCommandUtils initialization_fetchLockDetail];
    
}
-(void)getElectricQuantityWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Get_Electric_Quantity;
    [TTCommandUtils initialization_fetchLockDetail];

}

-(void)setNbServerInfoWithPortNumber:(NSString*)portNumber serverAddress:(NSString*)serverAddress lockData:(NSString *)lockData{
   
     [self handleLockData:lockData];
    [TTCenterManager sharedInstance].portNumber = portNumber;
    [TTCenterManager sharedInstance].serverAddress = serverAddress;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Set_NB_Server;//设置流程状态---eKey开锁
    [TTCommandUtils initialization_fetchLockDetail];
}

-(void)initLockWithInfoDic:(NSDictionary *)infoDic{
    //把对象先创建好
    TTLockDataModel *dataModel = [TTLockDataModel new];
    [TTCenterManager sharedInstance].lockDataModel = dataModel;
    
    [TTCenterManager sharedInstance].m_add_mac = infoDic[@"lockMac"];
    [TTCenterManager sharedInstance].hotelICKEY = [TTSecurityUtil decodeAeskey:infoDic[@"icKey"]];
    [TTCenterManager sharedInstance].hotelAESKEY = [TTSecurityUtil decodeAeskey:infoDic[@"aesKey"]];
    [TTCenterManager sharedInstance].hotelNumber = infoDic[@"hotelNumber"];
    [TTCenterManager sharedInstance].hotelBuildingNumber = infoDic[@"buildingNumber"];
    [TTCenterManager sharedInstance].hotelFloorNumber= infoDic[@"floorNumber"];
    
    NSDictionary *lockVersionDic = [TTDataTransformUtil convertDicFromStr:infoDic[@"lockVersion"]];
    int protocolCategory = [lockVersionDic[@"protocolType"] intValue];
    int protocolVersion =  [lockVersionDic[@"protocolVersion"] intValue];
    
    // 随机生成7位密码  管理员密码（车位锁没有这个功能）清空码（车位锁与三代锁没有这个功能）
    [TTCenterManager sharedInstance].m_keyboard_delete_admin = [TTDataTransformUtil getRandom7Length];
    [TTCenterManager sharedInstance].m_keyboard_password_admin =  [TTDataTransformUtil getRandom7Length];
    if (protocolCategory == 5 && protocolVersion == 3) {
    
        [TTCenterManager sharedInstance].m_keyboard_delete_admin = nil;
    }else if (protocolCategory == 10){
        [TTCenterManager sharedInstance].m_keyboard_delete_admin = nil;
        [TTCenterManager sharedInstance].m_keyboard_delete_admin = nil;
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Add_Admin;//设置流程状态---添加管理员key
    if (protocolCategory == Version_Lock_v3_AES && protocolVersion == 0x03 ) {
        [TTCommandUtils v3_fetchLockAesKeyWithSetClientPara:_setClientPara version:@"5.3.1.1.1" key:(Byte *)[[TTCommand getDefaultAesKey] bytes]];
        _setClientPara = nil;
    }
    else if (protocolCategory == Version_Lock_v4 && protocolVersion == 0x04 ) {
        [TTCommandUtils v2_aes_fetchLockAesKeyWithVersion:@"5.4.1.1.1" key:(Byte*)[AES_DEFAULT_KEY dataUsingEncoding:NSUTF8StringEncoding].bytes];

    }else{
        [TTCommandUtils initialization_fetchLockDetail];
    }

}
-(void)resetEkeyWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_reset_ekey;//设置流程状态
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)controlLockWithControlAction:(TTControlAction)controlAction lockData:(NSString *)lockData{
    
    [self handleLockData:lockData];
     [TTCenterManager sharedInstance].uniqueid = [[NSDate date] timeIntervalSince1970] *1000;
    if (self.userStartDate == 0 || self.isAdmin == YES) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
        
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:self.userStartDate/1000] ;
    }
    if (self.userEndDate == 0 || self.isAdmin == YES) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate = [NSDate dateWithTimeIntervalSince1970:self.userEndDate/1000] ;;
    }
    //遥控设备 卷闸门
    if ([self.lockVersion[@"protocolType"] intValue] == 5
        && [self.lockVersion[@"protocolVersion"] intValue] == 3
        && [self.lockVersion[@"scene"] intValue] == RemoteControlFourButtonType) {
        [TTCenterManager sharedInstance].lockingTime = controlAction;
        [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Modify_Remote_Control;
        if ([TTCenterManager sharedInstance].passwordFromLock != 0) {
            NSString *version ;
            [TTCommandUtils click_Remote_Control_with_psFromLock:[TTCenterManager sharedInstance].passwordFromLock psLocal:[TTCenterManager sharedInstance].passwordLocal uniqueid:[TTCenterManager sharedInstance].uniqueid buttonValue:controlAction version:version key:(Byte*)[TTCenterManager sharedInstance].lockDataModel.aesKeyStr.bytes];
            return;
            
        }
        [TTCommandUtils initialization_fetchLockDetail];
        return;
    }
    
    if (controlAction == TTControlActionUnlock) {
        //管理员
        if(self.isAdmin){
            [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Unlock_Admin;//设置流程状态---管理员开锁
            [TTCommandUtils initialization_fetchLockDetail];
            return;
        }
        [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Unlock_EKey;//设置流程状态---eKey开锁
        [TTCommandUtils initialization_fetchLockDetail];
        return;
    }
    if (controlAction == TTControlActionLock) {
        //闭锁
        [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Close_lock_Admin_And_EKey;//设置流程状态---设置admin键盘密码
        [TTCommandUtils initialization_fetchLockDetail];
        return;
    }

}


/**设置管理员的键盘密码
 */
-(void)modifyAdminPasscode:(NSString*)passcode
                  lockData:(NSString *)lockData;
{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboard_password_admin = passcode;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Set_Keyboard_password;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];
    
}

/**设置管理员的删除密码
 */
-(void)setAdminErasePasscode:(NSString*)passcode
                    lockData:(NSString *)lockData;
{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboard_password_admin = passcode;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Set_Admin_delete_ps;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];

}

-(void)setLockTimeWithTimestamp:(long long)timestamp lockData:(NSString *)lockData;{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].myTime = timestamp;
    if ([self.lockVersion[@"protocolType"] intValue] == 10) {
        printf("TTLockLog#####ERROR:Parking lock does not support the calibration Lock Clock#####");
        return;
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Calibation_Time;//校准时间
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getLockTimeWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Get_lock_time;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];
}

-(void)resetPasscodeWithLockData:(NSString *)lockData
{
    //传0 锁会有默认值
    [TTCenterManager sharedInstance].validPsNumber = 0;
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Init_900_ps;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];
  
}

- (void)createCustomPasscode:(NSString *)passcode startDate:(long long)startDate endDate:(long long)endDate lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboardPs = passcode;
    [TTCenterManager sharedInstance].m_psType = TTPasscodeTypePeriod;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Add_Onepsw;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];
    
}

//修改密码
- (void)modifyPasscodeWithCurrentCode:(NSString *)currentCode
                         originalCode:(NSString *)originalCode
                            startDate:(long long)startDate
                              endDate:(long long)endDate
                             lockData:(NSString *)lockData
{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboardPs = originalCode;
    [TTCenterManager sharedInstance].m_newKeyboardPs = currentCode;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Modify_Keyboard_Password;//设置流程状态---设置admin键盘密码
     [TTCommandUtils initialization_fetchLockDetail];
    
}
- (void)recoverPasscodeWithPasscodeType:(TTPasscodeType)passcodeType
                              cycleType:(NSInteger)cycleType
                            currentCode:(NSString *)currentCode
                           originalCode:(NSString *)originalCode
                              startDate:(long long)startDate
                                endDate:(long long)endDate
                               lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboardPs = originalCode;
    [TTCenterManager sharedInstance].m_newKeyboardPs = currentCode;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    [TTCenterManager sharedInstance].m_endDate = nil;
    if (passcodeType == TTPasscodeTypePeriod) {
        if (endDate == 0) {
            [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
        }else{
            [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
        }
    }
    [TTCenterManager sharedInstance].m_psType = passcodeType;
    [TTCenterManager sharedInstance].m_cycleType = cycleType;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Recover_Keyboard_Password;//设置流程状态---设置admin键盘密码
    [TTCommandUtils initialization_fetchLockDetail];
}

-(void)deletePasscode:(NSString *)passcode
             lockData:(NSString *)lockData{
    
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboardPs = passcode;
    [TTCenterManager sharedInstance].m_psType = TTPasscodeTypePermanent;//任意值
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_del_keyboard_password;
     [TTCommandUtils initialization_fetchLockDetail];
   
}

-(void)resetLockWithLockData:(NSString *)lockData{
    
     [self handleLockData:lockData];
     [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Restore_factory_settings;//设置流程状态---恢复出厂设置
     [TTCommandUtils initialization_fetchLockDetail];
   
}
- (void)getLockSpecialValueWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_get_device_characteristic;//设置流程状态---获取特征值
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)addICCardWithStartDate:(long long)startDate
                       endDate:(long long)endDate
                      lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_ICNumber = nil;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_add_IC;//设置流程状态---添加
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)modifyICCardValidityPeriodWithStartDate:(long long)startDate
                                        endDate:(long long)endDate
                                        cardNum:(NSString*)cardNum
                                       lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    
    [TTCenterManager sharedInstance].m_ICNumber = cardNum;
    
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }

    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Modify_IC;//设置流程状态---修改
    
    [TTCommandUtils initialization_fetchLockDetail];
}
/**  @see onDeleteICCard */
- (void)deleteICCardWithCardNum:(NSString*)cardNum
                       lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    
    [TTCenterManager sharedInstance]. m_ICNumber = cardNum;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_delete_IC;//设置流程状态---删除
    
    [TTCommandUtils initialization_fetchLockDetail];
}
/**  @see onClearICCard */
- (void)clearAllICCardsWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_clear_IC;//设置流程状态---清空
    
    [TTCommandUtils initialization_fetchLockDetail];
}
/**  @see onGetAllValidICCards: */
- (void)getAllValidICCardsWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Fetch_IC_Data;//设置流程状态---查询
    
    [TTCommandUtils initialization_fetchLockDetail];
}
//recoverICCard
- (void)recoverICCardWithStartDate:(long long)startDate
                           endDate:(long long)endDate
                           cardNum:(NSString*)cardNum
                          lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    
    [TTCenterManager sharedInstance].m_ICNumber = cardNum;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Recover_IC;
    
    [TTCommandUtils initialization_fetchLockDetail];
    
}
- (void)addFingerprintWithStartDate:(long long)startDate
                            endDate:(long long)endDate
                           lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_fingerprintNum = nil;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_add_Fingerprint;//设置流程状态---添加
     [TTCommandUtils initialization_fetchLockDetail];
}
- (void)modifyFingerprintValidityPeriodWithStartDate:(long long)startDate
                                             endDate:(long long)endDate
                                      fingerprintNum:(NSString*)fingerprintNum
                                            lockData:(NSString *)lockData{
     [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_fingerprintNum = fingerprintNum;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
        [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
        [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Modify_Fingerprint;//设置流程状态---修改
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)deleteFingerprintWithFingerprintNum:(NSString*)fingerprintNum
                                   lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_fingerprintNum = fingerprintNum;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_delete_Fingerprint;//设置流程状态---删除
    [TTCommandUtils initialization_fetchLockDetail];
}

- (void)recoverFingerprintWithStartDate:(long long)startDate
                                endDate:(long long)endDate
                         fingerprintNum:(NSString*)fingerprintNum
                               lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_fingerprintNum = fingerprintNum;
    if (startDate ==0 ) {
        [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
         [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
    }
    if (endDate == 0) {
          [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
    }else{
         [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
    }
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_State_Recover_Fingerprint;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)clearAllFingerprintsWithLockData:(NSString *)lockData{
      [self handleLockData:lockData];
      [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_clear_Fingerprint;//设置流程状态---清空
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getAllValidFingerprintsWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Fetch_Fingerprint_Data;//设置流程状态---查询
    [TTCommandUtils initialization_fetchLockDetail];
    
}
- (void)writeFingerprintData:(NSString *)fingerprintData
       tempFingerprintNumber:(NSString*)tempFingerprintNumber
                   startDate:(long long)startDate
                     endDate:(long long)endDate
                    lockData:(NSString *)lockData{
    
        [self handleLockData:lockData];
        [TTCenterManager sharedInstance].m_fingerprintData = fingerprintData;
        [TTCenterManager sharedInstance].m_tempFingerprintNumber = tempFingerprintNumber;
        if (startDate ==0 ) {
            [TTCenterManager sharedInstance].m_startDate = [TTDateHelper getPermanentStartDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
        }else{
            [TTCenterManager sharedInstance].m_startDate = [NSDate dateWithTimeIntervalSince1970:startDate/1000];
        }
        if (endDate == 0) {
            [TTCenterManager sharedInstance].m_endDate = [TTDateHelper getPermanentEndDateWithtimezoneRawOffset:[TTCenterManager sharedInstance].lockDataModel.timezoneRawOffset];
        }else{
            [TTCenterManager sharedInstance].m_endDate =  [NSDate dateWithTimeIntervalSince1970:endDate/1000];
        }
       [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Recover_Fingerprint_Data;
       [TTCommandUtils initialization_fetchLockDetail];
}
//onQueryPassageModeWithRecord
- (void)queryPassageModeWithLockData:(NSString *)lockData{
    
    [self handleLockData:lockData];
   [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Query_PassageMode;
    [TTCommandUtils initialization_fetchLockDetail];
    
}
- (void)configPassageModeWithType:(TTPassageModeType)type weekDays:(NSArray*)weekDays month:(int)month startDate:(int)startDate endDate:(int)endDate lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    if (type == TTPassageModeTypeWeek && weekDays.count == 0) {
        printf("weekDays can not be null");
        return;
    }
    [TTCenterManager sharedInstance].m_weekArr = [NSMutableArray arrayWithArray:weekDays];
    if (type == TTPassageModeTypeWeek) {
        //服务端周日是1 锁里周日是7 所以要改一下
        for (int i = 0 ; i < [TTCenterManager sharedInstance].m_weekArr.count; i++) {
            if ([[TTCenterManager sharedInstance].m_weekArr[i] intValue] == 1) {
                [[TTCenterManager sharedInstance].m_weekArr replaceObjectAtIndex:i withObject:@(7)];
            }else if( [[TTCenterManager sharedInstance].m_weekArr[i] intValue] != 0 ) {
                [[TTCenterManager sharedInstance].m_weekArr replaceObjectAtIndex:i withObject:@([[TTCenterManager sharedInstance].m_weekArr[i] intValue] - 1)];
            }
        }
    }
    [TTCenterManager sharedInstance].m_monthStr = month;
    if (startDate == 0 && endDate == 0) {
        [TTCenterManager sharedInstance].m_passageModeIsAllday = YES;
    }else{
        [TTCenterManager sharedInstance].m_passageModeIsAllday = NO;
    }
    [TTCenterManager sharedInstance].m_startMinutes = startDate;
    [TTCenterManager sharedInstance].m_endMinutes = endDate;
    [TTCenterManager sharedInstance].m_passageModeType = type;
    
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_AddOrModify_PassageMode;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)deletePassageModeWithType:(TTPassageModeType)type weekDays:(NSArray*)weekDays day:(int)day month:(int)month lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    if (type == TTPassageModeTypeWeek && weekDays.count == 0) {
        printf("when type == TTPassageModeTypeWeek , weekDays can not be null");
        return;
    }
    [TTCenterManager sharedInstance].m_weekArr = [NSMutableArray arrayWithArray:weekDays];
    //服务端周日是1 锁里周日是7 所以要改一下
    if (type == TTPassageModeTypeWeek) {
        for (int i = 0 ; i < [TTCenterManager sharedInstance].m_weekArr.count; i++) {
            if ([[TTCenterManager sharedInstance].m_weekArr[i] intValue] == 1) {
                [[TTCenterManager sharedInstance].m_weekArr replaceObjectAtIndex:i withObject:@(7)];
            }else if( [[TTCenterManager sharedInstance].m_weekArr[i] intValue] != 0 ) {
                [[TTCenterManager sharedInstance].m_weekArr replaceObjectAtIndex:i withObject:@([[TTCenterManager sharedInstance].m_weekArr[i] intValue] - 1)];
            }
        }
    }
    
    [TTCenterManager sharedInstance].m_monthStr = month;
    [TTCenterManager sharedInstance].m_passageModeType = type;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Delete_PassageMode;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)clearPassageModeWithLockData:(NSString *)lockData{
     [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Clean_PassageMode;
    [TTCommandUtils initialization_fetchLockDetail];
}

- (void)setLockWristbandKey:(NSString*)wristbandKey keyboardPassword:(NSString*)keyboardPassword lockData:(NSString *)lockData{

    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].m_keyboard_password_admin = keyboardPassword;
    [TTCenterManager sharedInstance].bongKey = wristbandKey;
    [TTCenterManager sharedInstance].m_currentOperatorState = Current_Operator_state_Set_Lock_BongKey;//设置流程状态---获取特征值
     [TTCommandUtils initialization_fetchLockDetail];
    
    
}
- (void)setWristbandKey:(NSString*)wristbandKey isOpen:(BOOL)isOpen{

     [TTCenterManager sharedInstance].bongOperateType = 1;
    [TTCommandUtils writeDataToBongWithKey:wristbandKey isOpen:isOpen p:[[TTCenterManager sharedInstance] activePeripheral]];
    
}
- (void)setWristbandRssi:(int)rssi{

   [TTCenterManager sharedInstance].bongOperateType = 2;
    int absrssi = abs(rssi);
    [TTCommandUtils writeDataToBongRssi:absrssi p:[[TTCenterManager sharedInstance] activePeripheral]];
    
}
- (void)setAutomaticLockingPeriodWithTime:(int)time
                                 lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].lockingTime = time;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Modify_lockingTime;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getAutomaticLockingPeriodWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Fetch_lockingTime_Data;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)operateDoorSensorLockingWithType:(TTOprationType)type isOn:(BOOL)isOn lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    if (type == TTOprationTypeQuery) {
       [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Fetch_DoorSensor_locking;
    }else if(type == TTOprationTypeModify) {
        [TTCenterManager sharedInstance].lockingTime = isOn;
       [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Modify_DoorSensor_locking;
    }
    [TTCommandUtils initialization_fetchLockDetail];
   
}
- (void)setAudioSwitchState:(BOOL)enable lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].lockingTime = enable;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Modify_Audio_Switch ;
    [TTCommandUtils initialization_fetchLockDetail];
}

- (void)getAudioSwitchStateWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Query_Audio_Switch ;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)setRemoteUnlockSwitchState:(BOOL)enable lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].lockingTime = enable;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Modify_Remote_Unlock ;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getRemoteUnlockSwitchStateWithLockData:(NSString *)lockData{
     [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Fetch_Remote_Unlock ;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)setPasscodeVisibleSwitchState:(BOOL)visible lockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].bongOperateType = 2;
    [TTCenterManager sharedInstance].lockingTime = visible;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getPasscodeVisibleSwithStateWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance].bongOperateType = 1;
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL;
    [TTCommandUtils initialization_fetchLockDetail];
}

-(void)getAdminPasscodeWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_get_admin_passcode;
    [TTCommandUtils initialization_fetchLockDetail];
}
- (void)getLockSystemInfoWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
   [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_get_deviceInfo;
   [TTCenterManager sharedInstance].deviceInfoDic = [[NSMutableDictionary alloc]init];
    [TTCenterManager sharedInstance].deviceInfoType = TTDeviceInfoTypeOfProductionModel;
    [TTCommandUtils initialization_fetchLockDetail];
   
}
- (void)enterUpgradeModeWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_Upgrade_Firmware;
    [TTCommandUtils initialization_fetchLockDetail];
}


/**
 * 设置或者查询门锁的硬件参数 AT指令
 */
- (void)setLockName:(NSString *)lockName lockData:(NSString *)lockData{
    if ([TTDataTransformUtil convertToByte:lockName] > 15) {
        printf("TTLockLog#####error：The name is more than 15 bytes#####");
        return;
    }
     [self handleLockData:lockData];
    [TTCenterManager sharedInstance].ATCommand = [NSString stringWithFormat:@"%@%@",@"AT+NAME=",lockName];
   [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_state_AT_COMMADN;
    [TTCommandUtils initialization_fetchLockDetail];
   
}
- (void)getLockStatusWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
    [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Get_Lock_Switch_State;
    [TTCommandUtils v3_getLockSwitchState];
}
- (void)getDoorSensorStateWithLockData:(NSString *)lockData{
    [self handleLockData:lockData];
   [TTCenterManager sharedInstance]. m_currentOperatorState = Current_Operator_State_Get_Door_Sensor_State;
    [TTCommandUtils v3_getLockSwitchState];
   
}

//    Base64.base64ToByteArray(encryptedStr)，解密出来的byteArray,后六位为lockMac地址的byte形式，
//    去除后6位后再AES解密，解密密钥为：lockMac去除第10个字符后的字符串，比如lockMac = "aa:aa:aa:22:22:22"，那解密密钥为“aa:aa:aa:2:22:22”
-(void)handleLockData:(NSString *)lockData{
   TTLockDataModel *dataModel = [TTHandleResponse getLockDataModel:lockData];
    [TTCenterManager sharedInstance].lockDataModel = dataModel;
    self.userStartDate = dataModel.startDate;
    self.userEndDate = dataModel.endDate;
    self.isAdmin = dataModel.isAdmin;
    self.lockVersion = dataModel.lockVersion;
}

@end
