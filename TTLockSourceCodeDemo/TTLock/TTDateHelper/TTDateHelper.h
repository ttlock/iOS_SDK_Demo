//
//  TTDateHelper.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2017/10/10.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTDateHelper : NSObject

+ (NSDateFormatter *)sharedDateFormatter;

/**
 * 获取永久时间的开始时间
 */
+ (NSDate*)getPermanentStartDateWithtimezoneRawOffset:(long)timezoneRawOffset;
/**
 * 获取永久时间的结束时间
 */
+(NSDate*)getPermanentEndDateWithtimezoneRawOffset:(long)timezoneRawOffset;

/** 把NSDate类型 转化成字符串 并根据timezoneRawOffset转化锁里时区的时间 */
+(NSString*)formateDate:(NSDate*)date format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset;

/** 把timestamp 转化成字符串 并根据timezoneRawOffset转化锁里时区的时间 */
+(NSString*)formateTimestamp:(long long)timestamp format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset;


+(NSDate*)formateDateFromStringToDate:(NSString*)dateStr format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset;
/**获取当前时间的年份 格式是 yyyy*/
+ (NSString *)getCurrentYear;
@end
