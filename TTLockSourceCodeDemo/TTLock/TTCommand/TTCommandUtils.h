//
//  CommandUtils.h
//  BTstackCocoa
//
//  Created by wan on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "TTMacros.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TTCommandUtils : NSObject

//当前操作
typedef NS_ENUM(NSInteger, CurrentOperatorState)
{
    Current_Operator_State_Normal = 0,
    
    Current_Operator_State_Add_Admin,                   //添加管理员
    Current_Operator_State_Get_Lock_Version,            //获取锁协议版本
    Current_Operator_State_Unlock_Admin,                //管理员开门
    Current_Operator_State_Unlock_EKey,                 //EKey开门
    Current_Operator_State_Set_Keyboard_password,       //设置管理员无钥匙密码
    Current_Operator_State_Set_Keyboard_password_user,  //设置普通用户键盘秘密
    Current_Operator_State_clear_Keyboard_password,     //清空键盘密码
    Current_Operator_State_get_keyboard_password_list,  //获取键盘密码列表
    Current_Operator_State_del_keyboard_password,       //删除键盘密码
    Current_Operator_State_Calibation_Time,             //校准时间
    Current_Operator_State_Init_900_ps,                 //设置900密码
    Current_Operator_State_Set_Admin_delete_ps,         //设置管理员删除密码
    Current_Operator_State_Add_Onepsw,                  //添加单个键盘密码
    Current_Operator_State_Unlock_record,               //获取开锁记录
    Current_Operator_State_Restore_factory_settings,    //恢复出厂设置
    Current_Operator_state_Get_lock_time,               //回去锁时间
    Current_Operator_state_Modify_Keyboard_Password,    //修改密码
    Current_Operator_state_set_lock_name,               //设置锁名
    Current_Operator_state_reset_ekey,                  //重置电子钥匙
    Current_Operator_state_get_device_characteristic,   //获取设备特征值
    Current_Operator_state_add_IC,                      //添加IC卡
    Current_Operator_state_clear_IC,                    //清空IC卡
    Current_Operator_state_delete_IC,                   //删除IC卡
    Current_Operator_state_Modify_IC,                   //修改IC卡
    Current_Operator_state_Fetch_IC_Data,               //读取IC数据
    Current_Operator_state_Set_Lock_BongKey,            //设置锁里的手环密码
    Current_Operator_state_AT_COMMADN,                  //AT指令
    Current_Operator_state_add_Fingerprint,             //添加指纹
    Current_Operator_state_clear_Fingerprint,           //清空指纹
    Current_Operator_state_delete_Fingerprint,          //删除指纹
    Current_Operator_state_Modify_Fingerprint,          //修改指纹
    Current_Operator_state_Fetch_Fingerprint_Data,      //读取指纹数据
    Current_Operator_state_Fetch_lockingTime_Data,      //查询闭锁时间
    Current_Operator_state_Modify_lockingTime,          //修改闭锁时间
    Current_Operator_state_get_deviceInfo,                   //读取设备的信息
    Current_Operator_state_Upgrade_Firmware,                 //固件升级
    Current_Operator_State_Get_Lock_Switch_State,            //查询锁开关状态
    Current_Operator_State_Close_lock_Admin_And_EKey,        //管理员和普通用户关(闭)锁指令
    Current_Operator_State_PASSWORD_DISPLAY_HIDE_CONTROL,    //是否在屏幕上显示输入的密码
    Current_Operator_State_Calibation_ParkLock_Time,         //校准时间
    Current_Operator_State_Recover_IC,                        //恢复IC卡
    Current_Operator_State_Recover_Fingerprint,               //恢复指纹
    Current_Operator_State_Recover_Keyboard_Password,         //恢复密码
    Current_Operator_State_Get_Password_Data,                 //读取新密码方案参数
    Current_Operator_State_Get_Total_Unlock_record,           //获取全部开锁记录
    Current_Operator_state_Fetch_DoorSensor_locking,          //查询门磁闭锁
    Current_Operator_state_Modify_DoorSensor_locking,         //修改门磁闭锁
    Current_Operator_State_Get_Door_Sensor_State,            //查询门磁状态
    Current_Operator_state_Fetch_Remote_Unlock,              //查询远程开门开关
    Current_Operator_state_Modify_Remote_Unlock,             //修改远程开门开关
    Current_Operator_state_Get_Electric_Quantity,            //获取锁电量
    Current_Operator_state_Query_Audio_Switch,
    Current_Operator_state_Modify_Audio_Switch,
    Current_Operator_state_Query_Remote_Control,
    Current_Operator_state_Modify_Remote_Control,
    Current_Operator_state_Set_NB_Server,
    Current_Operator_state_get_admin_passcode,
    Current_Operator_State_Recover_Fingerprint_Data,           //恢复指纹模块数据包
    Current_Operator_State_Query_PassageMode,                 //查询常开模式
    Current_Operator_State_AddOrModify_PassageMode,           //添加或修改常开模式
    Current_Operator_State_Delete_PassageMode,                //删除常开模式
    Current_Operator_State_Clean_PassageMode,                 //清空常开模式
};

#pragma mark ------ 通用
/**T指令 可获取锁版本*/
+(void)initialization_fetchLockDetail;

//读取开锁记录  type 1 读取操作记录  2 读取IC卡记录 //3 读取指纹记录 4 开锁密码
+(void)lock_fetch_record_num:(int)num
                        type:(int)type
                     version:(NSString*)version
                         key:(Byte*)pwdkey;


// 设备参数设置/查询
+ (void)setOrQuery_Para:(NSString*)para
       version:(NSString*)version
                    key:(Byte*)pwdkey ;
/** 添加单个键盘密码 */
+(void)add_onepassword_oprationType:(int)oprationType
                          limitType:(TTPasscodeType)limitType
                           password:(NSString*)password
                          startDate:(NSString*)startDate
                            endDate:(NSString*)endDate
                            version:(NSString*)version
                                key:(Byte*)pwdkey;

//删除单个键盘密码
+(void)delete_onepassword_oprationType:(int)oprationType
                                limitType:(int)limitType
                                 password:(NSString*)password
                         version:(NSString*)version  
                                      key:(Byte*)pwdkey;

//清空键盘密码
+(void)clear_allpassword_oprationType:(int)oprationType
                                adminPwd:(NSString*)adminPwd
                        version:(NSString*)version
                                     key:(Byte*)pwdkey;

#pragma mark ---- 5 1 Lock

/**添加管理员
 */
+(void)v4_add_admin_with_ps:(NSString*)password
                     number:(NSString*)unlocknumber ;

/**管理员身份检测
 */
+(void)v4_check_admin_with_ps:(NSString*)password flag:(int)flag ;

/**普通用户事件检测
 */
+(void)v4_check_user_startDate:(NSString*)startDate endDate:(NSString*)endDate flag:(int)flag ;

/**设置管理员密码。管理员密码：7到10位
 */
+(void)v4_set_admin_nokey_ps:(NSString*)password ;

/**设置管理员删除密码：7到10位
 */
+(void)v4_set_admin_delete_ps:(NSString*)password ;

/**设置删除有效密码指令  密码：7到10位
 */
+(void)v4_set_admin_del_ps:(NSString*)password ;

/**校准时间1
 */
+(void)v4_calibation_timeWithVersion:(NSString*)version  referenceTime:(NSString*)referenceTime;

/**开锁指令
 */
+(void)v4_unlock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString*)flag ;


/**初始化密码池，每次发送一条
 */
+(void)v4_init_ps_pool:(NSArray*)passwords pos:(int)pos ;

/**同步有效密码序列
 */
+(void)v4_update_ps_serial_number:(Byte*)serialNumberBytes ;//8个一起发送，

+(void)v4_update_ps_serial_number:(Byte*)serialNumberBytes indexLen:(int)indexlen group:(int)group ;//1个个发送

//初始化键盘密码约定数和映射数
+ (void)v4_initializ_password_code:(NSArray *)codeArr
                         secretKey:(NSArray *)secretKey
                           version:(NSString*)version
                              year:(NSString*)year
                               key:(Byte*)pwdkey ;

#pragma mark ---- 5 4 场景一 场景二
//获取aes key指令
+(void)v2_aes_fetchLockAesKeyWithVersion:(NSString*)version  
                                              key:(Byte*)pwdkey ;
//添加管理员指令
+(void)v2_aes_add_admin_with_ps:(NSString*)password
                         number:(NSString*)unlocknumber
               version:(NSString*)version
                            key:(Byte*)pwdkey ;

//检测管理员身份指令
+(void)v2_aes_check_admin_with_ps:(NSString*)password
                             flag:(int)flag
                version:(NSString*)version  
                              key:(Byte*)pwdkey ;
//普通用户时效性检测
+(void)v2_aes_check_user_with_startDate:(NSString*)startDate
                                endDate:(NSString*)endDate
                                   flag:(int)flag
                       version:(NSString*)version
                                    key:(Byte*)pwdkey ;

// 校准时间2
+(void)v2_aes_calibation_time_with_version:(NSString*)version  
                                      referenceTime:(NSString *)referenceTime
                                                key:(Byte*)pwdkey ;
//开锁指令
+(void)v2_aes_unlock_with_psFromLock:(long long)psFromLock
                             psLocal:(long long)psLocal
                                flag:(NSString*)flag
                             version:(NSString*)version
                                 key:(Byte*)pwdkey ;

+(void)v2_aes_set_admin_nokey_ps:(NSString*)password
                version:(NSString*)version
                             key:(Byte*)pwdkey;

/**初始化键盘密码
 */
+(void)v2_aes_init_ps_pool_bytes:(Byte*)bytes
                          length:(int)length
                             pos:(int)pos
                version:(NSString*)version
                             key:(Byte*)pwdkey;

/**设置删除键盘密码
 */
+(void)v2_aes_del_kbpwd:(NSString*)passwrod
       version:(NSString*)version
                    key:(Byte*)pwdkey;


#pragma mark ---- 5 3 三代锁
+ (void)v3_getLockSwitchState;
//获取aes key指令
+(void)v3_fetchLockAesKeyWithSetClientPara:(NSString*)setClientPara
                          version:(NSString*)version
                                          key:(Byte*)pwdkey ;
//重置lock指令
+(void)v3_resetLockWithversion:(NSString*)version
                                    key:(Byte*)pwdkey ;
//添加管理员指令
+(void)v3_add_admin_with_ps:(NSString*)password
                     number:(NSString*)unlocknumber
           version:(NSString*)version
                        key:(Byte*)pwdkey ;

//检测管理员身份指令
+(void)v3_check_admin_with_ps:(NSString*)password
                         flag:(int)flag
                       userID:(NSString *)userid
             version:(NSString*)version
                          key:(Byte*)pwdkey ;

//设置管理员密码指令
+(void)v3_set_admin_nokey_ps:(NSString*)password
           version:(NSString*)version
                         key:(Byte*)pwdkey ;

// 校准时间2
+(void)v3_calibation_time_with_version:(NSString*)version
                                   referenceTime:(NSString *)referenceTime
                                            key:(Byte*)pwdkey ;


//普通用户时效性检测
+(void)v3_check_user_with_startDate:(NSString*)startDate
                            endDate:(NSString*)endDate
                               flag:(int)flag
                             userID:(NSString *)userid
                  version:(NSString*)version
                                key:(Byte*)pwdkey ;
//获取锁时间
+ (void)v3_get_lockTimeWithversion:(NSString*)version
                                        key:(Byte*)pwdkey ;
//开锁指令
+(void)v3_unlock_with_psFromLock:(long long)psFromLock
                         psLocal:(long long)psLocal
                        uniqueid:(long long)uniqueid
                version:(NSString*)version
                             key:(Byte*)pwdkey;
//闭(guan)锁
+(void)v3_lock_with_psFromLock:(long long)psFromLock
                       psLocal:(long long)psLocal
                      uniqueid:(long long)uniqueid
                       version:(NSString*)version
                           key:(Byte*)pwdkey;

//随机数验证
+(void)v3_check_random_with_psFromLock:(long long)psFromLock
                               psLocal:(long long)psLocal
                               version:(NSString*)version
                                   key:(Byte*)pwdkey ;

//重命名蓝牙
+(void)v3_rename:(NSString*)name
WithVersion:(NSString*)version  
             key:(Byte*)pwdkey ;

//设备参数设置/查询
+(void)v3_device_parameter_settings_ATCommand:(NSString *)ATCommand
                             version:(NSString*)version
                                          key:(Byte*)pwdkey ;

//修改或恢复密码
+(void)v3_modify_Recover_keyboard_password_operateType:(TTOprationType)operateType
                                          keyboardType:(TTPasscodeType)keyboardType
                                             cycleType:(NSInteger)cycleType
                                           oldPassword:(NSString *)oldPassword
                                           newPassword:(NSString *)newPassword
                                             startDate:(NSDate *)startDate
                                               endDate:(NSDate*)endDate
                                     timezoneRawOffset:(long)timezoneRawOffset
                                               version:(NSString*)version
                                                   key:(Byte*)pwdkey;

//修改锁名
+(void)v3_set_lock_name_name:(NSString *)name
           version:(NSString*)version
                         key:(Byte*)pwdkey ;

//设置同时有效密码数
+(void)v3_set_max_number_of_keyboard_password_number:(int)number
                                    version:(NSString*)version
                                                 key:(Byte*)pwdkey ;


//删除键盘密码
+(void)v3_del_kbpwd:(NSString*)passwrod
             psType:(int)type
     version:(NSString*)version
                key:(Byte*)pwdkey ;

//清空键盘密码
+(void)v3_clear_kbpwd_WithVersion:(NSString*)version key:(Byte*)pwdkey  ;

//获取特征值
+(void)v3_get_device_characteristic_WithVersion:(NSString*)version  ;
/**
 *  恢复出厂设置
 *
 *  @param serviceUUID        serviceUUID description
 *  @param characteristicUUID characteristicUUID description
 *  @param peripheral         peripheral description
 */
+(void)v3_lock_v1_reset_version:(NSString*)version
                                     key:(Byte*)pwdkey;

//添加锁管理员完成通知
+(void)v3_lock_v1_notify_addAdmin_success_version:(NSString*)version
                                                       key:(Byte*)pwdkey ;



#pragma mark --- 车位锁
//PARK lock v1 在v4.1版本lock的基础上，增加以下两点功能
//1，读取lock当前状态
//2，增加关门指令
//3，去除键盘密码功能

+(void)park_lock_v1_check_user_startDate:(NSString*)startDate endDate:(NSString*)endDate ;

+(void)park_lock_v1_calibation_timeWithReferenceTime:(NSString *)referenceTime ;

+(void)park_lock_v1_unlock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString*)flag ;

+(void)park_lock_v1_lock_psFromLock:(long long)psFromLock psLocal:(long long)psLocal flag:(NSString *)flag ;

+(void)park_lock_v1_check_admin_with_ps:(NSString*)password ;

+(void)park_lock_v1_add_admin_with_ps:(NSString*)password number:(NSString*)unlocknumber ;

+(void)park_lock_v1_reset_lockWith;

+(void)park_lock_v1_get_lock_stateWith;

+(void)park_lock_v1_rename:(Byte*)nameBytes length:(NSUInteger)length ;

+(void)park_lock_v1_warn_recordWith;//地锁被人掰下后的警报，lock记录后传给app



#pragma mark ----- IC卡
//添加IC卡
+(void)AddIC_version:(NSString*)version
                          key:(Byte*)pwdkey
;
//清空IC卡
+(void)ClearIC_version:(NSString*)version
                            key:(Byte*)pwdkey
;
//删除IC卡
+(void)DeleteIC_ICNumber:(NSString*)ICNumber
        version:(NSString*)version
                     key:(Byte*)pwdkey
;
//修改或恢复IC卡  type 1-查询，2-添加，3-删除 4-清空 5-修改
+(void)ModifyOrRecoverICWithType:(NSInteger)type
                        ICNumber:(NSString*)ICNumber
               startDate:(NSString*)startDate
                 endDate:(NSString*)endDate
            version:(NSString*)version
                     key:(Byte*)pwdkey;

+(void)AddFingerprint_WithVersion:(NSString*)version
                              key:(Byte*)pwdkey;

+(void)DeleteFingerprint_FingerprintNumber:(NSString*)FingerprintNumber
                                   version:(NSString*)version
                                       key:(Byte*)pwdkey;

+(void)ClearFingerprint_version:(NSString*)version
                            key:(Byte*)pwdkey;

//1-查询，2-添加3-删除4-清空5-修改
+(void)ModifyOrRecoverFingerprintWithType:(NSInteger)type
                        FingerprintNumber:(NSString*)FingerprintNumber
                                 startDate:(NSString*)startDate
                                   endDate:(NSString*)endDate
                                   version:(NSString*)version
                                       key:(Byte*)pwdkey;

+(void)recoverFingerprintDataWithTempNumber:(NSString*)tempNumber
                        fingernumberDataStr:(NSString*)fingernumberDataStr
                                  startDate:(NSString*)startDate
                                    endDate:(NSString*)endDate
                                    version:(NSString*)version
                                        key:(Byte*)pwdkey;

+(void)recoverFingerprintDataWithFingernumberDataStr:(NSString*)fingernumberDataStr
                                               index:(int)index
                                            maxCount:(int)maxCount
                                             version:(NSString*)version
                                                 key:(Byte*)pwdkey;
//NB服务器地址配置
+ (void)setNBServerConfigWithPortNumber:(NSString*)portNumber
                          serverAddress:(NSString*)serverAddress
                                version:(NSString*)version
                                    key:(Byte*)pwdkey;

//常开模式
+ (void)setPassageModeWithType:(TTPassageModeType)type
                     weekOrDay:(int)weekOrDay
                         month:(int)month
                     startDate:(int)startDate
                       endDate:(int)endDate
                       version:(NSString*)version
                           key:(Byte*)pwdkey;

#pragma mark ----- 没有请求参数
+(void)noneRequestStringPara_WithVersion:(NSString*)version
                                   commandValue:(Byte)commandValue
                                            key:(Byte*)pwdkey;

#pragma mark ----- 只有一个请求参数
/**
 只有一个请求参数

 @param version 版本号
 @param requestPara 请求参数  类型int
 @param Paralength 请求参数所占字节大小  1-4个字节都可以
 @param commandValue commandValue
 @param pwdkey pwdkey
 */
+(void)oneRequestPara_WithVersion:(NSString*)version
                      requestPara:(int)requestPara
                       Paralength:(int)Paralength
                     commandValue:(Byte)commandValue
                              key:(Byte*)pwdkey;

#pragma mark ----- 两个请求参数
/**
 两个请求参数
 
 @param version 版本号
 @param requestPara 请求参数  类型int
 @param Paralength 请求参数所占字节大小  1-4个字节都可以
 @param tworequestPara 请求参数  类型int
 @param twoParalength 请求参数所占字节大小  1-4个字节都可以
 @param commandValue commandValue
 @param pwdkey pwdkey
 */
+(void)twoRequestPara_WithVersion:(NSString*)version
                      requestPara:(int)requestPara
                      tworequestPara:(int)tworequestPara
                       Paralength:(int)Paralength
                    twoParalength:(int)twoParalength
                     commandValue:(Byte)commandValue
                              key:(Byte*)pwdkey;
#pragma mark ----- 三个请求参数
/**
 三个请求参数
 
 @param version 版本号
 @param requestPara 请求参数  类型int
 @param Paralength 请求参数所占字节大小  1-4个字节都可以
 @param tworequestPara 请求参数  类型int
 @param twoParalength 请求参数所占字节大小  1-4个字节都可以
 @param threerequestPara 请求参数  类型int
 @param threeParalength 请求参数所占字节大小  1-4个字节都可以
 @param commandValue commandValue
 @param pwdkey pwdkey
 */
+(void)threeRequestPara_WithVersion:(NSString*)version
                        requestPara:(int)requestPara
                     tworequestPara:(int)tworequestPara
                   threerequestPara:(int)threerequestPara
                         Paralength:(int)Paralength
                      twoParalength:(int)twoParalength
                    threeParalength:(int)threeParalength
                       commandValue:(Byte)commandValue
                                key:(Byte*)pwdkey;

#pragma mark ----- 四个请求参数
/**
 四个请求参数
 
 @param version 版本号
 @param requestPara 请求参数  类型int
 @param Paralength 请求参数所占字节大小  1-4个字节都可以
 @param tworequestPara 请求参数  类型int
 @param twoParalength 请求参数所占字节大小  1-4个字节都可以
 @param threerequestPara 请求参数  类型int
 @param threeParalength 请求参数所占字节大小  1-4个字节都可以
 @param commandValue commandValue
 @param pwdkey pwdkey
 */
+(void)fourRequestPara_WithVersion:(NSString*)version
                        requestPara:(int)requestPara
                     tworequestPara:(int)tworequestPara
                   threerequestPara:(int)threerequestPara
                    fourrequestPara:(int)fourrequestPara
                         Paralength:(int)Paralength
                      twoParalength:(int)twoParalength
                    threeParalength:(int)threeParalength
                     fourParalength:(int)fourParalength
                       commandValue:(Byte)commandValue
                                key:(Byte*)pwdkey;

#pragma mark ----- 只有一个请求参数 请求参数是字符串类型
+(void)oneRequestStringPara_WithVersion:(NSString*)version
                            requestPara:(NSString*)requestPara
                           commandValue:(Byte)commandValue
                                    key:(Byte*)pwdkey;

+(void)click_Remote_Control_with_psFromLock:(long long)psFromLock
                                    psLocal:(long long)psLocal
                                   uniqueid:(long long)uniqueid
                                buttonValue:(int)buttonValue
                                    version:(NSString*)version
                                        key:(Byte*)pwdkey;

#pragma mark ----- 酒店锁参数配置 1 – IC Key 2 – AES Key 3 – 酒店编号、 楼栋编号、楼层编号
+ (void)setHotelICKey:(NSData *)ickey
         version:(NSString*)version
             key:(Byte*)pwdkey;
+ (void)setHotelAESKey:(NSData *)aesKey
          version:(NSString*)version
              key:(Byte*)pwdkey;
+ (void)setHotelNumber:(NSString *)hotelNumber
        buildingNumber:(NSString *)buildingNumber
           floorNumber:(NSString *)floorNumber
               version:(NSString*)version
                   key:(Byte*)pwdkey;
+ (void)queryHotelICKeyWithType:(int)type
                        version:(NSString*)version
                            key:(Byte*)pwdkey;
#pragma mark ----- 手环
//设置锁里的手环
+(void)v3_set_Bong_Key:(NSString*)BongKey
              version:(NSString*)version
                   key:(Byte*)pwdkey ;


#pragma mark ---- 写到bong手环里
//添加到手环中key
+ (void)writeDataToBongWithKey:(NSString*)key
                        isOpen:(BOOL)isOpen
                             p:(CBPeripheral *)peripheral;


+ (void)writeDataToBongRssi:(int )rssi
                          p:(CBPeripheral *)peripheral;

#pragma mark ---- 处理蓝牙数据 服务 特征 uuid
+(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID
                                           service:(CBService*)service;
+(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID
                                   p:(CBPeripheral *)p;
+(const char *) CBUUIDToString:(CBUUID *) UUID;
+(const char *) UUIDToString:(CFUUIDRef)UUID ;
+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
+(UInt16) swap:(UInt16)s;
@end
