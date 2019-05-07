//
//  UserModel.m
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import "UserModel.h"
#import <MJExtension/MJExtension.h>

#define kUserModelCachePath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"kUserModel.data"]

static UserModel *kUserModel = nil;

@implementation UserModel

MJLogAllIvars
MJCodingImplementation

+ (void)initialize{
    kUserModel = [NSKeyedUnarchiver unarchiveObjectWithFile:kUserModelCachePath];
    if (!kUserModel){
        kUserModel = [UserModel new];
    }
}


+ (UserModel *)userModel{
    return kUserModel;
}

+ (void)logout{
    kUserModel.accessToken = nil;
    [kUserModel cacheToDisk];
}

+ (BOOL)isLogin{
    return kUserModel.accessToken.length > 0 ? YES : NO;
}

- (void)cacheToDisk{
    kUserModel = self;
    [NSKeyedArchiver archiveRootObject:self toFile:kUserModelCachePath];
}

@end
