//
//  HFSmartLink.h
//  SmartlinkLib
//
//  Created by wangmeng on 15/3/16.
//  Copyright (c) 2015年 HF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HFSmartLinkDeviceInfo.h"

typedef void(^SmartLinkProcessBlock)(NSInteger process);
/**
 *  设置成功以后的Block
 *
 *  @param dev
 */
typedef void(^SmartLinkSuccessBlock)(HFSmartLinkDeviceInfo *dev);
/**
 *  设置失败的信息
 *
 *  @param failmsg 失败信息
 */
typedef void(^SmartLinkFailBlock)(NSString * failmsg);
/**
 *   用户手动停掉的block
 *
 *  @param stopMsg 停止的信息
 *  @param isOk    是否停止成功
 */
typedef void(^SmartLinkStopBlock)(NSString *stopMsg,BOOL isOk);
/**
 *  关闭服务的Block
 *
 *  @param closeMsg 关闭的信息
 *  @param isOK     是否关闭成功
 */
typedef void(^SmartLinkCloseBlock)(NSString * closeMsg,BOOL isOK);
/**
 *  发现设备的block
 *
 *  @param deviceDic 发现的设备
 */
typedef void(^SmartLinkEndblock)(NSDictionary * deviceDic);

@interface HFSmartLink : NSObject
/**
 *  是否配置单个设备，或者多个设备 默认false
 */
@property (nonatomic) BOOL isConfigOneDevice;
/**
 *  配置信息发送完成以后，等待搜索设备的时间 second 默认15
 */
@property (nonatomic) NSInteger waitTimers;

/**
 *  获取smartlink 的单例
 *
 *  @return 返回smartlink的单例
 */
+(instancetype)shareInstence;
/**
 *  开始配置 block不能为nil
 *
 *  @param key    路由器密码
 *  @param pblock 进度block
 *  @param sblock 成功block
 *  @param fblock 失败block
 *  @param eblock 结束block
 */
//-(void)startWithKey:(NSString*)key processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;

-(void)startWithSSID:(NSString*)ssid Key:(NSString*)key withV3x:(BOOL)v3x processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;
// for smartlink V7.0
//-(void)startWithContent:(char *)content lenght:(int)len key:(NSString *)key withV3x:(BOOL)v3x processblock:(SmartLinkProcessBlock)pblock successBlock:(SmartLinkSuccessBlock)sblock failBlock:(SmartLinkFailBlock)fblock endBlock:(SmartLinkEndblock)eblock;
/**
 *  停止配置
 *
 *  @param block 停止配置的block
 */
-(void)stopWithBlock:(SmartLinkStopBlock)block;
/**
 *  关闭整个Smartlink服务，再次调用的时候必须 从头开始 初始化。
 *
 *  @param block 关闭服务block
 */
-(void)closeWithBlock:(SmartLinkCloseBlock)block;
@end
