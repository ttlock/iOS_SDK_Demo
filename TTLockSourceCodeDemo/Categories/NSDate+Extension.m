//
//  NSDate+Extension.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)
+ (NSString *)stringWithTimevalue:(long long)timeValue dateFormatter:(NSString *)dateFormatter{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatter];
    return [formatter stringFromDate:date];
}
@end
