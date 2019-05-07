//
//  LockModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/22.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LockModel : NSObject
@property (nonatomic, strong) NSNumber * lockId;
@property (nonatomic, strong) NSString * lockName;
@property (nonatomic, strong) NSString * lockAlias;
@property (nonatomic, strong) NSString *lockData;
@property (nonatomic, assign) long long specialValue;
@property (nonatomic, assign) NSInteger electricQuantity;
@property (nonatomic, assign) NSInteger keyboardPwdVersion;
@property (nonatomic, strong) NSDictionary *lockVersion;
@property (nonatomic, strong) NSString *noKeyPwd;
@end

NS_ASSUME_NONNULL_END
