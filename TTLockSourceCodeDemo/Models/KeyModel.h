//
//  KeyModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "LockModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KeyModel : LockModel

@property (nonatomic, strong) NSNumber * keyId;
@property (nonatomic, assign) NSInteger userType;
@property (nonatomic, assign) NSInteger keyStatus;
@property (nonatomic, assign) NSInteger lockFlagPos;
@property (nonatomic,strong) NSString * remarks;
@property (nonatomic, retain) NSString *noKeyPwd;
@property (nonatomic, retain) NSString *deletePwd;
@property (nonatomic, assign) BOOL keyRight;
@property (nonatomic, assign) NSInteger remoteEnable;

@property (nonatomic, assign,readonly) BOOL isAdminEKey;

@end

NS_ASSUME_NONNULL_END
