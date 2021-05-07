//
//  TTUtil.h
//  TTLockDemo
//
//  Created by 王娟娟 on 2019/4/22.
//  Copyright © 2019 wjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTLock/TTMacros.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTUtil : NSObject

+ (BOOL)lockFeatureValue:(NSString *)lockData suportFunction:(TTLockFeatureValue)function;

+ (TTLockType)getLockTypeWithLockVersion:(NSDictionary *)lockVersion;

#pragma mark - deprecated

+ (BOOL)lockSpecialValue:(long long)specialValue suportFunction:(TTLockSpecialFunction)function DEPRECATED_MSG_ATTRIBUTE("SDK3.1.8,lockFeatureValue:suportFunction");

@end

NS_ASSUME_NONNULL_END
