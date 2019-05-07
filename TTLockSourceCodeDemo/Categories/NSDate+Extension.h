//
//  NSDate+Extension.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define YYYY_MM_DD_HH_MM_SS @"yyyy-MM-dd HH:mm:ss"
#define YYYY_MM_DD_HH_MM @"yyyy-MM-dd HH:mm"
#define YYYY_MM_DD @"yyyy-MM-dd"

@interface NSDate (Extension)
+ (NSString *)stringWithTimevalue:(long long)timeValue dateFormatter:(NSString *)dateFormatter;
@end

NS_ASSUME_NONNULL_END
