//
//  TTDateHelper.m
//  TTLockDemo
//
//  Created by 王娟娟 on 2017/10/10.
//  Copyright © 2017年 wjj. All rights reserved.
//

#import "TTDateHelper.h"

@implementation TTDateHelper

+ (NSDateFormatter *)sharedDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        //用公历日历
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
        dateFormatter.calendar = calendar;
        //24小时制
        NSLocale *local = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        dateFormatter.locale = local;
    });
    return dateFormatter;
}
+(NSDate*)getPermanentStartDateWithtimezoneRawOffset:(long)timezoneRawOffset{
    NSDateFormatter *formatter = [self sharedDateFormatter];
    NSString *dateStr = @"2000-01-01-00-00";
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSDate *desDate ;
    
    //锁里时区偏移差
    //如果时区偏移差 有设置 那把时间换成锁里的时区
    if (timezoneRawOffset != -1) {
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSTimeInterval dateInterval = [formatter dateFromString:dateStr].timeIntervalSince1970;
        desDate = [NSDate dateWithTimeIntervalSince1970:dateInterval - timezoneRawOffset/1000];
        
    }else{
        // 如果没有 就用默认时区
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        desDate = [formatter dateFromString:dateStr];
    }
    
    return desDate;
    
}
+(NSDate*)getPermanentEndDateWithtimezoneRawOffset:(long)timezoneRawOffset{
    NSDateFormatter *formatter = [self sharedDateFormatter];
    NSString *dateStr = @"2099-12-31-23-59";
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSDate *desDate ;
    //锁里时区偏移差
    //如果时区偏移差 有设置 那把时间换成锁里的时区
    if (timezoneRawOffset != -1) {
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSTimeInterval dateInterval = [formatter dateFromString:dateStr].timeIntervalSince1970;
        desDate = [NSDate dateWithTimeIntervalSince1970:dateInterval - timezoneRawOffset/1000];
        
    }else{
        // 如果没有 就用默认时区
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        desDate = [formatter dateFromString:dateStr];
    }
    
    return desDate;
}
+ (NSString *)getCurrentYear{
    NSDateFormatter *dateFormatter = [self sharedDateFormatter];
    NSDate *date = [NSDate date];
    //防止跨时区跨年问题
    date = [date dateByAddingTimeInterval:-24*60*60];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:date];
    return year;
}
+(NSString*)formateDate:(NSDate*)date format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset
{
    NSDateFormatter *formatter = [self sharedDateFormatter];
    //锁里时区偏移差
    //如果时区偏移差 有设置 那把时间换成锁里的时区
    if (timezoneRawOffset != -1) {
        date = [date dateByAddingTimeInterval:timezoneRawOffset/1000];
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }else{
        // 如果没有 就用默认时区
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    [formatter setDateFormat:@"yyyy"];
    NSString *currentyear = [formatter stringFromDate:date];
    //对特殊的时间做特殊处理 电子钥匙的永久时间
    if ([currentyear hasPrefix:@"1999"]&&[format hasPrefix:@"yy-MM-dd"]) {
        [formatter setDateFormat:format];
        NSString* dateStr = [formatter stringFromDate:date];
        NSMutableArray *dateArray = [NSMutableArray arrayWithArray:[dateStr componentsSeparatedByString:@"-"]];
        if (dateArray.count >0) {
            dateArray[0] = @"00";
        }
        NSString *lastDateStr = [dateArray componentsJoinedByString:@"-"];
        return lastDateStr;
    }
    if ([currentyear hasPrefix:@"2100"]&&[format hasPrefix:@"yy-MM-dd"]) {
        [formatter setDateFormat:format];
        NSString* dateStr = [formatter stringFromDate:date];
        NSMutableArray *dateArray = [NSMutableArray arrayWithArray:[dateStr componentsSeparatedByString:@"-"]];
        if (dateArray.count >0) {
            dateArray[0] = @"99";
        }
        NSString *lastDateStr = [dateArray componentsJoinedByString:@"-"];
        return lastDateStr;
    }
    [formatter setDateFormat:format];

    NSString* dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}
+(NSString*)formateTimestamp:(long long)timestamp format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset{
    NSDateFormatter *formatter = [self sharedDateFormatter];
    //锁里时区偏移差
    //如果时区偏移差 有设置 那把时间换成锁里的时区
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    if (timezoneRawOffset != -1) {
        date = [date dateByAddingTimeInterval:timezoneRawOffset/1000];
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }else{
        // 如果没有 就用默认时区
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    [formatter setDateFormat:@"yyyy"];
    NSString *currentyear = [formatter stringFromDate:date];
    //对特殊的时间做特殊处理 电子钥匙的永久时间
    if ([currentyear hasPrefix:@"1999"]&&[format hasPrefix:@"yy-MM-dd"]) {
        [formatter setDateFormat:format];
        NSString* dateStr = [formatter stringFromDate:date];
        NSMutableArray *dateArray = [NSMutableArray arrayWithArray:[dateStr componentsSeparatedByString:@"-"]];
        if (dateArray.count >0) {
            dateArray[0] = @"00";
        }
        NSString *lastDateStr = [dateArray componentsJoinedByString:@"-"];
        return lastDateStr;
    }
    if ([currentyear hasPrefix:@"2100"]&&[format hasPrefix:@"yy-MM-dd"]) {
        [formatter setDateFormat:format];
        NSString* dateStr = [formatter stringFromDate:date];
        NSMutableArray *dateArray = [NSMutableArray arrayWithArray:[dateStr componentsSeparatedByString:@"-"]];
        if (dateArray.count >0) {
            dateArray[0] = @"99";
        }
        NSString *lastDateStr = [dateArray componentsJoinedByString:@"-"];
        return lastDateStr;
    }
    [formatter setDateFormat:format];
    
    NSString* dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}
+(NSDate*)formateDateFromStringToDate:(NSString*)dateStr format:(NSString*)format timezoneRawOffset:(long)timezoneRawOffset
{
    
    NSDateFormatter *formatter = [self sharedDateFormatter];
    
    //对特殊的时间做特殊处理
    if ([dateStr hasPrefix:@"00"]||[dateStr hasPrefix:@"99"]) {
        dateStr = [NSString stringWithFormat:@"%@%@",@"20",dateStr];
        [formatter setDateFormat:[NSString stringWithFormat:@"%@%@",@"yy",format]];
    }else{
        [formatter setDateFormat:format];
    }
    
    NSDate *desDate ;
    //锁里时区偏移差
    //如果时区偏移差 有设置 那把时间换成锁里的时区
    if (timezoneRawOffset != -1) {
        [formatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSTimeInterval dateInterval = [formatter dateFromString:dateStr].timeIntervalSince1970;
        desDate = [NSDate dateWithTimeIntervalSince1970:dateInterval - timezoneRawOffset/1000];
        
    }else{
        // 如果没有 就用默认时区
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        desDate = [formatter dateFromString:dateStr];
    }
    
    return desDate;
    
    
}


@end
