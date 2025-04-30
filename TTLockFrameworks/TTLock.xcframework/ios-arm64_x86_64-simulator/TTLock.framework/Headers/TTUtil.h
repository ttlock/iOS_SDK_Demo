//
//  TTUtil.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/22.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTUtil : NSObject

/**
 lockData string of encrypted lock data, such as "wUY7gmkYCeXhrD9QqoBopAtJis0bLqScJgx1s7BvYNvUXA9PYh..."
 */
+ (BOOL)isSupportFeature:(TTLockFeatureValue)feature lockData:(NSString *)lockData;

+ (TTLockType)getLockTypeWithLockVersion:(NSDictionary *)lockVersion;

#pragma mark - deprecated

+ (BOOL)lockSpecialValue:(long long)specialValue suportFunction:(TTLockSpecialFunction)function DEPRECATED_MSG_ATTRIBUTE("SDK3.1.8,lockFeatureValue:supportFunction");
+ (BOOL)lockFeatureValue:(NSString *)lockData suportFunction:(TTLockFeatureValue)function DEPRECATED_MSG_ATTRIBUTE("SDK3.5.0,lockFeatureValue:supportFunction");
@end

NS_ASSUME_NONNULL_END
