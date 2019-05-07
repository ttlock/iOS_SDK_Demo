//
//  TTCenterManager.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/12.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMacros.h"
#import "TTCommandUtils.h"
#import "TTCommand.h"
#import "TTLockDataModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TTLockApi.h"
#import "TTScanModel.h"

typedef NS_ENUM(int, DoorSceneType)
{
    CommonDoorLockSceneType = 1,
    AdvancedDoorLockSceneType = 2,
    RYDoorLock = 3,
    GateLockSceneType = 4,
    SafeLockSceneType = 5,
    BicycleLockSceneType = 6,
    ParkSceneType = 7,
    PadLockSceneType = 8,
    CylinderLockSceneType = 9,
    RemoteControlFourButtonType = 10,
    HotelSafeLockSceneType = 11,
};


#define NOTNILSTRING(aa) (aa==nil?@"":aa)

@interface TTCenterManager : NSObject

@property (nonatomic,strong) CBCentralManager * manager;
@property (nonatomic,strong) CBPeripheral * activePeripheral;
@property (nonatomic, weak) id <TTSDKDelegate> delegate;


#pragma mark ------ 指令所需参数
@property (nonatomic,assign) BOOL isFirstCommand; /**是否是第一个指令 用来判读锁是否被重置的一个条件 （注：添加管理员时设为no！！！！）*/
@property (nonatomic,assign) BOOL isSendCommandByError;//错误就重试一次
@property (nonatomic,assign) CurrentOperatorState  m_currentOperatorState;//标记当前要实现的功能
@property (nonatomic,strong) NSArray *errorMsgArray;//错误描述的数组
//锁通讯需要的基本数据
@property (nonatomic,strong) TTLockDataModel *lockDataModel;
@property (nonatomic,assign)long long passwordLocal;
@property (nonatomic,assign) long long  passwordFromLock;
@property (nonatomic,strong) NSDate * m_startDate;
@property (nonatomic,strong) NSDate * m_endDate;
@property (nonatomic,assign) long long uniqueid;

//添加锁的时候用到的
@property (nonatomic,strong) NSString *m_lockName;
@property (nonatomic,strong) NSString *m_add_mac;
//管理员键盘密码
@property (nonatomic,strong) NSString * m_keyboard_password_admin;
//管理员删除密码
@property (nonatomic,strong) NSString *m_keyboard_delete_admin;
//要校准的时间
@property (nonatomic,assign) long long myTime;
//是否支持修改密码特殊处理
@property (nonatomic,assign) NSUInteger modifyPwdError;
//AT指令
@property (nonatomic,strong) NSString *ATCommand;
//1远程开门开关 2门磁闭锁开关 3闭锁时间 4在屏幕上显示输入的密码 0-隐藏  1-显示
@property (nonatomic,assign) int lockingTime;
//IC卡 指纹
@property (nonatomic,strong)NSString *m_ICNumber; //卡号
@property (nonatomic,strong)NSString *m_fingerprintNum;
@property (nonatomic,strong)NSString *m_fingerprintData;
@property (nonatomic,strong)NSString *m_tempFingerprintNumber;
@property (nonatomic,assign)int m_maxCount;
//添加、删除和设置密码的时候用到
@property (nonatomic,assign)TTPasscodeType m_psType;
@property (nonatomic,strong)NSString * m_keyboardPs;
@property (nonatomic,assign)NSInteger m_cycleType; //循环密码的循环类型
@property (nonatomic,strong)NSString * m_newKeyboardPs; //新的密码
//密码 及时间戳
@property (nonatomic,assign)long long timestamp;
@property (nonatomic,strong)NSString * pwdInfo;
//设备信息
@property (nonatomic,strong) NSMutableDictionary * deviceInfoDic;
@property (nonatomic,assign) TTDeviceInfoType deviceInfoType;
//操作记录
@property (nonatomic,strong) NSMutableArray *lockOpenRecordArr;
@property (nonatomic,assign) int m_operatelog_nextNum;
@property (nonatomic,assign) int m_operatelog_Count;
//常开模式
@property (nonatomic,assign) TTPassageModeType m_passageModeType;
@property (nonatomic,assign) BOOL m_passageModeIsAllday;
@property (nonatomic,strong)NSMutableArray *m_passageModeTypeRecord;
@property (nonatomic,strong)NSMutableArray *m_weekArr;
@property (nonatomic,assign)int m_monthStr;
@property (nonatomic,assign)int m_startMinutes;
@property (nonatomic,assign)int m_endMinutes;
//NB锁
@property (nonatomic,strong) NSString *portNumber;
@property (nonatomic,strong) NSString *serverAddress;
//酒店锁
@property (nonatomic,strong) NSData *hotelICKEY;
@property (nonatomic,strong) NSData *hotelAESKEY;
@property (nonatomic,strong) NSString *hotelNumber;
@property (nonatomic,strong) NSString *hotelBuildingNumber;
@property (nonatomic,strong) NSString *hotelFloorNumber;
//手环
@property (nonatomic,assign) int bongOperateType; //1 是 设置key  2 是设置 rssi   在屏幕上显示输入的密码1查询 2修改
@property (nonatomic,strong) NSString *bongKey;
//二代锁才有的
@property (nonatomic,assign) int validPsNumber;
@property (nonatomic,strong)NSMutableArray *Ps900Array;        //900个密码
@property (nonatomic,strong)NSMutableArray *PSTmp5Arr;            //辅助900个密码
@property (nonatomic, strong) NSMutableArray *timepsArr;
@property (nonatomic, strong) NSMutableArray *kpstimeArr;
@property (nonatomic, strong) NSMutableArray *kpschecknumbersArr;
@property (nonatomic) int timePsBytesSended;
@property (nonatomic, strong) NSString *posString;/**时间有效性所在位置*/
@property (nonatomic, strong) NSMutableString *psListString;/** 限时密码*/
@property (nonatomic, strong) NSString  *timeControlString;/**时间有效性数字对照表 */
@property (nonatomic, strong) NSMutableString *checkString;/**校验对照表*/

/** Get a single case */
+ (TTCenterManager *)sharedInstance;

/**
 Start scanning near specific service Bluetooth.
 
 @param isScanDuplicates every time the peripheral is seen, which may be many times per second. This can be useful in specific situations.If you only support v3 lock,we recommend this value to be 'NO',otherwise to be 'YES'.
 *
 *  @see onScanLockWithModel:
 */
-(void)startScanLock:(BOOL)isScanDuplicates;
/**
 Start scanning all Bluetooth nearby
 If you need to develop wristbands, you can use this method
 @param isScanDuplicates every time the peripheral is seen, which may be many times per second. This can be useful in specific situations.Recommend this value to be NO
 *
 *  @see onScanLockWithModel:
 */
- (void)scanAllBluetoothDeviceNearby:(BOOL)isScanDuplicates;

- (void)scanSpecificServicesBluetoothDeviceWithServicesArray:(NSArray<NSString *>*)servicesArray isScanDuplicates:(BOOL)isScanDuplicates ;

/** Stop scanning
 */
-(void)stopScanLock;

/**
 Connecting peripheral
 Connection attempts never time out .Pending attempts are cancelled automatically upon deallocation of <i>peripheral</i>, and explicitly via {@link cancelConnectPeripheralWithLockMac}.
 @param lockMac (If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see  onBTConnectSuccessWithPeripheral:lockName:
 */
- (void)connectPeripheralWithLockMac:(NSString *)lockMac;
/**
 Cancel connection
 @param lockMac （If there is no 'lockMac',you can use 'lockName'）
 *
 *  @see onBTDisconnectWithPeripheral:
 */
- (void)cancelConnectPeripheralWithLockMac:(NSString *)lockMac;

-(void)connect:(CBPeripheral *)peripheral;

/** Cancel connection
 *
 *  @see onBTDisconnectWithPeripheral:
 */
-(void)disconnect:(CBPeripheral *)peripheral;

@end

