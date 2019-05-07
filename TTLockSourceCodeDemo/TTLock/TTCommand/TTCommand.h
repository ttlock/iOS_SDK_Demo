//
//  Command.h
//  BTstackCocoa
//
//  Created by wan on 13-2-22.
//
//

#import <Foundation/Foundation.h>

#define Version_Lock_v1 1
#define Version_Lock_v2 3
#define Version_Lock_v3 4
#define Version_Lock_v4 5
#define Version_Lock_v2_AES 7
#define Version_Lock_v4_1 6
#define Version_Lock_v3_AES 5   // aes加密的command
#define Version_PARK_Lock_v1 0x0a   //车位锁
#define Version_EBYCICLE_LOCK_v1 0x0b  //电动车锁
#define  V2_AES_COMM_LOCK_SET_ADMIN_DEL_PS      'D'


#define COMM_RESPONSE                       'T'
#define COMM_INITIALIZATION                 'E'
#define COMM_ADD_USER                       'A'
#define COMM_LOCK_CHECK_USER_TIME           'U'
#define COMM_ADD_ADMIN                      'V'
#define COMM_LOCK_UNLOCK                    'G'
#define COMM_COMM_LOCK_SET_ADMIN_DEL_PS     'D'
#define COMM_LOCK_SET_ADMIN_PS              'S'
#define COMM_LOCK_TIME_CALIBRATION          'C'
#define COMM_LOCK_RESET                     'R'
#define COMM_LOCK_INIT_PS                   'I'
#define COMM_LOCK_NOTIFY_ADDADMIN          0x57
#define COMM_LOCK_INITIALIZ_PASSWORD       0x31
#define COMM_LOCK_Device_Parameter_Settings 0xFF
#define COMM_FETCH_AES_KEY                  0x19
#define COMM_USER_PS_SET_DEL                0x03    //管理键盘密码
#define COMM_FETCH_USER_PS_LIST             0x07
#define COMM_GET_DeviceInfo                 0x90
#define COMM_NBServer_Config                0x12
/**lock特有*/
#define  V4_COMM_LOCK_SERIAL_NUMBER         'J'
/**目前三代锁特有*/
#define LOCK_V3_COMM_CHECK_RANDOM           0x30
#define LOCK_V3_COMM_SET_LOCK_NAME          0x4E
#define LOCK_V4_COMM_READ_LOCKRECORD  0x25
#define LOCK_V3_COMM_RENAME                 'N'
#define Lock_V3_COMM_SET_MAX_NUMBER_OF_KEYBOARD_PASSWOED 0x33
#define Lock_V3_COMM_GET_LOCK_TIME 0x34
#define Lock_V3_COMM_GET_Device_CHARACTERISTIC 0x01
#define Lock_V3_COMM_IC_Manager   0x05
#define Lock_V3_COMM_SET_Bongkey   0x35
#define Lock_V3_COMM_Fingerprint_Manager  0x06
#define Lock_V3_COMM_lockingTime_Manager  0x36
#define Lock_V3_COMM_PREPARE_UPGRADE  0x02
#define Lock_V3_COMM_SWITCH_STATE 0x14
#define Lock_V3_COMM_LOCK   0x58 //闭锁，关锁
#define LOCK_V3_COMM_PASSWORD_DISPLAY_HIDE_CONTROL   0x59 //是否在屏幕上显示输入的密码
#define LOCK_V3_COMM_GET_PASSWORD_DATA   0x32 //读取新密码方案参数（约定数、映射数、删除日期）
#define LOCK_V3_COMM_Remote_Unlock   0x37 //远程开门开关
#define LOCK_V3_COMM_Audio_Switch    0x62
#define LOCK_V3_COMM_Remote_Control    0x63
#define LOCK_V3_COMM_HOTEL_CARD    0x64
#define LOCK_V3_COMM_GET_ADMIN_PASSCODE    0x65
#define LOCK_V3_COMM_PASSAGEMODE    0x66

//park lock v1 功能和v2家用锁基本相同，多了获取锁状态，增加关指令
#define PARK_LOCK_V1_COMM_ADD_ADMIN              'V'
#define PARK_LOCK_V1_COMM_CHECK_ADMIN            'A'
#define PARK_LOCK_V1_COMM_UNLOCK                 'G'
#define PARK_LOCK_V1_COMM_TIME_CALIBRATION       'C'
#define PARK_LOCK_V1_COMM_CHECK_USER_TIME        'U'
#define PARK_LOCK_V1_COMM_RESET                  'R'
#define PARK_LOCK_V1_COMM_GET_STATE              'B'
#define PARK_LOCK_V1_COMM_LOCK                   'L'
#define PARK_LOCK_V1_COMM_RENAME                 'N'
#define PARK_LOCK_V1_COMM_WARN_RECORD            'W'

#define GATEWAY_COMM_SCAN_NEARBY_WIFI            0x01
#define GATEWAY_COMM_CONFIG_WIFI                 0x02
#define GATEWAY_COMM_CONFIG_SERVER               0x03
#define GATEWAY_COMM_CONFIG_ACCOUNT              0x04


#define AES_DEFAULT_KEY             @"1234567890123456"

@interface TTCommand : NSObject
{
@public
    Byte header[2];	// 帧首 		2 字节
//	Byte reserved;	// 预留	 	1 字节    （lcokV1,lockV2,lightV1中表示版本号）
    Byte protocolCategory;  //协议类别  1字节 （lcokV1,lockV2,lightV1中表示版本号）
    Byte protocolVersion;   //协议版本  1字节
    Byte applyCatagory;     //应用类别  1字节     （场景）
    Byte applyID[2];           //应用id    2字节
    Byte applyID2[2];          //应用子id  2字节
	Byte command;	// 命令字 	1 字节
	Byte encrypt;	// 加密字		1 字节
//	Byte length;	// 长度		1 字节
	Byte data[256];	// 数据
	Byte checksum;	// 校验		1 字节
    BOOL mIsChecksumValid;
    Byte length;	// 长度		1 字节
    int dataLength;  //返回数据所占的长度
    NSString *version; //5.1.1.1.1 的格式
//    Byte *commandWithoutChecksum;  //全部指令;
}


-(void)commandWithVersion:(NSString*)lockVersion;

-(void)command:(Byte*)commandByte withLength:(int)length;

-(void)setCommand:(Byte)commandToSet;

-(Byte)getCommand;

/**老的加密
 */
-(void)setData:(Byte*)dataToSet withLength:(NSInteger)setdataLength;

/**aes加密
 */
-(void)setDataAES:(Byte*)dataToSet withLength:(NSInteger)setdataLength key:(Byte*)pwdKey;

-(Byte*)getData;

-(Byte*)getDataAes_pwdKey:(Byte*)pwdKey;
-(Byte*)getDataAes_pwdKeyStr:(NSString*)pwdKey;

//-(void)buildCommand;
-(void)buildCommand:(Byte*)data withLength:(int)length;

+ (NSData*)getDefaultAesKey;

@end
