//
//  HandleResponse.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/15.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTCommand.h"
#import "TTMacros.h"
#import "TTLockDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTHandleResponse : NSObject

+ (TTCommand *) handleCommandResponse: (NSData *)data;

/*开锁密码解析*/
+ (void)unlockPasswordWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset;
/**操作记录解析*/
+ (void)operationRecordWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset;
/**IC卡查询记录 type 0 ic 1 指纹*/
+(void)ICQueryWithByteData:(Byte*)data i:(int)i lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr type:(int)type timezoneRawOffset:(long)timezoneRawOffset;

+(void)passageModeWithByteData:(Byte*)data lockOpenRecordArr:(NSMutableArray *)lockOpenRecordArr timezoneRawOffset:(long)timezoneRawOffset;

/**年月日时分 转化成时间戳*/
+ (NSTimeInterval)convertTime:(Byte*)data index:(int)index length:(int)length timezoneRawOffset:(long)timezoneRawOffset;

/**
 *  生成三代锁的键盘密码
 *
 *  @return 返回生成的密码
 */
+ (NSString *)generateV3PasswordWithCodeArray:(NSArray *)code yearArray:(NSArray*)yearArray secretKeyArray:(NSArray *)secretKey timeString:(NSString *)timeString;
+ (NSArray*)generateSecretKey;
+ (NSArray*)generateV3Code;
+ (NSArray*)generateV3Year;
/**
 * 900个密码
 */
+ (NSString *)generateWith900Array:(NSArray*)Ps900Array;
/**
 * 当前手机时区与UTC时区的偏移差
 */
+ (int)gettimezoneRawOffset;

/**
 *  获取三代锁的键盘密码
 *
 *  @return 返回生成的密码
 */
+ (NSString *)getV3PasswordData:(Byte*)data timeString:(NSString *)timeString timezoneRawOffset:(long)timezoneRawOffset;

+ (NSString *)getDeviceInfoData:(Byte*)data deviceInfoType:(TTDeviceInfoType)deviceInfoType;
+ (void)setPowerWithCommand:(TTCommand*)command data:(Byte*)data;

+ (NSArray*)initErrorMsgArray;
//if retrun nil,means error
+ (TTLockDataModel *)getLockDataModel:(NSString *)lockData;

@end

NS_ASSUME_NONNULL_END
