//
//  UserModel.h
//  TTLockSourceCodeDemo
//
//  Created by Jinbo Lu on 2019/4/19.
//  Copyright © 2019 Sciener. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserModel : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *accessToken;

+ (UserModel *)userModel;
+ (BOOL)isLogin;
+ (void)logout;
- (void)cacheToDisk;
@end

